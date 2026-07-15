"use strict";

const LIMITS = Object.freeze({ vertices: 64, edges: 96, sectors: 16, portals: 16 });
const FORMAT = Object.freeze({ header: 17, vertex: 4, edge: 5, sector: 8, portal: 9 });
const PORTAL_MIN_WIDTH = 1.5;
const PORTAL_MIN_HEIGHT = 2;
const PORTAL_PLAYER_HEIGHT = 1.75;
const PORTAL_VERTICAL_MARGIN = 0.125;

const canvas = document.querySelector("#level-canvas");
const ctx = canvas.getContext("2d");
const ui = Object.fromEntries([
  "status-message", "level-stats", "selection-title", "selection-badge",
  "sector-name", "floor-height", "ceiling-height", "floor-color", "ceiling-color",
  "wall-title", "wall-color", "portal-capable", "mark-neighbor", "link-neighbor",
  "mark-portal", "link-portal", "vertex-limit", "edge-limit", "sector-limit", "portal-limit"
].map(id => [id, document.querySelector(`#${id}`)]));

const view = { scale: 44, originX: 70, originY: 570 };
let level = createStarterLevel();
let selected = { sector: 0, edge: null };
let draggedVertex = null;
let placingSpawn = false;
let pendingNeighbor = null;
let pendingPortal = null;

function createStarterLevel() {
  return {
    name: "Three-room stair test",
    spawn: { x: 2, y: 3, z: 0, sector: 0, angle: 0 },
    vertices: [
      { x: 0, y: 0 }, { x: 5, y: 0 }, { x: 5, y: 6 }, { x: 0, y: 6 },
      { x: 9, y: 0 }, { x: 9, y: 6 }, { x: 14, y: 1 }, { x: 14, y: 5 }
    ],
    sectors: [
      {
        name: "Entry room", vertexIds: [0, 1, 2, 3], floor: 0, ceiling: 3,
        floorColor: 3, ceilingColor: 2,
        walls: [wall(-1, 8, true), wall(1, 7), wall(-1, 8, true), wall(-1, 8, true)]
      },
      {
        name: "Step room", vertexIds: [1, 4, 5, 2], floor: 0.5, ceiling: 3.5,
        floorColor: 4, ceilingColor: 2,
        walls: [wall(-1, 10, true), wall(2, 9), wall(-1, 10, true), wall(0, 7)]
      },
      {
        name: "Angled room", vertexIds: [4, 6, 7, 5], floor: 1, ceiling: 4,
        floorColor: 5, ceilingColor: 2,
        walls: [wall(-1, 12, true), wall(-1, 12, true), wall(-1, 12, true), wall(1, 9)]
      }
    ],
    portals: []
  };
}

function wall(neighbor, color, portalCapable = false) {
  return { neighbor, color, portalCapable };
}

function screenPoint(point) {
  return { x: view.originX + point.x * view.scale, y: view.originY - point.y * view.scale };
}

function worldPoint(event) {
  const rect = canvas.getBoundingClientRect();
  const x = (event.clientX - rect.left) * canvas.width / rect.width;
  const y = (event.clientY - rect.top) * canvas.height / rect.height;
  return { x: (x - view.originX) / view.scale, y: (view.originY - y) / view.scale };
}

function snap(value) {
  return Math.round(value * 4) / 4;
}

function edgePoints(sectorIndex, edgeIndex) {
  const sector = level.sectors[sectorIndex];
  const a = level.vertices[sector.vertexIds[edgeIndex]];
  const b = level.vertices[sector.vertexIds[(edgeIndex + 1) % sector.vertexIds.length]];
  return { a, b };
}

function edgeLength(ref) {
  const { a, b } = edgePoints(ref.sector, ref.edge);
  return Math.hypot(b.x - a.x, b.y - a.y);
}

function pointInSector(point, sector) {
  let sign = 0;
  for (let i = 0; i < sector.vertexIds.length; i++) {
    const a = level.vertices[sector.vertexIds[i]];
    const b = level.vertices[sector.vertexIds[(i + 1) % sector.vertexIds.length]];
    const cross = (b.x - a.x) * (point.y - a.y) - (b.y - a.y) * (point.x - a.x);
    if (Math.abs(cross) < 0.0001) continue;
    const nextSign = Math.sign(cross);
    if (sign && nextSign !== sign) return false;
    sign = nextSign;
  }
  return true;
}

