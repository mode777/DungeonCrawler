import "augur" for Augur, Assert
import "./game/infrastructure" for EventQueue, GameEvent

Augur.describe("EventQueue") {
  Augur.it("dispatches"){
    var eq = EventQueue.new(2)
    var ev1 = GameEvent.new("a")
    var ev2 = GameEvent.new("b")

    var called = []

    eq.subscribe("a") { |ev| called.add(ev.id) }
    eq.subscribe("b") { |ev| called.add(ev.id) }

    eq.add(ev1)
    eq.add(ev2)

    var r1 = eq.dispatchNext()
    var r2 = eq.dispatchNext()
    var r3 = eq.dispatchNext()

    Assert.contains(called, "a")
    Assert.contains(called, "b")
    Assert.equal(eq.count, 0)
    Assert.equal(r1, true)
    Assert.equal(r2, true)
    Assert.equal(r3, false)
  }
}
