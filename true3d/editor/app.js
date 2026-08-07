"use strict";

const MAX_ROOMS = 8;
const HEADER_SIZE = 30;
const ROOM_SIZE = 18;
const FACE_NAMES = ["Floor", "Ceiling", "South wall", "North wall", "West wall", "East wall"];
const PALETTE = [
  ["Black", "#000000"], ["Void", "#0c0e19"], ["Floor A", "#36393e"],
  ["Ceiling A", "#202330"], ["Green", "#26cd4b"], ["Dark green", "#187634"],
  ["Floor B", "#413936"], ["Ceiling B", "#302023"], ["Red", "#d73434"],
  ["Dark red", "#7d1e22"], ["Portal blue", "#2d69f5"],
  ["Portal orange", "#f0911c"], ["White", "#f0f0f0"]
];

const canvas = document.querySelector("#map-canvas");
const ctx = canvas.getContext("2d");
const ui = Object.fromEntries([...document.querySelectorAll("[id]")].map(node => [node.id, node]));
let map = defaultMap();
let selectedRoom = 0;

function defaultMap() {
  return {
    name: "Wall to ceiling test",
    rooms: [
      room("Green chamber", -4, 4, 0, 10, 0, 5, [2, 3, 5, 4, 5, 5]),
      room("Red chamber", 8, 16, 0, 8, 0, 5, [6, 7, 9, 8, 9, 9])
    ],
    spawn: { room: 0, x: 0, y: 2, z: 1.5 },
    portals: [
      { active: true, room: 0, face: 3, x: 0, y: 10, z: 2.5 },
      { active: true, room: 1, face: 1, x: 12, y: 4, z: 5 }
    ]
  };
}

function room(name, minX, maxX, minY, maxY, minZ, maxZ, colors) {
  return { name, minX, maxX, minY, maxY, minZ, maxZ, colors: [...colors] };
}

function setStatus(title, message, error = false) {
  ui["status-title"].textContent = title;
  ui["status-message"].textContent = message;
  ui["status-title"].style.color = error ? "#f05c67" : "#45e477";
}

function paletteOptions(selected) {
  return PALETTE.map(([name, color], index) =>
    `<option value="${index}" ${index === selected ? "selected" : ""}>${index} · ${name} · ${color}</option>`
  ).join("");
}

function roomOptions(selected) {
  return map.rooms.map((entry, index) =>
    `<option value="${index}" ${index === selected ? "selected" : ""}>${index + 1} · ${entry.name}</option>`
  ).join("");
}

function faceOptions(selected) {
  return FACE_NAMES.map((name, index) =>
    `<option value="${index}" ${index === selected ? "selected" : ""}>${name}</option>`
  ).join("");
}

function renderInspector() {
  const current = map.rooms[selectedRoom];
  ui["room-list"].innerHTML = map.rooms.map((entry, index) =>
    `<button class="room-tab ${index === selectedRoom ? "active" : ""}" data-room="${index}" type="button">${index + 1} · ${escapeHtml(entry.name)}</button>`
  ).join("");
  ui["room-heading"].textContent = `Room ${selectedRoom + 1}`;
  ui["room-name"].value = current.name;
  [["min-x", "minX"], ["max-x", "maxX"], ["min-y", "minY"], ["max-y", "maxY"],
   ["min-z", "minZ"], ["max-z", "maxZ"]].forEach(([id, property]) => ui[id].value = current[property]);
  ui["face-colors"].innerHTML = FACE_NAMES.map((name, index) =>
    `<label>${name}<select data-face-color="${index}">${paletteOptions(current.colors[index])}</select></label>`
  ).join("");

  ui["spawn-room"].innerHTML = roomOptions(map.spawn.room);
  ui["spawn-x"].value = map.spawn.x;
  ui["spawn-y"].value = map.spawn.y;
  ui["spawn-z"].value = map.spawn.z;
  ui["portal-editors"].innerHTML = map.portals.map((portal, index) => `
    <div class="portal-box">
      <div class="portal-title ${index ? "blue" : "orange"}">
        <strong>${index ? "Blue" : "Orange"} portal</strong>
        <label class="check"><input type="checkbox" data-portal="${index}" data-field="active" ${portal.active ? "checked" : ""}> Active</label>
      </div>
      <div class="portal-grid">
        <label>Room<select data-portal="${index}" data-field="room">${roomOptions(portal.room)}</select></label>
        <label>Face<select data-portal="${index}" data-field="face">${faceOptions(portal.face)}</select></label>
        <div class="coordinates">
          <label>X<input type="number" step="0.25" value="${portal.x}" data-portal="${index}" data-field="x"></label>
          <label>Y<input type="number" step="0.25" value="${portal.y}" data-portal="${index}" data-field="y"></label>
          <label>Z<input type="number" step="0.25" value="${portal.z}" data-portal="${index}" data-field="z"></label>
        </div>
      </div>
      <button class="wide" data-center-portal="${index}" type="button">Center and snap to face</button>
    </div>`).join("");
  ui["map-stats"].textContent = `${map.rooms.length} room${map.rooms.length === 1 ? "" : "s"} · ${HEADER_SIZE + ROOM_SIZE * map.rooms.length} byte map`;
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, character => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;", "'": "&#39;"
  })[character]);
}

