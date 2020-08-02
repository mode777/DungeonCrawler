import "graphics" for Shader, Renderer, Colors, RendererBlendFunc

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
  foreign static pollEvent(out)
  foreign static loadModuleInternal(module, file)

  static loadModule(module, file){
    Fiber.new{ 
      Application.loadModuleInternal(module, file) 
    }.call()
  }

  static onUpdate(callback){
    on(Event.Update, callback)
  }

  static onInit(callback){
    on(Event.Init, callback)
  }

  static onLoad(callback){
    on(Event.Load, callback)
  }

  static on(event, fn){
    __handlers = __handlers || {}
    __handlers[event] = __handlers[event] || [] 
    __handlers[event].add(fn)
  }

  static dispatchEvent(type, args){
    var handlerList = __handlers[type]
    
    if(handlerList){
      for(handler in handlerList){
        handler.call(args)
      }
    }
  }

  static update(delta) { 
    while(Application.pollEvent(__eventArgs)){
      var type = __eventArgs[0]
      dispatchEvent(type,__eventArgs)
      
      if(__eventArgs[0] == Event.Quit) Application.quit()       
    }
    __updateArgs[1] = delta
    dispatchEvent(Event.Update, __updateArgs)
  }

  static init(args){
    __eventArgs = [null,null,null,null,null,null,null]
    Mouse.init()
    __args = args
    Colors.init()
    __updateArgs = [Event.Update, 0]
    
    dispatchEvent(Event.Init, [Event.Init])
  }

  static load(){
    Renderer.blendFunc(RendererBlendFunc.SrcAlpha, RendererBlendFunc.OneMinusSrcAlpha)
    Renderer.set3d()
    
    dispatchEvent(Event.Load, [Event.Load])

    System.gc()
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
  foreign static setPosition(x,y)
}

class Event {
    static getName(n){
      if(n == Event.Quit) return "Quit"
      if(n == Event.Terminating) return "Terminating"
      if(n == Event.Lowmemory) return "Lowmemory"
      if(n == Event.Willenterbackground) return "Willenterbackground"
      if(n == Event.Didenterbackground) return "Didenterbackground"
      if(n == Event.Willenterforeground) return "Willenterforeground"
      if(n == Event.Didenterforeground) return "Didenterforeground"
      if(n == Event.Displayevent) return "Displayevent"
      if(n == Event.Windowevent) return "Windowevent"
      if(n == Event.Syswmevent) return "Syswmevent"
      if(n == Event.Keydown) return "Keydown"
      if(n == Event.Keyup) return "Keyup"
      if(n == Event.Textediting) return "Textediting"
      if(n == Event.Textinput) return "Textinput"
      if(n == Event.Keymapchanged) return "Keymapchanged"
      if(n == Event.Mousemotion) return "Mousemotion"
      if(n == Event.Mousebuttondown) return "Mousebuttondown"
      if(n == Event.Mousebuttonup) return "Mousebuttonup"
      if(n == Event.Mousewheel) return "Mousewheel"
      if(n == Event.Joyaxismotion) return "Joyaxismotion"
      if(n == Event.Joyballmotion) return "Joyballmotion"
      if(n == Event.Joyhatmotion) return "Joyhatmotion"
      if(n == Event.Joybuttondown) return "Joybuttondown"
      if(n == Event.Joybuttonup) return "Joybuttonup"
      if(n == Event.Joydeviceadded) return "Joydeviceadded"
      if(n == Event.Joydeviceremoved) return "Joydeviceremoved"
      if(n == Event.Controlleraxismotion) return "Controlleraxismotion"
      if(n == Event.Controllerbuttondown) return "Controllerbuttondown"
      if(n == Event.Controllerbuttonup) return "Controllerbuttonup"
      if(n == Event.Controllerdeviceadded) return "Controllerdeviceadded"
      if(n == Event.Controllerdeviceremoved) return "Controllerdeviceremoved"
      if(n == Event.Controllerdeviceremapped) return "Controllerdeviceremapped"
      if(n == Event.Fingerdown) return "Fingerdown"
      if(n == Event.Fingerup) return "Fingerup"
      if(n == Event.Fingermotion) return "Fingermotion"
      if(n == Event.Dollargesture) return "Dollargesture"
      if(n == Event.Dollarrecord) return "Dollarrecord"
      if(n == Event.Multigesture) return "Multigesture"
      if(n == Event.Clipboardupdate) return "Clipboardupdate"
      if(n == Event.Dropfile) return "Dropfile"
      if(n == Event.Droptext) return "Droptext"
      if(n == Event.Dropbegin) return "Dropbegin"
      if(n == Event.Dropcomplete) return "Dropcomplete"
      if(n == Event.Audiodeviceadded) return "Audiodeviceadded"
      if(n == Event.Audiodeviceremoved) return "Audiodeviceremoved"
      if(n == Event.Sensorupdate) return "Sensorupdate"
      if(n == Event.Rendertargetsreset) return "Rendertargetsreset"
      if(n == Event.Renderdevicereset) return "Renderdevicereset"
      if(n == Event.Init) return "Init"
      if(n == Event.Load) return "Load"
      if(n == Event.Update) return "Update"

    }

