/**
 * SI-CAKRAWALA | NANGGROE CAKRAWALA SHIELD
 * Pusat Komando Operasional Siber Terpadu TNI AD
 * Engine: Military Modern Liquid Glass UI / Real-time Simulation Core
 */

document.addEventListener("DOMContentLoaded", () => {
  initClock();
  initParticles();
  initTabs();
  initCyberMap();
  initRadar();
  initTrafficChart();
  initTimelineAndThreats();
  initConsole();
  initSatelliteView();
  initOrbitTracker();
  initAIEngine();
  initPredictChart();
  initBlockchainVisualizer();
  initTelemetryGauges();
  initTelemetryCharts();
  initOpsMap();
  initOpsFeeds();
});

/* 1. CLOCK & STATUS TIMERS */
function initClock() {
  const dateEl = document.getElementById("clockDate");
  const timeEl = document.getElementById("clockTime");

  function update() {
    const now = new Date();
    const days = ["MINGGU", "SENIN", "SELASA", "RABU", "KAMIS", "JUMAT", "SABTU"];
    const months = ["JAN", "FEB", "MAR", "APR", "MEI", "JUN", "JUL", "AGU", "SEP", "OKT", "NOV", "DES"];
    if (dateEl) {
      dateEl.textContent = `${days[now.getDay()]}, ${String(now.getDate()).padStart(2, "0")} ${months[now.getMonth()]} ${now.getFullYear()}`;
    }
    if (timeEl) {
      const h = String(now.getHours()).padStart(2, "0");
      const m = String(now.getMinutes()).padStart(2, "0");
      const s = String(now.getSeconds()).padStart(2, "0");
      timeEl.textContent = `${h}:${m}:${s}`;
    }
  }
  update();
  setInterval(update, 1000);
}

/* 2. BACKGROUND PARTICLES CANVAS */
function initParticles() {
  const canvas = document.getElementById("particleCanvas");
  if (!canvas) return;
  const ctx = canvas.getContext("2d");
  let width, height;
  let particles = [];

  function resize() {
    width = canvas.width = window.innerWidth;
    height = canvas.height = window.innerHeight;
  }
  resize();
  window.addEventListener("resize", resize);

  const count = 45;
  for (let i = 0; i < count; i++) {
    particles.push({
      x: Math.random() * width,
      y: Math.random() * height,
      vx: (Math.random() - 0.5) * 0.4,
      vy: (Math.random() - 0.5) * 0.4,
      size: Math.random() * 1.8 + 0.6,
      color: Math.random() > 0.7 ? "#00e5ff" : (Math.random() > 0.5 ? "#39ff14" : "#d4af37")
    });
  }

  function loop() {
    ctx.clearRect(0, 0, width, height);
    for (let i = 0; i < particles.length; i++) {
      const p = particles[i];
      p.x += p.vx;
      p.y += p.vy;
      if (p.x < 0) p.x = width;
      if (p.x > width) p.x = 0;
      if (p.y < 0) p.y = height;
      if (p.y > height) p.y = 0;

      ctx.beginPath();
      ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
      ctx.fillStyle = p.color;
      ctx.globalAlpha = 0.35;
      ctx.fill();

      for (let j = i + 1; j < particles.length; j++) {
        const p2 = particles[j];
        const dist = Math.hypot(p.x - p2.x, p.y - p2.y);
        if (dist < 110) {
          ctx.beginPath();
          ctx.moveTo(p.x, p.y);
          ctx.lineTo(p2.x, p2.y);
          ctx.strokeStyle = "#00e5ff";
          ctx.globalAlpha = (1 - dist / 110) * 0.12;
          ctx.stroke();
        }
      }
    }
    requestAnimationFrame(loop);
  }
  loop();
}

