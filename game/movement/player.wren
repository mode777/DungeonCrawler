import "math" for Mat4, Noise, Vec3, Vec4
import "memory" for Grid
import "platform" for Application, Event, Keyboard

import "./game/events" for SystemEvents, InputEvents, PlayerEvents, MapEvents
import "./game/infrastructure" for EventQueue, GameEvent, GameSystem

GameSystem.attach("main"){|s|
  var queue = s.queue

  var playerState = {}
  var moveEvent = GameEvent.new(PlayerEvents.Move, playerState)
  var roomEvent = GameEvent.new(PlayerEvents.Room, null)
  var initEvent = GameEvent.new(PlayerEvents.Init, playerState)

  var pos = Vec3.zero()
  var yaw = 0
  var forward = Vec3.zero()
  var right = Vec3.zero()
  var target = Vec3.zero()
  var delta = Vec3.zero()
  var tmp = Vec3.zero()
  var room = null

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
    var graph = ev.payload.graph
    var c = ev.payload.startRoom.center()
    Vec3.set(c[0],0,c[1], pos)
    
    updatePlayerPos.call()
    queue.add(initEvent)

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
      var px = pos[0].floor
      var py = pos[2].floor
      if(room == null || !room.isInside(px,py)){
        room = graph.leafAt(px,py)
        roomEvent.payload = room
        queue.add(roomEvent)
      }
    }
  }


}

