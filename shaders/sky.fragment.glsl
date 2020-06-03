precision mediump float;

uniform mat4 uProjection;

varying vec4 varColor;
varying vec3 varPos;

const vec4 up = vec4(0.0,1.0,0.0,1.0);
const vec4 black = vec4(0.0,0.0,0.0,1.0);

void main(){
  vec4 c = varColor;
  vec4 pos = vec4(varPos.x, 1.0, varPos.z, 1.0);
  pos = pos * uProjection;
  pos = pos * (1.0/pos.w);
  pos = normalize(pos);

  float d = (dot(pos, up)+1.0)/2.0;
  c = mix(black, c, d);

  gl_FragColor = vec4(d,d,d,1.0);
}