function distanceToSegment(point, a, b) {
  const dx = b.x - a.x;
  const dy = b.y - a.y;
  const lengthSquared = dx * dx + dy * dy;
  const t = lengthSquared ? Math.max(0, Math.min(1,
    ((point.x - a.x) * dx + (point.y - a.y) * dy) / lengthSquared
  )) : 0;
  return Math.hypot(point.x - (a.x + t * dx), point.y - (a.y + t * dy));
}

function portalForEdge(sector, edge) {
  return level.portals.findIndex(portal => portal.sector === sector && portal.edge === edge);
}

function paletteColor(index, alpha = 1) {
  const colors = {
    2: [32, 36, 60], 3: [65, 65, 70], 4: [72, 72, 77], 5: [80, 80, 85],
    7: [30, 145, 65], 8: [50, 220, 90], 9: [145, 35, 35], 10: [235, 58, 58],
    11: [35, 75, 160], 12: [55, 115, 245], 13: [180, 125, 45]
  };
  const rgb = colors[index] || [150, 160, 170];
  return `rgba(${rgb[0]}, ${rgb[1]}, ${rgb[2]}, ${alpha})`;
}

function drawGrid() {
  ctx.fillStyle = "#0b0d10";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  const minor = view.scale / 4;
  ctx.lineWidth = 1;
  for (let x = ((view.originX % minor) + minor) % minor; x < canvas.width; x += minor) {
    const major = Math.abs(((x - view.originX) / view.scale) - Math.round((x - view.originX) / view.scale)) < 0.01;
    ctx.strokeStyle = major ? "#232932" : "#161b21";
    ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, canvas.height); ctx.stroke();
  }
  for (let y = ((view.originY % minor) + minor) % minor; y < canvas.height; y += minor) {
    const major = Math.abs(((view.originY - y) / view.scale) - Math.round((view.originY - y) / view.scale)) < 0.01;
    ctx.strokeStyle = major ? "#232932" : "#161b21";
    ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(canvas.width, y); ctx.stroke();
  }
}

function draw() {
  drawGrid();
  level.sectors.forEach((sector, sectorIndex) => {
    const points = sector.vertexIds.map(id => screenPoint(level.vertices[id]));
    ctx.beginPath();
    points.forEach((point, index) => index ? ctx.lineTo(point.x, point.y) : ctx.moveTo(point.x, point.y));
    ctx.closePath();
    ctx.fillStyle = paletteColor(sector.floorColor, selected.sector === sectorIndex ? 0.22 : 0.11);
    ctx.fill();

    sector.walls.forEach((edge, edgeIndex) => {
      const a = points[edgeIndex];
      const b = points[(edgeIndex + 1) % points.length];
      const isSelected = selected.sector === sectorIndex && selected.edge === edgeIndex;
      ctx.lineWidth = isSelected ? 6 : 3;
      ctx.strokeStyle = isSelected ? "#ffffff" : edge.neighbor >= 0 ? "#42d7d2" : paletteColor(edge.color);
      ctx.beginPath(); ctx.moveTo(a.x, a.y); ctx.lineTo(b.x, b.y); ctx.stroke();

      if (portalForEdge(sectorIndex, edgeIndex) >= 0) {
        ctx.lineWidth = 7;
        ctx.strokeStyle = "#f1a33b";
        ctx.beginPath();
        ctx.moveTo(a.x + (b.x - a.x) * 0.32, a.y + (b.y - a.y) * 0.32);
        ctx.lineTo(a.x + (b.x - a.x) * 0.68, a.y + (b.y - a.y) * 0.68);
        ctx.stroke();
      }
    });

    points.forEach(point => {
      ctx.fillStyle = "#dce3e8";
      ctx.fillRect(point.x - 3, point.y - 3, 6, 6);
    });

    const center = points.reduce((sum, point) => ({ x: sum.x + point.x, y: sum.y + point.y }), { x: 0, y: 0 });
    center.x /= points.length; center.y /= points.length;
    ctx.fillStyle = "#c5ccd3";
    ctx.font = "600 12px ui-monospace, SFMono-Regular, Consolas, monospace";
    ctx.textAlign = "center";
    ctx.fillText(`${sectorIndex + 1}  z${sector.floor}`, center.x, center.y);
  });

  const spawn = screenPoint(level.spawn);
  const angle = level.spawn.angle * Math.PI / 32;
  ctx.save();
  ctx.translate(spawn.x, spawn.y);
  ctx.rotate(-angle);
  ctx.fillStyle = "#52a9ff";
  ctx.beginPath(); ctx.moveTo(11, 0); ctx.lineTo(-7, -6); ctx.lineTo(-4, 0); ctx.lineTo(-7, 6); ctx.closePath(); ctx.fill();
  ctx.restore();
}

