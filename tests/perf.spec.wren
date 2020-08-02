import "augur" for Augur, Assert

class A {
  a { _a }
  b { _b }
  c { _c }
  d { _d }

  construct new(a,b,c,d){
    _a = a
    _b = b
    _c = c
    _d = d
  }
}

var CreateMap = Fn.new {|a,b,c,d|
  return {
    "a": a,
    "b": b,
    "c": c,
    "d": d
  }
}

var max = 100000

var classes = []
var maps = []



Augur.describe("Compare Class vs Map"){
  Augur.it("should create classes"){
    for(i in 0...max){
      classes.add(A.new(1,2,3,4))
    }
  }

  Augur.it("shoudl create maps"){
    for(i in 0...max){
      maps.add(CreateMap.call(1,2,3,4))
    }
  }
 
 
  Augur.it("Should access classes"){
    for(i in 0...max){
      var c = classes[i]
      var r = c.a + c.b + c.c + c.d
    }
  }

  Augur.it("Should access maps"){
    for(i in 0...max){
      var m = maps[i]
      var r = m["a"] + m["b"] + m["c"] + m["d"]
    }
  }
}