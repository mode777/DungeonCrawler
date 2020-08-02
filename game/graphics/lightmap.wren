import "math" for Vec3, Vec4
import "memory" for Grid
import "graphics" for Colors

class Lightmap is Grid {
  construct new(map){
    super(map.width, map.height, null, 0)
    _queue = []
    _visited = {}
    _map = map
    _color = [0,0,0,0]
    fill {|x,y|
      return [0,0,0,255]
    }
  }

  setLight(x,y,i){
    setLight(x,y,i,Colors.White)
  }

  setLight(x,y,i,c){
    _visited.clear()
    _queue.clear()
    var r = 0.08
    var a = 0.8
    addCell(x,y)

    while(i > 0.001){
      _depth = _queue.count
      while(_depth > 0){
        // set cell
        var cell = _queue.removeAt(0)

        Vec3.copy(c,_color)
        Vec3.mulV(_color, i, _color)
        Vec3.add(this[cell], _color, this[cell])
        Vec4.clampV(this[cell], 255, this[cell])
        
        
        x = cell % _map.width
        y = (cell/_map.width).floor
        // collect neightbours
        addCell(x-1,y)
        addCell(x,y-1)
        addCell(x+1,y)
        addCell(x,y+1)
        _depth = _depth-1
      }
      i = i * a
      a = a - r
    }
  }

  addCell(x,y){
    var idx = y*_map.width+x
    if(this.isOutOfBounds(x,y) || _map[x,y] == false || _visited.containsKey(idx)){
      return
    }
    _queue.add(idx)
    _visited[idx] = true
  }

}