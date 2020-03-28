import "json" for JSON, JSONParser
import "PGL" for Game, Keyboard, Camera, File, Image, Buffer, GeometryBuffer, Attribute, Primitive, Texture, Material, Mesh

class GLTF {

  meshes { _meshes }

  construct load(filename){
    var file = File.new(filename, "rb")
    var content = file.read(file.length())
    _json = JSON.parse(content)
    
    getFolder(filename)
    loadImages()
    loadBuffers()
    loadTextures()
    loadAttributeTypes()
    loadViews()
    loadAccessors()
    loadMaterials()
    loadMeshes()

    _json = null
  }

  getFolder(filename){
    var frags = filename.split("/")
    frags.removeAt(-1)
    _folder = frags.join("/")
  }

  loadImages(){
    _images = []
    for (image in _json["images"]) {
      _images.add(Image.new(_folder + "/" + image["uri"], 4))
    }
  }

  loadBuffers(){
    _buffers = []
    for(buffer in _json["buffers"]){
      _buffers.add(Buffer.new(_folder + "/" + buffer["uri"]))
    }
  }

  loadTextures(){
    _textures = []
    for(texture in _json["textures"]){
      _textures.add(Texture.new(_images[texture["source"]]))
    }
  }

  loadViews(){
    _views = []
    var i = 0
    for(view in _json["bufferViews"]){
      var buffer = _buffers[view["buffer"]]
      var offset = view["byteOffset"]
      var size = view["byteLength"]
      var stride = view["stride"] || 0
      _views.add(GeometryBuffer.new(buffer, offset, size, stride, _indices.contains(i)))
      i = i+1
    }
  }

  attributeType(str){
    if(str == "POSITION") return 1
    if(str == "COLOR_0") return 2
    if(str == "NORMAL") return 3
    if(str == "TANGENT") return 4
    if(str == "TEXCOORD_0") return 5
    if(str == "TEXCOORD_1") return 6
    return 0    
  }

  loadAttributeTypes(){
    _indices = []
    _attributeTypes = {}
    for(mesh in _json["meshes"]){
      for(prim in mesh["primitives"]){
        for(key in prim["attributes"].keys){
          _attributeTypes[prim["attributes"][key]] = attributeType(key)
        }
        // indices does not have an attribute type
        var indexBuffer = _json["accessors"][prim["indices"]]["bufferView"]
        _indices.add(indexBuffer)
        _attributeTypes[prim["indices"]] = 0
      }
    }
  }

  numComponents(str){
    if(str == "VEC3") return 3
    if(str == "VEC2") return 2
    if(str == "VEC4") return 4
    if(str == "SCALAR") return 1
    if(str == "MAT3") return 9
    if(str == "MAT2") return 4
    if(str == "MAT4") return 16
    return 1
  }

  loadAccessors(){
    _accessors = []
    var i = 0
    for(accessor in _json["accessors"]){
      var view = _views[accessor["bufferView"]]
      var componentType = accessor["componentType"]
      var count = accessor["count"]
      var componentCount = numComponents(accessor["type"])
      // TODO: Check offset property in spec
      var offset = accessor["offset"] || 0
      var normalized = accessor["normalized"] || false
      var attributeType = _attributeTypes[i]
      
      //System.print("CompType: %(componentType), Count: %(count), CompCount: %(componentCount), AttrType: %(attributeType)")

      _accessors.add(Attribute.new(view, attributeType, componentType, componentCount, offset, normalized, count))
      i = i+1 
    }
  }

  loadMaterials(){
    _materials = []
    for(material in _json["materials"]){
      var diffuse = _textures[material["pbrMetallicRoughness"]["baseColorTexture"]["index"]]
      _materials.add(Material.new(diffuse))
    }
  }

  loadMeshes(){
    _meshes = []
    for(mesh in _json["meshes"]){
      var name = mesh["name"]
      var primitives = []
      for(prim in mesh["primitives"]){
        var index = _accessors[prim["indices"]]
        var material = _materials[prim["material"]]
        var attributes = []
        for(key in prim["attributes"].keys){
          attributes.add(_accessors[prim["attributes"][key]])
        }
        primitives.add(Primitive.new(index, attributes, material))
      }
      _meshes.add(Mesh.new(name, primitives))
    }    
  }
}