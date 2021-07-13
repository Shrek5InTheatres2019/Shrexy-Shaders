#version 330 compatibility

varying vec4 texcoord;
uniform sampler2D colortex0;
/*DRAWBUFFERS:0*/

void main(){

  gl_FragData[0] = texture2D(colortex0, texcoord.st);
}