/* 3. NAVIGATION TABS */
function initTabs() {
  const buttons = document.querySelectorAll(".nav-btn");
  const panels = document.querySelectorAll(".tab-panel");

  buttons.forEach(btn => {
    btn.addEventListener("click", () => {
      const target = btn.getAttribute("data-tab");
      buttons.forEach(b => b.classList.remove("active"));
      panels.forEach(p => p.classList.remove("active"));

      btn.classList.add("active");
      const targetPanel = document.getElementById(`tab-${target}`);
      if (targetPanel) {
        targetPanel.classList.add("active");
      }
    });
  });
}
/* 4. PETA OPERASIONAL SIBER NUSANTARA CANVAS */
function initCyberMap() {
  const canvas = document.getElementById("mapCanvas");
  if (!canvas) return;
  const ctx = canvas.getContext("2d");
  const coordsEl = document.getElementById("mapCoords");

  function resize() {
    canvas.width = canvas.parentElement.clientWidth;
    canvas.height = canvas.parentElement.clientHeight;
  }
  resize();
  window.addEventListener("resize", resize);

  const nodes = [
    { name: "SABANG - SEKTOR ALFA", x: 0.12, y: 0.32, status: "warn" },
    { name: "MEDAN - KODAM I/BB", x: 0.18, y: 0.40, status: "safe" },
    { name: "NATUNA - POS DEPAN", x: 0.33, y: 0.28, status: "danger" },
    { name: "BATAM - SIBER HUB", x: 0.24, y: 0.45, status: "safe" },
    { name: "JAKARTA - MABES SATSIBER AD", x: 0.30, y: 0.72, status: "safe" },
    { name: "BANDUNG - PUSSENIF / DISINFOLAHTA", x: 0.33, y: 0.75, status: "safe" },
    { name: "SURABAYA - KODAM V/BRW", x: 0.44, y: 0.78, status: "warn" },
    { name: "PONTIANAK - KODAM XII/TPR", x: 0.35, y: 0.50, status: "safe" },
    { name: "BALIKPAPAN - KODAM VI/MLW", x: 0.48, y: 0.52, status: "safe" },
    { name: "TARAKAN - SEKTOR BRAVO", x: 0.52, y: 0.35, status: "danger" },
    { name: "MAKASSAR - KODAM XIV/HSN", x: 0.56, y: 0.65, status: "safe" },
    { name: "MANADO - KODAM XIII/MDK", x: 0.63, y: 0.38, status: "warn" },
    { name: "AMBON - KODAM XVI/PTM", x: 0.74, y: 0.62, status: "safe" },
    { name: "JAYAPURA - KODAM XVII/CEN", x: 0.88, y: 0.58, status: "danger" },
    { name: "MERAUKE - SEKTOR DELTA", x: 0.89, y: 0.80, status: "safe" },
    { name: "KUPANG - KODAM IX/UDY", x: 0.58, y: 0.85, status: "safe" }
  ];

  const links = [
    [4, 0], [4, 1], [4, 2], [4, 3], [4, 5], [4, 6], [4, 7], [4, 8],
    [8, 9], [4, 10], [10, 11], [10, 12], [4, 13], [13, 14], [6, 15]
  ];

  let pulse = 0;
  let packets = [];

  function spawnPacket() {
    if (packets.length < 12) {
      const link = links[Math.floor(Math.random() * links.length)];
      packets.push({
        from: link[0],
        to: link[1],
        progress: 0,
        speed: 0.008 + Math.random() * 0.012,
        color: Math.random() > 0.8 ? "#ff3344" : "#00e5ff"
      });
    }
  }

  canvas.addEventListener("mousemove", (e) => {
    const rect = canvas.getBoundingClientRect();
    const mx = (e.clientX - rect.left) / canvas.width;
    const my = (e.clientY - rect.top) / canvas.height;
    const lat = ((1 - my) * 16 - 11).toFixed(2);
    const lon = (mx * 46 + 95).toFixed(2);
    if (coordsEl) {
      coordsEl.textContent = `${Math.abs(lat)}°${lat >= 0 ? "N" : "S"} ${lon}°E [REF: ID-${Math.floor(mx*999)}]`;
    }
  });

  function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    pulse += 0.04;

    ctx.strokeStyle = "rgba(0, 229, 255, 0.05)";
    ctx.lineWidth = 1;
    const gridSize = 36;
    for (let x = 0; x < canvas.width; x += gridSize) {
      ctx.beginPath();
      ctx.moveTo(x, 0); ctx.lineTo(x, canvas.height); ctx.stroke();
    }
    for (let y = 0; y < canvas.height; y += gridSize) {
      ctx.beginPath();
      ctx.moveTo(0, y); ctx.lineTo(canvas.width, y); ctx.stroke();
    }

    ctx.fillStyle = "rgba(27, 58, 36, 0.18)";
    ctx.strokeStyle = "rgba(57, 255, 20, 0.25)";
    ctx.lineWidth = 1;

    ctx.beginPath();
    ctx.ellipse(canvas.width * 0.20, canvas.height * 0.45, canvas.width * 0.12, canvas.height * 0.22, -0.65, 0, Math.PI * 2);
    ctx.fill(); ctx.stroke();

    ctx.beginPath();
    ctx.ellipse(canvas.width * 0.38, canvas.height * 0.77, canvas.width * 0.14, canvas.height * 0.045, 0.08, 0, Math.PI * 2);
    ctx.fill(); ctx.stroke();

    ctx.beginPath();
    ctx.ellipse(canvas.width * 0.43, canvas.height * 0.46, canvas.width * 0.095, canvas.height * 0.12, 0.05, 0, Math.PI * 2);
    ctx.fill(); ctx.stroke();

    ctx.beginPath();
    ctx.ellipse(canvas.width * 0.58, canvas.height * 0.50, canvas.width * 0.05, canvas.height * 0.14, -0.2, 0, Math.PI * 2);
    ctx.fill(); ctx.stroke();

    ctx.beginPath();
    ctx.ellipse(canvas.width * 0.83, canvas.height * 0.65, canvas.width * 0.11, canvas.height * 0.15, 0.2, 0, Math.PI * 2);
    ctx.fill(); ctx.stroke();

    links.forEach(([i, j]) => {
      const n1 = nodes[i];
      const n2 = nodes[j];
      ctx.beginPath();
      ctx.moveTo(n1.x * canvas.width, n1.y * canvas.height);
      ctx.lineTo(n2.x * canvas.width, n2.y * canvas.height);
      ctx.strokeStyle = "rgba(0, 229, 255, 0.2)";
      ctx.setLineDash([3, 4]);
      ctx.stroke();
      ctx.setLineDash([]);
    });

    spawnPacket();
    for (let pIdx = packets.length - 1; pIdx >= 0; pIdx--) {
      const pkt = packets[pIdx];
      pkt.progress += pkt.speed;
      if (pkt.progress >= 1) {
        packets.splice(pIdx, 1);
        continue;
      }
      const nFrom = nodes[pkt.from];
      const nTo = nodes[pkt.to];
      const px = (nFrom.x + (nTo.x - nFrom.x) * pkt.progress) * canvas.width;
      const py = (nFrom.y + (nTo.y - nFrom.y) * pkt.progress) * canvas.height;

      ctx.beginPath();
      ctx.arc(px, py, 2.5, 0, Math.PI * 2);
      ctx.fillStyle = pkt.color;
      ctx.fill();
    }

    nodes.forEach(n => {
      const nx = n.x * canvas.width;
      const ny = n.y * canvas.height;
      let color = "#39ff14";
      if (n.status === "warn") color = "#ffcc00";
      if (n.status === "danger") color = "#ff3344";

      if (n.status !== "safe") {
        const ringRad = 8 + (Math.sin(pulse * 3) + 1) * 6;
        ctx.beginPath();
        ctx.arc(nx, ny, ringRad, 0, Math.PI * 2);
        ctx.strokeStyle = color;
        ctx.globalAlpha = 0.5 - (ringRad - 8) / 12 * 0.4;
        ctx.stroke();
        ctx.globalAlpha = 1;
      }

      ctx.beginPath();
      ctx.arc(nx, ny, 4.5, 0, Math.PI * 2);
      ctx.fillStyle = color;
      ctx.fill();

      ctx.font = '9px "Share Tech Mono"';
      ctx.fillStyle = "#e2e8f0";
      ctx.fillText(n.name, nx + 8, ny - 4);
    });

    requestAnimationFrame(draw);
  }
  draw();
}
/* 5. TACTICAL CYBER RADAR CANVAS */
function initRadar() {
  const canvas = document.getElementById("radarCanvas");
  if (!canvas) return;
  const ctx = canvas.getContext("2d");
  const cx = canvas.width / 2;
  const cy = canvas.height / 2;
  const radius = cx - 10;

  let angle = 0;
  const targets = [
    { dist: 0.35, angle: 0.8, color: "#39ff14", alpha: 0 },
    { dist: 0.65, angle: 2.1, color: "#ff3344", alpha: 0 },
    { dist: 0.82, angle: 3.9, color: "#ffcc00", alpha: 0 },
    { dist: 0.50, angle: 5.2, color: "#00e5ff", alpha: 0 }
  ];

  function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    angle = (angle + 0.025) % (Math.PI * 2);

    ctx.strokeStyle = "rgba(57, 255, 20, 0.25)";
    ctx.lineWidth = 1;
    for (let r = 1; r <= 4; r++) {
      ctx.beginPath();
      ctx.arc(cx, cy, (radius / 4) * r, 0, Math.PI * 2);
      ctx.stroke();
    }

    ctx.beginPath();
    ctx.moveTo(cx - radius, cy); ctx.lineTo(cx + radius, cy);
    ctx.moveTo(cx, cy - radius); ctx.lineTo(cx, cy + radius);
    ctx.stroke();

    const sweepGrad = ctx.createConicGradient(angle - Math.PI / 2, cx, cy);
    sweepGrad.addColorStop(0, "rgba(57, 255, 20, 0.35)");
    sweepGrad.addColorStop(0.12, "rgba(57, 255, 20, 0.0)");
    sweepGrad.addColorStop(1, "rgba(57, 255, 20, 0.0)");

    ctx.fillStyle = sweepGrad;
    ctx.beginPath();
    ctx.arc(cx, cy, radius, 0, Math.PI * 2);
    ctx.fill();

    const lx = cx + Math.cos(angle) * radius;
    const ly = cy + Math.sin(angle) * radius;
    ctx.beginPath();
    ctx.moveTo(cx, cy); ctx.lineTo(lx, ly);
    ctx.strokeStyle = "#39ff14";
    ctx.lineWidth = 1.5;
    ctx.stroke();

    targets.forEach(t => {
      const diff = (angle - t.angle + Math.PI * 2) % (Math.PI * 2);
      if (diff < 0.1) t.alpha = 1;
      else t.alpha = Math.max(0, t.alpha - 0.008);

      if (t.alpha > 0) {
        const tx = cx + Math.cos(t.angle) * (t.dist * radius);
        const ty = cy + Math.sin(t.angle) * (t.dist * radius);

        ctx.beginPath();
        ctx.arc(tx, ty, 3.5, 0, Math.PI * 2);
        ctx.fillStyle = t.color;
        ctx.globalAlpha = t.alpha;
        ctx.fill();
        ctx.globalAlpha = 1;
      }
    });

    requestAnimationFrame(draw);
  }
  draw();
}