    // Wren-Only
    static Init { 0x1 }
    static Load { 0x2 }
    static Update { 0x3 }

    static Quit { 0x100 } 
    static Terminating { 0x101 }        
    static Lowmemory { 0x102 }          
    static Willenterbackground { 0x103 } 
    static Didenterbackground { 0x104 } 
    static Willenterforeground { 0x105 } 
    static Didenterforeground { 0x106 } 
    /* Display Events */
    static Displayevent { 0x150 }  
    /* Window Events */
    static Windowevent { 0x200 } 
    static Syswmevent { 0x201 }             
    /* Keyboard Events */
    static Keydown { 0x300 } 
    static Keyup { 0x301 }                  
    static Textediting { 0x302 }            
    static Textinput { 0x303 }              
    static Keymapchanged { 0x304 }          
    /* Mouse Events */
    static Mousemotion { 0x400 } 
    static Mousebuttondown { 0x401 }        
    static Mousebuttonup { 0x402 }          
    static Mousewheel { 0x403 }             
    /* Joystick Events */
    static Joyaxismotion { 0x600 } 
    static Joyballmotion { 0x601 }          
    static Joyhatmotion { 0x602 }           
    static Joybuttondown { 0x603 }          
    static Joybuttonup { 0x604 }            
    static Joydeviceadded { 0x605 }         
    static Joydeviceremoved { 0x606 }       
    /* Game Controller Events */
    static Controlleraxismotion { 0x650 } 
    static Controllerbuttondown { 0x651 }          
    static Controllerbuttonup { 0x652 }            
    static Controllerdeviceadded { 0x653 }         
    static Controllerdeviceremoved { 0x654 }       
    static Controllerdeviceremapped { 0x655 }      
    /* Touch Events */
    static Fingerdown { 0x700 }
    static Fingerup { 0x701 }
    static Fingermotion { 0x702 }
    /* Gesture Events */
    static Dollargesture { 0x800 }
    static Dollarrecord { 0x801 }
    static Multigesture { 0x802 }
    /* Clipboard Events */
    static Clipboardupdate { 0x900 } 
    /* Drag And Drop Events */
    static Dropfile { 0x1000 } 
    static Droptext { 0x1001 }                 
    static Dropbegin { 0x1002 }                
    static Dropcomplete { 0x1003 }             
    /* Audio Hotplug Events */
    static Audiodeviceadded { 0x1100 } 
    static Audiodeviceremoved { 0x1101 }        
    /* Sensor Events */
    static Sensorupdate { 0x1200 }     
    /* Render Events */
    static Rendertargetsreset { 0x2000 } 
    static Renderdevicereset { 0x2001 } 
}