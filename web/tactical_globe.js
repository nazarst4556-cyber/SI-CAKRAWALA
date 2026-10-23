/**
 * SI-CAKRAWALA Tactical 3D WebGL Globe & Satellite Simulator
 * Realistic Earth with high-res texture, atmospheric glow, Natuna SAR radar lock,
 * 4 inclined satellite orbits, Hierarchical Geospatial Indexing (LOD labels),
 * and Smooth Fly-To Navigation.
 */

(function () {
  let scene, camera, renderer;
  let globeMesh, atmosphereMesh;
  let orbitsGroup, satellitesGroup, radarBeamGroup;
  let labelsGroup, natunaGroup, targetBeaconGroup;
  let animId;

  let isDragging = false;
  let prevMousePos = { x: 0, y: 0 };
  let targetRotation = { x: 0.12, y: -1.88 }; // Focused on Indonesia / Natuna
  let currentRotation = { x: 0.12, y: -1.88 };
  let targetCameraZ = 16.5;
  let autoRotateSpeed = 0.0012;
  let speedMultiplier = 1.0;
  let showOrbits = true;
  let showFootprint = true;
  let showLabels = true;

  // ── Hierarchical Geospatial Dataset (Continents, Oceans, Countries, Strategic Sectors) ──
  const geospatialIndex = [
    // ── MACRO LEVEL: Continents (Gold/Amber Badges) ──
    { name: "ASIA", lat: 34.0, lon: 100.0, tier: "macro", color: "#FFD166", border: "#D4AF37", icon: "🌐" },
    { name: "EROPA", lat: 54.0, lon: 18.0, tier: "macro", color: "#FFD166", border: "#D4AF37", icon: "🌐" },
    { name: "AFRIKA", lat: 2.0, lon: 20.0, tier: "macro", color: "#FFD166", border: "#D4AF37", icon: "🌐" },
    { name: "AUSTRALIA & OSEANIA", lat: -25.0, lon: 135.0, tier: "macro", color: "#FFD166", border: "#D4AF37", icon: "🌐" },
    { name: "AMERIKA UTARA", lat: 45.0, lon: -100.0, tier: "macro", color: "#FFD166", border: "#D4AF37", icon: "🌐" },
    { name: "AMERIKA SELATAN", lat: -15.0, lon: -60.0, tier: "macro", color: "#FFD166", border: "#D4AF37", icon: "🌐" },
    { name: "ANTARTIKA", lat: -80.0, lon: 0.0, tier: "macro", color: "#E2E8F0", border: "#94A3B8", icon: "❄️" },

    // ── MACRO/REGIONAL LEVEL: Oceans & Major Seas (Cyan/Deep Blue Badges) ──
    { name: "SAMUDRA PASIFIK", lat: 5.0, lon: 165.0, tier: "macro", color: "#00C6FF", border: "#0072FF", icon: "🌊" },
    { name: "SAMUDRA HINDIA", lat: -15.0, lon: 80.0, tier: "macro", color: "#00C6FF", border: "#0072FF", icon: "🌊" },
    { name: "SAMUDRA ATLANTIK", lat: 18.0, lon: -35.0, tier: "macro", color: "#00C6FF", border: "#0072FF", icon: "🌊" },
    { name: "SAMUDRA ARKTIK", lat: 82.0, lon: 0.0, tier: "macro", color: "#38BDF8", border: "#0284C7", icon: "🌊" },
    { name: "SAMUDRA ANTARTIKA", lat: -65.0, lon: 90.0, tier: "macro", color: "#38BDF8", border: "#0284C7", icon: "🌊" },

    // ── REGIONAL LEVEL: Major Seas & Straits (Cyan Marine Badges) ──
    { name: "LAUT CINA SELATAN", lat: 13.0, lon: 114.0, tier: "regional", color: "#38BDF8", border: "#00C6FF", icon: "⚓" },
    { name: "LAUT JAWA", lat: -5.5, lon: 112.0, tier: "regional", color: "#38BDF8", border: "#00C6FF", icon: "⚓" },
    { name: "LAUT BANDA", lat: -5.0, lon: 127.5, tier: "regional", color: "#38BDF8", border: "#00C6FF", icon: "⚓" },
    { name: "SELAT MALAKA", lat: 2.8, lon: 101.5, tier: "regional", color: "#38BDF8", border: "#00C6FF", icon: "⚓" },
    { name: "SELAT MAKASSAR (ALKI II)", lat: -1.5, lon: 118.5, tier: "regional", color: "#38BDF8", border: "#00C6FF", icon: "⚓" },

    // ── REGIONAL LEVEL: Sovereign Countries & Capitals (Emerald Badges) ──
    { name: "INDONESIA [JAKARTA]", lat: -6.2, lon: 106.8, tier: "regional", color: "#1CB96B", border: "#40916C", icon: "🇮🇩" },
    { name: "MALAYSIA [KUALA LUMPUR]", lat: 3.1, lon: 101.7, tier: "regional", color: "#4ADE80", border: "#22C55E", icon: "📍" },
    { name: "SINGAPURA", lat: 1.35, lon: 103.8, tier: "regional", color: "#4ADE80", border: "#22C55E", icon: "📍" },
    { name: "FILIPINA [MANILA]", lat: 14.6, lon: 121.0, tier: "regional", color: "#4ADE80", border: "#22C55E", icon: "📍" },
    { name: "VIETNAM [HANOI]", lat: 21.0, lon: 105.8, tier: "regional", color: "#4ADE80", border: "#22C55E", icon: "📍" },
    { name: "THAILAND [BANGKOK]", lat: 13.7, lon: 100.5, tier: "regional", color: "#4ADE80", border: "#22C55E", icon: "📍" },
    { name: "BRUNEI [B.S.B]", lat: 4.9, lon: 114.9, tier: "regional", color: "#4ADE80", border: "#22C55E", icon: "📍" },
    { name: "AUSTRALIA [CANBERRA]", lat: -35.3, lon: 149.1, tier: "regional", color: "#4ADE80", border: "#22C55E", icon: "📍" },
    { name: "TIONGKOK [BEIJING]", lat: 39.9, lon: 116.4, tier: "regional", color: "#4ADE80", border: "#22C55E", icon: "📍" },
    { name: "JEPANG [TOKYO]", lat: 35.7, lon: 139.7, tier: "regional", color: "#4ADE80", border: "#22C55E", icon: "📍" },
    { name: "INDIA [NEW DELHI]", lat: 28.6, lon: 77.2, tier: "regional", color: "#4ADE80", border: "#22C55E", icon: "📍" },

    // ── MICRO LEVEL: Indonesian Strategic Defense Sectors & Key Bases (Red/Cyan Glowing Badges) ──
    { name: "KEP. NATUNA (PAMTAS UTARA)", lat: 3.9, lon: 108.3, tier: "micro", color: "#FF2A37", border: "#E8001A", icon: "🛡️" },
    { name: "IKN NUSANTARA (PUSAT C2)", lat: -0.97, lon: 116.7, tier: "micro", color: "#00F0FF", border: "#0072FF", icon: "⭐" },
    { name: "BLOK AMBALAT (SEKTOR LAUT)", lat: 4.2, lon: 118.5, tier: "micro", color: "#FF2A37", border: "#E8001A", icon: "🎯" },
    { name: "SABANG (POS ALFA TITIK NOL)", lat: 5.9, lon: 95.3, tier: "micro", color: "#FF8F00", border: "#EA580C", icon: "📍" },
    { name: "MERAUKE (SEKTOR DELTA)", lat: -8.5, lon: 140.4, tier: "micro", color: "#FF8F00", border: "#EA580C", icon: "📍" },
    { name: "BIAK NUMFOR (PANGKALAN UDARA)", lat: -1.0, lon: 136.0, tier: "micro", color: "#38BDF8", border: "#0284C7", icon: "✈️" },
    { name: "MABES SATBER AD (JAKARTA)", lat: -6.2, lon: 106.85, tier: "micro", color: "#E8001A", border: "#991B1B", icon: "🏛️" },
    { name: "TARAKAN (KODAM VI SEKTOR UTARA)", lat: 3.3, lon: 117.6, tier: "micro", color: "#FF8F00", border: "#EA580C", icon: "🛡️" },
    { name: "BATAM (HUB SIBER KABEL LAUT)", lat: 1.1, lon: 104.0, tier: "micro", color: "#00F0FF", border: "#0072FF", icon: "📡" },
  ];

  const satellitesData = [
    {
      name: "CAKRAWALA-3A",
      type: "SAR LEO-520",
      radiusA: 6.2,
      radiusB: 4.8,
      tiltX: 1.68, // ~97.4 deg polar sweep
      tiltZ: 0.45,
      speed: 0.022,
      color: 0xE8001A,
      size: 0.22,
      progress: 0.15
    },
    {
      name: "MERAH-PUTIH-2",
      type: "SATCOM C/Ku",
      radiusA: 8.8,
      radiusB: 8.8,
      tiltX: 0.08, // Equatorial GEO
      tiltZ: 0.0,
      speed: 0.008,
      color: 0xFFD166,
      size: 0.26,
      progress: 0.45
    },
    {
      name: "CAKRAWALA-2B",
      type: "SIGINT GEO",
      radiusA: 7.8,
      radiusB: 7.0,
      tiltX: 0.42,
      tiltZ: 0.85,
      speed: 0.012,
      color: 0x00F0FF,
      size: 0.24,
      progress: 0.75
    },
    {
      name: "CAKRAWALA-1C",
      type: "OPTICAL LEO",
      radiusA: 6.6,
      radiusB: 5.4,
      tiltX: -0.95,
      tiltZ: -0.35,
      speed: 0.018,
      color: 0x1CB96B,
      size: 0.20,
      progress: 0.90
    }
  ];

  function latLonToVector3(lat, lon, radius) {
    const phi = (90 - lat) * (Math.PI / 180);
    const theta = (lon + 180) * (Math.PI / 180);
    const x = -(radius * Math.sin(phi) * Math.cos(theta));
    const z = radius * Math.sin(phi) * Math.sin(theta);
    const y = radius * Math.cos(phi);
    return new THREE.Vector3(x, y, z);
  }

  // Create crisp tactical badge texture on a canvas
  function createLabelTexture(item) {
    const canvas = document.createElement('canvas');
    canvas.width = 380;
    canvas.height = 90;
    const ctx = canvas.getContext('2d');

    // Rounded Box
    const r = 10;
    const x = 6, y = 6, w = 368, h = 78;
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.lineTo(x + w - r, y);
    ctx.quadraticCurveTo(x + w, y, x + w, y + r);
    ctx.lineTo(x + w, y + h - r);
    ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
    ctx.lineTo(x + r, y + h);
    ctx.quadraticCurveTo(x, y + h, x, y + h - r);
    ctx.lineTo(x, y + r);
    ctx.quadraticCurveTo(x, y, x + r, y);
    ctx.closePath();

    ctx.fillStyle = "rgba(10, 15, 26, 0.88)";
    ctx.fill();

    ctx.strokeStyle = item.border || item.color;
    ctx.lineWidth = 3;
    ctx.stroke();

    // Dot indicator
    ctx.beginPath();
    ctx.arc(28, 45, 9, 0, Math.PI * 2);
    ctx.fillStyle = item.color;
    ctx.fill();

    // Glow on dot
    ctx.strokeStyle = "rgba(255, 255, 255, 0.7)";
    ctx.lineWidth = 2;
    ctx.stroke();

    // Text Label
    ctx.font = "bold 26px 'Courier New', monospace, sans-serif";
    ctx.fillStyle = item.color;
    ctx.fillText(item.name, 48, 52);

    const texture = new THREE.CanvasTexture(canvas);
    texture.minFilter = THREE.LinearFilter;
    texture.magFilter = THREE.LinearFilter;
    return texture;
  }

  function init(container) {
    if (!container || !window.THREE) return;

    while (container.firstChild) {
      container.removeChild(container.firstChild);
    }

    const width = container.clientWidth || 800;
    const height = container.clientHeight || 540;

    scene = new THREE.Scene();

    camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 1000);
    camera.position.z = 16.5;

    renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, powerPreference: "high-performance" });
    renderer.setSize(width, height);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.2;
    container.appendChild(renderer.domElement);

    // 1. Lighting
    const ambientLight = new THREE.AmbientLight(0x0a192f, 1.4);
    scene.add(ambientLight);

    const sunLight = new THREE.DirectionalLight(0xffffff, 2.2);
    sunLight.position.set(15, 10, 12);
    scene.add(sunLight);

    const cyanRimLight = new THREE.DirectionalLight(0x00f0ff, 1.8);
    cyanRimLight.position.set(-15, -8, -10);
    scene.add(cyanRimLight);

    // 2. Stars Background
    createStarfield();

    // 3. Earth Globe Sphere with Real Texture
    const textureLoader = new THREE.TextureLoader();
    const earthGeo = new THREE.SphereGeometry(4.2, 64, 64);

    const earthTexture = textureLoader.load(
      'textures/earth_atmos.jpg',
      function () { renderer.render(scene, camera); }
    );
    earthTexture.anisotropy = 8;

    const earthMat = new THREE.MeshPhongMaterial({
      map: earthTexture,
      bumpScale: 0.05,
      specular: new THREE.Color(0x184a75),
      shininess: 18,
      color: 0x90c5ff
    });

    globeMesh = new THREE.Mesh(earthGeo, earthMat);
    scene.add(globeMesh);

    // 4. Atmospheric Fresnel Glow Outer Shell
    const atmoGeo = new THREE.SphereGeometry(4.45, 64, 64);
    const atmoMat = new THREE.ShaderMaterial({
      vertexShader: `
        varying vec3 vNormal;
        void main() {
          vNormal = normalize(normalMatrix * normal);
          gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
        }
      `,
      fragmentShader: `
        varying vec3 vNormal;
        void main() {
          float intensity = pow(0.68 - dot(vNormal, vec3(0, 0, 1.0)), 2.2);
          gl_FragColor = vec4(0.0, 0.94, 1.0, 1.0) * intensity * 1.6;
        }
      `,
      blending: THREE.AdditiveBlending,
      side: THREE.BackSide,
      transparent: true
    });
    atmosphereMesh = new THREE.Mesh(atmoGeo, atmoMat);
    scene.add(atmosphereMesh);

    // 5. Geospatial LOD Labels Layer
    createGeospatialLabels();

    // 6. Natuna SAR Target Radar Lock Marker
    createNatunaLockMarker();

    // 7. Interactive Target Beacon (for Fly-To)
    createTargetBeacon();

    // 8. Inclined Satellite Orbits & Meshes
    createSatellites();

    // 9. Mouse & Touch Drag Event Listeners
    setupInteractions(container);

    // 10. Start Animation Loop
    animate();

    window.addEventListener('resize', () => {
      if (!container || !renderer || !camera) return;
      const w = container.clientWidth || 800;
      const h = container.clientHeight || 540;
      camera.aspect = w / h;
      camera.updateProjectionMatrix();
      renderer.setSize(w, h);
    });
  }

  function createStarfield() {
    const starGeo = new THREE.BufferGeometry();
    const starCount = 600;
    const starPositions = new Float32Array(starCount * 3);

    for (let i = 0; i < starCount * 3; i += 3) {
      starPositions[i] = (Math.random() - 0.5) * 80;
      starPositions[i + 1] = (Math.random() - 0.5) * 80;
      starPositions[i + 2] = (Math.random() - 0.5) * 80;
    }

    starGeo.setAttribute('position', new THREE.BufferAttribute(starPositions, 3));
    const starMat = new THREE.PointsMaterial({
      color: 0x99ddff,
      size: 0.25,
      transparent: true,
      opacity: 0.75
    });

    const starField = new THREE.Points(starGeo, starMat);
    scene.add(starField);
  }

  let labelSprites = [];
  function createGeospatialLabels() {
    labelsGroup = new THREE.Group();

    geospatialIndex.forEach((item) => {
      const pos = latLonToVector3(item.lat, item.lon, 4.26);

      // Pin Dot
      const pinGeo = new THREE.SphereGeometry(0.045, 12, 12);
      const pinMat = new THREE.MeshBasicMaterial({ color: new THREE.Color(item.border || item.color) });
      const pinMesh = new THREE.Mesh(pinGeo, pinMat);
      pinMesh.position.copy(pos);
      labelsGroup.add(pinMesh);

      // Billboard Badge Sprite
      const texture = createLabelTexture(item);
      const spriteMat = new THREE.SpriteMaterial({
        map: texture,
        transparent: true,
        depthTest: true
      });
      const sprite = new THREE.Sprite(spriteMat);

      // Elevated slightly above pin
      const elevatedPos = latLonToVector3(item.lat, item.lon, 4.38);
      sprite.position.copy(elevatedPos);
      sprite.scale.set(1.4, 0.35, 1.0);

      // Store metadata for LOD management and occlusion culling
      sprite.userData = {
        tier: item.tier,
        normal: pos.clone().normalize(),
        pinMesh: pinMesh
      };

      labelSprites.push(sprite);
      labelsGroup.add(sprite);
    });

    globeMesh.add(labelsGroup);
  }

  function createNatunaLockMarker() {
    natunaGroup = new THREE.Group();
    const natunaPos = latLonToVector3(3.9, 108.3, 4.24);
    natunaGroup.position.copy(natunaPos);

    // Outer Target Rings
    const ringGeo = new THREE.RingGeometry(0.18, 0.22, 32);
    const ringMat = new THREE.MeshBasicMaterial({
      color: 0xE8001A,
      side: THREE.DoubleSide,
      transparent: true,
      opacity: 0.85
    });
    const ringMesh = new THREE.Mesh(ringGeo, ringMat);
    ringMesh.lookAt(natunaPos.clone().multiplyScalar(2));
    natunaGroup.add(ringMesh);

    // Center Red Pin
    const pinGeo = new THREE.SphereGeometry(0.06, 16, 16);
    const pinMat = new THREE.MeshBasicMaterial({ color: 0xFF2A37 });
    const pinMesh = new THREE.Mesh(pinGeo, pinMat);
    natunaGroup.add(pinMesh);

    globeMesh.add(natunaGroup);
  }

  function createTargetBeacon() {
    targetBeaconGroup = new THREE.Group();
    targetBeaconGroup.visible = false;

    const ringGeo = new THREE.RingGeometry(0.25, 0.30, 32);
    const ringMat = new THREE.MeshBasicMaterial({
      color: 0x00F0FF,
      side: THREE.DoubleSide,
      transparent: true,
      opacity: 0.95
    });
    const ring = new THREE.Mesh(ringGeo, ringMat);
    targetBeaconGroup.add(ring);

    globeMesh.add(targetBeaconGroup);
  }

  function createSatellites() {
    orbitsGroup = new THREE.Group();
    satellitesGroup = new THREE.Group();
    radarBeamGroup = new THREE.Group();

    satellitesData.forEach((sat) => {
      // 1. Orbit Ellipse Path
      const curve = new THREE.EllipseCurve(
        0, 0,
        sat.radiusA, sat.radiusB,
        0, 2 * Math.PI,
        false, 0
      );
      const points = curve.getPoints(120);
      const orbitGeo = new THREE.BufferGeometry().setFromPoints(points);

      const orbitMat = new THREE.LineBasicMaterial({
        color: sat.color,
        transparent: true,
        opacity: 0.45,
        linewidth: 1
      });

      const orbitLine = new THREE.Line(orbitGeo, orbitMat);
      orbitLine.rotation.x = sat.tiltX;
      orbitLine.rotation.z = sat.tiltZ;
      orbitsGroup.add(orbitLine);

      // 2. Satellite Vehicle Mesh (Body + Solar Panels)
      const satVehicle = new THREE.Group();

      const bodyGeo = new THREE.BoxGeometry(sat.size, sat.size * 0.7, sat.size * 0.7);
      const bodyMat = new THREE.MeshStandardMaterial({
        color: 0xeeeeee,
        metalness: 0.8,
        roughness: 0.2
      });
      const bodyMesh = new THREE.Mesh(bodyGeo, bodyMat);
      satVehicle.add(bodyMesh);

      const wingGeo = new THREE.BoxGeometry(sat.size * 2.8, sat.size * 0.08, sat.size * 0.5);
      const wingMat = new THREE.MeshStandardMaterial({
        color: sat.color,
        emissive: sat.color,
        emissiveIntensity: 0.4
      });
      const wingMesh = new THREE.Mesh(wingGeo, wingMat);
      satVehicle.add(wingMesh);

      const glowGeo = new THREE.SphereGeometry(sat.size * 0.9, 16, 16);
      const glowMat = new THREE.MeshBasicMaterial({
        color: sat.color,
        transparent: true,
        opacity: 0.5
      });
      const glowMesh = new THREE.Mesh(glowGeo, glowMat);
      satVehicle.add(glowMesh);

      sat.mesh = satVehicle;
      satellitesGroup.add(satVehicle);
    });

    scene.add(orbitsGroup);
    scene.add(satellitesGroup);
    scene.add(radarBeamGroup);
  }

  function setupInteractions(container) {
    const el = renderer.domElement;

    el.addEventListener('mousedown', (e) => {
      isDragging = true;
      prevMousePos = { x: e.clientX, y: e.clientY };
    });

    window.addEventListener('mousemove', (e) => {
      if (!isDragging) return;
      const dx = e.clientX - prevMousePos.x;
      const dy = e.clientY - prevMousePos.y;
      prevMousePos = { x: e.clientX, y: e.clientY };

      targetRotation.y += dx * 0.006;
      targetRotation.x += dy * 0.006;
      targetRotation.x = Math.max(-1.2, Math.min(1.2, targetRotation.x));
    });

    window.addEventListener('mouseup', () => {
      isDragging = false;
    });

    el.addEventListener('touchstart', (e) => {
      if (e.touches.length === 1) {
        isDragging = true;
        prevMousePos = { x: e.touches[0].clientX, y: e.touches[0].clientY };
      }
    });

    window.addEventListener('touchmove', (e) => {
      if (!isDragging || e.touches.length !== 1) return;
      const dx = e.touches[0].clientX - prevMousePos.x;
      const dy = e.touches[0].clientY - prevMousePos.y;
      prevMousePos = { x: e.touches[0].clientX, y: e.touches[0].clientY };

      targetRotation.y += dx * 0.006;
      targetRotation.x += dy * 0.006;
      targetRotation.x = Math.max(-1.2, Math.min(1.2, targetRotation.x));
    });

    window.addEventListener('touchend', () => {
      isDragging = false;
    });

    el.addEventListener('wheel', (e) => {
      e.preventDefault();
      targetCameraZ += e.deltaY * 0.01;
      targetCameraZ = Math.max(9.5, Math.min(26.0, targetCameraZ));
    }, { passive: false });
  }

  function updateLODAndOcclusion() {
    if (!globeMesh || !camera) return;

    const globeMatrix = globeMesh.matrixWorld;
    const camPos = camera.position;
    const currentDist = camPos.z;

    // LOD threshold rules:
    // Macro (Continents & Oceans): visible always, scaled slightly
    // Regional (Countries & Seas): visible when z <= 19.5
    // Micro (Defense Sectors & Bases): visible when z <= 15.0
    const showRegional = currentDist <= 19.5;
    const showMicro = currentDist <= 15.0;

    labelSprites.forEach((sprite) => {
      if (!showLabels) {
        sprite.visible = false;
        if (sprite.userData.pinMesh) sprite.userData.pinMesh.visible = false;
        return;
      }

      const tier = sprite.userData.tier;
      if (tier === 'regional' && !showRegional) {
        sprite.visible = false;
        if (sprite.userData.pinMesh) sprite.userData.pinMesh.visible = false;
        return;
      }
      if (tier === 'micro' && !showMicro) {
        sprite.visible = false;
        if (sprite.userData.pinMesh) sprite.userData.pinMesh.visible = false;
        return;
      }

      // Compute normal in world space to cull back hemisphere
      const worldNormal = sprite.userData.normal.clone().applyEuler(globeMesh.rotation);
      const toCamera = camPos.clone().normalize();
      const dot = worldNormal.dot(toCamera);

      // If point faces away from camera, hide it
      if (dot <= 0.12) {
        sprite.visible = false;
        if (sprite.userData.pinMesh) sprite.userData.pinMesh.visible = false;
      } else {
        sprite.visible = true;
        if (sprite.userData.pinMesh) sprite.userData.pinMesh.visible = true;

        // Dynamic scale adjustment based on camera distance for crisp readability
        const scaleFactor = (currentDist / 16.5) * (tier === 'macro' ? 1.4 : (tier === 'regional' ? 1.15 : 0.95));
        sprite.scale.set(scaleFactor * 1.4, scaleFactor * 0.35, 1.0);
      }
    });
  }

  function animate() {
    animId = requestAnimationFrame(animate);

    if (!isDragging) {
      targetRotation.y -= autoRotateSpeed * speedMultiplier;
    }

    // Smooth interpolation (lerp)
    currentRotation.x += (targetRotation.x - currentRotation.x) * 0.08;
    currentRotation.y += (targetRotation.y - currentRotation.y) * 0.08;

    if (camera) {
      camera.position.z += (targetCameraZ - camera.position.z) * 0.08;
    }

    if (globeMesh) {
      globeMesh.rotation.x = currentRotation.x;
      globeMesh.rotation.y = currentRotation.y;
    }

    // Update LOD & Occlusion
    updateLODAndOcclusion();

    // Pulse Natuna Target Lock
    if (natunaGroup) {
      const time = Date.now() * 0.004;
      const scale = 1.0 + Math.sin(time) * 0.25;
      natunaGroup.scale.set(scale, scale, scale);
    }

    // Pulse Target Beacon if active
    if (targetBeaconGroup && targetBeaconGroup.visible) {
      const bTime = Date.now() * 0.006;
      const bScale = 1.0 + Math.sin(bTime) * 0.4;
      targetBeaconGroup.scale.set(bScale, bScale, bScale);
    }

    // Update Satellites along Orbits
    satellitesData.forEach((sat) => {
      if (!sat.mesh) return;

      sat.progress = (sat.progress + sat.speed * 0.1 * speedMultiplier) % 1.0;
      const theta = sat.progress * Math.PI * 2;

      const ex = sat.radiusA * Math.cos(theta);
      const ey = sat.radiusB * Math.sin(theta);

      const pos = new THREE.Vector3(ex, ey, 0);
      pos.applyAxisAngle(new THREE.Vector3(1, 0, 0), sat.tiltX);
      pos.applyAxisAngle(new THREE.Vector3(0, 0, 1), sat.tiltZ);

      sat.mesh.position.copy(pos);
      sat.mesh.lookAt(0, 0, 0);
    });

    if (orbitsGroup) orbitsGroup.visible = showOrbits;
    if (satellitesGroup) satellitesGroup.visible = showOrbits;

    if (renderer && scene && camera) {
      renderer.render(scene, camera);
    }
  }

  // ── Global Bridge Functions for Flutter Integration ───────────────────────
  window.initTacticalGlobe = function (containerId) {
    const el = document.getElementById(containerId);
    if (el) init(el);
  };

  window.resetTacticalGlobeToNatuna = function () {
    targetRotation.x = 0.12;
    targetRotation.y = -1.88;
    targetCameraZ = 16.5;
  };

  window.zoomTacticalGlobe = function (delta) {
    targetCameraZ += delta;
    targetCameraZ = Math.max(9.5, Math.min(26.0, targetCameraZ));
  };

  window.setTacticalGlobeSpeed = function (multiplier) {
    speedMultiplier = multiplier;
  };

  window.toggleTacticalGlobeOrbits = function (visible) {
    showOrbits = visible;
  };

  window.toggleTacticalGlobeFootprint = function (visible) {
    showFootprint = visible;
    if (natunaGroup) natunaGroup.visible = showFootprint;
  };

  window.toggleTacticalGlobeLabels = function (visible) {
    showLabels = visible;
  };

  /**
   * Fly-To Controller: Smoothly flies camera & rotates globe to target latitude and longitude.
   * @param {number} lat Latitude in degrees (-90 to +90)
   * @param {number} lon Longitude in degrees (-180 to +180)
   * @param {number} targetZoom Camera distance (9.5 = Micro close-up, 15.0 = Regional, 20.0 = Macro)
   */
  window.flyToTacticalLocation = function (lat, lon, targetZoom) {
    // Spherical yaw and pitch calculation for Three.js sphere
    // Yaw: Longitude maps to Y rotation
    const pitch = (lat * Math.PI) / 180.0;
    const yaw = -((lon * Math.PI) / 180.0) - Math.PI / 2;

    targetRotation.x = Math.max(-1.2, Math.min(1.2, pitch));
    targetRotation.y = yaw;
    targetCameraZ = targetZoom || 13.5;

    // Attach target beacon to location
    if (targetBeaconGroup) {
      const beaconPos = latLonToVector3(lat, lon, 4.25);
      targetBeaconGroup.position.copy(beaconPos);
      targetBeaconGroup.lookAt(beaconPos.clone().multiplyScalar(2));
      targetBeaconGroup.visible = true;

      // Hide beacon after 6 seconds
      setTimeout(() => {
        if (targetBeaconGroup) targetBeaconGroup.visible = false;
      }, 6000);
    }
  };

  // Expose Geospatial Index to Flutter
  window.getGeospatialIndexList = function () {
    return JSON.stringify(geospatialIndex);
  };
})();
