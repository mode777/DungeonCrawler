import "architecture" for Pipeline
import "container" for GlobalContainer
import "platform" for Application

import "./game/events" for SystemEvents
import "./game/infrastructure" for EventQueue, GameEvent 

var queue = EventQueue.new(256)
//queue.debug = true

GlobalContainer.registerInstance(EventQueue, queue)

var initEvent = GameEvent.new(SystemEvents.Init)
var updateEvent = GameEvent.new(SystemEvents.Update)
var drawEvent = GameEvent.new(SystemEvents.Draw)

Application.onLoad {|args|
  queue.add(initEvent)
}

Application.onUpdate {|args|
  queue.add(updateEvent)
  var count = queue.count
  queue.add(drawEvent)
  for(i in 0...count){
    queue.dispatchNext()
  }
}

import "./game/input/index"
import "./game/movement/index"
import "./game/map/index"
import "./game/collision/index"
import "./game/graphics/index"