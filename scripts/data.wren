class Ringbuffer {

  construct new(capacity){
    _data = List.filled(capacity, null)
    _capacity = capacity
    _front = 0
    _back = 0
    _count = 0
  }

  count { _count }

  isEmpty { _count == 0 }

  enqueue(v){
    if(_count == _capacity) Fiber.abort("Ringbuffer capacity exceeded")
    _data[_front] = v
    _front = (_front+1) % _capacity
    _count = _count+1
  }

  dequeue(){
    if(isEmpty) return null
    var v = _data[_back]
    _back = (_back+1) % _capacity
    _count = _count-1
    return v
  }

}