attribute vec3 vPosition;
attribute vec3 vNormal;
attribute vec4 vColor;

varying vec4 varColor;

uniform mat4 uProjection;
uniform mat4 uModel;
uniform mat4 uView;

uniform vec3 uLight;
const vec4 black = vec4(0.1,0.0,0.2,1.0);
const vec4 white = vec4(1.0,0.8,0.5,1.0);

void main(){
  vec3 lightDir = normalize(uLight);
  float d = dot(vNormal, lightDir);
  //float low = clamp(d, -1.0,0.0) * -1.0;
  float high = max(d, 0.5) - 0.5;
  float r = 1.0 - ((d + 1.0) / 2.0);
  r = min(r, 0.9);
  vec4 color = mix(vColor, black, r);
  color = mix(color, white, high);
  
  varColor = color;
  //varColor = vec4(normalize(vNormal),1.0) + vec4(vColor*0.0);
  gl_Position = uProjection * uView * uModel * vec4(vPosition,1.0);
}

