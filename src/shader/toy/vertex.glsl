
varying vec2 vUv;

void main(){
    vUv = uv.xy;
    gl_Position = vec4(position, 1.);
    
}