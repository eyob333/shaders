// fragment.glsl
uniform float uTime;
uniform vec3 uCameraPosition;
uniform vec3 uBaseColor; // e.g. vec3(0.3, 0.8, 1.0)
uniform float uFresnelPower; // e.g. 3.0

varying vec3 vNormal;
varying vec3 vWorldPosition;

void main() {
    vec3 viewDir = normalize(uCameraPosition - vWorldPosition);
    vec3 normal = normalize(vNormal);

    // Fresnel effect
    float fresnel = pow(1.0 - max(dot(viewDir, normal), 0.0), uFresnelPower);

    // Animated hue shift for shimmer
    float shimmer = 0.5 + 0.5 * sin(uTime * 5.0 + vWorldPosition.y * 4.0);

    vec3 color = uBaseColor * shimmer + fresnel * vec3(1.0, 1.0, 1.0);

    // Add some inner glow
    color += fresnel * 0.3;

    gl_FragColor = vec4(color, 0.8); // semi-transparent crystal
}
