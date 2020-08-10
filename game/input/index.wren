import "platform" for Application, Event, Keyboard

import "./game/events" for SystemEvents, InputEvents
import "./game/infrastructure" for EventQueue, GameEvent, GameSystem

GameSystem.attach("main"){|s|
  var queue = s.queue

  var inputState = {}
  var inputEvent = GameEvent.new(InputEvents.Update, inputState) 

  queue.subscribe(SystemEvents.Update){
    inputState["forward"] = Keyboard.isDown("W")
    inputState["backward"] = Keyboard.isDown("S")
    inputState["turn_left"] = Keyboard.isDown("Left")
    inputState["turn_right"] = Keyboard.isDown("Right")
    inputState["strafe_left"] = Keyboard.isDown("A")
    inputState["strafe_right"] = Keyboard.isDown("D")
    queue.add(inputEvent)
  }
}
