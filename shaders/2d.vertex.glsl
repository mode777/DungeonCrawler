attribute vec2 vPosition;
attribute vec2 vTexcoord;
attribute vec4 vColor;

varying vec2 varTexcoord;
varying vec4 varColor;

uniform mat4 uProjection;
uniform mat4 uModel;
uniform mat4 uView;
uniform vec2 uTextureSize;


void main(){
  varColor = vColor;
  varTexcoord = vTexcoord / uTextureSize;

  vec4 position = uProjection * uModel * uView * vec4(vPosition.xy, 0.0, 1.0);
  position.z = 0.0;

  gl_Position = position;
}