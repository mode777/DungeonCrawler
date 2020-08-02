import "io" for File, SeekOrigin, Path
import "2d" for Quad, SpriteBatch
import "graphics" for Texture


class Text is SpriteBatch {
  construct new(text, font, width){
    super(font.pages[0], text.count)
    _text = text
    _font = font
    _width = width
    format()
  }

  format(){
    var x = 0
    var y = _font.base
    var target = Quad.clone(Quad.empty)
    var i = 0
    for(c in _text.codePoints){
      var char = _font[c]
      if(char){
        var source = char.quad
        target.set(x+char.offset[0], y+char.offset[1], char.quad.w, char.quad.h)
        super.setSprite(i,source, target)
        x = x + char.xadvance
        i = i + 1
      }
      if(x > _width || c == 10 /*LF*/){
        x = 0
        y = y + _font.lineHeight
      }
    }
  }
}

class BMFont {

  size { _size }
  name { _name }
  lineHeight { _lineHeight }
  base { _base }
  pages { _pages }

  construct fromFile(path){
    var file = File.open(path, "rb")
    var magic = file.read(3)
    if(magic != "BMF"){
      Fiber.abort("Not a valid BMFont file")
    }
    var version = file.readUByte()
    while(file.pos()<file.length()){
      var block = file.readUByte()
      var length = file.readUInt()
      if(block == 1){ 
        parseInfo(file, length)
      } else if(block == 2){
        parseCommon(file, length)
      } else if(block == 3){
        parsePages(file,length, Path.getFolder(path))
      } else if(block == 4){
        parseChars(file, length)
      } else if(block == 5){
        parseKernings(file, length)
      }else{ 
        Fiber.abort("Unknown block %(block)") 
      }
    }
  }

  parseInfo(f, l){
    _size = f.readShort()
    var options = f.readUByte()
    var charSet = f.readUByte()
    var stretchH = f.readUShort()
    var aa = f.readUByte()
    var padding = [f.readUByte(), f.readUByte(), f.readUByte(), f.readUByte()]
    var spacing = [f.readUByte(), f.readUByte()]
    var outline = f.readUByte()
    _name = f.readString(l-14)
  }

  parseCommon(f,l){
    _lineHeight = f.readUShort()
    _base = f.readUShort()
    var scale = [f.readUShort(),f.readUShort()]
    var numPages = f.readUShort()
    var bitField = f.readUByte()
    var channels = [f.readUByte(),f.readUByte(),f.readUByte(),f.readUByte()] 
  }

  parsePages(f,l, folder){
    _pages = f.readString(l).split("\0").map{|f| Texture.fromFile(folder + "/" + f) }.toList
  }

  parseChars(f,l){
    _chars = {}
    var count = l/20
    for(i in 0...count){
      var char = BMChar.fromStream(f)
      _chars[char.id] = char 
    }
  }

  parseKernings(f,l){
    var kernings = {}
    var count = l/10
    for(i in 0...count){
      var from = f.readUInt()
      var to = f.readUInt()
      var amount = f.readShort()
      if(!kernings[from]) kernings[from] = {}
      kernings[from][to] = amount
    }
  }

  [id] {
    return _chars[id]
  }

  getKerning(from, to){
    if(kernings[from]){
      return kernings[from][to] || 0
    }
    return 0
  }

}

class BMChar {

  id { _id }
  quad { _quad }
  offset { _offset }
  xadvance { _xadvance }
  page { _page }
  channel { _channel }

  construct fromStream(f){
    _id = f.readUInt()
    _quad = Quad.new(f.readUShort(), f.readUShort(), f.readUShort(), f.readUShort())
    _offset = [f.readShort(), f.readShort()]
    _xadvance = f.readShort()
    _page = f.readUByte()
    _channel = f.readUByte()
  }
}