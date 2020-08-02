import "platform" for Application, Event, Keyboard
import "container" for GlobalContainer

GlobalContainer.registerInstance("INPUT", { "strafe_left": false, "strafe_right": false, "forward": false, "backward": false, "turn_left": false, "turn_right": false })
GlobalContainer.registerFactory("InputComponent") {|c| InputComponent.new(c.resolve("INPUT"))}

class InputComponent {
  construct new(input){
    _inputState = input
  }

  start(){
  }

  update(){
    _inputState["forward"] = Keyboard.isDown("W")
    _inputState["backward"] = Keyboard.isDown("S")
    _inputState["turn_left"] = Keyboard.isDown("Left")
    _inputState["turn_right"] = Keyboard.isDown("Right")
    _inputState["strafe_left"] = Keyboard.isDown("A")
    _inputState["strafe_right"] = Keyboard.isDown("D")
  }
}