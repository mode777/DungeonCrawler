import "./game/events" for SystemEvents, MapEvents
import "./game/infrastructure" for EventQueue, GameEvent, GameSystem
import "./game/map/generator" for MapGen

GameSystem.attach("main"){|s|
  var queue = s.queue


  queue.subscribe(SystemEvents.Init){|ev|
    var mapState = MapGen.new(64,64, 4)
    var loadEvent = GameEvent.new(MapEvents.Load, mapState)
    queue.add(loadEvent)
  }
}

