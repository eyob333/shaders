
varying vec2 vUv;

uniform vec2 iResolution;
uniform vec2 iMouse;
uniform float iTime;


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

vec4 brow(vec2 uv, float t){
    uv -= .5;
    uv.y += .25;
    float y = uv.y;
    uv.y += uv.x *.8 -.3;

    vec4 col = vec4(.0);
    float blur = .1;

    float d1 = length(uv);
    float s1 = S(.45, .45-blur, d1);
    float d2 = length( uv - vec2(.1, -.2) * .7);
    float s2 = S(.5, .5 -blur, d2);

    float browMask = sat(s1- s2);
    float colMask = remap01(.7, .8, y) * .75;
    colMask *= S(.6, .9, browMask);

    vec4 browCol = mix(vec4(.4, .2, .2, 1.), vec4(1., .75, .5, 1.), colMask);
    // col.a = S(1., .9, d1);
     uv.y += .15;
    blur += .1;
    d1 = length(uv);
    s1 = S(.45, .45-blur, d1);
    d2 = length(uv-vec2(.1, -.2)*.7);
    s2 = S(.5, .5-blur, d2);
    float shadowMask = sat(s1-s2);
    
    col = mix(col, vec4(0.,0.,0.,1.), S(.0, 1., shadowMask)*.6);
    col = mix(col, browCol, S(.2, .4, browMask));
    return col;
}

vec4 mouthF(vec2 uv, float t){
    uv -= .5;
    uv.y *= 1.5;
    vec4 col = vec4(.5, .18, .05, 1.);
    uv.y -= uv.x * uv.x * 2. * t;
    uv.x *= mix( 2., 1., t);
    float d = length( uv);
    col.a = S(.5, .47, d );


    vec2 tUv = uv;
    tUv.y += (abs(uv.x)*.5+.1)*(1.-t);

    float td =length(tUv - vec2(.0, .6));

    vec3 toothCol = vec3(1.) * S(.6, .35, d);

    col.rgb = mix( col.rgb, toothCol, S(.4, .37, td));
    
    td = length(uv + vec2(.0, .5 ));

    col.rgb = mix(col.rgb,  vec3(1., .5, .5), S(.5, .2, td));

    return col;
}
vec4 eyes(vec2 uv, float side, vec2 m, float t ){
    vec4 col = vec4(1.);
    uv -= .5;
    uv.x *= side;
    float d = length(uv );
    
    vec4 irisCol = vec4(.3, .5, 1., 1.);
    col = mix( vec4(1.), irisCol, S(.1, .7, d) * .5);  
    col.a = S(.5, .48, d) ;
    col.rgb *= 1. - S(.45, .5, d) * .5 * sat(-uv.y - uv.x * side); 

    d = length(uv - m * .4);
    
    col.rgb = mix(col.rgb, vec3(0.), S(.3, .28, d) );
    irisCol.rgb *= 1. + S(.3, .05, d);

    float irisMask = S(.28, .25, d);
    col.rgb = mix(col.rgb, irisCol.rgb, irisMask);

    d = length(uv - m * .6);

    float pupleSize =  mix( .4, .16, t);
    float pupleMask = S(pupleSize, pupleSize * .9, d);
    pupleMask *= irisMask;
    col.rgb = mix(col.rgb, vec3(0.), pupleMask);

    float T = iTime * 3.;
    vec2 offSet = vec2( sin(T + uv.y * 25. ), cos( T + uv.x * 25.) );
    uv += offSet * .01 * (1. - t);

    float highLight = S(.1, .09, length( uv - vec2(-.15, .15)));
    highLight += S(.07, .05, length( uv - vec2(.08, -.08)));
    col.rgb = mix( col.rgb, vec3(1.), highLight);
   

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
    highLight *= S(.18, .19, length(uv - vec2(.2, .07)));
    col.rgb = mix( col.rgb, vec3(1.), highLight);

    d = length(uv - vec2(.25, -.2));
    float check = S(.2, .01, d) * .4;
    check *= S(1.7, 1.6, d);
    col.rgb = mix( col.rgb, vec3(1., .1, .1), check);
    return col;
}

vec4 smily(vec2 uv, vec2 m, float t){
    vec4 col = vec4( .0);
    float side = sign(uv.x);
    uv.x = abs(uv.x);
    vec4 head = headF(uv); 
    vec4 eye = eyes(withIN(uv, vec4(.03, -.1, .37, .25)), side, m, t);
    vec4 mouth = mouthF(withIN(uv, vec4(-.3, -.4, .3, -.1)), t);
    vec4 brow = brow( withIN( uv, vec4(.1, .15, .43, .37)), t); //my solution 
    col = mix( col, head, head.a);
    col = mix (col, eye, eye.a);
    col = mix (col, mouth, mouth.a);
    col = mix (col, brow, brow.a);
    
    return col;
}
// One use case for this is creating functions that “return” multiple values.

// void decimateTwo(inout float x, inout float y) {
//   x *= 0.9;
//   y *= 0.9;
// }


// void decimate(inout float x){
//     x *= 0.9;
// }

void main(){
    vec2 uv = vUv;
    uv -= .5;
    uv.x *= iResolution.x / iResolution.y;

    vec2 m = ( iMouse.xy  / iResolution.xy );
    m -= .5;
    float t = cos(iTime) * .5 + .5;
    gl_FragColor = smily(uv, m, t);
    // gl_FragColor = vec4(0.72, 0.02, 0.02, 1.0);
}