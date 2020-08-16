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

import "./game/infrastructure" for GameSystem
import "./game/events" for SystemEvents, MapEvents, PlayerEvents

GameSystem.attach("main"){|sys|
  sys.queue.subscribeCombined([PlayerEvents.Init, MapEvents.Load]){|evs|
    var playerState = evs[0].payload
    var mapState = evs[1].payload

    var scale = 4
    var cam = OrthograficCamera.new()
    var target = Vec3.zero()
    var txt = Texture.fromImage(mapState.image, {"magFilter": TextureFilters.Nearest, "minFilter": TextureFilters.Nearest, "mipmaps": false })
    var batch = SpriteBatch.new(txt,3)
    var s = Quad.new(0,0,txt.width,txt.height)
    var t = Quad.new(0,0,txt.width * scale, txt.height * scale)
    
    batch.setSprite(0, s,t, [255,255,255,128])
    s.set(1,1,1,1)
    t.set(0,0,scale/2, scale/2)
    batch.setSprite(1, s, t, [255,0,0,255])
    batch.setSprite(2, s, t, [255,255,0,255])
    
    var pointer = Quad.clone(t)
    var pointertarget = t
    
    sys.queue.subscribe(SystemEvents.Update){|ev|
      var p = playerState["position"]
      var t = playerState["heading"]
      Vec3.mulV(t,0.5,target)
      Vec3.add(p, target, target)

      // update pointer
      pointer.set(p[0]*scale-scale/4,p[2]*scale-scale/4,scale/2, scale/2)
      batch.setTarget(1, pointer)
      pointertarget.set(target[0]*scale-scale/4,target[2]*scale-scale/4,scale/2, scale/2)
      batch.setTarget(2, pointertarget)
    }

    sys.queue.subscribe(SystemEvents.Draw2){|ev|
      Renderer.set2d()
      cam.enable()
      batch.draw()      
    }

  }
}