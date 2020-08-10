
import "./game/infrastructure" for GameSystem
import "./game/events" for PlayerEvents, MapEvents

import "./game/collision/player" for PlayerCollisionComponent

GameSystem.attach("main"){|s|

  var comp = PlayerCollisionComponent.new()

  s.queue.subscribe(PlayerEvents.Init){|e|
    comp.start(e.payload)
  }

  s.queue.subscribe(MapEvents.Load){|e|
    var map = e.payload["map"]
    s.queue.subscribe(PlayerEvents.Move){|e|
      comp.update(map)      
    }
  }

}