/* 6. LIVE TRAFFIC CHART CANVAS */
function initTrafficChart() {
  const canvas = document.getElementById("trafficChart");
  if (!canvas) return;
  const ctx = canvas.getContext("2d");

  function resize() {
    canvas.width = canvas.parentElement.clientWidth - 32;
    canvas.height = 110;
  }
  resize();
  window.addEventListener("resize", resize);

  const maxPoints = 30;
  const inbound = Array.from({ length: maxPoints }, () => 40 + Math.random() * 25);
  const attacks = Array.from({ length: maxPoints }, () => 8 + Math.random() * 12);
  const blocked = Array.from({ length: maxPoints }, () => 7 + Math.random() * 11);

  setInterval(() => {
    inbound.shift(); inbound.push(40 + Math.random() * 35);
    attacks.shift(); attacks.push(Math.random() > 0.7 ? 22 + Math.random() * 15 : 6 + Math.random() * 8);
    blocked.shift(); blocked.push(attacks[attacks.length - 1] * 0.92);
  }, 1000);

  function drawSeries(data, color) {
    const step = canvas.width / (maxPoints - 1);
    ctx.beginPath();
    ctx.moveTo(0, canvas.height - (data[0] / 80) * canvas.height);
    for (let i = 1; i < data.length; i++) {
      ctx.lineTo(i * step, canvas.height - (data[i] / 80) * canvas.height);
    }
    ctx.strokeStyle = color;
    ctx.lineWidth = 1.8;
    ctx.stroke();
  }

  function render() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    drawSeries(inbound, "#00e5ff");
    drawSeries(attacks, "#cc0001");
    drawSeries(blocked, "#39ff14");
    requestAnimationFrame(render);
  }
  render();
}

