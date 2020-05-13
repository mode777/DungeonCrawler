precision mediump float;

varying vec2 varTexcoord;
varying vec3 varNormal;
varying vec3 varPos;

uniform sampler2D uTexture;
uniform vec3 uLight0;

void main(){

  vec4 color = texture2D(uTexture, varTexcoord);

  // fog
  const float LOG2 = 1.442695;
  float z = gl_FragCoord.z / gl_FragCoord.w;
  float fogFactor = exp2( -0.1 * // -Density
            0.1 * // Density
            z * 
            z * 
            LOG2 );
  fogFactor = clamp(fogFactor, 0.0, 1.0);

  //light
  vec3 norm = normalize(varNormal);
  vec3 lightDir = normalize(uLight0 - varPos);
  float diff = max(dot(norm, lightDir), 0.0);
  vec3 diffuse = diff * vec3(1.0);  // Light color
  color = color * vec4(diffuse, 1.0);

  gl_FragColor = mix(vec4(0.08,0.0,0.1,1.0), color, fogFactor );
}