function setStatus(message, kind = "") {
  ui["status-message"].textContent = message;
  ui["status-message"].className = kind;
}

function flattenedCounts() {
  const edges = level.sectors.reduce((count, sector) => count + sector.vertexIds.length, 0);
  const bytes = FORMAT.header + level.vertices.length * FORMAT.vertex + edges * FORMAT.edge +
    level.sectors.length * FORMAT.sector + level.portals.length * FORMAT.portal;
  return { vertices: level.vertices.length, edges, sectors: level.sectors.length, portals: level.portals.length, bytes };
}

function updateInspector() {
  const sector = level.sectors[selected.sector];
  const hasEdge = Number.isInteger(selected.edge);
  ui["selection-title"].textContent = sector?.name || "No selection";
  ui["selection-badge"].textContent = `ROOM ${selected.sector + 1}`;
  ui["sector-name"].value = sector?.name || "";
  ui["floor-height"].value = sector?.floor ?? "";
  ui["ceiling-height"].value = sector?.ceiling ?? "";
  ui["floor-color"].value = sector?.floorColor ?? "";
  ui["ceiling-color"].value = sector?.ceilingColor ?? "";
  const edge = hasEdge ? sector.walls[selected.edge] : null;
  ui["wall-title"].textContent = edge ? `Wall ${selected.edge + 1} · ${edge.neighbor >= 0 ? `to room ${edge.neighbor + 1}` : "solid"}` : "No wall selected";
  ui["wall-color"].disabled = !edge;
  ui["portal-capable"].disabled = !edge;
  ui["wall-color"].value = edge?.color ?? "";
  ui["portal-capable"].checked = edge?.portalCapable || false;
  ["mark-neighbor", "link-neighbor", "mark-portal", "link-portal"].forEach(id => ui[id].disabled = !edge);

  const counts = flattenedCounts();
  ui["vertex-limit"].textContent = `${counts.vertices} / ${LIMITS.vertices}`;
  ui["edge-limit"].textContent = `${counts.edges} / ${LIMITS.edges}`;
  ui["sector-limit"].textContent = `${counts.sectors} / ${LIMITS.sectors}`;
  ui["portal-limit"].textContent = `${counts.portals} / ${LIMITS.portals}`;
  ui["level-stats"].textContent = `${counts.sectors} sectors · ${counts.edges} edges · ${counts.bytes} byte level blob`;
  draw();
}

function selectAt(point) {
  let best = null;
  level.sectors.forEach((sector, sectorIndex) => {
    sector.walls.forEach((_, edgeIndex) => {
      const { a, b } = edgePoints(sectorIndex, edgeIndex);
      const distance = distanceToSegment(point, a, b);
      if (distance < 9 / view.scale && (!best || distance < best.distance)) {
        best = { sector: sectorIndex, edge: edgeIndex, distance };
      }
    });
  });
  if (best) selected = { sector: best.sector, edge: best.edge };
  else {
    const sector = level.sectors.findIndex(candidate => pointInSector(point, candidate));
    if (sector >= 0) selected = { sector, edge: null };
  }
  updateInspector();
}

function nearestVertex(point) {
  let best = null;
  level.vertices.forEach((vertex, index) => {
    const distance = Math.hypot(vertex.x - point.x, vertex.y - point.y);
    if (distance < 10 / view.scale && (!best || distance < best.distance)) best = { index, distance };
  });
  return best?.index ?? null;
}

function selectedReference() {
  return Number.isInteger(selected.edge) ? { sector: selected.sector, edge: selected.edge } : null;
}

function sameEdgeGeometry(first, second) {
  const a = edgePoints(first.sector, first.edge);
  const b = edgePoints(second.sector, second.edge);
  const close = (p, q) => Math.hypot(p.x - q.x, p.y - q.y) < 0.01;
  return close(a.a, b.b) && close(a.b, b.a);
}

