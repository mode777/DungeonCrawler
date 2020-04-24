import "augur" for Augur, Assert
import "image" for Image
import "geometry" for AttributeType, GeometryData
import "memory" for DataType, Buffer, BufferView, FloatVecAccessor, UShortAccessor

import "graphics" for Geometry, Texture, Attribute, GraphicsBuffer, VertexIndices, Renderer, Mesh

Augur.describe("Texture") {

  Augur.it("should create from image") {
    var img = Image.new(128,128)
    var text = Texture.fromImage(img)
  }

  Augur.it("should create from file") {
    var text = Texture.fromFile("./tests/test.tga")
  }

}

Augur.describe("GraphicsBuffer") {
  Augur.it("constructs from BufferView") {
    var bv = BufferView.new(Buffer.new(1024))
    var gb = GraphicsBuffer.forVertices(bv)
  }
}

Augur.describe("Attribute") {
  Augur.it("constructs") {
    var bv = BufferView.new(Buffer.new(1024))
    var gb = GraphicsBuffer.forVertices(bv)
    var pos = Attribute.new(gb, AttributeType.Normal, 3, DataType.Float, false, 20, 0)
    var texcoord = Attribute.new(gb, AttributeType.Texcoord1, 2, DataType.Float, false, 20, 12)
    Renderer.checkErrors()
  }

  Augur.it("enables"){
  	var bv = BufferView.new(Buffer.new(1024))
    var gb = GraphicsBuffer.forVertices(bv)
    var pos = Attribute.new(gb, AttributeType.Normal, 3, DataType.Float, false, 0, 0)
    pos.enable()
    Renderer.checkErrors()
  }
}

Augur.describe("VertexIndices") {
  Augur.it("constructs"){
    var bv = BufferView.new(Buffer.new(1024))
    var gb = GraphicsBuffer.forIndices(bv)
    var idx = VertexIndices.new(gb, 512, DataType.UShort)
    Renderer.checkErrors()
  }

  Augur.it("draws"){
    var bv = BufferView.new(Buffer.new(1024))
    var gb = GraphicsBuffer.forIndices(bv)
    var idx = VertexIndices.new(gb, 512, DataType.UShort)
    idx.draw()
    Renderer.checkErrors()
  }
}


var createGD = Fn.new {
  return GeometryData.new({
    AttributeType.Position: FloatVecAccessor.new(4, 3),
    AttributeType.Texcoord1: FloatVecAccessor.new(4, 2)
  }, UShortAccessor.new(6))
}

Augur.describe("Geometry") {

  Augur.it("constructs from geometry data"){
    var gd = createGD.call()
    var g = Geometry.new(gd)
    Renderer.checkErrors()
  }

  Augur.it("draws"){
    var gd = createGD.call()
    var g = Geometry.new(gd)
    g.draw()
    Renderer.checkErrors()
  }
}

Augur.describe("Mesh"){
  
  var createG = Fn.new {
    var gd = createGD.call()
    return Geometry.new(gd)
  }
  
  Augur.it("construct from Geometry"){
    var g1 = createG.call()
    var g2 = createG.call()
    var m = Mesh.new([g1,g2])
  }
}



// Augur.describe("Mesh") {
//   Augur.it("should create from geometry data"){
//     var mesh = Mesh.create(geoData, material)
//   }
// }