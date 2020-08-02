import "graphics" for Shader, Renderer, UniformType, RendererFeature
import "geometry" for AttributeType

class Gfx is Shader {
  construct fromFiles(){
    var mapping = {
      "attributes": {
        "vPosition": AttributeType.Position,
        "vTexcoord": AttributeType.Texcoord0,
        "vColor": AttributeType.Color,
        "vOffset": AttributeType.Offset
      },
      "uniforms": {
        "uTexture": UniformType.Texture0,
        //"uNoise": UniformType.Texture1,
        "uProjection": UniformType.Projection,
        "uModel": UniformType.Model,
        "uView": UniformType.View,
        "uTextureSize": UniformType.TextureSize,
        "uFogColor": UniformType.FogColor
      }
    } 
    super("./shaders/terrain.vertex.glsl","./shaders/terrain.fragment.glsl", mapping)
  }

  enable(){
    Renderer.toggleFeature(RendererFeature.Blend, false)
    Renderer.toggleFeature(RendererFeature.CullFace, true)
    Renderer.toggleFeature(RendererFeature.DepthTest, true)
    super.enable()
  }
}