function validateLevel() {
  const counts = flattenedCounts();
  const errors = [];
  Object.keys(LIMITS).forEach(key => {
    if (counts[key] > LIMITS[key]) errors.push(`${key} exceed ${LIMITS[key]}`);
  });
  level.sectors.forEach((sector, index) => {
    if (sector.vertexIds.length < 3) errors.push(`room ${index + 1} has fewer than three walls`);
    if (sector.ceiling - sector.floor < 2) errors.push(`room ${index + 1} is under 2 units tall`);
  });
  level.portals.forEach((portal, index) => {
    const sector = level.sectors[portal.sector];
    const edge = sector?.walls[portal.edge];
    const linked = level.portals[portal.linked];
    if (!edge) {
      errors.push(`portal ${index + 1} references a missing wall`);
      return;
    }
    if (edge.neighbor >= 0) errors.push(`portal ${index + 1} must be on a solid wall, not a doorway`);
    if (!edge.portalCapable) errors.push(`portal ${index + 1} uses a wall that is not portal-capable`);
    if (!linked || linked.linked !== index) errors.push(`portal ${index + 1} does not have a reciprocal link`);
    if (portal.halfWidth <= 0 || portal.centerU - portal.halfWidth < 0 || portal.centerU + portal.halfWidth > 255) {
      errors.push(`portal ${index + 1} extends beyond its wall`);
    }
    if (portal.bottom < sector.floor || portal.top > sector.ceiling ||
        portal.top - portal.bottom < PORTAL_PLAYER_HEIGHT) {
      errors.push(`portal ${index + 1} is outside its room or too short for the player`);
    }
  });
  return errors;
}

function addRoom() {
  const counts = flattenedCounts();
  if (counts.sectors >= LIMITS.sectors || counts.vertices + 4 > LIMITS.vertices || counts.edges + 4 > LIMITS.edges) {
    setStatus("DCE1 room, edge, or vertex limit reached.", "error");
    return;
  }
  const maxX = Math.max(...level.vertices.map(vertex => vertex.x));
  const start = level.vertices.length;
  level.vertices.push(
    { x: maxX + 1, y: 0 }, { x: maxX + 5, y: 0 },
    { x: maxX + 5, y: 4 }, { x: maxX + 1, y: 4 }
  );
  level.sectors.push({
    name: `Room ${level.sectors.length + 1}`,
    vertexIds: [start, start + 1, start + 2, start + 3],
    floor: 0, ceiling: 3, floorColor: 3, ceilingColor: 2,
    walls: [wall(-1, 8, true), wall(-1, 8, true), wall(-1, 8, true), wall(-1, 8, true)]
  });
  selected = { sector: level.sectors.length - 1, edge: null };
  setStatus("Room added. Drag its vertices into place, then link overlapping doorway edges.", "success");
  updateInspector();
}

function linkNeighbors() {
  const current = selectedReference();
  if (!pendingNeighbor || !current || (pendingNeighbor.sector === current.sector && pendingNeighbor.edge === current.edge)) {
    setStatus("Choose a different wall for doorway side B.", "error");
    return;
  }
  if (!sameEdgeGeometry(pendingNeighbor, current)) {
    setStatus("Doorway edges must overlap and run in opposite directions.", "error");
    return;
  }
  level.sectors[pendingNeighbor.sector].walls[pendingNeighbor.edge].neighbor = current.sector;
  level.sectors[current.sector].walls[current.edge].neighbor = pendingNeighbor.sector;
  pendingNeighbor = null;
  setStatus("Doorway linked. Different floor heights become walkable steps.", "success");
  updateInspector();
}

