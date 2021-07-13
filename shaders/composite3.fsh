#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform sampler2D colortex4;

uniform vec3 cameraPosition;   

varying vec4 texcoord;
varying vec3 normal;
varying vec4 position;


float layers = 256;


float map(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}


vec2 ParallaxOcclusionMapping( sampler2D depthMap, vec2 uv, vec2 displacement, float pivot ) {
	float layerDepth = 1.0 /  layers;
	float currentLayerDepth = 0.0;

	vec2 deltaUv = displacement / layers;
	vec2 currentUv = uv + pivot * displacement;
	float currentDepth = (texture2D( depthMap, currentUv ).a * 0.3);

	for( int i = 0; i < layers; i++ ) {
		if( currentLayerDepth > currentDepth )
			break;

		currentUv -= deltaUv;
		currentDepth = (texture2D( depthMap, currentUv ).a * 0.3);
		currentLayerDepth += layerDepth;
	}

	vec2 prevUv = currentUv + deltaUv;
	float endDepth = currentDepth - currentLayerDepth;
	float startDepth =
		(texture2D( depthMap, currentUv ).a * 0.3) - currentLayerDepth + layerDepth;

	float w = endDepth / ( endDepth - startDepth );

	return mix( currentUv, prevUv, w );
}
void main(void){
    vec2 nice = ParallaxOcclusionMapping(colortex4, texcoord.st, (gl_FragCoord.xyz - cameraPosition).st * 0.000025, 0.0);
	  
    

	gl_FragData[0] = normalize(texture2D(colortex0, nice));
}