class Container {
  
  construct new() {
    _registry = {}
    _factories = {}
  }
  
  register(type){
    _factories[type.toString] = Fn.new { type.new() }
  }

  registerFactory(type, factory){
    _factories[type.toString] = factory
  }

  registerInstance(type, inst){
    _registry[type.toString] = inst
  }

  resolve(name){
    if(!_registry.containsKey(name.toString)){
      if(_factories[name.toString] == null) Fiber.abort("Cannot resolve " + name.toString)

      _registry[name.toString] = _factories[name.toString].call(this)
    }

    return _registry[name.toString]
  }

  resolveAll(list) { list.map{|x| resolve(x)}.toList }
}

var GlobalContainer = Container.new() 