function pairPortals() {
  const current = selectedReference();
  if (!pendingPortal || !current || (pendingPortal.sector === current.sector && pendingPortal.edge === current.edge)) {
    setStatus("Choose a different wall for portal side B.", "error");
    return;
  }
  if (level.portals.length + 2 > LIMITS.portals) {
    setStatus("The level already uses all 16 portal records.", "error");
    return;
  }
  for (const ref of [pendingPortal, current]) {
    const sector = level.sectors[ref.sector];
    const edge = sector.walls[ref.edge];
    if (edge.neighbor >= 0) {
      setStatus("Portals must be placed on solid walls, not linked doorways.", "error");
      return;
    }
    if (edgeLength(ref) < PORTAL_MIN_WIDTH || sector.ceiling - sector.floor < PORTAL_MIN_HEIGHT) {
      setStatus("Both portal walls must be at least 1.5 units wide and 2 units tall.", "error");
      return;
    }
    if (portalForEdge(ref.sector, ref.edge) >= 0) {
      setStatus("One of those walls already contains a portal.", "error");
      return;
    }
  }
  const firstIndex = level.portals.length;
  const makePortal = (ref, linked) => {
    const sector = level.sectors[ref.sector];
    return {
      sector: ref.sector, edge: ref.edge, linked, centerU: 128, halfWidth: 48,
      bottom: sector.floor + PORTAL_VERTICAL_MARGIN,
      top: sector.ceiling - PORTAL_VERTICAL_MARGIN,
      enabled: true
    };
  };
  level.portals.push(makePortal(pendingPortal, firstIndex + 1), makePortal(current, firstIndex));
  level.sectors[pendingPortal.sector].walls[pendingPortal.edge].portalCapable = true;
  level.sectors[current.sector].walls[current.edge].portalCapable = true;
  pendingPortal = null;
  setStatus("Portal pair added. Orientation comes directly from each wall edge.", "success");
  updateInspector();
}

function flattenEdges() {
  const edges = [];
  const offsets = [];
  level.sectors.forEach((sector, sectorIndex) => {
    offsets[sectorIndex] = edges.length;
    sector.vertexIds.forEach((vertexId, edgeIndex) => {
      const model = sector.walls[edgeIndex];
      edges.push({
        a: vertexId,
        b: sector.vertexIds[(edgeIndex + 1) % sector.vertexIds.length],
        neighbor: model.neighbor,
        color: model.color,
        flags: model.portalCapable ? 1 : 0
      });
    });
  });
  return { edges, offsets };
}

function writeSigned16(view, offset, value) {
  view.setInt16(offset, Math.max(-32768, Math.min(32767, Math.round(value))), true);
}

function buildDcl() {
  const errors = validateLevel();
  if (errors.length) throw new Error(errors.join("; "));
  const { edges, offsets } = flattenEdges();
  const counts = flattenedCounts();
  const buffer = new ArrayBuffer(counts.bytes);
  const data = new DataView(buffer);
  let at = 0;
  [68, 67, 69, 49].forEach(value => data.setUint8(at++, value));
  data.setUint8(at++, 1);
  data.setUint8(at++, level.vertices.length);
  data.setUint8(at++, edges.length);
  data.setUint8(at++, level.sectors.length);
  data.setUint8(at++, level.portals.length);
  writeSigned16(data, at, level.spawn.x * 16); at += 2;
  writeSigned16(data, at, level.spawn.y * 16); at += 2;
  writeSigned16(data, at, level.spawn.z * 256); at += 2;
  data.setUint8(at++, level.spawn.sector);
  data.setUint8(at++, Math.round(level.spawn.angle) & 63);

  level.vertices.forEach(vertex => {
    writeSigned16(data, at, vertex.x * 16); at += 2;
    writeSigned16(data, at, vertex.y * 16); at += 2;
  });
  edges.forEach(edge => {
    data.setUint8(at++, edge.a);
    data.setUint8(at++, edge.b);
    data.setInt8(at++, edge.neighbor);
    data.setUint8(at++, edge.color);
    data.setUint8(at++, edge.flags);
  });
  level.sectors.forEach((sector, index) => {
    data.setUint8(at++, offsets[index]);
    data.setUint8(at++, sector.vertexIds.length);
    writeSigned16(data, at, sector.floor * 256); at += 2;
    writeSigned16(data, at, sector.ceiling * 256); at += 2;
    data.setUint8(at++, sector.floorColor);
    data.setUint8(at++, sector.ceilingColor);
  });
  level.portals.forEach(portal => {
    data.setUint8(at++, offsets[portal.sector] + portal.edge);
    data.setUint8(at++, portal.linked);
    data.setUint8(at++, portal.centerU);
    data.setUint8(at++, portal.halfWidth);
    writeSigned16(data, at, portal.bottom * 256); at += 2;
    writeSigned16(data, at, portal.top * 256); at += 2;
    data.setUint8(at++, portal.enabled ? 1 : 0);
  });
  return buffer;
}

function download(blob, filename) {
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url; link.download = filename; link.click();
  setTimeout(() => URL.revokeObjectURL(url), 0);
}

