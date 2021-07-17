#version 330 compatibility  

varying vec4 texcoord;

varying vec3 normal;
varying vec3 worldPos;

uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

void main(){
    texcoord = gl_MultiTexCoord0;
    normal = normalize(gl_NormalMatrix * gl_Normal);
    worldPos = (gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex)).xyz + cameraPosition;
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}