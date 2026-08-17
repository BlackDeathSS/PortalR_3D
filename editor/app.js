"use strict";

const MAX_LEVELS = 16;
const FACE_NAMES = ["Floor", "Ceiling", "South wall", "North wall", "West wall", "East wall"];
/* These values are the engine's fixed portal-face IDs.  The labels and
 * arrows describe the *open side of the wall tile*, which is what an author
 * sees on the map and the side from which a player can enter the portal. */
const DIRECTIONS = ["West side", "East side", "North side", "South side"];
const DIRECTION_ARROWS = ["←", "→", "↑", "↓"];
const DIRECTION_SHORT_NAMES = ["West", "East", "North", "South"];
const DIRECTION_VECTORS = [{ x:-1, y:0 }, { x:1, y:0 }, { x:0, y:-1 }, { x:0, y:1 }];
const LEGACY_ARROW_TO_ENGINE_DIRECTION = [2, 3, 0, 1];
const PALETTE = [
  ["Black", "#000000"], ["Void", "#0c0e19"], ["Floor A", "#36393e"],
  ["Ceiling A", "#202330"], ["Green", "#26cd4b"], ["Dark green", "#187634"],
  ["Floor B", "#413936"], ["Ceiling B", "#302023"], ["Red", "#d73434"],
  ["Dark red", "#7d1e22"], ["Portal blue", "#2d69f5"],
  ["Portal orange", "#f0911c"], ["White", "#f0f0f0"]
];

const ui = Object.fromEntries([...document.querySelectorAll("[id]")].map(node => [node.id, node]));
const canvas = ui["editor-canvas"];
const ctx = canvas.getContext("2d");
let project = loadLocalProject() || defaultProject();
let engine = "portal3d";
let selected = { portal3d: 0, t3d3: 0 };
let currentRoom = 0;
let portalTool = "wall";
let pendingPortalSource = null;
let selectedPortalIndex = null;
let newPortalDirections = { direction: 0, targetDirection: 1 };
ensureProjectSettings(project);
let portalMigrationNotice = migrateLegacyPortalFacings(project);

function originalPortalCells() {
  return [
    "###############", "#.............#", "#............##", "#......#......#",
    "#..........#..#", "#.............#", "#.............#", "######........#",
    "#....#........#", "#....#........#", "#....#........#", "#.............#",
    "#....#........#", "#....#........#", "###############"
  ].map(row => [...row].map(cell => cell === "#" ? 1 : 0));
}

function newPortalLevel(name = "New raycaster level") {
  const cells = Array.from({ length: 15 }, (_, y) => Array.from({ length: 15 }, (_, x) =>
    x === 0 || y === 0 || x === 14 || y === 14 ? 1 : 0));
  return { name, cells, spawn: { x: 2.5, y: 2.5, angle: 0 }, portals: [] };
}

function newT3D3Level(name = "New 3D chamber") {
  return {
    name,
    rooms: [{ name: "Room 1", minX: -4, maxX: 4, minY: 0, maxY: 10, minZ: 0, maxZ: 5, colors: [2,3,5,4,5,5] }],
    spawn: { room: 0, x: 0, y: 2, z: 1.5 },
    portals: [
      { active: false, room: 0, face: 3, x: 0, y: 10, z: 2.5 },
      { active: false, room: 0, face: 2, x: 0, y: 0, z: 2.5 }
    ]
  };
}

function defaultProject() {
  const portal = newPortalLevel("Test chambers");
  portal.cells = originalPortalCells();
  portal.spawn = { x: 1.5, y: 2.5, angle: 45 };
  portal.portals = [
    { x:0,y:13,direction:1,targetX:5,targetY:13,targetDirection:0 },
    { x:5,y:13,direction:0,targetX:0,targetY:13,targetDirection:1 },
    { x:0,y:4,direction:1,targetX:5,targetY:9,targetDirection:0 },
    { x:5,y:9,direction:0,targetX:0,targetY:4,targetDirection:1 },
    { x:5,y:0,direction:3,targetX:7,targetY:0,targetDirection:3 },
    { x:7,y:0,direction:3,targetX:5,targetY:0,targetDirection:3 },
    { x:14,y:5,direction:0,targetX:14,targetY:6,targetDirection:0 },
    { x:14,y:6,direction:0,targetX:14,targetY:5,targetDirection:0 },
    { x:0,y:2,direction:1,targetX:3,targetY:0,targetDirection:3 },
    { x:3,y:0,direction:3,targetX:0,targetY:2,targetDirection:1 }
  ];
  const t3d = newT3D3Level("Wall to ceiling");
  t3d.rooms.push({ name: "Red chamber", minX: 8, maxX: 16, minY: 0, maxY: 8, minZ: 0, maxZ: 5, colors: [6,7,9,8,9,9] });
  t3d.portals = [
    { active:true, room:0, face:3, x:0, y:10, z:2.5 },
    { active:true, room:1, face:1, x:12, y:4, z:5 }
  ];
  return {
    format: "PortalR3DProject", version: 1,
    portal3d: {
      settings: { portalRecursion: 6, alwaysShowFps: true },
      levels: [portal, newPortalLevel("Empty workshop")]
    },
    t3d3: { levels: [t3d, newT3D3Level("Single chamber")] }
  };
}

