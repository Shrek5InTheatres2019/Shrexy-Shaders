#version 330 compatibility

varying vec4 texcoord;

varying vec4 blockColor;
varying vec3 normal;

uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform int worldTime;
uniform float frameTime;
uniform sampler2D noisetex;
uniform mat4 gbufferModelView;
attribute vec2 mc_midTexCoord;  
attribute vec3 mc_Entity;
const float PI = 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main(){
    texcoord = gl_MultiTexCoord0;

    blockColor = gl_Color;
    normal = normalize(gl_NormalMatrix * gl_Normal);

    bool isTop = texcoord.y < mc_midTexCoord.y;
    vec3 worldPos = (gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex)).xyz + cameraPosition;
    if(mc_Entity.x == 10021 || (mc_Entity.x == 10022 && isTop) || (mc_Entity.x == 10023 && isTop) || mc_Entity.x == 10024){
        float magnitude = sin(worldTime * PI / 204) * 0.05;
        worldPos.x += sin((worldTime * (worldPos.x / 100)) * PI / 154) * magnitude;
        worldPos.z += sin((worldTime * (worldPos.y / 100)) * PI / 92) * magnitude;
    }
    gl_Position = gl_ProjectionMatrix * (gbufferModelView * vec4(worldPos - cameraPosition, 1.0));
}