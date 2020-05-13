attribute vec3 vPosition;
attribute vec2 vTexcoord;
attribute vec3 vNormal;

varying vec2 varTexcoord;
varying vec3 varNormal;
varying vec3 varPos;

uniform mat4 uProjection;
uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uNormal;
//uniform vec3 uLight0;

void main(){
  varTexcoord = vTexcoord;
  varNormal = mat3(uNormal) * vNormal;
  //varNormal = vNormal;
  varPos = vec3(uModel * vec4(vPosition, 1.0));

  gl_Position = uProjection * uView * uModel * vec4(vPosition,1.0);
}