import "data" for Ringbuffer
import "./game/events" for SystemEvents

class GameEvent {

  id { _id }
  payload { _payload }

  construct new(id){
    _id = id
    _payload = null
  }

  construct new(id, payload){
    _id = id
    _payload = payload
  }
}

class EventQueue {

  count { _queue.count  }

  construct new(size){
    _queue = Ringbuffer.new(size)
    _handlers = {}
    _debug = false
  }

  debug=(v) { _debug = v }

  add(gameEvent){
    _queue.enqueue(gameEvent)
  }

  subscribe(id, handler){
    if(!_handlers.containsKey(id)) _handlers[id] = []
    _handlers[id].add(handler)
  }

  subscribeCombined(ids, handler){
    var count = ids.count
    var ctr = 0
    var ret = List.filled(count, null)
    for(i in 0...count){
      var called = false
      subscribe(ids[i]){|ev|
        if(!called) {
          called = true
          ctr = ctr+1
        }
        ret[i] = ev
        if(ctr == count) handler.call(ret)
      }
    }
  }

  dispatchNext(){
    if(count == 0) return false
    var ev = _queue.dequeue()
    var handlers = _handlers[ev.id]
    if(_debug) System.print("EQ: Dispatch '%(ev.id)'")
    if(handlers){
      for(h in handlers){
        h.call(ev)
      }
    }
    return true
  }
}

var InitEvent = GameEvent.new(SystemEvents.Init)
var UpdateEvent = GameEvent.new(SystemEvents.Update)
var DrawEvent = GameEvent.new(SystemEvents.Draw)

class GameSystem {
  
  static attach(id, fn){
    fn.call(__systems[id])
  }

  id { _id }
  queue { _queue }

  construct new(id, queueSize){
    _id = id
    _queue = EventQueue.new(queueSize)
    __systems = __systems || {}
    __systems[id] = this

    _queue.add(InitEvent)
  }

  update(){
    _queue.add(UpdateEvent)
    var count = queue.count
    _queue.add(DrawEvent)
    for(i in 0...count){
      _queue.dispatchNext()
    }
  }
}