/* 7. TIMELINE, STATUS & THREATS */
function initTimelineAndThreats() {
  const tlContainer = document.getElementById("incidentTimeline");
  const incidents = [
    { time: "15:28:14", type: "danger", desc: "<strong>Brute-force SSH attack</strong> terdeteksi pada gateway Kodam XVII/Cen dari IP 185.220.101.4" },
    { time: "15:26:02", type: "warn", desc: "<strong>Anomali port scan</strong> di Natuna Frontline Node. Firewall mengisolasi 42 paket." },
    { time: "15:23:45", type: "normal", desc: "<strong>Blockchain Konsensus Blok #48,271</strong> tervalidasi oleh 15 node Kodam." },
    { time: "15:19:10", type: "normal", desc: "<strong>Satelit CAKRAWALA-3A</strong> menyelesaikan orbit melintasi Selat Malaka." },
    { time: "15:15:33", type: "danger", desc: "<strong>Pola Malware Stux-Variant</strong> diblokir otomatis oleh AI Inference Engine." }
  ];

  if (tlContainer) {
    tlContainer.innerHTML = incidents.map(item => `
      <div class="timeline-item ${item.type}">
        <span class="tl-time">${item.time}</span>
        <div class="tl-desc">${item.desc}</div>
      </div>
    `).join("");
  }

  const statusContainer = document.getElementById("systemStatus");
  const sysItems = [
    { name: "SATELIT DATA LINK (SAR/IR)", val: "ONLINE 99.9%" },
    { name: "AI THREAT INFERENCE CORE", val: "AKTIF (4ms)" },
    { name: "BLOCKCHAIN TACTICAL CONSENSUS", val: "SYNCED (100%)" },
    { name: "EDGE FIREWALL KODAM I-XVIII", val: "TERHUBUNG" },
    { name: "QUANTUM CRYPTO ACCELERATOR", val: "SECURE" }
  ];

  if (statusContainer) {
    statusContainer.innerHTML = sysItems.map(s => `
      <div class="status-item">
        <span class="status-name">${s.name}</span>
        <span class="status-val">${s.val}</span>
      </div>
    `).join("");
  }

  const threatContainer = document.getElementById("threatList");
  const threatData = [
    { name: "APT-29 LATERAL MOVEMENT", score: "94/100", meta: "Sasaran: Database Taktis Kodam VI | Status: Diblokir" },
    { name: "SYN-FLOOD DDOS ATTACK", score: "82/100", meta: "Sasaran: Relay Server Tarakan | Status: Mitigasi AI" },
    { name: "ZERO-DAY EXPLOIT ATTEMPT", score: "76/100", meta: "Sasaran: Radio Gateway UHF | Status: Karantina" }
  ];

  if (threatContainer) {
    threatContainer.innerHTML = threatData.map(t => `
      <div class="threat-item">
        <div class="threat-top">
          <span class="threat-name">${t.name}</span>
          <span class="threat-score">${t.score}</span>
        </div>
        <div class="threat-meta">${t.meta}</div>
      </div>
    `).join("");
  }
}

