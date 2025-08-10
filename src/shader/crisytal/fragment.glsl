#define saturate(x) clamp(x, 0.0, 1.0)

uniform vec3 iResolution;
uniform float iTime;
uniform vec4 iMouse;
uniform sampler2D iChannel0;

uint ihash1D(uint q) {
    q = (q << 13u) ^ q;
    return q * (q * q * 15731u + 789221u) + 1376312589u;
}
uvec4 ihash1D(uvec4 q) {
    q = (q << 13u) ^ q;
    return q * (q * q * 15731u + 789221u) + 1376312589u;
}

vec2 betterHash2D(vec2 x) {
    uvec2 q = uvec2(x);
    uint h0 = ihash1D(ihash1D(q.x) + q.y);
    uint h1 = h0 * 1933247u + ~h0 ^ 230123u;
    return vec2(h0, h1) * (1.0 / float(0xffffffffu));
}

void betterHash2D(vec4 coords0, vec4 coords1, out vec4 hashX, out vec4 hashY) {
    uvec4 hash0 = ihash1D(ihash1D(uvec4(coords0.xz, coords1.xz)) + uvec4(coords0.yw, coords1.yw));
    uvec4 hash1 = hash0 * 1933247u + ~hash0 ^ 230123u;
    hashX = vec4(hash0) * (1.0 / float(0xffffffffu));
    hashY = vec4(hash1) * (1.0 / float(0xffffffffu));
}

vec3 cellularNoised(vec2 pos, vec2 scale, float jitter, float phase, float seed) {
    const float kPI2 = 6.2831853071;
    pos *= scale;
    vec2 i = floor(pos);
    vec2 f = pos - i;

    const vec3 offset = vec3(-1.0, 0.0, 1.0);
    vec4 cells = mod(i.xyxy + offset.xxzz, scale.xyxy) + seed;
    i = mod(i, scale) + seed;
    vec4 dx0, dy0, dx1, dy1;
    betterHash2D(vec4(cells.xy, vec2(i.x, cells.y)), vec4(cells.zyx, i.y), dx0, dy0);
    betterHash2D(vec4(cells.zwz, i.y), vec4(cells.xw, vec2(i.x, cells.w)), dx1, dy1);
    dx0 = 0.5 * sin(phase + kPI2 * dx0) + 0.5;
    dy0 = 0.5 * sin(phase + kPI2 * dy0) + 0.5;
    dx1 = 0.5 * sin(phase + kPI2 * dx1) + 0.5;
    dy1 = 0.5 * sin(phase + kPI2 * dy1) + 0.5;

    dx0 = offset.xyzx + dx0 * jitter - f.xxxx;
    dy0 = offset.xxxy + dy0 * jitter - f.yyyy;
    dx1 = offset.zzxy + dx1 * jitter - f.xxxx;
    dy1 = offset.zyzz + dy1 * jitter - f.yyyy;
    vec4 d0 = dx0 * dx0 + dy0 * dy0;
    vec4 d1 = dx1 * dx1 + dy1 * dy1;

    vec2 centerPos = (0.5 * sin(phase + kPI2 * betterHash2D(i)) + 0.5) * jitter - f;
    float dCenter = dot(centerPos, centerPos);
    vec4 d = min(d0, d1);
    vec4 less = step(d1, d0);
    vec4 dx = mix(dx0, dx1, less);
    vec4 dy = mix(dy0, dy1, less);

    vec3 t1 = d.x < d.y ? vec3(d.x, dx.x, dy.x) : vec3(d.y, dx.y, dy.y);
    vec3 t2 = d.z < d.w ? vec3(d.z, dx.z, dy.z) : vec3(d.w, dx.w, dy.w);
    t2 = t2.x < dCenter ? t2 : vec3(dCenter, centerPos);
    vec3 t = t1.x < t2.x ? t1 : t2;
    t.x = sqrt(t.x);

    return t * vec3(1.0, -2.0, -2.0) * (1.0 / 1.125);
}

vec3 crystalsd(vec2 pos, vec2 scale, float jitter, float phase) {
    vec3 c0 = cellularNoised(pos, scale, jitter, phase, 0.0);
    vec3 c1 = cellularNoised(pos, scale, jitter, phase, 23.0);
    c0.x = 1.0 - c0.x;
    c1.x = 1.0 - c1.x;
    if(c0.x > c1.x) {
        vec3 temp = c0;
        c0 = c1;
        c1 = temp;
    }

    return vec3(c1.x - c0.x, c0.yz - c1.yz);
}

void main() {
    vec2 uvN = gl_FragCoord.xy / iResolution.xy;
    vec2 uv = gl_FragCoord.xy / iResolution.y;

    vec3 baseColor = vec3(0.3, 0.1, 0.85);
    float shininess = 20.0;
    float strength = 0.75;
    float jitter = abs(sin(iTime));
    float scale = 7.0;
    float phase = iTime * 0.3;
    float shadow = 0.30;

    vec3 c = crystalsd(uv, vec2(scale), jitter, phase);
    c.x = c.x * 0.75 + 0.25;
    vec3 normal = normalize(vec3(c.yz, c.x * 8.0));
    normal = normalize(mix(vec3(0.0, 0.0, 1.0), normal, strength));

    vec3 lightDir = normalize(vec3(sin(iTime * 3.0), 0.0, 1.0));
    lightDir = mix(normalize(vec3(cos(iTime), sin(iTime), 1.0)), lightDir, pow(abs(sin(iTime * 0.25)), 2.0));

    vec3 viewDir = normalize(vec3(uvN * 2.0 - 1.0, 0.75));
    vec3 halfDir = normalize(viewDir + lightDir);
    vec3 R = reflect(viewDir, normalize(normal));

    vec3 col = max(dot(lightDir, normal), 0.0) * baseColor;
    col += pow(max(0.0, dot(normal, halfDir)), shininess) * texture(iChannel0, R.xy).rgb * 1.5;
    col *= min(vec3(pow(c.x - 0.23, shadow)) * 2.0, 1.0);

    gl_FragColor = vec4(col, 1.0);
}