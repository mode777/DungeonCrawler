import "augur" for Augur, Assert
import "data" for Ringbuffer

Augur.describe("Ringbuffer") {
  Augur.it("enqueues"){
    var uut = Ringbuffer.new(2)

    uut.enqueue(1)
    uut.enqueue(2)

    Assert.equal(uut.count, 2)
    Assert.equal(uut.isEmpty, false)
  }

  Augur.it("dequeues"){
    var uut = Ringbuffer.new(2)

    uut.enqueue(1)
    uut.enqueue(2)
    var a = uut.dequeue()
    var b = uut.dequeue()
    var c = uut.dequeue()

    Assert.equal(a, 1)
    Assert.equal(b, 2)
    Assert.equal(c, null)
    Assert.equal(uut.count, 0)
    Assert.equal(uut.isEmpty, true)
  }
}
