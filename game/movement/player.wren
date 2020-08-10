import "math" for Mat4, Noise, Vec3, Vec4
import "memory" for Grid
import "platform" for Application, Event, Keyboard

import "./game/events" for SystemEvents, InputEvents, PlayerEvents, MapEvents
import "./game/infrastructure" for EventQueue, GameEvent, GameSystem

GameSystem.attach("main"){|s|
  var queue = s.queue

  var playerState = {}
  var moveEvent = GameEvent.new(PlayerEvents.Move, playerState)
  var initEvent = GameEvent.new(PlayerEvents.Init, playerState)

  var pos = Vec3.zero()
  var yaw = 0
  var forward = Vec3.zero()
  var right = Vec3.zero()
  var target = Vec3.zero()
  var delta = Vec3.zero()
  var tmp = Vec3.zero()

  var updatePlayerPos = Fn.new {
    Vec3.set(yaw.cos, 0, yaw.sin, forward)
    Vec3.set(-yaw.sin, 0, yaw.cos, right)
    Vec3.add(delta,pos,pos)
    playerState["yaw"] = yaw
    Vec3.add(pos, forward, target)
  }

  playerState["position"]= pos
  playerState["target"] = target
  playerState["heading"] = forward
  playerState["delta"] = delta
  playerState["forward"] = forward
  playerState["yaw"] = yaw

  queue.subscribe(MapEvents.Load){|ev|
    Vec3.set(2,0,2, pos)
    updatePlayerPos.call()
    queue.add(initEvent)
  }

  queue.subscribe(InputEvents.Update){|ev|
    var inputState = ev.payload
    
    Vec3.zero(delta)
    Vec3.zero(tmp)
    var moved = false

    if(inputState["forward"]){
      Vec3.mulV(forward, 0.05, tmp)
      Vec3.add(delta, tmp, delta)
      moved = true
    }
    if(inputState["backward"]){
      Vec3.mulV(forward, -0.05, tmp)
      Vec3.add(delta, tmp, delta)
      moved = true
    }
    if(inputState["strafe_left"]){
      Vec3.mulV(right, -0.05, tmp)
      Vec3.add(delta, tmp, delta)
      moved = true
    }
    if(inputState["strafe_right"]){
      Vec3.mulV(right, 0.05, tmp)
      Vec3.add(delta, tmp, delta)
      moved = true
    }
    if(inputState["turn_left"]){
      yaw = yaw - 0.03
    }
    if(inputState["turn_right"]){
      yaw = yaw + 0.03
    }

    updatePlayerPos.call()
    if(moved) queue.add(moveEvent)
  }
}

