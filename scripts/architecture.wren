class Pipeline {
  construct new(children){
    _children = children
  }

  start(){
    for(c in _children){ c.start() }
  }

  update(){
    for(c in _children){ c.update() }
  }
}