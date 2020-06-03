attribute vec3 vPosition;
attribute vec4 vColor;

uniform mediump mat4 uProjection;


varying vec4 varColor;
varying vec3 varPos;

void main(){
  varColor = vColor;
  varPos = vPosition;
  
  gl_Position = vec4(vPosition,1.0);
}

