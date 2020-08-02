import "container" for GlobalContainer
import "architecture" for Pipeline

import "./game/graphics/2d" for Gfx2dComponent
import "./game/graphics/3d" for Gfx3dComponent

GlobalContainer.registerFactory("GraphicsSubsystem"){ |c| Pipeline.new(c.resolveAll([
  Gfx3dComponent,
  Gfx2dComponent
])) }