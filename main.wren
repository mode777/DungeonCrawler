import "platform" for Application, Severity, Window
//import "./gui/index"
import "./game/index"
//import "./game2d/index"

var width = 1280
var height = 720

Application.onInit {|args|
  //Application.logLevel(Severity.Debug)
  Application.logLevel(Severity.Info)
  Window.config(width,height,"Light test!")
}