function bounds() {
  return map.rooms.reduce((result, entry) => ({
    minX: Math.min(result.minX, entry.minX), maxX: Math.max(result.maxX, entry.maxX),
    minY: Math.min(result.minY, entry.minY), maxY: Math.max(result.maxY, entry.maxY),
    minZ: Math.min(result.minZ, entry.minZ), maxZ: Math.max(result.maxZ, entry.maxZ)
  }), { minX: Infinity, maxX: -Infinity, minY: Infinity, maxY: -Infinity, minZ: Infinity, maxZ: -Infinity });
}

function drawPreview() {
  const area = bounds();
  const range = Math.max(area.maxX - area.minX, area.maxY - area.minY, (area.maxZ - area.minZ) * 1.7, 8);
  const scale = Math.min(canvas.width, canvas.height * 1.35) / (range * 2.25);
  const centerX = (area.minX + area.maxX) / 2;
  const centerY = (area.minY + area.maxY) / 2;
  const project = point => ({
    x: canvas.width / 2 + ((point.x - centerX) - (point.y - centerY)) * scale,
    y: canvas.height * .68 + ((point.x - centerX) + (point.y - centerY)) * scale * .43 - (point.z - area.minZ) * scale
  });

  ctx.clearRect(0, 0, canvas.width, canvas.height);
  const gradient = ctx.createLinearGradient(0, 0, 0, canvas.height);
  gradient.addColorStop(0, "#0e1520"); gradient.addColorStop(1, "#070a0f");
  ctx.fillStyle = gradient; ctx.fillRect(0, 0, canvas.width, canvas.height);
  ctx.strokeStyle = "rgba(80,102,130,.14)"; ctx.lineWidth = 1;
  for (let x = 0; x < canvas.width; x += 32) { ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, canvas.height); ctx.stroke(); }
  for (let y = 0; y < canvas.height; y += 32) { ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(canvas.width, y); ctx.stroke(); }

  const ordered = map.rooms.map((entry, index) => ({ entry, index })).sort((a, b) =>
    (a.entry.minX + a.entry.minY) - (b.entry.minX + b.entry.minY));
  ordered.forEach(({ entry, index }) => drawRoom(entry, index, project));
  drawMarker(map.spawn, "#ffffff", "S", project);
  map.portals.forEach((portal, index) => {
    if (portal.active) drawMarker(portal, index ? "#3980ff" : "#f09227", index ? "B" : "O", project);
  });
}

function roomCorners(entry) {
  return [
    { x: entry.minX, y: entry.minY, z: entry.minZ }, { x: entry.maxX, y: entry.minY, z: entry.minZ },
    { x: entry.maxX, y: entry.maxY, z: entry.minZ }, { x: entry.minX, y: entry.maxY, z: entry.minZ },
    { x: entry.minX, y: entry.minY, z: entry.maxZ }, { x: entry.maxX, y: entry.minY, z: entry.maxZ },
    { x: entry.maxX, y: entry.maxY, z: entry.maxZ }, { x: entry.minX, y: entry.maxY, z: entry.maxZ }
  ];
}

