
varying vec2 vUv;

uniform vec2 iResolution;


#define S(a, b, t) smoothstep(a, b, t)
#define sat(x) clamp(x, 0., 1.)

float remap01(float a, float b, float t){
    return sat((t -a)/ (b -a));
}

float remap(float a, float b, float c, float d, float t){
    return remap01(a, b, t) * (d-c) + c;
}


vec4 mouth(vec2 uv){
    vec4 col = vec4(1., .3, .2, 1.);
    return col;
}
vec4 eyes(vec2 uv){
    vec4 col = vec4(1., .3, .2, 1.);
    return col;
}
vec4 headF(vec2 uv){
    vec4 col = vec4(0.94, 0.68, 0.08, 1.0);
    float d = length(uv);

    col.a = S(.5, .49, d);

    float edgeRemap = remap01(.3, .5, d);
    
    col.rgb *= 1. - edgeRemap * edgeRemap * .5;
    col.rgb  = mix(col.rgb, vec3(0.72, 0.02, 0.02), S( .48, .49, d));

    float highLight = S(.41, .40, d);
    highLight *= remap(.41, 0., .7, .0 uv.y);
    col.rgb = mix( col.rgb, vec3(1.), highLight);
    return col;
}

vec4 smily(vec2 uv){
    vec4 col = vec4( .0);
    vec4 head = headF(uv);

    col = mix( col, head, head.a);
    return col;
}

void main(){
    vec2 uv = vUv;
    uv -= .5;
    uv.x *= iResolution.x / iResolution.y;
    gl_FragColor = smily(uv);
    // gl_FragColor = vec4(0.72, 0.02, 0.02, 1.0);
}