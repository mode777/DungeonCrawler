import "./game/events" for SystemEvents, MapEvents
import "./game/infrastructure" for EventQueue, GameEvent, GameSystem
import "./game/map/generator" for MapGen

GameSystem.attach("main"){|s|
  var queue = s.queue

  var mapState = {}

  var loadEvent = GameEvent.new(MapEvents.Load, mapState)

  queue.subscribe(SystemEvents.Init){|ev|
    var gen = MapGen.new(32,32, 5)
    mapState["lights"] = gen.lights
    mapState["enemies"] = gen.enemies
    mapState["items"] = gen.items
    mapState["map"] = gen.map
    mapState["img"] = gen.image
    queue.add(loadEvent)
  }
}

