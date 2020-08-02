import "container" for GlobalContainer
import "architecture" for Pipeline

import "./game/collision/player" for PlayerCollisionComponent

GlobalContainer.registerFactory("CollisionSubsystem"){ |c| Pipeline.new(c.resolveAll([
  PlayerCollisionComponent,
])) }