function drawRoom(entry, index, project) {
  const points = roomCorners(entry).map(project);
  const faces = [[0, 1, 5, 4], [1, 2, 6, 5], [4, 5, 6, 7]];
  faces.forEach((face, faceIndex) => {
    ctx.beginPath(); face.forEach((vertex, i) => i ? ctx.lineTo(points[vertex].x, points[vertex].y) : ctx.moveTo(points[vertex].x, points[vertex].y)); ctx.closePath();
    ctx.fillStyle = index === selectedRoom ? `rgba(69,228,119,${faceIndex === 2 ? .18 : .1})` : "rgba(72,96,125,.10)";
    ctx.fill();
  });
  const edges = [[0,1],[1,2],[2,3],[3,0],[4,5],[5,6],[6,7],[7,4],[0,4],[1,5],[2,6],[3,7]];
  ctx.strokeStyle = index === selectedRoom ? "#45e477" : "#50637b";
  ctx.lineWidth = index === selectedRoom ? 2.5 : 1.4;
  edges.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(points[a].x, points[a].y); ctx.lineTo(points[b].x, points[b].y); ctx.stroke(); });
  const label = project({ x: (entry.minX + entry.maxX) / 2, y: (entry.minY + entry.maxY) / 2, z: entry.maxZ });
  ctx.fillStyle = index === selectedRoom ? "#dfffea" : "#9aaabd";
  ctx.font = "600 13px system-ui"; ctx.textAlign = "center"; ctx.fillText(`${index + 1} · ${entry.name}`, label.x, label.y - 12);
}

function drawMarker(marker, color, label, project) {
  const point = project(marker);
  ctx.beginPath(); ctx.arc(point.x, point.y, 7, 0, Math.PI * 2); ctx.fillStyle = color; ctx.fill();
  ctx.strokeStyle = "#080b11"; ctx.lineWidth = 2; ctx.stroke();
  ctx.fillStyle = color; ctx.font = "800 12px system-ui"; ctx.fillText(label, point.x, point.y - 12);
}

function render() { renderInspector(); drawPreview(); }

function snapPortal(portal, center = false) {
  const entry = map.rooms[portal.room];
  if (!entry) return;
  if (center) {
    portal.x = (entry.minX + entry.maxX) / 2;
    portal.y = (entry.minY + entry.maxY) / 2;
    portal.z = (entry.minZ + entry.maxZ) / 2;
  }
  if (portal.face <= 1) {
    portal.x = clamp(portal.x, entry.minX + 1.5, entry.maxX - 1.5);
    portal.y = clamp(portal.y, entry.minY + 1.75, entry.maxY - 1.75);
    portal.z = portal.face === 0 ? entry.minZ : entry.maxZ;
  } else if (portal.face <= 3) {
    portal.x = clamp(portal.x, entry.minX + 1.5, entry.maxX - 1.5);
    portal.z = clamp(portal.z, entry.minZ + 1.75, entry.maxZ - 1.75);
    portal.y = portal.face === 2 ? entry.minY : entry.maxY;
  } else {
    portal.y = clamp(portal.y, entry.minY + 1.5, entry.maxY - 1.5);
    portal.z = clamp(portal.z, entry.minZ + 1.75, entry.maxZ - 1.75);
    portal.x = portal.face === 4 ? entry.minX : entry.maxX;
  }
}

function clamp(value, minimum, maximum) { return Math.min(maximum, Math.max(minimum, value)); }

function validateMap() {
  const errors = [];
  if (!map.rooms.length || map.rooms.length > MAX_ROOMS) errors.push(`Room count must be 1–${MAX_ROOMS}`);
  map.rooms.forEach((entry, index) => {
    const coordinates = [entry.minX, entry.maxX, entry.minY, entry.maxY, entry.minZ, entry.maxZ];
    if (coordinates.some(value => !Number.isFinite(value))) {
      errors.push(`Room ${index + 1} has a non-numeric coordinate`);
    } else if (entry.maxX - entry.minX < 2 || entry.maxY - entry.minY < 2 || entry.maxZ - entry.minZ < 2) {
      errors.push(`Room ${index + 1} must be at least 2 units on every axis`);
    }
    coordinates.forEach(value => {
      if (value < -128 || value >= 128) errors.push(`Room ${index + 1} exceeds the Q8.8 coordinate range`);
    });
    if (!Array.isArray(entry.colors) || entry.colors.length !== 6 ||
        entry.colors.some(color => !Number.isInteger(color) || color < 0 || color >= PALETTE.length)) {
      errors.push(`Room ${index + 1} needs six valid face colors`);
    }
  });
  const spawnRoom = map.rooms[map.spawn.room];
  if (!spawnRoom || map.spawn.x <= spawnRoom.minX || map.spawn.x >= spawnRoom.maxX ||
      map.spawn.y <= spawnRoom.minY || map.spawn.y >= spawnRoom.maxY ||
      map.spawn.z < spawnRoom.minZ + .25 || map.spawn.z >= spawnRoom.maxZ) {
    errors.push("Player spawn must be inside its selected room");
  }
  map.portals.forEach((portal, index) => {
    if (portal.active && (!map.rooms[portal.room] || portal.face < 0 || portal.face > 5)) {
      errors.push(`Portal ${index + 1} has an invalid room or face`);
    } else if (portal.active) {
      const entry = map.rooms[portal.room];
      const width = portal.face <= 1 ? entry.maxX - entry.minX :
        portal.face <= 3 ? entry.maxX - entry.minX : entry.maxY - entry.minY;
      const height = portal.face <= 1 ? entry.maxY - entry.minY : entry.maxZ - entry.minZ;
      if (width < 3 || height < 3.5) {
        errors.push(`Portal ${index + 1}'s face is too small (needs 3 by 3.5 units)`);
      }
    }
  });
  return [...new Set(errors)];
}

