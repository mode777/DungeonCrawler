precision mediump float;

varying vec2 varTexcoord;
uniform sampler2D uTexture;

void main(){
  vec4 color = texture2D(uTexture, varTexcoord);
  gl_FragColor = color;
}

