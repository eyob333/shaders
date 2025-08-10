
varying vec2 vUv;

uniform vec2 iResolution;


#define S(a, b, t) smoothstep(a, b, t)


// float circle(a){
//     return 
// }

vec4 mouth(vec2 uv){
    vec4 col = vec4(1., .3, .2, 1.);
    return col;
}
vec4 eyes(vec2 uv){
    vec4 col = vec4(1., .3, .2, 1.);
    return col;
}
vec4 head(vec2 uv){
    vec4 col = vec4(0.94, 0.68, 0.08, 1.0);
    float d = S(.5, .5 -0.01, length(uv));
    return d * col;
}

vec4 smily(vec2 uv){
    vec4 col = vec4( .9, .6, .2, 1.);
    return head(uv);
}

void main(){
    vec2 uv = vUv;
    uv -= .5;
    uv.x *= iResolution.x / iResolution.y;
    gl_FragColor = smily(uv);
    // gl_FragColor = vec4(0.94, 0.68, 0.08, 1.0);
}