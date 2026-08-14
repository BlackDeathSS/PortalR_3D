"use strict";

const MAX_LEVELS = 16;
const FACE_NAMES = ["Floor", "Ceiling", "South wall", "North wall", "West wall", "East wall"];
const DIRECTIONS = ["North face", "South face", "West face", "East face"];
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
    portal3d: { levels: [portal, newPortalLevel("Empty workshop")] },
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

function renderLevelList() {
  ui["level-list"].innerHTML = levels().map((entry,index) =>
    `<button class="level-item ${index === selected[engine] ? "active" : ""}" data-level="${index}">${index + 1} · ${escapeHtml(entry.name)}</button>`).join("");
  document.querySelectorAll("[data-engine]").forEach(button => button.classList.toggle("active", button.dataset.engine === engine));
}

function renderPortalInspector() {
  const entry = level();
  ui.inspector.innerHTML = `
    <section class="card"><h2>Level</h2>
      <label>Menu name<input data-level-name value="${escapeHtml(entry.name)}" maxlength="31"></label>
      <div class="field-grid three" style="margin-top:9px">
        <label>Spawn X<input data-spawn="x" type="number" step=".25" value="${entry.spawn.x}"></label>
        <label>Spawn Y<input data-spawn="y" type="number" step=".25" value="${entry.spawn.y}"></label>
        <label>Angle °<input data-spawn="angle" type="number" step="1" value="${entry.spawn.angle}"></label>
      </div>
    </section>
    <section class="card"><h2>Grid tools</h2>
      <div class="tool-grid">
        ${[["wall","Wall"],["erase","Erase"],["spawn","Spawn"],["portal","Link portal"]].map(([tool,name]) => `<button data-tool="${tool}" class="${portalTool === tool ? "active" : ""}">${name}</button>`).join("")}
      </div>
      <div class="field-grid" style="margin-top:10px">
        <label>Entry face<select id="new-source-dir">${directionOptions(0)}</select></label>
        <label>Exit face<select id="new-target-dir">${directionOptions(1)}</select></label>
      </div>
      <p class="empty">Portal link tool: click an entry wall, then an exit wall. Add reverse links when two-way travel is desired.</p>
    </section>
    <section class="card"><div class="card-title"><h2>Directed portal links (${entry.portals.length}/10)</h2><button class="mini" data-clear-portals>Clear</button></div>
      ${entry.portals.length ? entry.portals.map((portal,index) => `
        <div class="portal-row"><header><strong>Link ${index + 1}</strong><button class="mini danger" data-delete-portal="${index}">Remove</button></header>
          <div class="field-grid three">
            ${portalNumber(index,"x","Entry X",portal.x)}${portalNumber(index,"y","Entry Y",portal.y)}
            <label>Entry face<select data-portal-index="${index}" data-portal-field="direction">${directionOptions(portal.direction)}</select></label>
            ${portalNumber(index,"targetX","Exit X",portal.targetX)}${portalNumber(index,"targetY","Exit Y",portal.targetY)}
            <label>Exit face<select data-portal-index="${index}" data-portal-field="targetDirection">${directionOptions(portal.targetDirection)}</select></label>
          </div>
        </div>`).join("") : `<div class="empty">No linked portals in this level.</div>`}
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
  ui["level-title"].textContent = entry.name;
  ui["engine-kicker"].textContent = engine === "portal3d" ? "RAYCASTER · 15×15" : "TRUE 3D · AXIS-ALIGNED ROOMS";
  ui.stats.textContent = engine === "portal3d" ? `${entry.portals.length} portal links · ${entry.cells.flat().filter(Boolean).length} wall cells` : `${entry.rooms.length} rooms · ${30 + entry.rooms.length * 18} bytes`;
  ui["canvas-help"].textContent = engine === "portal3d" ? "Paint walls, place the spawn, and link portal-bearing wall faces. The outer border must remain solid." : "Isometric overview of room bounds, spawn, and initial portals. Edit exact room geometry in the inspector.";
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
function drawPortalLevel() {
  drawBackground(); const entry=level(), grid=portalGridGeometry();
  for (let y=0;y<15;y++) for (let x=0;x<15;x++) {
    const px=grid.left+x*grid.size, py=grid.top+y*grid.size;
    ctx.fillStyle=entry.cells[y][x]?"#52657b":"#0b1119"; ctx.fillRect(px+1,py+1,grid.size-2,grid.size-2);
    if (entry.cells[y][x]) { ctx.fillStyle="rgba(255,255,255,.055)";ctx.fillRect(px+4,py+4,grid.size-8,4); }
    ctx.strokeStyle="#243247";ctx.strokeRect(px+.5,py+.5,grid.size-1,grid.size-1);
  }
  entry.portals.forEach((p,index) => {
    const px=grid.left+(p.x+.5)*grid.size, py=grid.top+(p.y+.5)*grid.size;
    ctx.beginPath();ctx.arc(px,py,grid.size*.28,0,Math.PI*2);ctx.fillStyle="#f39a31";ctx.fill();
    ctx.fillStyle="#071019";ctx.font=`800 ${Math.max(10,grid.size*.28)}px system-ui`;ctx.textAlign="center";ctx.textBaseline="middle";ctx.fillText(String(index+1),px,py);
    const tx=grid.left+(p.targetX+.5)*grid.size, ty=grid.top+(p.targetY+.5)*grid.size;
    ctx.strokeStyle="rgba(68,136,255,.55)";ctx.setLineDash([4,4]);ctx.beginPath();ctx.moveTo(px,py);ctx.lineTo(tx,ty);ctx.stroke();ctx.setLineDash([]);
  });
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

canvas.addEventListener("click", event => {
  if(engine!=="portal3d")return; const p=canvasPosition(event),g=portalGridGeometry(),x=Math.floor((p.x-g.left)/g.size),y=Math.floor((p.y-g.top)/g.size),entry=level();
  if(x<0||x>14||y<0||y>14)return;
  if(portalTool==="wall")entry.cells[y][x]=1;
  else if(portalTool==="erase") { if(x&&y&&x<14&&y<14){entry.cells[y][x]=0;entry.portals=entry.portals.filter(link=>!(link.x===x&&link.y===y)&&!(link.targetX===x&&link.targetY===y));} }
  else if(portalTool==="spawn") { if(!entry.cells[y][x]){entry.spawn.x=x+.5;entry.spawn.y=y+.5;} }
  else if(portalTool==="portal") {
    if(!entry.cells[y][x])return;
    if(!pendingPortalSource) pendingPortalSource={x,y};
    else if(entry.portals.length<10&&!entry.portals.some(link=>link.x===pendingPortalSource.x&&link.y===pendingPortalSource.y)) {
      entry.portals.push({x:pendingPortalSource.x,y:pendingPortalSource.y,direction:Number(document.querySelector("#new-source-dir")?.value||0),targetX:x,targetY:y,targetDirection:Number(document.querySelector("#new-target-dir")?.value||1)});pendingPortalSource=null;
    }
  }
  render();
});

ui["level-list"].addEventListener("click", event=>{const button=event.target.closest("[data-level]");if(!button)return;selected[engine]=Number(button.dataset.level);currentRoom=0;pendingPortalSource=null;render();});
document.querySelector(".engine-switch").addEventListener("click",event=>{const button=event.target.closest("[data-engine]");if(!button)return;engine=button.dataset.engine;currentRoom=0;pendingPortalSource=null;render();});
ui["add-level"].addEventListener("click",()=>{if(levels().length>=MAX_LEVELS)return alert(`A package supports up to ${MAX_LEVELS} levels.`);levels().push(engine==="portal3d"?newPortalLevel(`Level ${levels().length+1}`):newT3D3Level(`Level ${levels().length+1}`));selected[engine]=levels().length-1;currentRoom=0;render();});
ui["duplicate-level"].addEventListener("click",()=>{if(levels().length>=MAX_LEVELS)return;const copy=clone(level());copy.name=`${copy.name} copy`;levels().splice(selected[engine]+1,0,copy);selected[engine]++;render();});
ui["delete-level"].addEventListener("click",()=>{if(levels().length===1)return alert("Each game needs at least one level.");levels().splice(selected[engine],1);selected[engine]=Math.min(selected[engine],levels().length-1);currentRoom=0;render();});

ui.inspector.addEventListener("change",event=>{
  const t=event.target,entry=level();
  if(t.matches("[data-level-name]")){entry.name=t.value||"Untitled level";render();return;}
  if(t.dataset.spawn){entry.spawn[t.dataset.spawn]=Number(t.value);draw();saveLocalProject();return;}
  if(t.dataset.portalIndex!==undefined){entry.portals[Number(t.dataset.portalIndex)][t.dataset.portalField]=Number(t.value);draw();saveLocalProject();return;}
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
  if(button.dataset.tool){portalTool=button.dataset.tool;pendingPortalSource=null;render();}
  else if(button.dataset.deletePortal!==undefined){entry.portals.splice(Number(button.dataset.deletePortal),1);render();}
  else if(button.hasAttribute("data-clear-portals")){entry.portals=[];pendingPortalSource=null;render();}
  else if(button.dataset.room!==undefined){currentRoom=Number(button.dataset.room);render();}
  else if(button.hasAttribute("data-add-room")){if(entry.rooms.length>=8)return;const maxX=Math.max(...entry.rooms.map(r=>r.maxX));entry.rooms.push({name:`Room ${entry.rooms.length+1}`,minX:maxX+2,maxX:maxX+8,minY:0,maxY:8,minZ:0,maxZ:5,colors:[2,3,5,4,5,5]});currentRoom=entry.rooms.length-1;render();}
  else if(button.hasAttribute("data-delete-room")){if(entry.rooms.length===1)return;entry.rooms.splice(currentRoom,1);entry.spawn.room=Math.min(entry.spawn.room,entry.rooms.length-1);entry.portals.forEach(p=>p.room=Math.min(p.room,entry.rooms.length-1));currentRoom=Math.min(currentRoom,entry.rooms.length-1);render();}
  else if(button.hasAttribute("data-center-spawn")){const r=entry.rooms[currentRoom];entry.spawn={room:currentRoom,x:(r.minX+r.maxX)/2,y:(r.minY+r.maxY)/2,z:r.minZ+1.5};render();}
  else if(button.dataset.snapPortal!==undefined){snapPortal(entry.portals[Number(button.dataset.snapPortal)]);render();}
});

ui["new-project"].addEventListener("click",()=>{if(confirm("Replace the current project with the built-in starter levels?")){project=defaultProject();selected={portal3d:0,t3d3:0};render();}});
ui["save-project"].addEventListener("click",()=>download(JSON.stringify(project,null,2),"portalr3d-project.json"));
ui["import-project"].addEventListener("change",async event=>{const file=event.target.files[0];if(!file)return;try{const next=JSON.parse(await file.text());if(next.format!=="PortalR3DProject"||!next.portal3d?.levels?.length||!next.t3d3?.levels?.length)throw new Error("Not a PortalR 3D project.");project=next;selected={portal3d:0,t3d3:0};currentRoom=0;render();}catch(error){alert(error.message);}event.target.value="";});

document.querySelectorAll("[data-build]").forEach(button=>button.addEventListener("click",async()=>{
  const target=button.dataset.build;ui["build-title"].textContent=`Building ${target === "both" ? "both games" : target}`;ui["build-status"].textContent="Generating levels and running CEdev…";ui["build-log"].textContent="Build started. This can take a little while.";ui["package-link"].hidden=true;
  document.querySelectorAll(".build").forEach(item=>item.disabled=true);
  try{const response=await fetch("/api/build",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({target,project})});const result=await response.json();if(!response.ok)throw new Error(result.error||"Build failed");ui["build-status"].textContent="Package ready";ui["build-log"].textContent=result.log||"Build completed.";ui["package-link"].href=result.url;ui["package-link"].download=result.package;ui["package-link"].textContent=`Download ${result.package}`;ui["package-link"].hidden=false;}catch(error){ui["build-status"].textContent="Build failed";ui["build-log"].textContent=error.message;}finally{document.querySelectorAll(".build").forEach(item=>item.disabled=false);}
}));

window.addEventListener("resize",draw);
render();
