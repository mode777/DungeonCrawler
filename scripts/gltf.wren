import "json" for Json
import "io" for File
import "image" for Image
import "memory" for Buffer, BufferView, Float32Array, Accessor, DataType, ByteVecAccessor, UByteVecAccessor, ShortVecAccessor, UShortVecAccessor, IntVecAccessor, UIntVecAccessor, FloatVecAccessor, ByteAccessor, UByteAccessor, ShortAccessor, UShortAccessor, IntAccessor, UIntAccessor, FloatAccessor
import "geometry" for GeometryData, AttributeType
import "graphics" for Geometry, Mesh, Texture

class Gltf {

  static numComponents(str){
    if(str == "VEC3") return 3
    if(str == "VEC2") return 2
    if(str == "VEC4") return 4
    if(str == "SCALAR") return 1
    if(str == "MAT3") return 9
    if(str == "MAT2") return 4
    if(str == "MAT4") return 16
    return 1
  }

  static attributeType(str){
    if(str == "POSITION") return AttributeType.Position
    if(str == "COLOR_0") return AttributeType.Color
    if(str == "NORMAL") return AttributeType.Normal
    if(str == "TANGENT") return AttributeType.Tangent
    if(str == "TEXCOORD_0") return AttributeType.Texcoord0
    if(str == "TEXCOORD_1") return AttributeType.Texcoord1
    return 0    
  }

  static accessorVecType(type){
    if(type == DataType.Byte) return ByteVecAccessor
    if(type == DataType.UByte) return UByteVecAccessor
    if(type == DataType.Short) return ShortVecAccessor
    if(type == DataType.UShort) return UShortVecAccessor
    if(type == DataType.Int) return IntVecAccessor
    if(type == DataType.UInt) return UIntVecAccessor
    if(type == DataType.Float) return FloatVecAccessor
  }

  static accessorType(type){
    if(type == DataType.Byte) return ByteAccessor
    if(type == DataType.UByte) return UByteAccessor
    if(type == DataType.Short) return ShortAccessor
    if(type == DataType.UShort) return UShortAccessor
    if(type == DataType.Int) return IntAccessor
    if(type == DataType.UInt) return UIntAccessor
    if(type == DataType.Float) return FloatAccessor
  }

  meshes { _meshes }
  accessors { _accessors }
  textures { _textures }
  materials { _materials }

  construct fromFile(filename){
    var file = File.open(filename, "rb")
    var content = file.readToEnd()
    file.close()
    _json = Json.parse(content)
    
    getFolder(filename)
    loadImages()
    loadBuffers()
    loadTextures()
    loadViews()
    loadAccessors()
    loadMeshes()
    loadMaterials()
    
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
      _images.add(Image.fromFile(_folder + "/" + image["uri"]))
    }
  }

  loadBuffers(){
    _buffers = []
    for(buffer in _json["buffers"]){
      _buffers.add(Buffer.fromFile(_folder + "/" + buffer["uri"]))
    }
  }

  loadTextures(){
    _textures = []
    for(texture in _json["textures"]){
      _textures.add(GltfTexture.fromJson(_images[texture["source"]], texture))
    }
  }

  loadViews(){
    _views = []
    for(view in _json["bufferViews"]){
      var buffer = _buffers[view["buffer"]]
      var offset = view["byteOffset"]
      var size = view["byteLength"]
      var stride = view["stride"] || 0
      _views.add(BufferView.new(buffer, offset, size))
    }
  }

  loadAccessors(){
    _accessors = []
    for(acc in _json["accessors"]){
      loadAccessor(acc)
    }
  }

  loadAccessor(json){
    var view = _views[json["bufferView"]]
    var componentType = json["componentType"]
    var numComponents = Gltf.numComponents(json["type"])
    var accessor = null
    // TODO: Get stride and offset
    if(numComponents == 1){
      accessor = Gltf.accessorType(componentType).fromBufferView(view, 0, 0)
    } else {
      accessor = Gltf.accessorVecType(componentType).fromBufferView(view, numComponents, 0, 0)
    }
    _accessors.add(accessor)
  }

  loadMeshes(){
    _meshes = []
    for(mesh in _json["meshes"]){
      var primitives = []
      for(prim in mesh["primitives"]){
        var index = _accessors[prim["indices"]]
        //var material = _materials[prim["material"]]
        var attributes = {}
        for(key in prim["attributes"].keys){
          var aType= Gltf.attributeType(key)
          attributes[aType] =  _accessors[prim["attributes"][key]]
        }
        primitives.add(GeometryData.new(attributes, index))
      }
      _meshes.add(GltfMesh.fromJson(primitives, mesh))
    }    
  }

  loadMaterials(){
    _materials = []
    for(material in _json["materials"]){
      var mat = GltfMaterial.fromJson(_textures, material)
      _materials.add(mat)
    }
  }

}

class GltfTexture {

  source { _source }

  construct fromJson(imageSrc, json) {
    _source = imageSrc
  }  

  toGraphicsTexture(){
    return Texture.fromImage(_source)
  }
}

class GltfMesh {
  
  name { _name }
  primitives { _primitives }
  
  construct fromJson(primitives, json){
    _primitives = primitives
    _name = json["name"]
  }

  toGraphicsMesh(){
    var geometry = _primitives.map {|x| Geometry.new(x) }.toList
    return Mesh.new(geometry)
  }
}

class GltfMaterial {
  
  diffuse { _diffuse }
  
  construct fromJson(textures, json){
    _diffuse = textures[json["pbrMetallicRoughness"]["baseColorTexture"]["index"]]
  }
}