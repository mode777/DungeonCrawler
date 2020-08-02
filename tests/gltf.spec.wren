import "augur" for Augur, Assert
import "gltf" for Gltf
import "geometry" for AttributeType
import "graphics" for Renderer

Augur.describe("Gltf") { 


  Augur.it("should load file"){
    var gltf = Gltf.fromFile("./tests/gltf/stone2.gltf") 
    
    Assert.equal(gltf.meshes.count, 1)
    Assert.equal(gltf.meshes[0].primitives.count, 2)
    Assert.equal(gltf.meshes[0].primitives[0].geometryData.count, 3)
    Assert.defined(gltf.meshes[0].primitives[0].geometryData.indices)
    Assert.defined(gltf.meshes[0].primitives[0].geometryData[AttributeType.Texcoord0])
    Assert.defined(gltf.meshes[0].primitives[0].geometryData[AttributeType.Position])
    Assert.defined(gltf.meshes[0].primitives[0].geometryData[AttributeType.Normal])

    Assert.equal(gltf.textures.count, 2)
  }

  Augur.it("should create texture"){
    var gltf = Gltf.fromFile("./tests/gltf/stone2.gltf") 
    var txt = gltf.textures[0].toGraphicsTexture()
    Renderer.checkErrors()
  }

  // Augur.it("should create meshes"){
  //   var gltf = Gltf.fromFile("./tests/gltf/stone2.gltf") 
  //   var meshes = gltf.meshes[0].toGraphicsMeshes()
  //   Renderer.checkErrors()
  // }

  // Augur.it("should create meshes"){
  //   var gltf = Gltf.fromFile("./tests/gltf/three.gltf") 
  //   var meshes = gltf.scene("Scene").toGraphicsMeshes()
  //   Assert.equal(meshes.count, 4)
  //   Renderer.checkErrors()
  // }

  Augur.it("should load from binary file") {
    var glb = Gltf.fromFile("./tests/gltf/out.glb")
    //glb.images[0].save("test.tga")
    Assert.equal(glb.images.count, 1)
  }
}

