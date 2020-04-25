import "augur" for Augur, Assert
import "memory" for Buffer, BufferView, Float32Array, Accessor, DataType, ByteVecAccessor, UByteVecAccessor, ShortVecAccessor, UShortVecAccessor, IntVecAccessor, UIntVecAccessor, FloatVecAccessor, ByteAccessor, UByteAccessor, ShortAccessor, UShortAccessor, IntAccessor, UIntAccessor, FloatAccessor

Augur.describe("Buffer") {

  Augur.it("should create") {
    var b = Buffer.new(256)
  }

  Augur.it("should load file") {
    var f = Buffer.fromFile("./tests/file.bin")
    Assert.equal(f.size, 1246)
  }

  Augur.it("should write byte"){
    var b = Buffer.new(16)
    b.writeByte(1,-1)
    Assert.equal(b.readByte(1), -1)
  }

  Augur.it("should write ubyte"){
    var b = Buffer.new(16)
    b.writeUByte(1,255)
    Assert.equal(b.readUByte(1), 255)
  }

  Augur.it("should write short"){
    var b = Buffer.new(16)
    b.writeShort(1,-256)
    Assert.equal(b.readShort(1), -256)
  }

  Augur.it("should write ushort"){
    var b = Buffer.new(16)
    b.writeUShort(1,60000)
    Assert.equal(b.readUShort(1), 60000)
  }

  Augur.it("should write int"){
    var b = Buffer.new(16)
    b.writeInt(1,-66000)
    Assert.equal(b.readInt(1), -66000)
  }

  Augur.it("should write uint"){
    var b = Buffer.new(16)
    b.writeUInt(1,4000000)
    Assert.equal(b.readUInt(1), 4000000)
  }

  Augur.it("should fill 128k buffer"){
    var b = Buffer.new(1024*128)
    var byte = 128
    for (i in 0...b.size) {
      b.writeUByte(i, 128)
    }
  }

  Augur.it("should fill 128k buffer Vec"){
    var b = Buffer.new(1024*128)
    var bytes = [128,128,128,128]
    bytes = bytes + bytes
    for (i in 0...b.size/8) {
      b.writeUByteVec(i*8, bytes)
    }
  }

  Augur.it("should copy"){
    var b1 = Buffer.new(4)
    var b2 = Buffer.new(8)
    b1.writeUInt(0, 42)
    b2.copyFrom(b1, 0, 4, 4)
    Assert.equal(b2.readUInt(4), 42)
  }

  Augur.it("should create from bufferView"){
    var b1 = Buffer.new(256)
    var v1 = BufferView.new(b1)
    var b2 = Buffer.fromBufferView(v1)
    Assert.equal(b1.size, b2.size)
  }
}

Augur.describe("BufferView") {

  Augur.it("should create from buffer") {
    var buffer = Buffer.new(256)
    var view = BufferView.new(buffer)
    Assert.equal(view.size, buffer.size)
  }

  Augur.it("should create with offset") {
    var buffer = Buffer.new(256)
    var view = BufferView.new(buffer, 128, 128)
    Assert.equal(view.size, 128)
    Assert.equal(view.offset, 128)
  }

  Augur.it("should abort if invalid size") {
    var buffer = Buffer.new(256)
    Assert.error {
      BufferView.new(buffer, 128, 256)
    }
  }

}

Augur.describe("Float32Array") {
  
  Augur.it("should create"){
    var arr = Float32Array.new(5)
    Assert.equal(arr.count, 5)
  }

  Augur.it("should fill"){
    var arr = Float32Array.new(5)
    for (i in 0...arr.count) {
      arr[i] = 4
    }
    Assert.elementsEqual(arr, [4,4,4,4,4])
  }

  Augur.it("should create from buffer"){
    var buffer = Buffer.new(4*4)
    var arr1 = Float32Array.new(buffer, 0, 2*4)
    var arr2 = Float32Array.new(buffer, 2*4, 2*4)
    var arr3 = Float32Array.new(buffer, 0, buffer.size)
    arr1[0] = 1
    arr2[0] = 2

    Assert.elementsEqual(arr3, [1,0,2,0])
  }

}

var testNew = Fn.new {|ctor|
  var count = 3
  var acc = ctor.new(count)
  for (i in 0...acc.count) {
    acc[i] = 1
  }
  for (v in acc) {
    Assert.equal(v, 1)
  }
}

