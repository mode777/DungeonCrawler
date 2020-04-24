import "augur" for Augur, Assert
import "gltf" for Gltf
import "geometry" for AttributeType
import "graphics" for Renderer

Augur.describe("Gltf") {

  Augur.it("should load file"){
    var gltf = Gltf.fromFile("./tests/gltf/stone2.gltf") 
    
    Assert.equal(gltf.meshes.count, 1)
    Assert.equal(gltf.meshes[0].primitives.count, 2)
    Assert.equal(gltf.meshes[0].primitives[0].count, 3)
    Assert.defined(gltf.meshes[0].primitives[0].indices)

    Assert.defined(gltf.meshes[0].primitives[0][AttributeType.Texcoord0])
    Assert.defined(gltf.meshes[0].primitives[0][AttributeType.Position])
    Assert.defined(gltf.meshes[0].primitives[0][AttributeType.Normal])

    Assert.equal(gltf.textures.count, 2)
  }

  Augur.it("should create texture"){
    var gltf = Gltf.fromFile("./tests/gltf/stone2.gltf") 
    var txt = gltf.textures[0].toGraphicsTexture()
    Renderer.checkErrors()
  }

  Augur.it("should create mesh"){
    var gltf = Gltf.fromFile("./tests/gltf/stone2.gltf") 
    var mesh = gltf.meshes[0].toGraphicsMesh()
    Renderer.checkErrors()
  }

}