function parseDcl(buffer) {
  const data = new DataView(buffer);
  if (data.byteLength < FORMAT.header || [68, 67, 69, 49].some((v, i) => data.getUint8(i) !== v)) {
    throw new Error("Not a DCE1 level file.");
  }
  let at = 4;
  const version = data.getUint8(at++);
  const vertexCount = data.getUint8(at++);
  const edgeCount = data.getUint8(at++);
  const sectorCount = data.getUint8(at++);
  const portalCount = data.getUint8(at++);
  if (version !== 1) throw new Error(`Unsupported DCE1 version ${version}.`);
  const next = {
    name: "Imported DCE1 level",
    spawn: {
      x: data.getInt16(at, true) / 16,
      y: data.getInt16(at + 2, true) / 16,
      z: data.getInt16(at + 4, true) / 256,
      sector: data.getUint8(at + 6), angle: data.getUint8(at + 7)
    },
    vertices: [], sectors: [], portals: []
  };
  at += 8;
  for (let i = 0; i < vertexCount; i++) {
    next.vertices.push({ x: data.getInt16(at, true) / 16, y: data.getInt16(at + 2, true) / 16 });
    at += FORMAT.vertex;
  }
  const edges = [];
  for (let i = 0; i < edgeCount; i++) {
    edges.push({
      a: data.getUint8(at), b: data.getUint8(at + 1), neighbor: data.getInt8(at + 2),
      color: data.getUint8(at + 3), portalCapable: Boolean(data.getUint8(at + 4) & 1)
    });
    at += FORMAT.edge;
  }
  const sectorRecords = [];
  for (let i = 0; i < sectorCount; i++) {
    sectorRecords.push({
      first: data.getUint8(at), count: data.getUint8(at + 1),
      floor: data.getInt16(at + 2, true) / 256,
      ceiling: data.getInt16(at + 4, true) / 256,
      floorColor: data.getUint8(at + 6), ceilingColor: data.getUint8(at + 7)
    });
    at += FORMAT.sector;
  }
  sectorRecords.forEach((record, sectorIndex) => {
    const ownEdges = edges.slice(record.first, record.first + record.count);
    next.sectors.push({
      name: `Room ${sectorIndex + 1}`, vertexIds: ownEdges.map(edge => edge.a),
      floor: record.floor, ceiling: record.ceiling,
      floorColor: record.floorColor, ceilingColor: record.ceilingColor,
      walls: ownEdges.map(edge => wall(edge.neighbor, edge.color, edge.portalCapable))
    });
  });
  const edgeOwner = flatIndex => {
    const sector = sectorRecords.findIndex(record => flatIndex >= record.first && flatIndex < record.first + record.count);
    return { sector, edge: flatIndex - sectorRecords[sector].first };
  };
  for (let i = 0; i < portalCount; i++) {
    const owner = edgeOwner(data.getUint8(at));
    next.portals.push({
      ...owner, linked: data.getUint8(at + 1), centerU: data.getUint8(at + 2), halfWidth: data.getUint8(at + 3),
      bottom: data.getInt16(at + 4, true) / 256, top: data.getInt16(at + 6, true) / 256,
      enabled: Boolean(data.getUint8(at + 8) & 1)
    });
    at += FORMAT.portal;
  }
  return next;
}

canvas.addEventListener("pointerdown", event => {
  const point = worldPoint(event);
  if (placingSpawn) {
    const sector = level.sectors.findIndex(candidate => pointInSector(point, candidate));
    if (sector < 0) return setStatus("Spawn must be inside a sector.", "error");
    level.spawn = { ...level.spawn, x: snap(point.x), y: snap(point.y), sector };
    placingSpawn = false;
    document.querySelector("#spawn-tool").classList.remove("active");
    document.querySelector("#select-tool").classList.add("active");
    setStatus("Player spawn placed.", "success");
    return updateInspector();
  }
  draggedVertex = nearestVertex(point);
  if (draggedVertex === null) selectAt(point);
  canvas.setPointerCapture(event.pointerId);
});

canvas.addEventListener("pointermove", event => {
  if (draggedVertex === null) return;
  const point = worldPoint(event);
  level.vertices[draggedVertex].x = snap(point.x);
  level.vertices[draggedVertex].y = snap(point.y);
  draw();
});

