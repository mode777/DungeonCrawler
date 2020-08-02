import "container" for GlobalContainer
import "architecture" for Pipeline

import "./game/map/generator" for GeneratorComponent

GlobalContainer.registerFactory("MapSubsystem"){ |c| Pipeline.new(c.resolveAll([
  GeneratorComponent,
])) }