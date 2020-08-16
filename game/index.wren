import "architecture" for Pipeline
import "container" for GlobalContainer
import "platform" for Application, Event

import "./game/events" for SystemEvents
import "./game/infrastructure" for EventQueue, GameEvent, GameSystem

var sys = GameSystem.new("main",256)

var time = 0
var iterations = 0

Application.onUpdate {|args|
  var c = System.clock
  sys.update()
  time = time + (System.clock -c)
  iterations = iterations + 1
}

Application.on(Event.Quit){|args|
  var ms = (time / iterations) * 1000
  System.print("Avg. Frame Time %(ms)")
}

import "./game/input/index"
import "./game/movement/index"
import "./game/map/index"
import "./game/collision/index"
import "./game/graphics/index"