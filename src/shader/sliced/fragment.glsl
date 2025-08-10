varying vec3 vPosition;

uniform float uSliceStart;
uniform float uSliceArc;

void main(){
    float SliceStart = uSliceStart;
    float SliceArc = uSliceArc;

    // angle
    float angle = atan(vPosition.y, vPosition.x);
    angle -= SliceStart;
    angle = mod(angle, PI2);
    
    if ( angle > 0. && angle < SliceArc)
        discard;

    float csm_Slice;

    // if (!gl_FrontFacing)
    //     csm_FragColor = vec4( 0.75, 0.15, 0.1, 1.);
    // csm_DiffuseColor *= vec4(vec3(angle), 1.0);
}