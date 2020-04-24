
import "augur" for Augur, Assert
import "memory" for FloatVecAccessor, UShortAccessor
import "geometry" for GeometryData, AttributeType

Augur.describe("GeometryData") {
  Augur.it("is created by accessors"){
    var p = GeometryData.new({
      AttributeType.Position: FloatVecAccessor.new(4, 3),
      AttributeType.Texcoord1: FloatVecAccessor.new(4, 2)
    }, UShortAccessor.new(6))

    p[AttributeType.Position][0] = [1,1,1]
    p[AttributeType.Texcoord1][0] = [2,2]
    
    Assert.equal(p.count, 2)
    Assert.elementsEqual(p[AttributeType.Position][0], [1,1,1])
    Assert.elementsEqual(p[AttributeType.Texcoord1][0], [2,2])
  }
}
