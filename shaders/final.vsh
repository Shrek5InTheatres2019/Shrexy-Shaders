#version 330 compatibility

varying vec4 texcoord;
varying vec3 normal;
varying vec4 position;
void main(){
  texcoord = gl_MultiTexCoord0;
  normal = gl_NormalMatrix * gl_Normal;
  position = gl_ModelViewProjectionMatrix * gl_Vertex;

  gl_Position = position;
}