function clone(value) { return JSON.parse(JSON.stringify(value)); }
function levels() { return project[engine].levels; }
function level() { return levels()[selected[engine]]; }
function escapeHtml(value) { return String(value).replace(/[&<>"']/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"})[c]); }
function saveLocalProject() { localStorage.setItem("portalr3d-project", JSON.stringify(project)); }
function loadLocalProject() { try { const value = JSON.parse(localStorage.getItem("portalr3d-project")); return value?.format === "PortalR3DProject" ? value : null; } catch { return null; } }
function download(value, name, type = "application/json") {
  const blob = value instanceof Blob ? value : new Blob([value], { type });
  const link = document.createElement("a"); link.href = URL.createObjectURL(blob); link.download = name; link.click();
  setTimeout(() => URL.revokeObjectURL(link.href), 0);
}

function directionOptions(value) { return DIRECTIONS.map((name, index) => `<option value="${index}" ${index === Number(value) ? "selected" : ""}>${name}</option>`).join(""); }
function roomOptions(value) { return level().rooms.map((room, index) => `<option value="${index}" ${index === Number(value) ? "selected" : ""}>${index + 1} · ${escapeHtml(room.name)}</option>`).join(""); }
function faceOptions(value) { return FACE_NAMES.map((name,index) => `<option value="${index}" ${index === Number(value) ? "selected" : ""}>${name}</option>`).join(""); }
function colorOptions(value) { return PALETTE.map(([name,color],index) => `<option value="${index}" ${index === Number(value) ? "selected" : ""}>${index} · ${name} · ${color}</option>`).join(""); }

function ensureProjectSettings(nextProject) {
  if (!nextProject.portal3d.settings || typeof nextProject.portal3d.settings !== "object") {
    nextProject.portal3d.settings = {};
  }
  const settings = nextProject.portal3d.settings;
  const recursion = Number(settings.portalRecursion);
  settings.portalRecursion = Number.isInteger(recursion) ? Math.max(1,Math.min(6,recursion)) : 6;
  settings.alwaysShowFps = settings.alwaysShowFps !== false;
}

function portalDirectionsAt(entry, x, y) {
  return DIRECTION_VECTORS.map(({x:dx,y:dy}) => {
    const neighborX = Number(x) + dx, neighborY = Number(y) + dy;
    return neighborX >= 0 && neighborX < 15 && neighborY >= 0 && neighborY < 15 && !entry.cells[neighborY][neighborX];
  });
}

function portalLinkDirectionsAreOpen(entry, portal, directions = null) {
  const mapping = directions || [portal.direction, portal.targetDirection];
  return portalDirectionsAt(entry,portal.x,portal.y)[mapping[0]] &&
    portalDirectionsAt(entry,portal.targetX,portal.targetY)[mapping[1]];
}

/* The first version of the visual arrow controls used screen directions as
 * raw engine values. Existing levels that are invalid under the real engine
 * mapping but completely valid under that old mapping can be repaired without
 * guessing at the author's intent. */
function migrateLegacyPortalFacings(nextProject) {
  if (!nextProject?.portal3d?.levels || nextProject.portalFacingVersion === 2) return false;
  let migrated = false;
  nextProject.portal3d.levels.forEach(entry => {
    const portals = entry.portals || [];
    if (!portals.length) return;
    const currentValid = portals.every(portal => portalLinkDirectionsAreOpen(entry,portal));
    const legacyValid = portals.every(portal => portalLinkDirectionsAreOpen(entry,portal,[
      LEGACY_ARROW_TO_ENGINE_DIRECTION[portal.direction],
      LEGACY_ARROW_TO_ENGINE_DIRECTION[portal.targetDirection]
    ]));
    if (!currentValid && legacyValid) {
      portals.forEach(portal => {
        portal.direction = LEGACY_ARROW_TO_ENGINE_DIRECTION[portal.direction];
        portal.targetDirection = LEGACY_ARROW_TO_ENGINE_DIRECTION[portal.targetDirection];
      });
      migrated = true;
    }
  });
  nextProject.portalFacingVersion = 2;
  return migrated;
}

function ensurePortalSelection() {
  if (engine !== "portal3d") return;
  const count = level().portals.length;
  if (count === 0) selectedPortalIndex = null;
  else if (selectedPortalIndex === null || selectedPortalIndex >= count) selectedPortalIndex = 0;
}

function directionControl(index, field, value, label) {
  return `<div class="direction-control ${field === "direction" ? "entry-facing" : "exit-facing"}"><span>${label}</span><div class="direction-options" role="group" aria-label="${label}">
    ${DIRECTIONS.map((_,direction) => `<button type="button" class="direction-choice ${direction === Number(value) ? "active" : ""}" data-portal-direction="${index}" data-portal-field="${field}" data-direction="${direction}" title="Face ${DIRECTION_SHORT_NAMES[direction]}"><b>${DIRECTION_ARROWS[direction]}</b><small>${DIRECTION_SHORT_NAMES[direction]}</small></button>`).join("")}
  </div></div>`;
}

