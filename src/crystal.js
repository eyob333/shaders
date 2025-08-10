// main.js
import * as THREE from 'three';

// ==================== Vertex Shader ====================
const vertexShader = `
uniform float uTime;
uniform float uNoiseScale;
uniform float uNoiseStrength;

varying vec3 vNormal;
varying vec3 vWorldPosition;
varying float vNoiseVal;

// ---------------- Simplex Noise ----------------
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 permute(vec4 x) { return mod289(((x*34.0)+1.0)*x); }
vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

float snoise(vec3 v) { 
    const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
    const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

    vec3 i  = floor(v + dot(v, C.yyy) );
    vec3 x0 =   v - i + dot(i, C.xxx) ;

    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min( g.xyz, l.zxy );
    vec3 i2 = max( g.xyz, l.zxy );

    vec3 x1 = x0 - i1 + 1.0 * C.xxx;
    vec3 x2 = x0 - i2 + 2.0 * C.xxx;
    vec3 x3 = x0 - 1.0 + 3.0 * C.xxx;

    i = mod289(i); 
    vec4 p = permute( permute( permute( 
                i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
              + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
              + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

    float n_ = 1.0/7.0;
    vec3  ns = n_ * D.wyz - D.xzx;

    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  

    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_ );  

    vec4 x = x_ *ns.x + ns.yyyy;
    vec4 y = y_ *ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4( x.xy, y.xy );
    vec4 b1 = vec4( x.zw, y.zw );

    vec4 s0 = floor(b0)*2.0 + 1.0;
    vec4 s1 = floor(b1)*2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
    vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

    vec3 p0 = vec3(a0.xy,h.x);
    vec3 p1 = vec3(a0.zw,h.y);
    vec3 p2 = vec3(a1.xy,h.z);
    vec3 p3 = vec3(a1.zw,h.w);

    vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2,p2), dot(p3,p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

    vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), 
                            dot(x2,x2), dot(x3,x3)), 0.0);
    m = m * m;
    return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
                                  dot(p2,x2), dot(p3,x3) ) );
}
// -------------------------------------------------

void main() {
    vNormal = normalize(normalMatrix * normal);

    // Layered noise for complex deformation
    float n1 = snoise(position * uNoiseScale + vec3(0.0, uTime * 0.3, 0.0));
    float n2 = snoise(position * (uNoiseScale * 2.0) + vec3(0.0, uTime * 0.5, 0.0));
    vNoiseVal = n1 * 0.6 + n2 * 0.4;

    vec3 displacedPosition = position + normal * (vNoiseVal * uNoiseStrength);

    vec4 worldPosition = modelMatrix * vec4(displacedPosition, 1.0);
    vWorldPosition = worldPosition.xyz;

    gl_Position = projectionMatrix * viewMatrix * worldPosition;
}
`;

// ==================== Fragment Shader ====================
const fragmentShader = `
uniform float uTime;
uniform vec3 uCameraPosition;
uniform vec3 uBaseColor;
uniform float uFresnelPower;

varying vec3 vNormal;
varying vec3 vWorldPosition;
varying float vNoiseVal;

// Convert hue to RGB (for rainbow Fresnel)
vec3 hueToRGB(float h) {
    h = mod(h, 1.0);
    float r = abs(h * 6.0 - 3.0) - 1.0;
    float g = 2.0 - abs(h * 6.0 - 2.0);
    float b = 2.0 - abs(h * 6.0 - 4.0);
    return clamp(vec3(r, g, b), 0.0, 1.0);
}

void main() {
    vec3 viewDir = normalize(uCameraPosition - vWorldPosition);
    vec3 normal = normalize(vNormal);

    // Rainbow Fresnel
    float fresnel = pow(1.0 - max(dot(viewDir, normal), 0.0), uFresnelPower);
    vec3 fresnelColor = hueToRGB(0.6 + sin(uTime * 0.2 + vWorldPosition.y * 2.0) * 0.2);

    // Shimmer wave across surface
    float shimmer = 0.5 + 0.5 * sin(uTime * 6.0 + vWorldPosition.x * 5.0 + vWorldPosition.y * 3.0);

    // Depth-based inner glow
    float depthGlow = smoothstep(-0.5, 1.0, vNoiseVal) * 0.4;

    // Final color blend
    vec3 color = uBaseColor * (0.5 + 0.5 * shimmer);
    color += fresnelColor * fresnel * 1.5;
    color += depthGlow * vec3(0.3, 0.6, 1.0);

    gl_FragColor = vec4(color, 0.9);
}

`;

// ==================== Three.js Setup ====================
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x000000);

// Camera
const camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 100);
camera.position.set(0, 0, 3);
scene.add(camera);

// Renderer
const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

// Crystal Material
const uniforms = {
    uTime: { value: 0 },
    uCameraPosition: { value: camera.position },
    uBaseColor: { value: new THREE.Color(0.3, 0.8, 1.0) },
    uNoiseScale: { value: 2.5 },
    uNoiseStrength: { value: 0.25 },
    uBaseColor: { value: new THREE.Color(0.2, 0.4, 1.0) },
    uFresnelPower: { value: 4.0 }
    };

const material = new THREE.ShaderMaterial({
    vertexShader,
    fragmentShader,
    uniforms,
    transparent: true,
    side: THREE.DoubleSide
});

// Crystal Mesh
const geometry = new THREE.IcosahedronGeometry(1, 4);
const crystal = new THREE.Mesh(geometry, material);
scene.add(crystal);

// Lighting
const light = new THREE.PointLight(0xffffff, 2);
light.position.set(5, 5, 5);
scene.add(light);

// Resize Handling
window.addEventListener('resize', () => {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
});

// Animation Loop
renderer.setAnimationLoop((time) => {
    uniforms.uTime.value = time * 0.001;
    crystal.rotation.y += 0.005;
    crystal.rotation.x += 0.002;
    renderer.render(scene, camera);
});
