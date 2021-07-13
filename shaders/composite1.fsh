#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D colortex4;

varying vec4 texcoord;
/*DRAWBUFFERS:01*/
void main(void){
    gl_FragData[0] = vec4(texture2D(colortex0, texcoord.st).rgb, 1.0);
    gl_FragData[4] = texture2D(colortex4, texcoord.st);
}