/* 8. INTERACTIVE COMMANDER CONSOLE */
function initConsole() {
  const output = document.getElementById("consoleOutput");
  const input = document.getElementById("consoleInput");
  if (!output || !input) return;

  function appendLine(text, cls = "") {
    const div = document.createElement("div");
    div.className = `console-line ${cls}`;
    div.textContent = text;
    output.appendChild(div);
    output.scrollTop = output.scrollHeight;
  }

  appendLine("SI-CAKRAWALA [Kernel v4.7.2-TNI-AD]", "sys");
  appendLine("Otentikasi: KOL. RIZKY PRATAMA - CLEARANCE TOP SECRET", "sys");
  appendLine("Ketik 'help' untuk melihat daftar perintah taktis.", "");

  input.addEventListener("keydown", (e) => {
    if (e.key === "Enter") {
      const cmd = input.value.trim().toLowerCase();
      if (!cmd) return;
      appendLine(`ROOT@SICAKRAWALA:~$ ${input.value}`, "");
      input.value = "";

      switch (cmd) {
        case "help":
          appendLine("PERINTAH TERSEDIA: status, scan, satellite, ai, blockchain, defend, clear");
          break;
        case "status":
          appendLine("[OK] SATSIBER Gateway: NORMAL | Enkripsi: AES-256-GCM", "sys");
          appendLine("[OK] Node Aktif: 1,247/1,250 | Latensi Rata-rata: 12ms", "sys");
          break;
        case "scan":
          appendLine("Memulai deep vulnerability scan seluruh sektor...", "sys");
          setTimeout(() => appendLine("Scan selesai: 15 Kodam terhubung aman.", "sys"), 800);
          break;
        case "satellite":
          appendLine("CAKRAWALA-3A: ALT 520km SAR | STATUS: OPTIMAL LOCK", "sys");
          break;
        case "ai":
          appendLine("AI Core: Transformer v9.4 | Akurasi: 97.3% | Waktu Respon: 4ms", "sys");
          break;
        case "blockchain":
          appendLine("Ledger Blok #48,271 | Hash: 0x9f4a8b...7d21 | Konsensus BFT 100%", "sys");
          break;
        case "defend":
          appendLine("PERINGATAN: PROTOKOL PERISAI CYBER DIAKTIFKAN!", "err");
          break;
        case "clear":
          output.innerHTML = "";
          break;
        default:
          appendLine(`Perintah tidak dikenal: '${cmd}'. Ketik 'help'.`, "err");
      }
    }
  });
}
/* 9. SATELLITE CANVAS VIEW */
function initSatelliteView() {
  const canvas = document.getElementById("satCanvas");
  if (!canvas) return;
  const ctx = canvas.getContext("2d");

  function resize() {
    canvas.width = canvas.parentElement.clientWidth;
    canvas.height = canvas.parentElement.clientHeight;
  }
  resize();
  window.addEventListener("resize", resize);

  let scanLineY = 0;
  let targetAngle = 0;

  function render() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    const cx = canvas.width / 2;
    const cy = canvas.height / 2;

    const earthRadius = Math.min(canvas.width, canvas.height) * 0.38;
    const earthGrad = ctx.createRadialGradient(cx - earthRadius * 0.3, cy - earthRadius * 0.3, earthRadius * 0.1, cx, cy, earthRadius);
    earthGrad.addColorStop(0, "#0e2b19");
    earthGrad.addColorStop(0.5, "#06160b");
    earthGrad.addColorStop(0.9, "#020703");
    earthGrad.addColorStop(1, "#000000");

    ctx.beginPath();
    ctx.arc(cx, cy, earthRadius, 0, Math.PI * 2);
    ctx.fillStyle = earthGrad;
    ctx.fill();
    ctx.strokeStyle = "#00e5ff";
    ctx.lineWidth = 1;
    ctx.stroke();

    ctx.beginPath();
    ctx.arc(cx, cy, earthRadius + 4, 0, Math.PI * 2);
    ctx.strokeStyle = "rgba(0, 229, 255, 0.25)";
    ctx.lineWidth = 3;
    ctx.stroke();

    scanLineY = (scanLineY + 2) % (canvas.height);
    ctx.beginPath();
    ctx.moveTo(0, scanLineY);
    ctx.lineTo(canvas.width, scanLineY);
    ctx.strokeStyle = "rgba(204, 0, 1, 0.45)";
    ctx.lineWidth = 1.5;
    ctx.stroke();

    targetAngle += 0.01;
    const tBoxX = cx + Math.cos(targetAngle) * (earthRadius * 0.55);
    const tBoxY = cy + Math.sin(targetAngle) * (earthRadius * 0.4);

    ctx.strokeStyle = "#ff3344";
    ctx.strokeRect(tBoxX - 16, tBoxY - 16, 32, 32);
    ctx.font = '10px "Share Tech Mono"';
    ctx.fillStyle = "#ff3344";
    ctx.fillText("TARGET LOCK", tBoxX + 20, tBoxY);
    ctx.fillText("05°32'N 095°19'E", tBoxX + 20, tBoxY + 12);

    requestAnimationFrame(render);
  }
  render();

  const satList = document.getElementById("satelliteList");
  const sats = [
    { name: "CAKRAWALA-3A", type: "SAR LEO", alt: "520 km", status: "ONLINE" },
    { name: "CAKRAWALA-2B", type: "SIGINT GEO", alt: "35,786 km", status: "ONLINE" },
    { name: "CAKRAWALA-1C", type: "OPTICAL LEO", alt: "610 km", status: "ONLINE" },
    { name: "MERAH-PUTIH-2", type: "SATCOM TELKOM", alt: "36,000 km", status: "ONLINE" },
    { name: "LAPAN-A3 TAKTIS", type: "SURVEILLANCE", alt: "505 km", status: "ONLINE" }
  ];

  if (satList) {
    satList.innerHTML = sats.map((s, idx) => `
      <div class="sat-item ${idx === 0 ? "active" : ""}">
        <div>
          <div style="font-weight:700; color:#fff;">${s.name}</div>
          <div style="font-size:0.65rem; color:#8fa89b;">${s.type} &bull; ${s.alt}</div>
        </div>
        <span class="badge badge-live">${s.status}</span>
      </div>
    `).join("");
  }
}

/* 10. ORBIT TRACKER MINI CANVAS */
function initOrbitTracker() {
  const canvas = document.getElementById("orbitCanvas");
  if (!canvas) return;
  const ctx = canvas.getContext("2d");
  const cx = canvas.width / 2;
  const cy = canvas.height / 2;
  let t = 0;

  function render() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    t += 0.02;

    ctx.beginPath();
    ctx.arc(cx, cy, 32, 0, Math.PI * 2);
    ctx.fillStyle = "#0d2b1a";
    ctx.fill();
    ctx.strokeStyle = "#39ff14";
    ctx.stroke();

    ctx.beginPath();
    ctx.ellipse(cx, cy, 90, 45, 0.8, 0, Math.PI * 2);
    ctx.strokeStyle = "rgba(0, 229, 255, 0.4)";
    ctx.stroke();

    const s1x = cx + Math.cos(t) * 90 * Math.cos(0.8) - Math.sin(t) * 45 * Math.sin(0.8);
    const s1y = cy + Math.cos(t) * 90 * Math.sin(0.8) + Math.sin(t) * 45 * Math.cos(0.8);
    ctx.beginPath();
    ctx.arc(s1x, s1y, 4, 0, Math.PI * 2);
    ctx.fillStyle = "#00e5ff";
    ctx.fill();

    requestAnimationFrame(render);
  }
  render();
}

