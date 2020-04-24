
class Json {
  static parse(string) {
    return JsonParser.new(string).parse()
  }
}

class Tokens {
  static Undefined { 0 }
  static Object { 1 }
  static Array { 2 }
  static String { 3 }
  static Null { 4 }
  static Number { 5 }
  static Bool { 6 }
}

foreign class JsonParser {
    
  construct new(string){

  }

  parse(){
    nextToken()
    while(getToken() == Tokens.Undefined){
      nextToken()
    }
    return parseToken(getToken())
  }

  parseToken(token){
    if(token == Tokens.Object){
      return parseObject()
    } else if(token == Tokens.Array){
      return parseArray()
    } else {
      return getValue()
    }
  }

  parseObject(){
    var obj = {}
    for (i in 0...getChildren()) {
      nextToken()
      var key = getValue()
      nextToken()
      obj[key] = parseToken(getToken())
    }
    return obj
  }

  parseArray(){
    var arr = []
    for (i in 0...getChildren()) {
      nextToken()
      arr.add(parseToken(getToken()))
    }
    return arr
  }

  foreign getValue()
  foreign getToken()
  foreign nextToken()
  foreign getChildren()  
}