function writeQ8(view, offset, value) { view.setInt16(offset, Math.round(value * 256), true); }

function buildT3D() {
  map.portals.forEach(portal => snapPortal(portal));
  const errors = validateMap();
  if (errors.length) throw new Error(errors.join("; "));
  const buffer = new ArrayBuffer(HEADER_SIZE + ROOM_SIZE * map.rooms.length);
  const view = new DataView(buffer);
  let at = 0;
  [84, 51, 68, 49].forEach(value => view.setUint8(at++, value));
  view.setUint8(at++, 1);
  view.setUint8(at++, map.rooms.length);
  view.setUint8(at++, map.spawn.room);
  view.setUint8(at++, (map.portals[0].active ? 1 : 0) | (map.portals[1].active ? 2 : 0));
  writeQ8(view, at, map.spawn.x); at += 2;
  writeQ8(view, at, map.spawn.y); at += 2;
  writeQ8(view, at, map.spawn.z); at += 2;
  map.portals.forEach(portal => {
    view.setUint8(at++, portal.room);
    view.setUint8(at++, portal.face);
    writeQ8(view, at, portal.x); at += 2;
    writeQ8(view, at, portal.y); at += 2;
    writeQ8(view, at, portal.z); at += 2;
  });
  map.rooms.forEach(entry => {
    [entry.minX, entry.maxX, entry.minY, entry.maxY, entry.minZ, entry.maxZ].forEach(value => {
      writeQ8(view, at, value); at += 2;
    });
    entry.colors.forEach(color => view.setUint8(at++, color));
  });
  return buffer;
}

function parseT3D(buffer) {
  const view = new DataView(buffer);
  if (view.byteLength < HEADER_SIZE || [84, 51, 68, 49].some((value, index) => view.getUint8(index) !== value)) {
    throw new Error("Not a T3D1 map.");
  }
  if (view.getUint8(4) !== 1) throw new Error("Unsupported T3D map version.");
  const roomCount = view.getUint8(5);
  if (!roomCount || roomCount > MAX_ROOMS || view.byteLength < HEADER_SIZE + roomCount * ROOM_SIZE) throw new Error("Invalid room count or file length.");
  const next = { name: "Imported T3D1", rooms: [], spawn: {}, portals: [] };
  next.spawn.room = view.getUint8(6);
  const portalMask = view.getUint8(7);
  next.spawn.x = view.getInt16(8, true) / 256;
  next.spawn.y = view.getInt16(10, true) / 256;
  next.spawn.z = view.getInt16(12, true) / 256;
  let at = 14;
  for (let index = 0; index < 2; index++) {
    next.portals.push({
      active: Boolean(portalMask & (1 << index)), room: view.getUint8(at), face: view.getUint8(at + 1),
      x: view.getInt16(at + 2, true) / 256, y: view.getInt16(at + 4, true) / 256,
      z: view.getInt16(at + 6, true) / 256
    });
    at += 8;
  }
  for (let index = 0; index < roomCount; index++) {
    const values = [];
    for (let value = 0; value < 6; value++) { values.push(view.getInt16(at, true) / 256); at += 2; }
    const colors = [];
    for (let face = 0; face < 6; face++) colors.push(view.getUint8(at++));
    next.rooms.push(room(`Room ${index + 1}`, ...values, colors));
  }
  return next;
}

function download(bufferOrBlob, filename, type = "application/octet-stream") {
  const blob = bufferOrBlob instanceof Blob ? bufferOrBlob : new Blob([bufferOrBlob], { type });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a"); link.href = url; link.download = filename; link.click();
  setTimeout(() => URL.revokeObjectURL(url), 0);
}

ui["room-list"].addEventListener("click", event => {
  const button = event.target.closest("[data-room]");
  if (!button) return;
  selectedRoom = Number(button.dataset.room); render();
});

