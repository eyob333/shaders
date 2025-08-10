
varying vec2 vUv;

uniform vec2 iResolution;
uniform float iTime;

float remap01(float a, float b, float t){

    return (t - a) / (b -a) ;
}
float remap( float a, float b, float c, float d, float t){
    return remap01( a, b, t) * (d -c) + c ;
}

float circle(vec2 uv, vec2 p, float r, float blur){
    float d = length(uv - p);
    return smoothstep( r,r - blur, d);
}

float smile(vec2 uv, vec2 p, float size){
    uv -= p;
    uv /= size;
    float mask = circle(uv, vec2(.0), .4, .01);
    mask -= circle(uv, vec2(.13, .12), .07, .01);
    mask -= circle(uv, vec2(-.13, .12), .07, .01);

    float motuh = circle(uv, vec2(.0), .3, .02);
    motuh -= circle(uv, vec2(.0, .1), .3,  .02);
    mask -= motuh;

    return mask;
}

float band( float t, float start, float end, float blur){
    float step1 = smoothstep(start - blur, start + blur, t );
    float step2 = smoothstep(end + blur, end - blur, t);

    return  step1 * step2;
}

float react( vec2 uv, float top, float right, float bottom ,float left, float blur){
    float band1 = band(uv.x, left, right, blur) ;
    float band2 = band(uv.y, bottom, top, blur) ;
    return band1 * band2;
}

void main(){
    vec2 uv = vUv;
    float aspect = iResolution.x / iResolution.y;
    float t = iTime;
    uv -= .5;
    uv.x *= aspect;

    float mask = 0.;
    float y = uv.y;
    float x = uv.x;

    // float m = (x+.5) * ( x- .5);
    // m *= m * 4.;
    float m = cos(x * 5. + iTime) * .1;
    y -= m;
    float blur = remap( -.5, .5, 0.002, .1, x);
    blur = pow(blur* 8., 3.);
    // y += x
    // mask += smile(uv, vec2(.0), .5);
    // mask = band(uv.x,  -.2, .2, .01);
    mask = react(vec2(x, y), .1 , .5 , -.1, -.5 , blur);

    vec3 col = vec3(1., 1., 1.) * mask ;
    // if (d < .3) c = 0.; else c = 1.;
    gl_FragColor = vec4(col, 1.);
}