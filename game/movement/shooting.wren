import "math" for Vec3
import "data" for Stack
import "graphics" for Colors

import "./game/events" for SystemEvents, InputEvents, PlayerEvents, MapEvents, ActorEvents
import "./game/infrastructure" for EventQueue, GameEvent, GameSystem
import "./game/graphics/billboard" for BillboardBatch
import "./game/graphics/gfx_db" for GfxDb

GameSystem.attach("main"){|s|
  var queue = s.queue
  var room = null

  queue.subscribe(PlayerEvents.Room){|ev|
    if(room != null){
      room["projectiles"] = []
    }
    room = ev.payload
  }

  queue.subscribe(MapEvents.Load){|ev|
    var map = ev.payload
    for(r in map.rooms){
      r["projectile-billboards"] = BillboardBatch.new(GfxDb.instance.texture, 128, GfxDb.instance.scale)
      r["projectiles"] = []
    }
  }

  var cooldown = {}
  var idCtr = 0
  
  queue.subscribe(ActorEvents.Shoot){|ev|
    if(!room) return

    var act = ev.payload
    var id = act["id"]

    if(!cooldown[id] || cooldown[id] <= 0){
      idCtr = idCtr + 1
      room["projectiles"].add({
        "position": Vec3.clone(act["position"]),
        "heading": Vec3.clone(act["heading"]),
        "velocity": 0.1,
        "sprite": "shuriken",
        "billboard": GfxDb.instance.billboards["shuriken"].instance(act["position"][0],act["position"][1]),
        "lifetime": 300,
        "actor": act["id"],
        "id": idCtr
      })
      cooldown[id] = 60
    }
  }

  var player = null
  queue.subscribe(PlayerEvents.Init){|ev|
    player = ev.payload
  }

  var tmp = [0,0,0]
  var remove = Stack.new(128)

  queue.subscribe(SystemEvents.Update){|ev|
    if(!room) return

    for(id in cooldown.keys){
      cooldown[id] = cooldown[id] - 1
    }


    var projectiles = room["projectiles"]
    var billboards = room["projectile-billboards"] 
    billboards.clear()

    for(i in 0...projectiles.count){
      var p = projectiles[i]
      //Vec3.mulV(p["heading"], p["velocity"], tmp)
      //Vec3.add(p["position"], tmp, p["position"])
      p["lifetime"] = p["lifetime"] -1
      if(p["lifetime"] <= 0) remove.push(i)
      //p["billboard"].offsetXY(p["position"][0], p["position"][1])
      
      billboards.addBillboard(p["billboard"], Colors.White)
    }

    while(!remove.isEmpty){
      var idx = remove.pop()
      var id = projectiles[idx]["id"]
      projectiles.removeAt(idx)
    }

    billboards.update(player["yaw"])

  }

  // queue.subscribe(SystemEvents.Draw2){|ev|
  //   if(!room) return

  //   var boards = room["projectile-billboards"]
  //   boards.draw()
  // }

}