import "container" for GlobalContainer
import "architecture" for Pipeline

import "./game/movement/player" for PlayerComponent
import "./game/movement/enemy" for EnemyMovementComponent

GlobalContainer.registerFactory("MovementSubsystem"){ |c| Pipeline.new(c.resolveAll([
  PlayerComponent,
  EnemyMovementComponent
])) }