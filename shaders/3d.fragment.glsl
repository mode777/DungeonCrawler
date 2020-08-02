//
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : stegu
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//               https://github.com/stegu/webgl-noise
// 
precision mediump float;

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

float snoise(vec2 v)
  {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

varying vec2 varTexcoord;
//varying vec4 varColor;
//varying vec3 varNormal;
varying vec3 varPos;

uniform float t;
uniform sampler2D uTexture;
//uniform vec3 uLight0;

void main(){

  vec4 color = texture2D(uTexture, varTexcoord, -1.0);
  //vec4 color = varColor;

  // fog
  const float LOG2 = 1.442695;
  float z = gl_FragCoord.z / gl_FragCoord.w;
  float density = 0.03;
  float fogFactor = exp2( -density * // -Density
            density * // Density
            z * 
            z * 
            LOG2 );
  //float  fogFactor = (1.0-z*0.02);
  //fogFactor = smoothstep(0.0, 0.5, fogFactor);

  //float volume = abs((cos(varPos.z/2.0+t*0.25) * sin(varPos.x/4.0+t*0.125)));
  //volume = smoothstep(0.2, 1.0, volume) * 0.5;
  float volume = clamp(snoise(vec2(varPos.x/16.0+t*0.1, varPos.z/8.0+t*0.2)), 0.0, 1.0) * 0.4; 
  //float volume = 0.0;
  //light
  // vec3 norm = normalize(varNormal);
  // vec3 lightDir = normalize(uLight0 - varPos);
  // float diff = max(dot(norm, lightDir), 0.0);
  // vec3 diffuse = diff * vec3(1.0);  // Light color
  // color = color * vec4(diffuse, 1.0);

  gl_FragColor = mix(vec4(1.0,1.0,1.0,1.0), color * (1.0-volume), 1.0);
}

