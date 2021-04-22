class Queue {

  construct new(capacity){
    _data = List.filled(capacity, null)
    _capacity = capacity
    _front = 0
    _back = 0
    _count = 0
  }

  count { _count }

  isEmpty { _count == 0 }

  clear(){ _count = 0 }

  enqueue(v){
    if(_count == _capacity) Fiber.abort("Queue capacity exceeded")
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

class Stack {

  construct new(capacity){
    _data = List.filled(capacity, null)
    _capacity = capacity
    _top = 0
  }

  count { _top }

  isEmpty { _top == 0 }

  clear(){ _top = 0 }

  push(v){
    if(_top == _capacity) Fiber.abort("Stack capacity exceeded")
    _data[_top] = v
    _top = _top + 1
  }

  pop(){
    if(isEmpty) return null
    _top = _top - 1
    return _data[_top]
  }

}