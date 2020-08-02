import "camera" for OrbitCamera
import "platform" for Keyboard, Application, Event
import "math" for Vec2

class CameraHelpers {
  static OrbitCameraKeyboardInput(cam, speed){
    if(Keyboard.isDown("up")){
      cam.phi(-speed)
    }
    if(Keyboard.isDown("down")){
      cam.phi(speed)
    }
    if(Keyboard.isDown("left")){
      cam.theta(speed)
    }
    if(Keyboard.isDown("right")){
      cam.theta(-speed)
    }
    if(Keyboard.isDown("w")){
      cam.radius(-speed*0.5)
    }
    if(Keyboard.isDown("s")){
      cam.radius(speed*0.5)
    }

  }

  static OrbitCameraMouseInput(cam, speed){
    var mouse = [0,0]
    var move = false

    Application.on(Event.Mousemotion){|args|
      if(move){
        var dx = args[1] - mouse[0]
        var dy = args[2] - mouse[1]
        cam.phi(-dy/10)
        cam.theta(dx/10)
      }
      mouse[0] = args[1]
      mouse[1] = args[2]
    }
    Application.on(Event.Mousebuttondown){|args|
      move = true
    }
    Application.on(Event.Mousebuttonup){|args|
      move = false
    }    
  }

  static FlyCameraKeyboardInput(cam, speed){
    if(Keyboard.isDown("up")){
      cam.pitch(speed)
    }
    if(Keyboard.isDown("down")){
      cam.pitch(-speed)
    }
    if(Keyboard.isDown("left")){
      cam.yaw(-speed)
    }
    if(Keyboard.isDown("right")){
      cam.yaw(speed)
    }
    if(Keyboard.isDown("w")){
      cam.moveForward(speed*0.1)
    }
    if(Keyboard.isDown("s")){
      cam.moveForward(-speed*0.1)
    }
    if(Keyboard.isDown("a")){
      cam.moveRight(-speed*0.1)
    }
    if(Keyboard.isDown("d")){
      cam.moveRight(speed*0.1)
    }

  }
}

