import "memory" for Grid

var Wall_
var Floor_
var Door_

class LevelElement {

  static Wall { Wall_ }
  static Floor { Floor_ }
  static Door { Door_ }

  sprite { _sprite }
  isSolid { _flags & SOLID > 0 }
  isPassable { _flags & PASSABLE > 0 }
  isDoor { _flags & DOOR > 0 }
  flags { _flags }
  offset { _offset }
  
  construct new(flags, sprite){
    _flags = flags
    _sprite = sprite
    _offset = 0
  }

  construct new(flags, sprite, offset){
    _flags = flags
    _sprite = sprite
    _offset = offset
  }
}

var NONE = 0
var SOLID = 1 << 0
var PASSABLE = 1 << 1
var DOOR = 1 << 2

Wall_ = LevelElement.new(SOLID, "wall_a")
Floor_ = LevelElement.new(PASSABLE, "floor_checker")
Door_ = LevelElement.new(SOLID | PASSABLE | DOOR, "door_a", 0.1)

class LevelMap is Grid {
  construct new(w,h){
    super(w, h, LevelElement.Wall, LevelElement.Wall)
  }

}