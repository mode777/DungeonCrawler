class Severity {
  static Off { 0 }
  static Error { 1 }
  static Warning { 2 }
  static Info { 3 }
  static Debug { 4 }
}

class Module {
  static Core { 1 }
  static Graphics { 2 }
  static Json { 3 }
  static Wren { 4 }
  static Platform { 5 }
  static Renderer { 6 }
  static Image { 7 }
}

class Application {  

  static args { __args }

  foreign static logLevel(severity)
  foreign static logLevel(module, severity)
  foreign static quit()

  static onUpdate(callback){
    __update = callback
  }

  static onInit(callback){
    Mouse.init()
    __init = callback
  }

  static onLoad(callback){
    __load = callback
  }

  static update(delta) { 
    if(__update != null){
      __update.call(delta)
    }    
  }

  static init(args){
    __args = args
    if(__init != null){
      __init.call()
    }
  }

  static load(){
    if(__load != null){
      __load.call()
      System.gc()
    }
  }
}

class Window {
  foreign static config(w,h,title)
}

class Keyboard {
  foreign static isDown(key)
}

class Mouse {

  static init(){
    __pos = [0,0]
  }

  static position {
    Mouse.getPosition(__pos) 
    return __pos
  }

  foreign static getPosition(vec2)
}
