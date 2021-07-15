#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D colortex4;

uniform vec3 cameraPosition;   

uniform mat4 gbufferModelView;
uniform mat4 gbufferProjection;

uniform float viewWidth;
uniform float viewHeight;
vec2 resolution = vec2(viewWidth, viewHeight);

uniform float near;
uniform float far;

varying vec4 texcoord;
varying vec3 normal;
varying vec4 position;


float layers = 1024;


float map(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

float linearize_depth(float d,float zNear,float zFar)
{
    return zNear * zFar / (zFar + d * (zNear - zFar));
}

vec2 ParallaxOcclusionMapping( sampler2D depthMap, vec2 uv, vec2 displacement, float pivot ) {
	float layerDepth = 1.0 /  layers;
	float currentLayerDepth = 0.0;

	vec2 deltaUv = displacement / layers;
	vec2 currentUv = uv + pivot * displacement;
	float currentDepth = (texture2D( depthMap, currentUv ).a * 0.5);

	for( int i = 0; i < layers; i++ ) {
		if( currentLayerDepth > currentDepth )
			break;

		currentUv -= deltaUv;
		currentDepth = (texture2D( depthMap, currentUv ).a * 0.5);
		currentLayerDepth += layerDepth;
	}

	vec2 prevUv = currentUv + deltaUv;
	float endDepth = currentDepth - currentLayerDepth;
	float startDepth =
		(texture2D( depthMap, currentUv ).a * 0.5) - currentLayerDepth + layerDepth;

	float w = endDepth / ( endDepth - startDepth );

	return mix( currentUv, prevUv, w );
}
vec3 thing(float depth){
    mat4 projInv = inverse(gbufferProjection * gbufferModelView); // There's probably a uniform for this
    vec4 vec = vec4(gl_FragCoord.xy / resolution, depth, 1.0);
    vec4 clip = projInv * vec;
    return ((clip / clip.w).xyz);
}



void main(void){
    vec2 nice = ParallaxOcclusionMapping(colortex4, texcoord.st, thing(linearize_depth(texture2D(depthtex1, texcoord.st).r * 0.09, near, far)).xy * 0.25, 0.5);
	
    

	gl_FragData[0] = texture2D(colortex0, nice);
}