function portalLinkSummary(portal) {
  return `A (${portal.x}, ${portal.y}) ${DIRECTION_ARROWS[portal.direction] || "?"} · B (${portal.targetX}, ${portal.targetY}) ${DIRECTION_ARROWS[portal.targetDirection] || "?"}`;
}

function renderLevelList() {
  ui["level-list"].innerHTML = levels().map((entry,index) =>
    `<button class="level-item ${index === selected[engine] ? "active" : ""}" data-level="${index}">${index + 1} · ${escapeHtml(entry.name)}</button>`).join("");
  document.querySelectorAll("[data-engine]").forEach(button => button.classList.toggle("active", button.dataset.engine === engine));
}

function renderPortalInspector() {
  const entry = level();
  const settings = project.portal3d.settings;
  ensurePortalSelection();
  const portal = selectedPortalIndex === null ? null : entry.portals[selectedPortalIndex];
  ui.inspector.innerHTML = `
    <section class="card"><h2>Level</h2>
      <label>Menu name<input data-level-name value="${escapeHtml(entry.name)}" maxlength="31"></label>
      <div class="field-grid three" style="margin-top:9px">
        <label>Spawn X<input data-spawn="x" type="number" step=".25" value="${entry.spawn.x}"></label>
        <label>Spawn Y<input data-spawn="y" type="number" step=".25" value="${entry.spawn.y}"></label>
        <label>Angle °<input data-spawn="angle" type="number" step="1" value="${entry.spawn.angle}"></label>
      </div>
      <p class="angle-guide">Spawn heading: 0° → east, 90° ↓ south, 180° ← west, 270° ↑ north.</p>
    </section>
    <section class="card"><h2>Game rendering</h2>
      <div class="field-grid">
        <label>Portal recursion<input data-portal-setting="portalRecursion" type="number" min="1" max="6" step="1" value="${settings.portalRecursion}"></label>
        <label class="checkbox-setting"><input data-portal-setting="alwaysShowFps" type="checkbox" ${settings.alwaysShowFps ? "checked" : ""}> Always show FPS</label>
      </div>
      <p class="angle-guide">Recursion 1 is fastest; 6 shows the deepest portal chains.</p>
    </section>
    <section class="card"><h2>Grid tools</h2>
      <div class="tool-grid">
        ${[["select","Select portal"],["wall","Wall"],["erase","Erase"],["spawn","Spawn"],["portal","Link portal"]].map(([tool,name]) => `<button data-tool="${tool}" class="${portalTool === tool ? "active" : ""}">${name}</button>`).join("")}
      </div>
      <div class="field-grid" style="margin-top:10px">
        <label>New end A face<select data-new-portal-field="direction">${directionOptions(newPortalDirections.direction)}</select></label>
        <label>New end B face<select data-new-portal-field="targetDirection">${directionOptions(newPortalDirections.targetDirection)}</select></label>
      </div>
      <p class="empty">Portal pair tool: click one wall, then the connected wall. Both faces are created and work in both directions.</p>
    </section>
    ${portal ? `<section class="card selected-portal-card"><div class="card-title"><h2>Selected connection ${selectedPortalIndex + 1}</h2><button class="mini danger" data-delete-portal="${selectedPortalIndex}">Remove</button></div>
      <div class="connection-banner"><span class="entry-key">End A</span><strong>Bidirectional pair</strong><span class="exit-key">End B</span></div>
      <div class="field-grid" style="margin-top:10px">
        ${portalNumber(selectedPortalIndex,"x","End A X",portal.x)}${portalNumber(selectedPortalIndex,"y","End A Y",portal.y)}
        ${portalNumber(selectedPortalIndex,"targetX","End B X",portal.targetX)}${portalNumber(selectedPortalIndex,"targetY","End B Y",portal.targetY)}
      </div>
      ${directionControl(selectedPortalIndex,"direction",portal.direction,"End A facing")}
      ${directionControl(selectedPortalIndex,"targetDirection",portal.targetDirection,"End B facing")}
    </section>` : ""}
    <section class="card"><div class="card-title"><h2>Portal pairs (${entry.portals.length}/10)</h2><button class="mini" data-clear-portals>Clear</button></div>
      ${entry.portals.length ? `<div class="portal-link-list">${entry.portals.map((item,index) => `
        <button type="button" class="portal-link ${index === selectedPortalIndex ? "active" : ""}" data-select-portal="${index}"><strong>Connection ${index + 1}</strong><span>${portalLinkSummary(item)}</span></button>`).join("")}</div>` : `<div class="empty">No linked portals in this level.</div>`}
    </section>`;
}

function portalNumber(index, field, label, value) {
  return `<label>${label}<input type="number" min="0" max="14" step="1" value="${value}" data-portal-index="${index}" data-portal-field="${field}"></label>`;
}

