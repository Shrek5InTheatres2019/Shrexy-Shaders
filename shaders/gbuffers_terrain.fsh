#version 330 compatibility

varying vec4 texcoord;
varying vec4 blockColor;
varying vec3 normal;

uniform sampler2D tex;
uniform sampler2D normals;
uniform sampler2D depthtex1;

void main(){
    vec4 color = texture2D(tex, texcoord.st);
    vec4 normalMap = texture2D(normals, texcoord.st);
    color *= blockColor;
    gl_FragData[0] = color;
    gl_FragData[4] = normalMap;
}