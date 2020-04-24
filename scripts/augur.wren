class Assert {
  static equal(actual, expected){
    if(actual != expected){
      Fiber.abort("%(actual) was expected to be %(expected)")
    }
  }

  static error(fn){
    var f = Fiber.new {
      fn.call()
    }
    var e = f.try()
    if(!e){
      Fiber.abort("Expected error")
    }
  }

  static defined(actual){
    if(actual == null){
      Fiber.abort("Expected value to be defined")
    }
  }

  static elementsEqual(actual, expected){
    if(actual.count != expected.count){
      Fiber.abort("Expected list count %(expected.count) but got %(actual.count)")
    }

    for (i in 0...actual.count) {
      if(actual[i] != expected[i]){
        Fiber.abort("Expected element %(i) to be %(expected[i]) but got %(actual[i])")
      }
    }
  }
}

class Augur {
  static describe(desc, fn){
    if(!__suites){
      __suites = []
    }
    var suite = Suite.new(desc)
    __suites.add(suite)
    __suite = suite
    fn.call()
  }

  static it(desc, fn) {
    __suite.addTest(desc, fn)
  }

  static beforeAll(fn){
    __suite.beforeAll(fn)
  }

  static beforeEach(fn){
    __suite.beforeEach(fn)
  }

  static afterAll(fn){
    __suite.afterAll(fn)
  }

  static afterEach(fn){
    __suite.afterEach(fn)
  }

  static run(){
    for (suite in __suites) {
      suite.run()
    }
  }
}

class Suite {
  construct new(desc){
    _name = desc
    _tests = []
  }

  addTest(name, fn){
    _tests.add(TestFunc.new(name, fn))
  }

  beforeAll(fn){
    _beforeAll = fn
  }

  beforeEach(fn){
    _beforeEach = fn
  }

  afterAll(fn){
    _afterAll = fn
  }

  afterEach(fn){
    _afterEach = fn
  }

  run(){
    System.print("[AUGUR] Running Suite <%(_name)>")
    if(_beforeAll) { _beforeAll.call() }
    for (test in _tests) {
        if(_beforeEach) { _beforeEach.call() }
        test.run(_name)
        if(_afterEach) { _afterEach.call() }
    }
    if(_afterAll) { _afterAll.call() }
  }
}

class TestFunc {
  construct new(desc, fn){
    _desc = desc
    _fn = fn
  }

  run(suite){    
    //_fn.call() 
    var fiber = Fiber.new { 
      _fn.call() 
    }
    var before = System.clock
    var error = fiber.try()
    var time = System.clock - before
    var state 
    if(error){
      state = "[ERROR: %(error)]"
    } else {
      state = "[SUCCESS]"
    }

    System.print("[AUGUR] %(state) %(suite) %(_desc) (%(time)s)")
  }

}