function renderT3D3Inspector() {
  const entry = level();
  currentRoom = Math.min(currentRoom, entry.rooms.length - 1);
  const room = entry.rooms[currentRoom];
  ui.inspector.innerHTML = `
    <section class="card"><h2>Level</h2><label>Menu name<input data-level-name value="${escapeHtml(entry.name)}" maxlength="31"></label></section>
    <section class="card"><div class="card-title"><h2>Rooms (${entry.rooms.length}/8)</h2><button class="mini" data-add-room>Add</button></div>
      ${entry.rooms.map((item,index) => `<button class="wide ${index === currentRoom ? "primary" : ""}" data-room="${index}">${index + 1} · ${escapeHtml(item.name)}</button>`).join("")}
      <button class="wide danger" data-delete-room>Delete selected room</button>
    </section>
    <section class="card"><h2>Selected room</h2>
      <label>Name<input data-room-field="name" value="${escapeHtml(room.name)}" maxlength="24"></label>
      <div class="field-grid" style="margin-top:9px">
        ${["minX","maxX","minY","maxY","minZ","maxZ"].map(key => `<label>${key.replace(/([A-Z])/g," $1")}<input data-room-field="${key}" type="number" step=".25" value="${room[key]}"></label>`).join("")}
      </div>
      <div class="color-grid" style="margin-top:10px">${FACE_NAMES.map((name,index) => `<label>${name}<select data-color="${index}">${colorOptions(room.colors[index])}</select></label>`).join("")}</div>
    </section>
    <section class="card"><h2>Player spawn</h2>
      <label>Room<select data-t3d-spawn="room">${roomOptions(entry.spawn.room)}</select></label>
      <div class="field-grid three" style="margin-top:9px">${["x","y","z"].map(key => `<label>${key.toUpperCase()}<input data-t3d-spawn="${key}" type="number" step=".25" value="${entry.spawn[key]}"></label>`).join("")}</div>
      <button class="wide" data-center-spawn>Center in selected room</button>
    </section>
    <section class="card"><h2>Initial portals</h2>
      ${entry.portals.map((portal,index) => `
        <div class="portal-row"><header><strong style="color:${index ? "#4488ff" : "#f39a31"}">${index ? "Blue" : "Orange"}</strong>
          <label style="display:flex;align-items:center"><input style="width:auto" type="checkbox" data-t3d-portal="${index}" data-field="active" ${portal.active ? "checked" : ""}> Active</label></header>
          <div class="field-grid"><label>Room<select data-t3d-portal="${index}" data-field="room">${roomOptions(portal.room)}</select></label><label>Face<select data-t3d-portal="${index}" data-field="face">${faceOptions(portal.face)}</select></label></div>
          <div class="field-grid three" style="margin-top:8px">${["x","y","z"].map(key => `<label>${key.toUpperCase()}<input type="number" step=".25" value="${portal[key]}" data-t3d-portal="${index}" data-field="${key}"></label>`).join("")}</div>
          <button class="wide" data-snap-portal="${index}">Center and snap to face</button>
        </div>`).join("")}
    </section>`;
}

function render() {
  renderLevelList();
  const entry = level();
  if (engine === "portal3d") ensurePortalSelection();
  ui["level-title"].textContent = entry.name;
  ui["engine-kicker"].textContent = engine === "portal3d" ? "RAYCASTER · 15×15" : "TRUE 3D · AXIS-ALIGNED ROOMS";
  ui.stats.textContent = engine === "portal3d" ? `${entry.portals.length} pairs · ${selectedPortalIndex === null ? "none" : `pair ${selectedPortalIndex + 1}`} selected` : `${entry.rooms.length} rooms · ${30 + entry.rooms.length * 18} bytes`;
  ui["canvas-help"].textContent = engine === "portal3d" ? `${portalMigrationNotice ? "Corrected portal facings created with the previous arrow mapping. " : ""}${portalTool === "select" ? "Click either colored endpoint to select its pair. Click an overlapping endpoint again to cycle. Every arrow button is available." : "Orange and blue are the two usable ends of one portal pair. Each arrow shows the side where that portal faces."}` : "Isometric overview of room bounds, spawn, and initial portals. Edit exact room geometry in the inspector.";
  canvas.dataset.tool = engine === "portal3d" ? portalTool : "overview";
  if (engine === "portal3d") renderPortalInspector(); else renderT3D3Inspector();
  draw();
  saveLocalProject();
}

function canvasPosition(event) {
  const rect = canvas.getBoundingClientRect();
  return { x: (event.clientX - rect.left) * canvas.width / rect.width, y: (event.clientY - rect.top) * canvas.height / rect.height };
}

function drawBackground() {
  const gradient = ctx.createLinearGradient(0,0,0,canvas.height); gradient.addColorStop(0,"#101a27"); gradient.addColorStop(1,"#05080d");
  ctx.fillStyle = gradient; ctx.fillRect(0,0,canvas.width,canvas.height);
  ctx.strokeStyle = "rgba(83,111,145,.11)"; ctx.lineWidth = 1;
  for (let x=0;x<canvas.width;x+=32) { ctx.beginPath();ctx.moveTo(x,0);ctx.lineTo(x,canvas.height);ctx.stroke(); }
  for (let y=0;y<canvas.height;y+=32) { ctx.beginPath();ctx.moveTo(0,y);ctx.lineTo(canvas.width,y);ctx.stroke(); }
}