/* 11. AI ENGINE NEURAL NETWORK CANVAS */
function initAIEngine() {
  const canvas = document.getElementById("aiCanvas");
  if (!canvas) return;
  const ctx = canvas.getContext("2d");

  function resize() {
    canvas.width = canvas.parentElement.clientWidth;
    canvas.height = canvas.parentElement.clientHeight;
  }
  resize();
  window.addEventListener("resize", resize);

  const layers = [4, 7, 9, 7, 3];
  let nodes = [];

  function buildNetwork() {
    nodes = [];
    const layerSpacing = canvas.width / (layers.length + 1);
    layers.forEach((count, lIdx) => {
      const x = layerSpacing * (lIdx + 1);
      const nodeSpacing = (canvas.height - 80) / (count + 1);
      for (let i = 0; i < count; i++) {
        nodes.push({ layer: lIdx, x, y: 40 + nodeSpacing * (i + 1), activation: Math.random() });
      }
    });
  }
  buildNetwork();
  window.addEventListener("resize", buildNetwork);

  function render() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    nodes.forEach(n1 => {
      nodes.forEach(n2 => {
        if (n2.layer === n1.layer + 1) {
          ctx.beginPath();
          ctx.moveTo(n1.x, n1.y);
          ctx.lineTo(n2.x, n2.y);
          ctx.strokeStyle = "rgba(0, 229, 255, 0.15)";
          ctx.stroke();
        }
      });
    });

    nodes.forEach(n => {
      ctx.beginPath();
      ctx.arc(n.x, n.y, 4, 0, Math.PI * 2);
      ctx.fillStyle = n.layer === 0 ? "#39ff14" : (n.layer === layers.length - 1 ? "#ff3344" : "#00e5ff");
      ctx.fill();
    });
    requestAnimationFrame(render);
  }
  render();

  const threatAnalysis = document.getElementById("aiThreatAnalysis");
  const vectors = [
    { name: "Anomali DNS Taktis", val: 78, col: "#ff3344" },
    { name: "Brute-force SSH Gateway", val: 92, col: "#ff4d4d" },
    { name: "Protokol Routing Hijack", val: 34, col: "#ffcc00" },
    { name: "Exfiltrasi Data Satelit", val: 18, col: "#39ff14" }
  ];

  if (threatAnalysis) {
    threatAnalysis.innerHTML = vectors.map(v => `
      <div class="ai-vector-item">
        <div style="display:flex; justify-content:space-between;">
          <span>${v.name}</span>
          <strong style="color:${v.col};">${v.val}%</strong>
        </div>
        <div class="ai-vector-bar-wrap">
          <div class="ai-vector-bar" style="width:${v.val}%; background:${v.col};"></div>
        </div>
      </div>
    `).join("");
  }

  const aiLog = document.getElementById("aiLog");
  const logEntries = [
    "[15:28:10] Inferensi: Pola APT-29 terdeteksi pada 10.6.9.14 (Probabilitas 94.2%)",
    "[15:27:55] Aksi Otomatis: Rule firewall diterapkan di Kodam XVII/Cen dalam 1.2ms",
    "[15:26:40] Update Bobot: Retraining model transfer learning selesai (Akurasi +0.4%)"
  ];
  if (aiLog) aiLog.innerHTML = logEntries.map(e => `<div>${e}</div>`).join("");

  const modelList = document.getElementById("modelList");
  const models = [
    { name: "CAKRAWALA-TRANSFORMER-v9", status: "AKTIF", acc: "98.4%" },
    { name: "GRAPH-NEURAL-APT-HUNTER", status: "AKTIF", acc: "97.1%" }
  ];
  if (modelList) {
    modelList.innerHTML = models.map(m => `
      <div style="display:flex; justify-content:space-between; font-size:0.75rem; padding:6px; background:rgba(0,0,0,0.3); border-radius:4px;">
        <span>${m.name}</span>
        <span style="color:#39ff14;">${m.status} (${m.acc})</span>
      </div>
    `).join("");
  }
}

