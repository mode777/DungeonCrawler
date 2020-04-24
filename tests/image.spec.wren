import "augur" for Augur, Assert
import "image" for Image
import "vector" for Vec4

Augur.describe("Image") {

  var createImage = Fn.new {|w,h|
    var image = Image.new(w,h)
    var pixel = [0,0,255,255]

    for (y in 0...h) {
      pixel[0] = (pixel[0] + 1)%256
      pixel[1] = 0
      for (x in 0...w){
        pixel[1] = (pixel[1] + 1)%256
        image.setPixel(x,y,pixel)
      }
    }
    return image
  }

  Augur.it("should create from size"){
    var image = Image.new(128,128)
  }

  Augur.it("should load tga"){
    var image = Image.fromFile("./tests/test.tga")
  }

  Augur.it("should fill pixels"){
    var img = createImage.call(256,256)
    var pixel = Vec4.zero()
    img.getPixel(0,0, pixel)
    Assert.elementsEqual(pixel, [1,1,255,255])
  }

  Augur.it("should put pixels"){
    var img = createImage.call(256,256)
    var img2 = createImage.call(64,64)
    img.put(img2, 50, 50)
    var pixel = Vec4.zero()
    img.getPixel(50,50, pixel)
    Assert.elementsEqual(pixel, [1,1,255,255])
  }

  Augur.it("should save image") {
    var img = createImage.call(256,256)
    img.save("./tests/save.tga")
  }

}