function portalGridGeometry() { const size = Math.min((canvas.width-150)/15,(canvas.height-70)/15); return { size, left:(canvas.width-size*15)/2, top:(canvas.height-size*15)/2 }; }

function portalGridPoint(grid, x, y) {
  return { x:grid.left+(Number(x)+.5)*grid.size, y:grid.top+(Number(y)+.5)*grid.size };
}

function drawFacingArrow(point, direction, color, size, selected) {
  const vector = DIRECTION_VECTORS[Number(direction)] || DIRECTION_VECTORS[0];
  const length = size * (selected ? .45 : .36);
  const startX = point.x + vector.x * size * .08;
  const startY = point.y + vector.y * size * .08;
  const endX = point.x + vector.x * length;
  const endY = point.y + vector.y * length;
  const wing = size * (selected ? .12 : .09);
  const backX = endX - vector.x * wing;
  const backY = endY - vector.y * wing;

  ctx.strokeStyle = color;
  ctx.fillStyle = color;
  ctx.lineWidth = selected ? 4 : 2.5;
  ctx.lineCap = "round";
  ctx.beginPath();ctx.moveTo(startX,startY);ctx.lineTo(endX,endY);ctx.stroke();
  ctx.beginPath();
  ctx.moveTo(endX,endY);
  ctx.lineTo(backX-vector.y*wing*.7,backY+vector.x*wing*.7);
  ctx.lineTo(backX+vector.y*wing*.7,backY-vector.x*wing*.7);
  ctx.closePath();ctx.fill();
}

function drawPortalEndpoint(grid, x, y, direction, index, kind, selected) {
  const point = portalGridPoint(grid,x,y);
  const entryEndpoint = kind === "entry";
  const color = entryEndpoint ? "#f39a31" : "#4488ff";
  const radius = grid.size * (selected ? .24 : .18);

  ctx.save();
  if (selected) {
    ctx.fillStyle = entryEndpoint ? "rgba(243,154,49,.18)" : "rgba(68,136,255,.18)";
    ctx.fillRect(grid.left+x*grid.size+2,grid.top+y*grid.size+2,grid.size-4,grid.size-4);
    ctx.strokeStyle = color;ctx.lineWidth = 3;
    ctx.strokeRect(grid.left+x*grid.size+3.5,grid.top+y*grid.size+3.5,grid.size-7,grid.size-7);
  }
  ctx.beginPath();ctx.arc(point.x,point.y,radius,0,Math.PI*2);
  ctx.fillStyle = entryEndpoint ? "#442609" : "#0b214a";ctx.fill();
  ctx.strokeStyle = color;ctx.lineWidth = selected ? 4 : 2;ctx.stroke();
  drawFacingArrow(point,direction,color,grid.size,selected);
  ctx.fillStyle = "#ffffff";ctx.font = `900 ${Math.max(9,grid.size*(selected?.25:.2))}px system-ui`;ctx.textAlign = "center";ctx.textBaseline = "middle";
  ctx.fillText(String(index+1),point.x,point.y);
  if (selected) {
    ctx.fillStyle = color;ctx.font = `900 ${Math.max(9,grid.size*.19)}px system-ui`;
    ctx.fillText(entryEndpoint ? "END A" : "END B",point.x,point.y+grid.size*.34);
  }
  ctx.restore();
}

function drawPortalConnection(portal, index, selected, grid) {
  const source = portalGridPoint(grid,portal.x,portal.y);
  const target = portalGridPoint(grid,portal.targetX,portal.targetY);
  const gradient = ctx.createLinearGradient(source.x,source.y,target.x,target.y);
  gradient.addColorStop(0,"#f39a31");gradient.addColorStop(1,"#4488ff");

  ctx.save();
  ctx.globalAlpha = selected ? 1 : .35;
  ctx.strokeStyle = gradient;ctx.lineWidth = selected ? 5 : 1.5;
  ctx.setLineDash(selected ? [] : [5,5]);
  ctx.beginPath();ctx.moveTo(source.x,source.y);ctx.lineTo(target.x,target.y);ctx.stroke();
  ctx.setLineDash([]);
  drawPortalEndpoint(grid,portal.x,portal.y,portal.direction,index,"entry",selected);
  drawPortalEndpoint(grid,portal.targetX,portal.targetY,portal.targetDirection,index,"exit",selected);
  ctx.restore();
}

