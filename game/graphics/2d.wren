import "graphics" for Shader, Renderer, Geometry, Mesh, Node, UniformType, RendererFeature, Texture, DiffuseMaterial, TextureFilters, TextureWrap
import "platform" for Application, Event
import "helpers" for CameraHelpers
import "geometry" for GeometryData, AttributeType
import "math" for Mat4, Noise, Vec3, Vec4
import "memory" for FloatVecAccessor, UShortAccessor, Grid
import "camera" for OrthograficCamera
import "gltf" for Gltf
import "image" for Image
import "2d" for Tileset, AbstractBatch, SpriteBatch, Quad
import "component" for Component
import "container" for GlobalContainer

GlobalContainer.registerFactory("Gfx2dComponent"){ |c| Gfx2dComponent.new(c.resolve("MAP"), c.resolve("PLAYER")) }

class Gfx2dComponent {
  construct new(map, player){
    _mapState = map
    _playerState = player
  }

  start(){
    _scale = 4
    _cam = OrthograficCamera.new()
    _target = Vec3.zero()
    load()
  }

  update(){
    var p = _playerState["position"]
    var t = _playerState["heading"]
    Vec3.mulV(t,0.5,_target)
    Vec3.add(p, _target, _target)

    updatePointer(p[0],p[2],_target[0],_target[2])

    Renderer.set2d()
    _cam.enable()
    if(_batch) _batch.draw()
  }

  load(){
    var txt = Texture.fromImage(_mapState["img"], {"magFilter": TextureFilters.Nearest, "minFilter": TextureFilters.Nearest, "mipmaps": false })
    _batch = SpriteBatch.new(txt,3)
    var s = Quad.new(0,0,txt.width,txt.height)
    var t = Quad.new(0,0,txt.width * _scale, txt.height * _scale)
    _batch.setSprite(0, s,t, [255,255,255,128])
    s.set(1,1,1,1)
    t.set(0,0,_scale/2, _scale/2)
    _batch.setSprite(1, s, t, [255,0,0,255])
    _batch.setSprite(2, s, t, [255,255,0,255])
    
    _pointer = Quad.clone(t)
    _pointer_target = t
  }

  updatePointer(x,y,tx,ty) {
    _pointer.set(x*_scale-_scale/4,y*_scale-_scale/4,_scale/2, _scale/2)
    _batch.setTarget(1, _pointer)
    _pointer_target.set(tx*_scale-_scale/4,ty*_scale-_scale/4,_scale/2, _scale/2)
    _batch.setTarget(2, _pointer_target)
  }

}