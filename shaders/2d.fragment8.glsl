precision mediump float;

varying vec4 varColor;
varying vec2 varTexcoord;
uniform sampler2D uTexture;
uniform sampler2D uPalette;

void main(){
  float indexed = texture2D(uTexture, varTexcoord).r;
  vec2 uv = vec2(indexed, 0);
  vec4 color = texture2D(uPalette, uv);
  gl_FragColor = color;
}

