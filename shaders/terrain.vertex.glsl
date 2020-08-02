attribute vec3 vPosition;
attribute vec2 vTexcoord;
attribute vec4 vColor;
attribute vec3 vOffset;
//attribute vec3 vNormal;

varying vec2 varTexcoord;
varying vec4 varColor;
//varying vec4 varColor;
//varying vec3 varNormal;
//varying vec3 varPos;

uniform mat4 uProjection;
uniform mat4 uModel;
uniform mat4 uView;
uniform sampler2D uTexture;

void main(){
  varTexcoord = vTexcoord;
  varColor = vColor;
  //vec2 uv = (vPosition.xz + 5.0) / 10.0;
  //float y = texture2D(uTexture, uv).x * 5.0;
  vec4 world = uModel * vec4(vPosition,1.0);
  world = world + vec4(vOffset, 0.0); 
  //world.y = y;
  gl_Position = uProjection * uView * world;
}