function drawPortalLevel() {
  drawBackground(); const entry=level(), grid=portalGridGeometry();
  for (let y=0;y<15;y++) for (let x=0;x<15;x++) {
    const px=grid.left+x*grid.size, py=grid.top+y*grid.size;
    ctx.fillStyle=entry.cells[y][x]?"#52657b":"#0b1119"; ctx.fillRect(px+1,py+1,grid.size-2,grid.size-2);
    if (entry.cells[y][x]) { ctx.fillStyle="rgba(255,255,255,.055)";ctx.fillRect(px+4,py+4,grid.size-8,4); }
    ctx.strokeStyle="#243247";ctx.strokeRect(px+.5,py+.5,grid.size-1,grid.size-1);
  }
  entry.portals.forEach((p,index) => { if(index!==selectedPortalIndex)drawPortalConnection(p,index,false,grid); });
  if(selectedPortalIndex!==null&&entry.portals[selectedPortalIndex])drawPortalConnection(entry.portals[selectedPortalIndex],selectedPortalIndex,true,grid);
  if (pendingPortalSource) { const p=pendingPortalSource;ctx.strokeStyle="#45e477";ctx.lineWidth=3;ctx.strokeRect(grid.left+p.x*grid.size+2,grid.top+p.y*grid.size+2,grid.size-4,grid.size-4);ctx.lineWidth=1; }
  const spawn=entry.spawn, sx=grid.left+spawn.x*grid.size, sy=grid.top+spawn.y*grid.size, angle=spawn.angle*Math.PI/180;
  ctx.save();ctx.translate(sx,sy);ctx.rotate(angle);ctx.fillStyle="#45e477";ctx.beginPath();ctx.moveTo(grid.size*.35,0);ctx.lineTo(-grid.size*.25,-grid.size*.22);ctx.lineTo(-grid.size*.25,grid.size*.22);ctx.closePath();ctx.fill();ctx.restore();
  ctx.fillStyle="#8ea0b6";ctx.font="12px system-ui";ctx.textAlign="right";ctx.textBaseline="alphabetic";ctx.fillText("Wall coordinates 0–14",canvas.width-18,canvas.height-15);
}

function t3dBounds() { return level().rooms.reduce((a,r)=>({minX:Math.min(a.minX,r.minX),maxX:Math.max(a.maxX,r.maxX),minY:Math.min(a.minY,r.minY),maxY:Math.max(a.maxY,r.maxY),minZ:Math.min(a.minZ,r.minZ),maxZ:Math.max(a.maxZ,r.maxZ)}),{minX:Infinity,maxX:-Infinity,minY:Infinity,maxY:-Infinity,minZ:Infinity,maxZ:-Infinity}); }
function drawT3D3Level() {
  drawBackground(); const entry=level(), area=t3dBounds(), range=Math.max(area.maxX-area.minX,area.maxY-area.minY,(area.maxZ-area.minZ)*1.7,8), scale=Math.min(canvas.width,canvas.height*1.35)/(range*2.25), cx=(area.minX+area.maxX)/2, cy=(area.minY+area.maxY)/2;
  const project=p=>({x:canvas.width/2+((p.x-cx)-(p.y-cy))*scale,y:canvas.height*.69+((p.x-cx)+(p.y-cy))*scale*.43-(p.z-area.minZ)*scale});
  entry.rooms.forEach((r,index)=>{
    const c=[[r.minX,r.minY,r.minZ],[r.maxX,r.minY,r.minZ],[r.maxX,r.maxY,r.minZ],[r.minX,r.maxY,r.minZ],[r.minX,r.minY,r.maxZ],[r.maxX,r.minY,r.maxZ],[r.maxX,r.maxY,r.maxZ],[r.minX,r.maxY,r.maxZ]].map(v=>project({x:v[0],y:v[1],z:v[2]}));
    [[0,1],[1,2],[2,3],[3,0],[4,5],[5,6],[6,7],[7,4],[0,4],[1,5],[2,6],[3,7]].forEach(([a,b])=>{ctx.strokeStyle=index===currentRoom?"#45e477":"#53677f";ctx.lineWidth=index===currentRoom?2.5:1.3;ctx.beginPath();ctx.moveTo(c[a].x,c[a].y);ctx.lineTo(c[b].x,c[b].y);ctx.stroke();});
    const p=project({x:(r.minX+r.maxX)/2,y:(r.minY+r.maxY)/2,z:r.maxZ});ctx.fillStyle=index===currentRoom?"#dfffea":"#9aabbe";ctx.font="600 13px system-ui";ctx.textAlign="center";ctx.fillText(`${index+1} · ${r.name}`,p.x,p.y-10);
  });
  const marker=(p,color,text)=>{const q=project(p);ctx.beginPath();ctx.arc(q.x,q.y,7,0,Math.PI*2);ctx.fillStyle=color;ctx.fill();ctx.fillStyle=color;ctx.font="800 12px system-ui";ctx.fillText(text,q.x,q.y-12);};
  marker(entry.spawn,"#fff","S");entry.portals.forEach((p,i)=>{if(p.active)marker(p,i?"#4488ff":"#f39a31",i?"B":"O");});
}
function draw() { if (engine === "portal3d") drawPortalLevel(); else drawT3D3Level(); }

function snapPortal(portal) {
  const room=level().rooms[portal.room]; if(!room)return;
  portal.x=(room.minX+room.maxX)/2;portal.y=(room.minY+room.maxY)/2;portal.z=(room.minZ+room.maxZ)/2;
  if(portal.face===0)portal.z=room.minZ;else if(portal.face===1)portal.z=room.maxZ;else if(portal.face===2)portal.y=room.minY;else if(portal.face===3)portal.y=room.maxY;else if(portal.face===4)portal.x=room.minX;else portal.x=room.maxX;
}

