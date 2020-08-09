import "data" for Ringbuffer

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