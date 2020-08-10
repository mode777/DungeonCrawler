import "architecture" for Pipeline
import "container" for GlobalContainer
import "platform" for Application

import "./game/events" for SystemEvents
import "./game/infrastructure" for EventQueue, GameEvent, GameSystem

var sys = GameSystem.new("main",256)

Application.onUpdate {|args|
  sys.update()
}

import "./game/input/index"
import "./game/movement/index"
import "./game/map/index"
import "./game/collision/index"
import "./game/graphics/index"