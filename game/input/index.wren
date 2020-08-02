import "container" for GlobalContainer
import "architecture" for Pipeline

import "./game/input/input" for InputComponent

GlobalContainer.registerFactory("InputSubsystem"){ |c| Pipeline.new(c.resolveAll([InputComponent])) }