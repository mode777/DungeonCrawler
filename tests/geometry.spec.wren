
import "augur" for Augur, Assert
import "memory" for FloatVecAccessor, UShortAccessor
import "geometry" for GeometryData, AttributeType
import "math" for Mat4

Augur.describe("GeometryData") {

  var create = Fn.new {
    return GeometryData.new({
      AttributeType.Position: FloatVecAccessor.new(4, 3),
      AttributeType.Texcoord1: FloatVecAccessor.new(4, 2)
    }, UShortAccessor.new(6))
  }

  Augur.it("is created by accessors"){
    var p = create.call() 

    p[AttributeType.Position][0] = [1,1,1]
    p[AttributeType.Texcoord1][0] = [2,2]
    
    Assert.equal(p.count, 2)
    Assert.elementsEqual(p[AttributeType.Position][0], [1,1,1])
    Assert.elementsEqual(p[AttributeType.Texcoord1][0], [2,2])
  }

  Augur.it("calculates index size"){
    var gd = create.call()
    Assert.equal(gd.indexSize(), 12)
  }

  Augur.it("calculates combined vertices size"){
    var gd = create.call()
    Assert.equal(gd.combinedVertexSize(), 80)
  }

  Augur.it("calculates vertex size"){
    var gd = create.call()
    Assert.equal(gd.vertexSize(), 20)
  }

  Augur.it("transforms"){
    var gd = create.call()
    var t = Mat4.new()
    t.translate(1,2,3)
    gd.transform(AttributeType.Position, t)
    for(v in gd[AttributeType.Position]){
      Assert.elementsEqual(v, [1,2,3])
    }
  }
}