/* 12. PREDICTIVE CHART CANVAS */
function initPredictChart() {
  const canvas = document.getElementById("predictChart");
  if (!canvas) return;
  const ctx = canvas.getContext("2d");

  function resize() {
    canvas.width = canvas.parentElement.clientWidth - 32;
    canvas.height = 120;
  }
  resize();
  window.addEventListener("resize", resize);

  const forecast = [25, 18, 42, 78, 92, 64, 30];
  const step = canvas.width / (forecast.length - 1);

  ctx.beginPath();
  ctx.moveTo(0, canvas.height - (forecast[0] / 100) * (canvas.height - 20) - 10);
  for (let i = 1; i < forecast.length; i++) {
    ctx.lineTo(i * step, canvas.height - (forecast[i] / 100) * (canvas.height - 20) - 10);
  }
  ctx.strokeStyle = "#ff3344";
  ctx.lineWidth = 2;
  ctx.stroke();
}
/* 13. BLOCKCHAIN TAKTIS VISUALIZER */
function initBlockchainVisualizer() {
  const canvas = document.getElementById("blockchainCanvas");
  if (!canvas) return;
  const ctx = canvas.getContext("2d");

  function resize() {
    canvas.width = canvas.parentElement.clientWidth;
    canvas.height = canvas.parentElement.clientHeight - 46;
  }
  resize();
  window.addEventListener("resize", resize);

  let offset = 0;
  const blocks = [];
  for (let i = 48268; i <= 48275; i++) {
    blocks.push({
      height: i,
      hash: "0x" + Math.random().toString(16).substr(2, 8) + "...",
      txs: Math.floor(Math.random() * 80 + 20)
    });
  }

  function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    offset += 0.5;
    if (offset >= 160) {
      offset = 0;
      blocks.shift();
      const last = blocks[blocks.length - 1].height;
      blocks.push({
        height: last + 1,
        hash: "0x" + Math.random().toString(16).substr(2, 8) + "...",
        txs: Math.floor(Math.random() * 80 + 20)
      });
    }

    const startX = 20 - offset;
    blocks.forEach((b, idx) => {
      const bx = startX + idx * 160;
      const by = canvas.height / 2 - 45;

      if (idx < blocks.length - 1) {
        ctx.beginPath();
        ctx.moveTo(bx + 120, by + 45);
        ctx.lineTo(bx + 160, by + 45);
        ctx.strokeStyle = "#00e5ff";
        ctx.lineWidth = 2;
        ctx.stroke();
      }

      ctx.fillStyle = "rgba(10, 24, 16, 0.85)";
      ctx.strokeStyle = "#d4af37";
      ctx.lineWidth = 1.5;
      ctx.fillRect(bx, by, 120, 90);
      ctx.strokeRect(bx, by, 120, 90);

      ctx.font = '10px "Orbitron"';
      ctx.fillStyle = "#39ff14";
      ctx.fillText(`BLOK #${b.height}`, bx + 10, by + 22);

      ctx.font = '9px "Share Tech Mono"';
      ctx.fillStyle = "#a0aec0";
      ctx.fillText(`HASH: ${b.hash}`, bx + 10, by + 42);
      ctx.fillText(`TX: ${b.txs} Taktis`, bx + 10, by + 60);
      ctx.fillText(`KONSENSUS: BFT`, bx + 10, by + 78);
    });

    requestAnimationFrame(draw);
  }
  draw();

  const ledgerEl = document.getElementById("bcLedger");
  const ledgerEntries = [
    { hash: "0x3f4a...9b12", event: "PERINTAH TAKTIS DISIARKAN KE KODAM I/BB", sig: "VALIDATED" },
    { hash: "0x88c1...1e40", event: "TELEMETRI SATELLITE 3A DIENKRIPSI KE LEDGER", sig: "VALIDATED" },
    { hash: "0xaa90...7d33", event: "LOG INSIDEN SIBER TARAKAN TERTANDATANGAN", sig: "VALIDATED" }
  ];
  if (ledgerEl) {
    ledgerEl.innerHTML = ledgerEntries.map(e => `
      <div class="ledger-item">
        <span>${e.hash} &bull; ${e.event}</span>
        <strong style="color:#39ff14;">${e.sig}</strong>
      </div>
    `).join("");
  }

  const cryptoEl = document.getElementById("cryptoList");
  const cryptos = [
    { name: "KONSENSUS ALGORITMA", val: "PBFT Militer (Byzantine Fault Tolerant)" },
    { name: "ENKRIPSI DATA-IN-TRANSIT", val: "Kyber-1024 Quantum-Resistant" },
    { name: "DIGITAL SIGNATURE", val: "Dilithium-5 Post-Quantum" }
  ];
  if (cryptoEl) {
    cryptoEl.innerHTML = cryptos.map(c => `
      <div style="display:flex; justify-content:space-between; font-size:0.75rem; padding:6px; background:rgba(0,0,0,0.3); border-radius:4px;">
        <span style="color:#8fa89b;">${c.name}</span>
        <strong style="color:#00e5ff;">${c.val}</strong>
      </div>
    `).join("");
  }
}

/* 14. TELEMETRY GAUGES & CHARTS */
function initTelemetryGauges() {
  const gaugesEl = document.getElementById("teleGauges");
  if (!gaugesEl) return;
  const gauges = [
    { name: "CPU CLUSTER", val: 42, unit: "%", col: "#39ff14" },
    { name: "GPU NEURAL", val: 78, unit: "%", col: "#00e5ff" },
    { name: "RAM TERENKRIPSI", val: 64, unit: "%", col: "#ffcc00" },
    { name: "SATCOM BANDWIDTH", val: 89, unit: "%", col: "#39ff14" }
  ];

  gaugesEl.innerHTML = gauges.map(g => `
    <div style="background:rgba(0,0,0,0.3); border:1px solid rgba(255,255,255,0.08); border-radius:8px; padding:12px; text-align:center;">
      <div style="font-size:0.65rem; color:#8fa89b; font-family:'Orbitron';">${g.name}</div>
      <div style="font-size:1.8rem; font-weight:800; font-family:'Share Tech Mono'; color:${g.col}; margin:6px 0;">${g.val}${g.unit}</div>
      <div style="height:4px; background:rgba(255,255,255,0.1); border-radius:2px; overflow:hidden;">
        <div style="height:100%; width:${g.val}%; background:${g.col};"></div>
      </div>
    </div>
  `).join("");
}

