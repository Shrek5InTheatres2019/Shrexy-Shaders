#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;
uniform sampler2D colortex4;

uniform vec3 cameraPosition;   

uniform mat4 gbufferModelView;
uniform mat4 gbufferProjection;

uniform float viewWidth;
uniform float viewHeight;
float resolution = viewWidth / viewHeight;

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
	float currentDepth = texture2D( depthMap, currentUv ).a;

	for( int i = 0; i < layers; i++ ) {
		if( currentLayerDepth > currentDepth )
			break;

		currentUv -= deltaUv;
		currentDepth = texture2D( depthMap, currentUv ).a;
		currentLayerDepth += layerDepth;
	}

	vec2 prevUv = currentUv + deltaUv;
	float endDepth = currentDepth - currentLayerDepth;
	float startDepth =
		texture2D( depthMap, currentUv ).a - currentLayerDepth + layerDepth;

	float w = endDepth / ( endDepth - startDepth );

	return mix( currentUv, prevUv, w );
}
vec3 thing(float depth){
    mat4 projInv = inverse(gbufferProjection * gbufferModelView); // There's probably a uniform for this
    vec4 vec = vec4(gl_FragCoord.xy / resolution, depth, 1.0);
    vec4 clip = projInv * vec;
    return ((clip / clip.w).xyz);
}

vec3 fromWorldCoordsToScreenCoords(vec3 wc)
{
		vec4 pos0 = gl_ModelViewProjectionMatrix * vec4(wc, 1.0);
	 	pos0 /= pos0.w;		
		return pos0.xyz;
}

/*DRAWBUFFERS:0*/
void main(void){
	vec3 ndc = fromWorldCoordsToScreenCoords(cameraPosition);
	vec2 yo = -(ndc.xy / ndc.z);
	
    vec2 nice = ParallaxOcclusionMapping(colortex4, texcoord.st, ndc.xy * 0.00001, 1.0);
	float pom = texture2D(colortex4, texcoord.st).a;
    if(pom == 0){
		gl_FragData[0] = vec4(texture2D(colortex0, texcoord.st).rgb, 1.0);
	}else{
		gl_FragData[0] = vec4(texture2D(colortex0, nice).rgb, 1.0);
	}
}