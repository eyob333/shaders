
varying vec2 vUv;

uniform vec2 iResolution;
uniform float iTime;

#define s(x) clamp(x, .0, 1.)
float band(float right, float  left, float blur, float t){
    float band1 = smoothstep(right,right -blur,  t);
    float band2 = smoothstep( left - blur, left,  t);
    return band1 * band2;
}

float rect(float right, float left, float top, float bottom, float blur, vec2 uv){
    float x = band(right, left, blur, uv.x) ;
    float y = band(top, bottom, blur, uv.y) ;
    return x * y;
}


void main(){
    vec2 uv = vUv;
    uv -= .5;
    // uv.x *= iResolution.x / iResolution.y;
    float d = length(uv );
    vec3 col = vec3(1.);


    uv.y = fract(uv.y + uTime);
    float r = rect(.01, -.00, .1, -.1, .005, uv);
    r +=  rect(.4, .39, .0, -.2, .005, uv);
    r +=  rect(.2, .19, .4, .2, .005, uv);
    r +=  rect(-.43, -.44, .1, -.1, .005, uv);
    r +=  rect(-.2, -.21, .3, .1, .005, uv);
    r +=  rect(.15, .14, -.3, -.48, .005, uv);
    r +=  rect(-.3, -.31, -.2, -.4, .005, uv);
    r +=  rect(-.4, -.41, .45, .35, .005, uv);
    r +=  rect(.5, .49, .35, .18, .005, uv);
    r +=  rect(-.01, -.02, .5, .36, .005, uv);
    r +=  rect(-.15, -.16, -.3, -.5, .005, uv);
    col *= r;

    gl_FragColor = vec4(col, 1.);
}