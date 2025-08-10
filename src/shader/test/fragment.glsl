

uniform vec3 iResolution;
uniform float iTime;

#define PI 3.14159265359


float plot(vec2 st, float pct){
    return smoothstep( pct-0.02, pct, st.y) - smoothstep( pct, pct+0.02, st.y);
}

void main(){
    //normalizing fragCoord
    // vec2 st = gl_FragCoord.xy/uResolution;
    // gl_FragColor = vec4( st.x, st.y, .0, 1.);
    // vec2 fl  = clamp(gl_FragCoord.xy, 0.0, 1.0); 
    vec2 st = vec2(gl_FragCoord.x + .5, gl_FragCoord.y + .5)/iResolution.xy;
    // st = clamp(st, 0.0, 1.0);

    //**** step and smoothstep

    //float y =  step(.5, st.x);
    // float y = smoothstep(.2, .8, st.x);
    // float y = smoothstep(0.2,0.5,st.x) - smoothstep(0.5,0.8,st.x);d

     //sine and cosine
    float y = st.x;
    // y += uTime;
    // y *= PI;
    // y = (sinn(y + uTime * PI) + 1.) * .5;
    // y = abs(sin(y + uTime));
    // y = fract(sin(y + uTime));

    // y =  1. - pow( abs(y ), .5); //karate a-1
    // y = 1. - pow(abs(y), 1.); //karate a-2
    // y = 1. - pow(abs(y), 3.5); //karate a-3
    y = 1. - pow(cos(PI * y / 2.), .5); 

    


    
    vec3 color = vec3(y);
    float pct = plot(st, y);
    
    color = (1.0-pct)*color+pct*vec3(0.0,1.0,0.0);


    gl_FragColor = vec4( vec3(color), 1.);

    // gl_FragColor = vec4(1.);
}