import "camera" for OrbitCamera
import "platform" for Keyboard

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
      cam.moveForward(speed*0.2)
    }
    if(Keyboard.isDown("s")){
      cam.moveForward(-speed*0.2)
    }
    if(Keyboard.isDown("a")){
      cam.moveRight(-speed*0.2)
    }
    if(Keyboard.isDown("d")){
      cam.moveRight(speed*0.2)
    }

  }
}

