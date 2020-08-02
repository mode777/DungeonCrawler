precision mediump float;

uniform sampler2D uTexture;
//uniform sampler2D uNoise;
uniform vec3 uFogColor;
uniform vec2 uTextureSize;

varying vec2 varTexcoord;
varying vec4 varColor;

float dither(float v, float m){
  v = m - floor(v*m);
  return clamp(mod(gl_FragCoord.x+m,v), 0.0, 1.0);
}

void main(){

  const float LOG2 = 1.442695;
  float z = gl_FragCoord.z / gl_FragCoord.w;
  float density = 0.03;
  float fogFactor = exp2( -density * // -Density
            density * // Density
            z * 
            z * 
            LOG2 );
  //z = z / 25.0;
  //float fogFactor = 1.0-z;
  //fogFactor = floor(fogFactor * 10.0) / 10.0;
  //fogFactor = dither(fogFactor, 32.0);
  // dither
  // float noise = texture2D(uNoise, gl_FragCoord.xy/255.0).x;
  // fogFactor = floor(smoothstep(0.4,0.6,noise+fogFactor)*2.0)/2.0;
  
  fogFactor = smoothstep(0.0,0.7,fogFactor);
  vec4 fogColor = vec4(uFogColor/255.0, 1.0);
  vec4 fac = varColor;
  vec4 color = texture2D(uTexture, varTexcoord/uTextureSize) * fac;

  if(color.a < 1.0) discard;

  //vec2 noisecoord = mod(varTexcoord, 32.0);
  //float noise = texture2D(uTexture, noisecoord/uTextureSize).r;
  //fogFactor = mix(noise,1.0,fogFactor);
  //fogFactor = floor(smoothstep(0.0,0.8,(fogFactor)*(noise+1.0)) * 4.0) / 4.0;
  
  gl_FragColor = mix(fogColor, color, fogFactor);
  //gl_FragColor = vec4(z,z,z,1.0);
}

