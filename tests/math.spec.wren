import "augur" for Augur, Assert
import "math" for Vec3, Math

Augur.describe("Vec3") {
  
  Augur.it("normalizes"){
    var v = [0,0,3]
    Vec3.normalize(v,v)
    Assert.elementsEqual(v, [0,0,1])
  }

  Augur.it("calculates cross"){
    var a = [1,0,0]
    var b = [0,1,0]
    var c = Vec3.zero()
    Vec3.cross(a,b,c)
    Assert.elementsEqual(c, [0,0,1])
  }

}

Augur.describe("Math"){
  Augur.it("calculates rad"){
    //System.print(Math.rad(360))
    //System.print(Math.deg(Num.pi*2))
  }
}
