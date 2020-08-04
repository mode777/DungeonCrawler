import "platform" for Application, Severity, Window
import "./game/index"

var width = 640
var height = 400

Application.onInit {|args|
  //Application.logLevel(Severity.Debug)
  Application.logLevel(Severity.Info)
  Window.config(width,height,"Light test!")
}