#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D colortex4;
uniform sampler2D depthtex0;
uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;
vec2 camerarange = vec2(near, far);
vec2 screensize = vec2(viewWidth, viewHeight);
varying vec4 texcoord;


#define EDGE_DETECTION_DIVISOR 1.5 //divisor for edge detection intensity, higher values means less intense outlines [1.0 1.2 1.5 2 2.5 3 5 10]



mat3 sx = mat3( 
    1.0, 2.0, 1.0, 
    0.0, 0.0, 0.0, 
   -1.0, -2.0, -1.0 
);
mat3 sy = mat3( 
    1.0, 0.0, -1.0, 
    2.0, 0.0, -2.0, 
    1.0, 0.0, -1.0 
);


vec3 detectEdges(){
    mat3 I;
    for (int i=0; i<3; i++) {
        for (int j=0; j<3; j++) {
            vec3 sample  = texelFetch(colortex0, ivec2(gl_FragCoord) + ivec2(i-1,j-1), 0 ).rgb;
            I[i][j] = length(sample); 
		}
	}


	float gx = dot(sx[0], I[0]) + dot(sx[1], I[1]) + dot(sx[2], I[2]); 
	float gy = dot(sy[0], I[0]) + dot(sy[1], I[1]) + dot(sy[2], I[2]);

	float g = sqrt(pow(gx, 2.0)+pow(gy, 2.0)) / EDGE_DETECTION_DIVISOR;
	return (vec3(1) - (vec3(g, g, g) * (1.9 - texture2D(depthtex0, texcoord.st).rgb))) ;
}

/*DRAWBUFFERS:04*/

void main(void)
{
	vec3 diffuse = texture2D(colortex0, texcoord.st).rgb;
    diffuse = diffuse * detectEdges();
	gl_FragData[0] = vec4(diffuse, 1.0);
	gl_FragData[1] = texture2D(colortex4, texcoord.st);
}