function selectPortalAtCell(entry, x, y) {
  const matches = entry.portals.map((portal,index) => ({portal,index})).filter(({portal}) =>
    (portal.x===x&&portal.y===y)||(portal.targetX===x&&portal.targetY===y)).map(({index}) => index);
  if (!matches.length) return false;
  const current = matches.indexOf(selectedPortalIndex);
  selectedPortalIndex = matches[(current + 1) % matches.length];
  return true;
}

function removePortal(entry, index) {
  entry.portals.splice(index,1);
  if (selectedPortalIndex === index) selectedPortalIndex = Math.min(index,entry.portals.length-1);
  else if (selectedPortalIndex !== null && selectedPortalIndex > index) --selectedPortalIndex;
  if (entry.portals.length === 0) selectedPortalIndex = null;
}

canvas.addEventListener("click", event => {
  if(engine!=="portal3d")return; const p=canvasPosition(event),g=portalGridGeometry(),x=Math.floor((p.x-g.left)/g.size),y=Math.floor((p.y-g.top)/g.size),entry=level();
  if(x<0||x>14||y<0||y>14)return;
  if(portalTool==="select") { selectPortalAtCell(entry,x,y); }
  else if(portalTool==="wall")entry.cells[y][x]=1;
  else if(portalTool==="erase") { if(x&&y&&x<14&&y<14){entry.cells[y][x]=0;entry.portals=entry.portals.filter(link=>!(link.x===x&&link.y===y)&&!(link.targetX===x&&link.targetY===y));ensurePortalSelection();} }
  else if(portalTool==="spawn") { if(!entry.cells[y][x]){entry.spawn.x=x+.5;entry.spawn.y=y+.5;} }
  else if(portalTool==="portal") {
    if(!entry.cells[y][x])return;
    if(!pendingPortalSource) {
      pendingPortalSource={x,y};
    }
    else if(entry.portals.length<10) {
      entry.portals.push({x:pendingPortalSource.x,y:pendingPortalSource.y,direction:newPortalDirections.direction,targetX:x,targetY:y,targetDirection:newPortalDirections.targetDirection});selectedPortalIndex=entry.portals.length-1;pendingPortalSource=null;
    }
  }
  render();
});

ui["level-list"].addEventListener("click", event=>{const button=event.target.closest("[data-level]");if(!button)return;selected[engine]=Number(button.dataset.level);currentRoom=0;pendingPortalSource=null;selectedPortalIndex=null;render();});
document.querySelector(".engine-switch").addEventListener("click",event=>{const button=event.target.closest("[data-engine]");if(!button)return;engine=button.dataset.engine;currentRoom=0;pendingPortalSource=null;selectedPortalIndex=null;render();});
ui["add-level"].addEventListener("click",()=>{if(levels().length>=MAX_LEVELS)return alert(`A package supports up to ${MAX_LEVELS} levels.`);levels().push(engine==="portal3d"?newPortalLevel(`Level ${levels().length+1}`):newT3D3Level(`Level ${levels().length+1}`));selected[engine]=levels().length-1;currentRoom=0;selectedPortalIndex=null;render();});
ui["duplicate-level"].addEventListener("click",()=>{if(levels().length>=MAX_LEVELS)return;const copy=clone(level());copy.name=`${copy.name} copy`;levels().splice(selected[engine]+1,0,copy);selected[engine]++;selectedPortalIndex=null;render();});
ui["delete-level"].addEventListener("click",()=>{if(levels().length===1)return alert("Each game needs at least one level.");levels().splice(selected[engine],1);selected[engine]=Math.min(selected[engine],levels().length-1);currentRoom=0;selectedPortalIndex=null;render();});

ui.inspector.addEventListener("change",event=>{
  const t=event.target,entry=level();
  if(t.matches("[data-level-name]")){entry.name=t.value||"Untitled level";render();return;}
  if(t.dataset.portalSetting){const settings=project.portal3d.settings,key=t.dataset.portalSetting;settings[key]=key==="alwaysShowFps"?t.checked:Math.max(1,Math.min(6,Math.round(Number(t.value)||6)));render();return;}
  if(t.dataset.spawn){entry.spawn[t.dataset.spawn]=Number(t.value);draw();saveLocalProject();return;}
  if(t.dataset.newPortalField){newPortalDirections[t.dataset.newPortalField]=Number(t.value);return;}
  if(t.dataset.portalIndex!==undefined){selectedPortalIndex=Number(t.dataset.portalIndex);entry.portals[selectedPortalIndex][t.dataset.portalField]=Number(t.value);draw();saveLocalProject();return;}
  if(t.dataset.roomField){const key=t.dataset.roomField;entry.rooms[currentRoom][key]=key==="name"?(t.value||`Room ${currentRoom+1}`):Number(t.value);render();return;}
  if(t.dataset.color!==undefined){entry.rooms[currentRoom].colors[Number(t.dataset.color)]=Number(t.value);saveLocalProject();return;}
  if(t.dataset.t3dSpawn){entry.spawn[t.dataset.t3dSpawn]=Number(t.value);draw();saveLocalProject();return;}
  if(t.dataset.t3dPortal!==undefined){const p=entry.portals[Number(t.dataset.t3dPortal)],field=t.dataset.field;p[field]=field==="active"?t.checked:Number(t.value);if(field==="room"||field==="face")snapPortal(p);render();}
});

