attribute vec3 vPosition;
attribute vec2 vTexcoord;

varying vec2 varTexcoord;

uniform mat4 uProjection;
uniform mat4 uModel;
uniform mat4 uView;

void main(){
  varTexcoord = vTexcoord;
  gl_Position = uProjection * uView * uModel * vec4(vPosition,1.0);
}