import "json" for Json
import "io" for File
import "image" for Image
import "memory" for ListUtil, Buffer, BufferView, Float32Array, Accessor, DataType, ByteVecAccessor, UByteVecAccessor, ShortVecAccessor, UShortVecAccessor, IntVecAccessor, UIntVecAccessor, FloatVecAccessor, ByteAccessor, UByteAccessor, ShortAccessor, UShortAccessor, IntAccessor, UIntAccessor, FloatAccessor
import "geometry" for GeometryData, AttributeType
import "graphics" for Geometry, Mesh, Texture, DiffuseMaterial
import "math" for Mat4

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

  meshes { _meshes }
  accessors { _accessors }
  textures { _textures }
  materials { _materials }
  nodes { _nodes }
  scenes { _scenes }

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
    loadNodes()
    loadScenes()

    _json = null
  }

  getFolder(filename){
    var frags = filename.split("/")
    frags.removeAt(-1)
    _folder = frags.join("/")
  }

  loadImages(){
    _images = []
    if(_json["images"] == null) return

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

    if(_json["textures"] == null) return

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
      accessor = Accessor.constructorForType(componentType).fromBufferView(view, 0, 0)
    } else {
      accessor = Accessor.constructorForVecType(componentType).fromBufferView(view, numComponents, 0, 0)
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
      _meshes.add(GltfMesh.fromJson(this, primitives, mesh))
    }    
  }

  loadMaterials(){
    _materials = []

    if(_json["materials"] == null) return

    for(material in _json["materials"]){
      var mat = GltfMaterial.fromJson(_textures, material)
      _materials.add(mat)
    }
  }

  loadNodes(){
    _nodes = []

    if(_json["nodes"] == null) return

    for(node in _json["nodes"]){
      _nodes.add(GltfNode.fromJson(this, node))
    }
  }

  loadScenes(){
    _scenes = []

    if(_json["scenes"] == null) return

    for(scene in _json["scenes"]){
      _scenes.add(GltfScene.fromJson(this, scene))
    }
  }

  scene(name){
    return ListUtil.first(_scenes) {|e| e.name == name }
  }

  node(name){
    return ListUtil.first(_nodes) {|e| e.name == name }
  }

  mesh(name){
    return ListUtil.first(_meshes) {|e| e.name == name }
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
  material { _material }

  construct fromJson(gltf, primitives, json){
    _primitives = primitives
    _name = json["name"]
    var i = json["material"]
    if(i) _material = gltf.materials[i]
  }

  toGraphicsMeshes(){
    var mat = _material ? _material.toGraphicsMaterial() : null
    return _primitives.map {|x| Mesh.new(Geometry.new(x),mat) }.toList
  }

  toGraphicsMeshes(transform){
    var mat = _material ? _material.toGraphicsMaterial() : null
    return _primitives.map {|x| Mesh.new(Geometry.new(x),mat, transform) }.toList
  }
}

class GltfMaterial {
  
  diffuse { _diffuse }
  
  construct fromJson(textures, json){
    _diffuse = textures[json["pbrMetallicRoughness"]["baseColorTexture"]["index"]]
  }

  toGraphicsMaterial(){
    return DiffuseMaterial.new(_diffuse.toGraphicsTexture())
  }
  
}

class GltfNode {

  transform { _transform }
  mesh { _mesh }
  name { _name }

  construct fromJson(gltf, json){
    _transform = parseTransform(json)
    var i = json["mesh"] 
    if(i) _mesh = gltf.meshes[i]
    _name = json["name"]
  }

  parseTransform(json){
    var m = Mat4.new()

    var s = json["scale"]
    var r = json["rotation"]
    var t = json["translation"]

    if(t) m.translate(t[0], t[1], t[2])
    if(r) m.rotateQuat(r[0], r[1], r[2], r[3])
    if(s) m.scale(s[0], s[1], s[2])

    return m
  }

  toGraphicsMeshes(){
    if(_mesh){
      return _mesh.toGraphicsMeshes(_transform)
    }
    return []
  }
}

class GltfScene {

  name { _name }
  nodes { _nodes }

  construct fromJson(gltf, json){
    _name = json["name"]
    _nodes = json["nodes"].map {|i| gltf.nodes[i]}.toList
  }

  toGraphicsMeshes() {
    return _nodes.reduce([]) {|p,c|  
      c.toGraphicsMeshes().each {|m| p.add(m)}
      return p
    }.toList
  }
}