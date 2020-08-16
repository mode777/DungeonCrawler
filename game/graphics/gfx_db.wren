import "image" for Image
import "graphics" for Texture, TextureFilters
import "2d" for Tileset

import "./game/graphics/billboard" for BillboardProto

class GfxDb {
  
  image { _img }
  texture { _txt }
  tileset { _tileset }
  tiles { _tiles }
  billboards { _billboards }
  scale { _scale }
  
  construct new(filename){
    _img = Image.fromFile(filename)
    _txt = Texture.fromImage(_img, { "magFilter": TextureFilters.Nearest, "minFilter": TextureFilters.NearestMipmapLinear, "mipmaps": true })
    _tileset = Tileset.new(256/32,1024/32,32,32)
    _scale = 5

    _tiles = createTiles()
    _billboards = createBillboards()
  }

  createTiles(){
    return {
      "panel_a": _tileset[0,1],
      "bump_a": _tileset[1,1],
      "panel_b": _tileset[2,1],
      "panel_b_cracked": _tileset[3,1],
      "panel_b_locked": _tileset[4,1],
      "stairs_down": _tileset[5,1],
      "stairs_up": _tileset[6,1],
      "shaft": _tileset[7,1],
      "bump_b": _tileset[0,2],
      "bump_c": _tileset[1,2],
      "wall_a": _tileset[2,2],
      "wall_b": _tileset[3,2],
      "wall_b_cracked": _tileset[4,2],
      "door_a": _tileset[5,2],
      "door_b": _tileset[6,2],
      "door_c": _tileset[7,2],
      "columns": _tileset[0,3],
      "door_d": _tileset[1,3],
      "grate": _tileset[2,3],
      "spikes": _tileset[3,3],
      "floor_checker": _tileset[4,3],
      "water": _tileset[5,3],
      "slime": _tileset[6,3],
      "stars": _tileset[7,3],
    }
  }

  createBillboards(){
    return {
      "chest": BillboardProto.new(_scale, _tileset[0,4], -1.3, 0.7),
      "chest_open": BillboardProto.new(_scale, _tileset[1,4],-1.3,0.7),
      "key_a": BillboardProto.new(_scale, _tileset[2,4],-2.2, 0.5),
      "goblin": BillboardProto.new(_scale, _tileset[0,22],-0.25, 1),
      "zombie": BillboardProto.new(_scale, _tileset[1,22],-0.25, 1),
      "skeleton": BillboardProto.new(_scale, _tileset[2,22],-0.25, 1),
      "ork": BillboardProto.new(_scale, _tileset[3,22],-0.25, 1),
      "cyclop": BillboardProto.new(_scale, _tileset[4,22],-0.25, 1),
      "cheetaman": BillboardProto.new(_scale, _tileset[5,22],-0.25, 1),
      "golem": BillboardProto.new(_scale, _tileset[6,22],-0.25, 1),
      "demon": BillboardProto.new(_scale, _tileset[7,22],-0.25, 1),
      "blobs": BillboardProto.new(_scale, _tileset[0,21],-0.25, 1),
      "blob": BillboardProto.new(_scale, _tileset[1,21],-0.25, 1),
      "scorpion": BillboardProto.new(_scale, _tileset[2,21],-0.25, 1),
      "octopus": BillboardProto.new(_scale, _tileset[3,21],-0.25, 1),
      "vampire": BillboardProto.new(_scale, _tileset[4,21],-0.25, 1),
      "mummy": BillboardProto.new(_scale, _tileset[5,21],-0.25, 1),
      "ghost": BillboardProto.new(_scale, _tileset[6,21],-0.25, 1),
      "beholder": BillboardProto.new(_scale, _tileset[7,21],-0.25, 1),

    }
  }
}