ui["add-room"].addEventListener("click", () => {
  if (map.rooms.length >= MAX_ROOMS) return setStatus("Room limit", `T3D1 supports ${MAX_ROOMS} rooms.`, true);
  const maxX = Math.max(...map.rooms.map(entry => entry.maxX));
  map.rooms.push(room(`Room ${map.rooms.length + 1}`, maxX + 2, maxX + 8, 0, 8, 0, 5, [2, 3, 5, 4, 5, 5]));
  selectedRoom = map.rooms.length - 1; render();
});

ui["delete-room"].addEventListener("click", () => {
  if (map.rooms.length === 1) return setStatus("Cannot delete", "A map needs at least one room.", true);
  map.rooms.splice(selectedRoom, 1);
  map.spawn.room = Math.min(map.spawn.room, map.rooms.length - 1);
  map.portals.forEach(portal => portal.room = Math.min(portal.room, map.rooms.length - 1));
  selectedRoom = Math.min(selectedRoom, map.rooms.length - 1); render();
});

ui["room-name"].addEventListener("change", event => { map.rooms[selectedRoom].name = event.target.value || `Room ${selectedRoom + 1}`; render(); });
[["min-x", "minX"], ["max-x", "maxX"], ["min-y", "minY"], ["max-y", "maxY"],
 ["min-z", "minZ"], ["max-z", "maxZ"]].forEach(([id, property]) => ui[id].addEventListener("change", event => {
  map.rooms[selectedRoom][property] = Number(event.target.value); render();
}));
ui["face-colors"].addEventListener("change", event => {
  if (event.target.dataset.faceColor === undefined) return;
  map.rooms[selectedRoom].colors[Number(event.target.dataset.faceColor)] = Number(event.target.value); drawPreview();
});

ui["spawn-room"].addEventListener("change", event => { map.spawn.room = Number(event.target.value); drawPreview(); });
[["spawn-x", "x"], ["spawn-y", "y"], ["spawn-z", "z"]].forEach(([id, property]) => ui[id].addEventListener("change", event => {
  map.spawn[property] = Number(event.target.value); drawPreview();
}));
ui["center-spawn"].addEventListener("click", () => {
  const entry = map.rooms[selectedRoom];
  map.spawn = { room: selectedRoom, x: (entry.minX + entry.maxX) / 2, y: (entry.minY + entry.maxY) / 2, z: entry.minZ + 1.5 };
  render();
});

ui["portal-editors"].addEventListener("change", event => {
  const index = Number(event.target.dataset.portal);
  const field = event.target.dataset.field;
  if (!Number.isInteger(index) || !field) return;
  map.portals[index][field] = field === "active" ? event.target.checked : Number(event.target.value);
  if (field === "room" || field === "face") snapPortal(map.portals[index], true);
  render();
});
ui["portal-editors"].addEventListener("click", event => {
  const button = event.target.closest("[data-center-portal]");
  if (!button) return;
  snapPortal(map.portals[Number(button.dataset.centerPortal)], true); render();
});

ui["new-map"].addEventListener("click", () => { map = defaultMap(); selectedRoom = 0; setStatus("New map", "Restored the two-room wall-to-ceiling test."); render(); });
ui["export-json"].addEventListener("click", () => download(new Blob([JSON.stringify(map, null, 2)], { type: "application/json" }), "true3d-map.json"));
ui["export-raw"].addEventListener("click", () => {
  try { download(buildT3D(), "T3DLVL1.t3d"); setStatus("Raw map exported", "T3DLVL1.t3d contains the packed calculator map."); }
  catch (error) { setStatus("Export failed", error.message, true); }
});
ui["export-appvar"].addEventListener("click", () => {
  try { download(True3DAppVar.pack(buildT3D()), "T3DLVL1.8xv"); setStatus("Calculator map exported", "Transfer T3DLVL1.8xv with TRUE3D06."); }
  catch (error) { setStatus("Export failed", error.message, true); }
});
ui["import-map"].addEventListener("change", async event => {
  const file = event.target.files[0];
  if (!file) return;
  try {
    const buffer = await file.arrayBuffer();
    map = file.name.toLowerCase().endsWith(".json") ? JSON.parse(new TextDecoder().decode(buffer)) :
      parseT3D(file.name.toLowerCase().endsWith(".8xv") ? True3DAppVar.unpack(buffer) : buffer);
    selectedRoom = 0;
    const errors = validateMap();
    if (errors.length) throw new Error(errors.join("; "));
    setStatus("Map imported", `${file.name} is ready to edit.`); render();
  } catch (error) { setStatus("Import failed", error.message, true); }
  event.target.value = "";
});

window.addEventListener("resize", drawPreview);
render();
