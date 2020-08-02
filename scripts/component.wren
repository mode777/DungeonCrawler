import "platform" for Application,Event

class Component {
  
  construct new(parent){
    _parent = parent
    _children = []
    _channels = {}
    _parent.addChild(this) 
  }

  construct new(){
    _parent = null
    _children = []
    _channels = {}
  }

  init(){
    for(c in _children){
      c.init()
    }
  }

  start(){
    for(c in _children){
      c.start()
    }
  }

  update(){
    for(c in _children){
      c.update()
    }
  }

  addChild(c){
    _children.add(c)
  }

  publishChannel(id, c){
    _parent.addChannel(id,c)
  }

  addChannel(id, c){
    _channels[id] = c
  }

  getChannel(id){
    var c = _channels[id]
    if(c) return c
    var val = _parent ? _parent.getChannel(id) : null
    if(val == null){
      Fiber.abort("Channel not found " + id)
    }
    return val
  }
}

class RootComponent is Component {
  construct new(){
    super()
    Application.on(Event.Init){|a| this.init() }
    Application.on(Event.Load){|a| this.start() }
    Application.on(Event.Update){|a| this.update() }
  }


}

class Channel {

  value { _value }
  generation { _generation }

  construct new(initial){
    _value = initial
    _generation = 0
  }

  setValue(v){
    _value = v
    _generation = _generation + 1
  }
}