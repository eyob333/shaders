import * as THREE from 'three';
import cryistalVertex from './shader/crisytal/vertex.glsl'
import cryistalfragment from './shader/crisytal/fragment.glsl'
import testFragment from './shader/test/fragment.glsl'
import testVertex from './shader/test/vertex.glsl'
import toyVert from './shader/toy/vertex.glsl'
import toyFrag from './shader/toy/fragment.glsl'

// Set up the scene, camera, and renderer
let scene, camera, renderer;
let uniforms;
let isReady = false;
let outputBox;


/**
 * Initializes the Three.js environment, loads textures, and sets up uniforms.
 */
function init() {
    // Scene setup
    scene = new THREE.Scene();

    // Camera setup
    camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.1, 10);
    camera.position.z = 1;

    // Renderer setup
    renderer = new THREE.WebGLRenderer();
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setSize(window.innerWidth, window.innerHeight);
    document.body.appendChild(renderer.domElement);

    // Get UI elements


    // A loading manager ensures that all asynchronous texture loading is complete before rendering.
    const manager = new THREE.LoadingManager();
    manager.onLoad = () => {
        // Once all textures are loaded, create the shader material and add the mesh
        createShaderMesh();
        isReady = true;
        animate(); // Start the animation loop
    };

    const textureLoader = new THREE.TextureLoader(manager);
    const channel0Texture = textureLoader.load('/noiseTexture.png');
    channel0Texture.wrapS = THREE.RepeatWrapping;
    channel0Texture.wrapT = THREE.RepeatWrapping;

    // Define uniforms with the loaded textures and other ShaderToy variables
    uniforms = {
        iResolution: { value: new THREE.Vector3(window.innerWidth, window.innerHeight, 1) },
        iTime: { value: 0 },
        iMouse: { value: new THREE.Vector4(0, 0, 0, 0) },
        iChannel0: { value: channel0Texture }
    };

    // Add event listeners for mouse and window resize
    window.addEventListener('mousemove', onMouseMove);
    window.addEventListener('mousedown', onMouseDown);
    window.addEventListener('mouseup', onMouseUp);
    window.addEventListener('resize', onWindowResize);
}



/**
 * Creates the shader material and adds the plane mesh to the scene.
 * This function is called only after all textures have loaded.
 */
function createShaderMesh() {
    // Create a shader material
    const material = new THREE.ShaderMaterial({
        uniforms: uniforms,
        // vertexShader: cryistalVertex,
        // fragmentShader: cryistalfragment,
        vertexShader: toyVert,
        fragmentShader: toyFrag
    });

    // Create a full-screen plane geometry
    const geometry = new THREE.PlaneGeometry(2, 2);
    const mesh = new THREE.Mesh(geometry, material);
    scene.add(mesh);
}

/**
 * Handles window resizing to keep the shader full-screen.
 */
function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
    if (uniforms) {
        uniforms.iResolution.value.x = window.innerWidth;
        uniforms.iResolution.value.y = window.innerHeight;
    }
}

/**
 * Updates the mouse uniform position for interaction.
 */
function onMouseMove(event) {
    if (uniforms) {
        uniforms.iMouse.value.x = event.clientX;
        uniforms.iMouse.value.y = window.innerHeight - event.clientY;
    }
}

/**
 * Handles mouse down events for the iMouse uniform.
 */
function onMouseDown(event) {
    if (uniforms) {
        uniforms.iMouse.value.z = 1;
        uniforms.iMouse.value.w = 1;
    }
}

/**
 * Handles mouse up events for the iMouse uniform.
 */
function onMouseUp(event) {
    if (uniforms) {
        uniforms.iMouse.value.z = 0;
        uniforms.iMouse.value.w = 0;
    }
}

/**
 * The main animation loop.
 */
function animate() {
    if (!isReady) return;
    requestAnimationFrame(animate);

    // Update time uniform
    uniforms.iTime.value = performance.now() / 1000;

    renderer.render(scene, camera);
}

// Initialize the app on window load
window.onload = function () {
    init();
}