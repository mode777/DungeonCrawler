import "architecture" for Pipeline
import "container" for GlobalContainer
import "platform" for Application

import "./game/input/index"
import "./game/movement/index"
import "./game/map/index"
import "./game/collision/index"
import "./game/graphics/index"

var components = [
  "MapSubsystem",
  "InputSubsystem",
  "MovementSubsystem",
  "CollisionSubsystem",
  "GraphicsSubsystem"
].map{|x| GlobalContainer.resolve(x)}.toList

var pipeline = Pipeline.new(components)

Application.onLoad {|args|
  pipeline.start()
}

Application.onUpdate {|args|
  pipeline.update()
}