var testView = Fn.new {|ctor,type|
  var count = 3
  var buffer = Buffer.new(DataType.size(type)*count)
  var view = BufferView.new(buffer)

  var acc = ctor.fromBufferView(view, 0, 0)
  for (i in 0...acc.count) {
    acc[i] = i
  }
  for (i in 0...acc.count) {
    Assert.equal(acc[i], i)
  }
}

var vecTestNew = Fn.new {|ctor|
  var components = 3
  var count = 4
  var acc = ctor.new(count, components)
  for (i in 0...acc.count) {
    acc[i] = [1,1,1]
  }
  for (v in acc) {
    Assert.elementsEqual(v, [1,1,1])
  }
}

var vecTestView = Fn.new {|ctor,type|
  var components = 3
  var count = 4
  var buffer = Buffer.new(components*DataType.size(type)*count)
  var view = BufferView.new(buffer)

  var acc = ctor.fromBufferView(view, components, 0, 0)
  for (i in 0...acc.count) {
    acc[i] = [i,i,i]
  }
  for (i in 0...acc.count) {
    Assert.elementsEqual(acc[i], [i,i,i])
  }
}

Augur.describe("ByteAccessor") {
  Augur.it("should set values") { testNew.call(ByteAccessor) }
  Augur.it("should set values from buffer") { testView.call(ByteAccessor, DataType.Byte) }
}

Augur.describe("UByteAccessor") {
  Augur.it("should set values") { testNew.call(UByteAccessor) }
  Augur.it("should set values from buffer") { testView.call(UByteAccessor, DataType.UByte) }
}

Augur.describe("ShortAccessor") {
  Augur.it("should set values") { testNew.call(ShortAccessor) }
  Augur.it("should set values from buffer") { testView.call(ShortAccessor, DataType.Short) }
}

Augur.describe("UShortAccessor") {
  Augur.it("should set values") { testNew.call(UShortAccessor) }
  Augur.it("should set values from buffer") { testView.call(UShortAccessor, DataType.UShort) }
}

Augur.describe("IntAccessor") {
  Augur.it("should set values") { testNew.call(IntAccessor) }
  Augur.it("should set values from buffer") { testView.call(IntAccessor, DataType.Int) }
}

Augur.describe("UIntAccessor") {
  Augur.it("should set values") { testNew.call(UIntAccessor) }
  Augur.it("should set values from buffer") { testView.call(UIntAccessor, DataType.UInt) }
}

Augur.describe("FloatAccessor") {
  Augur.it("should set values") { testNew.call(FloatAccessor) }
  Augur.it("should set values from buffer") { testView.call(FloatAccessor, DataType.Float) }
}

Augur.describe("ByteVecAccessor") {
  Augur.it("should set values") { vecTestNew.call(ByteVecAccessor) }
  Augur.it("should set values from buffer") { vecTestView.call(ByteVecAccessor, DataType.Byte) }
}

Augur.describe("UByteVecAccessor") {
  Augur.it("should set values") { vecTestNew.call(UByteVecAccessor) }
  Augur.it("should set values from buffer") { vecTestView.call(UByteVecAccessor, DataType.UByte) }
}

Augur.describe("ShortVecAccessor") {
  Augur.it("should set values") { vecTestNew.call(ShortVecAccessor) }
  Augur.it("should set values from buffer") { vecTestView.call(ShortVecAccessor, DataType.Short) }
}

Augur.describe("UShortVecAccessor") {
  Augur.it("should set values") { vecTestNew.call(UShortVecAccessor) }
  Augur.it("should set values from buffer") { vecTestView.call(UShortVecAccessor, DataType.UShort) }
}

Augur.describe("IntVecAccessor") {
  Augur.it("should set values") { vecTestNew.call(IntVecAccessor) }
  Augur.it("should set values from buffer") { vecTestView.call(IntVecAccessor, DataType.Int) }
}

Augur.describe("UIntVecAccessor") {
  Augur.it("should set values") { vecTestNew.call(UIntVecAccessor) }
  Augur.it("should set values from buffer") { vecTestView.call(UIntVecAccessor, DataType.UInt) }
}

Augur.describe("FloatVecAccessor") {
  Augur.it("should set values") { vecTestNew.call(FloatVecAccessor) }
  Augur.it("should set values from buffer") { vecTestView.call(FloatVecAccessor, DataType.Float) }
}