function initTelemetryCharts() {
  ["cpuChart", "memChart", "bwChart"].forEach((id, idx) => {
    const canvas = document.getElementById(id);
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    canvas.width = canvas.parentElement.clientWidth;
    canvas.height = 70;
    const data = Array.from({ length: 40 }, () => 20 + Math.random() * 40);
    const colors = ["#39ff14", "#00e5ff", "#d4af37"];

    function draw() {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      const step = canvas.width / (data.length - 1);
      ctx.beginPath();
      ctx.moveTo(0, canvas.height - (data[0] / 100) * canvas.height);
      for (let i = 1; i < data.length; i++) {
        ctx.lineTo(i * step, canvas.height - (data[i] / 100) * canvas.height);
      }
      ctx.strokeStyle = colors[idx];
      ctx.lineWidth = 1.8;
      ctx.stroke();
    }
    draw();
    setInterval(() => {
      data.shift(); data.push(30 + Math.random() * 50); draw();
    }, 1200);
  });

  const sensorsEl = document.getElementById("sensorList");
  const sensors = [
    { name: "SHELTER BUNKER SERVER", val: "NORMAL" },
    { name: "GENSET TAKTIS UPS-1", val: "NORMAL" },
    { name: "UHF/VHF JAMMING DETECTOR", val: "SECURE" }
  ];
  if (sensorsEl) {
    sensorsEl.innerHTML = sensors.map(s => `
      <div style="display:flex; justify-content:space-between; font-size:0.75rem; padding:6px; background:rgba(0,0,0,0.3); border-radius:4px;">
        <span>${s.name}</span>
        <strong style="color:#39ff14;">${s.val}</strong>
      </div>
    `).join("");
  }
}

/* 15. FIELD OPERATIONS MAP & FEEDS */
function initOpsMap() {
  const canvas = document.getElementById("opsMapCanvas");
  if (!canvas) return;
  const ctx = canvas.getContext("2d");

  function resize() {
    canvas.width = canvas.parentElement.clientWidth;
    canvas.height = canvas.parentElement.clientHeight - 46;
  }
  resize();
  window.addEventListener("resize", resize);

  const units = [
    { name: "SATGAS SIBER-01 (NATUNA)", x: 0.32, y: 0.35, status: "PATROLI" },
    { name: "SATGAS SIBER-02 (TARAKAN)", x: 0.55, y: 0.40, status: "INTERVENSI" },
    { name: "SATGAS SIBER-03 (PAPUA)", x: 0.85, y: 0.65, status: "SIAGA 1" }
  ];

  function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    units.forEach(u => {
      const ux = u.x * canvas.width;
      const uy = u.y * canvas.height;

      ctx.beginPath();
      ctx.arc(ux, uy, 10, 0, Math.PI * 2);
      ctx.strokeStyle = "rgba(57, 255, 20, 0.5)";
      ctx.stroke();

      ctx.beginPath();
      ctx.arc(ux, uy, 4, 0, Math.PI * 2);
      ctx.fillStyle = "#39ff14";
      ctx.fill();

      ctx.font = '10px "Share Tech Mono"';
      ctx.fillStyle = "#fff";
      ctx.fillText(u.name, ux + 12, uy);
    });
    requestAnimationFrame(draw);
  }
  draw();
}

function initOpsFeeds() {
  const unitList = document.getElementById("unitList");
  const units = [
    { code: "UNIT-ALPHA-01", pers: "6 Personel", loc: "Perbatasan Natuna", state: "SIBER PATROL" },
    { code: "UNIT-BRAVO-02", pers: "4 Personel", loc: "Bunker Tarakan", state: "HARDENING" }
  ];
  if (unitList) {
    unitList.innerHTML = units.map(u => `
      <div class="unit-item">
        <div style="font-weight:700; color:#00e5ff;">${u.code}</div>
        <div style="font-size:0.7rem; color:#8fa89b;">${u.pers} &bull; ${u.loc}</div>
      </div>
    `).join("");
  }

  const missionList = document.getElementById("missionList");
  const missions = [
    { title: "OPERASI CAKRAWALA-DEFENSE 2026", prog: "74%" },
    { title: "OPERASI PERISAI SELAT MALAKA", prog: "91%" }
  ];
  if (missionList) {
    missionList.innerHTML = missions.map(m => `
      <div class="mission-item">
        <div style="font-weight:700; color:#d4af37;">${m.title}</div>
        <div style="font-size:0.68rem; color:#39ff14;">PROGRES: ${m.prog}</div>
      </div>
    `).join("");
  }

  const commsFeed = document.getElementById("commsFeed");
  const comms = [
    { sender: "SATGAS-01", text: "Koneksi uplink satelit LEO stabil. Sinyal SAR bebas noise." },
    { sender: "PUSKODAL-AD", text: "Seluruh komando: Tingkatkan status waspada ke level ELEVATED." }
  ];
  if (commsFeed) {
    commsFeed.innerHTML = comms.map(c => `
      <div class="comms-msg">
        <strong style="color:#00e5ff;">[${c.sender}]:</strong> ${c.text}
      </div>
    `).join("");
  }
}
