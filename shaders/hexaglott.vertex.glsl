attribute vec3 vPosition;
attribute vec3 vNormal;
attribute vec2 vTexcoord;

varying vec4 varColor;

uniform mat4 uProjection;
uniform mat4 uModel;
uniform mat4 uView;
uniform sampler2D uTexture;

uniform vec3 uLight;
const vec4 black = vec4(0.1,0.0,0.2,1.0);
const vec4 white = vec4(1.0,0.8,0.5,1.0);

void main(){
  vec3 lightDir = normalize(uLight);
  float d = dot(vNormal, lightDir);
  float x = (d + 1.0) / 2.0;
  float y = vTexcoord.y;
  float offset = vTexcoord.x - 0.5;


  vec4 color = texture2D(uTexture, vec2(x+offset,y));

  varColor = color;
  //varColor = vec4(normalize(vNormal),1.0) + vec4(vColor*0.0);
  gl_Position = uProjection * uView * uModel * vec4(vPosition,1.0);
}

