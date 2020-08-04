class Entity {

  x { _x }
  y { _y }

  construct new(x,y){
    _x = x
    _y = y
    _tags = {}
  }

  [key] {
    return _tags[key]
  }

  [key]=(v) {
    _tags[key] = v
  }

  move(x,y){
    _x = _x + x
    _y = _y + y
  }

  pos(x,y){
    _x = x
    _y = y
  }
}

class Light is Entity {

  color { _color }
  intensity { _intensity }

  construct new(x,y,color,intensity){
    super(x,y)
    _color = color
    _intensity = intensity
  }
}

class Enemy is Entity {

  type { _type }

  construct new(x,y,type){
    super(x,y)
    _type = type
  }
}

class Item is Entity {

  type { _type }

  construct new(x,y,type){
    super(x,y)
    _type = type
  }
}