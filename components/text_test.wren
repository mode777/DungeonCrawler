import "font" for Text, BMFont
import "platform" for Application, Event
import "camera" for OrthograficCamera
import "graphics" for Renderer
import "io" for File

var t
var cam

Application.on(Event.Load){|args|
  cam = OrthograficCamera.new()
  var f = BMFont.fromFile("./assets/fonts/vera_14.fnt")
  var txt = File.open("./assets/wren.txt","rb").readToEnd()
  t = Text.new(txt, f, 500)
  Renderer.setBackgroundColor(0.1,0,0.4)
  t.transform.translate(100,100, 0)
}

Application.on(Event.Update){|args|
  Renderer.set2d()
  cam.enable()
  t.draw()
}




