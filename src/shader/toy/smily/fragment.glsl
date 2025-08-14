
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

vec2 withIN( vec2 uv, vec4 rect){
    return ( uv.xy - rect.xy) / (rect.zw - rect.xy);
}


vec4 mouthF(vec2 uv){
    uv -= .5;
    uv.y *= 1.5;
    vec4 col = vec4(.5, .18, .05, 1.);
    uv.y -= uv.x * uv.x * 2.;
    float d = length( uv);
    col.a = S(.5, .47, d);


    float td =length(uv - vec2(.0, .6));

    vec3 toothCol = vec3(1.) * S(.6, .35, d);

    col.rgb = mix( col.rgb, toothCol, S(.4, .37, td));
    
    td = length(uv + vec2(.0, .5 ));

    col.rgb = mix(col.rgb,  vec3(1., .5, .5), S(.5, .2, td));

    return col;
}
vec4 eyes(vec2 uv){
    vec4 col = vec4(1.);
    uv -= .5;
    float d = length(uv);
    
    vec4 irisCol = vec4(.3, .5, 1., 1.);
    col = mix( vec4(1.), irisCol, S(.1, .7, d) * .5);  

    col.rgb *= 1. - S(.45, .5, d) * .5 * sat(uv.y);     
    
    col.rgb = mix(col.rgb, vec3(0.), S(.3, .28, d));
    irisCol.rgb *= 1. + S(.3, .05, d);
    col.rgb = mix(col.rgb, irisCol.rgb, S(.3, .25, d));
    col.rgb = mix(col.rgb, vec3(0.), S(.16, .15, d));

    float highLight = S(.1, .09, length( uv - vec2(-.15, .15)));
    highLight += S(.07, .05, length( uv - vec2(.08, -.08)));
    col.rgb = mix( col.rgb, vec3(1.), highLight);
    col.a = S(.5, .48, d);

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
    highLight *= remap(.41, -.1, .7, .0, uv.y);
    col.rgb = mix( col.rgb, vec3(1.), highLight);

    d = length(uv - vec2(.25, -.2));
    float check = S(.2, .01, d) * .4;
    check *= S(1.7, 1.6, d);
    col.rgb = mix( col.rgb, vec3(1., .1, .1), check);
    return col;
}

vec4 smily(vec2 uv){
    vec4 col = vec4( .0);
    uv.x = abs(uv.x);
    vec4 head = headF(uv); 
    vec4 eye = eyes(withIN(uv, vec4(.03, -.1, .37, .25)));
    vec4 mouth = mouthF(withIN(uv, vec4(-.3, -.4, .3, -.1)));

    col = mix( col, head, head.a);
    col = mix (col, eye, eye.a);
    col = mix (col, mouth, mouth.a);
    
    return col;
}

void main(){
    vec2 uv = vUv;
    uv -= .5;
    uv.x *= iResolution.x / iResolution.y;
    gl_FragColor = smily(uv);
    // gl_FragColor = vec4(0.72, 0.02, 0.02, 1.0);
}