canvas.addEventListener("pointerup", () => {
  if (draggedVertex !== null) {
    draggedVertex = null;
    setStatus("Vertex moved on the 0.25-unit grid.", "success");
    updateInspector();
  }
});

canvas.addEventListener("wheel", event => {
  event.preventDefault();
  view.scale = Math.max(20, Math.min(90, view.scale * (event.deltaY > 0 ? 0.9 : 1.1)));
  draw();
}, { passive: false });

document.querySelector("#select-tool").addEventListener("click", () => {
  placingSpawn = false;
  document.querySelector("#spawn-tool").classList.remove("active");
  document.querySelector("#select-tool").classList.add("active");
});
document.querySelector("#spawn-tool").addEventListener("click", () => {
  placingSpawn = true;
  document.querySelector("#spawn-tool").classList.add("active");
  document.querySelector("#select-tool").classList.remove("active");
  setStatus("Click inside a sector to place the player spawn.");
});
document.querySelector("#add-room").addEventListener("click", addRoom);

const sectorFields = {
  "sector-name": ["name", value => value],
  "floor-height": ["floor", Number],
  "ceiling-height": ["ceiling", Number],
  "floor-color": ["floorColor", Number],
  "ceiling-color": ["ceilingColor", Number]
};
Object.entries(sectorFields).forEach(([id, [property, convert]]) => {
  ui[id].addEventListener("change", event => {
    level.sectors[selected.sector][property] = convert(event.target.value);
    updateInspector();
  });
});

ui["wall-color"].addEventListener("change", event => {
  level.sectors[selected.sector].walls[selected.edge].color = Number(event.target.value);
  updateInspector();
});
ui["portal-capable"].addEventListener("change", event => {
  level.sectors[selected.sector].walls[selected.edge].portalCapable = event.target.checked;
  updateInspector();
});

ui["mark-neighbor"].addEventListener("click", () => {
  pendingNeighbor = selectedReference();
  setStatus("Doorway side A marked. Select the reverse overlapping wall and link it.");
});
ui["link-neighbor"].addEventListener("click", linkNeighbors);
ui["mark-portal"].addEventListener("click", () => {
  pendingPortal = selectedReference();
  setStatus("Portal wall A marked. Select any other valid wall and pair it.");
});
ui["link-portal"].addEventListener("click", pairPortals);
document.querySelector("#clear-portals").addEventListener("click", () => {
  level.portals = [];
  pendingPortal = null;
  setStatus("All portal pairs cleared.");
  updateInspector();
});

document.querySelector("#export-json").addEventListener("click", () => {
  download(new Blob([JSON.stringify(level, null, 2)], { type: "application/json" }), "doomce-level.json");
  setStatus("JSON project exported.", "success");
});
document.querySelector("#export-dcl").addEventListener("click", () => {
  try {
    const buffer = buildDcl();
    download(new Blob([buffer], { type: "application/octet-stream" }), "DOOMLVL1.dcl");
    setStatus(`Packed DCE1 level exported (${buffer.byteLength} bytes).`, "success");
  } catch (error) {
    setStatus(error.message, "error");
  }
});
document.querySelector("#export-8xv").addEventListener("click", () => {
  try {
    const dcl = buildDcl();
    const appVar = DoomCeAppVar.pack(dcl);
    download(new Blob([appVar], { type: "application/octet-stream" }), "DOOMLVL1.8xv");
    setStatus(`Archived DOOMLVL1 AppVar exported (${appVar.byteLength} bytes).`, "success");
  } catch (error) {
    setStatus(error.message, "error");
  }
});
document.querySelector("#import-file").addEventListener("change", async event => {
  const file = event.target.files[0];
  if (!file) return;
  try {
    const lowerName = file.name.toLowerCase();
    if (lowerName.endsWith(".json")) {
      level = JSON.parse(await file.text());
    } else {
      let data = await file.arrayBuffer();
      if (lowerName.endsWith(".8xv")) data = DoomCeAppVar.unpack(data);
      level = parseDcl(data);
    }
    selected = { sector: 0, edge: null };
    pendingNeighbor = null; pendingPortal = null;
    const errors = validateLevel();
    if (errors.length) throw new Error(errors.join("; "));
    setStatus(`${file.name} imported.`, "success");
    updateInspector();
  } catch (error) {
    setStatus(`Import failed: ${error.message}`, "error");
  } finally {
    event.target.value = "";
  }
});

updateInspector();
