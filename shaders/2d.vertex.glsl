attribute vec2 vPosition;
attribute vec2 vTexcoord;

varying vec2 varTexcoord;

void main(){

  varTexcoord = vTexcoord;

  vec4 position = vec4(vPosition.x * 2.0 - 1.0, (1.0-vPosition.y)*2.0-1.0, 0.0, 1.0);

  gl_Position = position;
}