ui.inspector.addEventListener("input", event => {
  const target = event.target;
  if (target.matches("[data-level-name]")) {
    level().name = target.value || "Untitled level";
    ui["level-title"].textContent = level().name;
    const item = ui["level-list"].querySelector(`[data-level="${selected[engine]}"]`);
    if (item) item.textContent = `${selected[engine] + 1} · ${level().name}`;
    saveLocalProject();
  } else if (target.dataset.roomField === "name" && engine === "t3d3") {
    level().rooms[currentRoom].name = target.value || `Room ${currentRoom + 1}`;
    saveLocalProject();
    draw();
  }
});

ui.inspector.addEventListener("click",event=>{
  const button=event.target.closest("button");if(!button)return;const entry=level();
  if(button.dataset.selectPortal!==undefined){selectedPortalIndex=Number(button.dataset.selectPortal);portalTool="select";pendingPortalSource=null;render();}
  else if(button.dataset.portalDirection!==undefined){selectedPortalIndex=Number(button.dataset.portalDirection);entry.portals[selectedPortalIndex][button.dataset.portalField]=Number(button.dataset.direction);render();}
  else if(button.dataset.tool){portalTool=button.dataset.tool;pendingPortalSource=null;render();}
  else if(button.dataset.deletePortal!==undefined){removePortal(entry,Number(button.dataset.deletePortal));render();}
  else if(button.hasAttribute("data-clear-portals")){entry.portals=[];selectedPortalIndex=null;pendingPortalSource=null;render();}
  else if(button.dataset.room!==undefined){currentRoom=Number(button.dataset.room);render();}
  else if(button.hasAttribute("data-add-room")){if(entry.rooms.length>=8)return;const maxX=Math.max(...entry.rooms.map(r=>r.maxX));entry.rooms.push({name:`Room ${entry.rooms.length+1}`,minX:maxX+2,maxX:maxX+8,minY:0,maxY:8,minZ:0,maxZ:5,colors:[2,3,5,4,5,5]});currentRoom=entry.rooms.length-1;render();}
  else if(button.hasAttribute("data-delete-room")){if(entry.rooms.length===1)return;entry.rooms.splice(currentRoom,1);entry.spawn.room=Math.min(entry.spawn.room,entry.rooms.length-1);entry.portals.forEach(p=>p.room=Math.min(p.room,entry.rooms.length-1));currentRoom=Math.min(currentRoom,entry.rooms.length-1);render();}
  else if(button.hasAttribute("data-center-spawn")){const r=entry.rooms[currentRoom];entry.spawn={room:currentRoom,x:(r.minX+r.maxX)/2,y:(r.minY+r.maxY)/2,z:r.minZ+1.5};render();}
  else if(button.dataset.snapPortal!==undefined){snapPortal(entry.portals[Number(button.dataset.snapPortal)]);render();}
});

ui["new-project"].addEventListener("click",()=>{if(confirm("Replace the current project with the built-in starter levels?")){project=defaultProject();portalMigrationNotice=false;selected={portal3d:0,t3d3:0};selectedPortalIndex=null;render();}});
ui["save-project"].addEventListener("click",()=>download(JSON.stringify(project,null,2),"portalr3d-project.json"));
ui["import-project"].addEventListener("change",async event=>{const file=event.target.files[0];if(!file)return;try{const next=JSON.parse(await file.text());if(next.format!=="PortalR3DProject"||!next.portal3d?.levels?.length||!next.t3d3?.levels?.length)throw new Error("Not a PortalR 3D project.");project=next;ensureProjectSettings(project);portalMigrationNotice=migrateLegacyPortalFacings(project);selected={portal3d:0,t3d3:0};currentRoom=0;selectedPortalIndex=null;render();}catch(error){alert(error.message);}event.target.value="";});

document.querySelectorAll("[data-build]").forEach(button=>button.addEventListener("click",async()=>{
  const target=button.dataset.build;ui["build-title"].textContent=`Building ${target === "both" ? "both games" : target}`;ui["build-status"].textContent="Generating levels and running CEdev…";ui["build-log"].textContent="Build started. This can take a little while.";ui["package-link"].hidden=true;
  document.querySelectorAll(".build").forEach(item=>item.disabled=true);
  try{const response=await fetch("/api/build",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({target,project})});const result=await response.json();if(!response.ok)throw new Error(result.error||"Build failed");ui["build-status"].textContent="Package ready";ui["build-log"].textContent=result.log||"Build completed.";ui["package-link"].href=result.url;ui["package-link"].download=result.package;ui["package-link"].textContent=`Download ${result.package}`;ui["package-link"].hidden=false;}catch(error){ui["build-status"].textContent="Build failed";ui["build-log"].textContent=error.message;}finally{document.querySelectorAll(".build").forEach(item=>item.disabled=false);}
}));

window.addEventListener("resize",draw);
render();
