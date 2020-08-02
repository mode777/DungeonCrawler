import "math" for Mat4, Noise, Vec3, Vec4
import "container" for GlobalContainer
import "memory" for Grid

GlobalContainer.registerFactory("EnemyMovementComponent") {|c| EnemyMovementComponent.new(c.resolve("MAP"))}

class EnemyMovementComponent {
  construct new(map){
    _map = map
  }

  start(){
    _enemies = _map["enemies"]
    _t = 0
  }

  update(){
    for(e in _enemies){
      e.move(_t.sin / 150, _t.cos / 150)
    }
    _t = _t + 0.05
  }
}