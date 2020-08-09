import "memory" for Grid
import "./game/map/entity" for Entity

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

  root { _root }

  construct new(root){
    super(root.w, root.h, LevelElement.Wall, LevelElement.Wall)
    _root = root
  }


}

class Room {

  node { _node }
  x { _node.x }
  y { _node.y }
  w { _node.w }
  h { _node.h }

  construct new(node){
    _node = node
  }

  fillMap(m){
    for(y in y+1...y+h-1){
      for(x in x+1...x+w-1){
        m[x,y] = LevelElement.Floor
      }
    }
  }
}