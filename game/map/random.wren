import "random" for Random

class ProdGen {
  construct new(seed){
    _random = Random.new(seed)
  }

  construct new(){
    _random = Random.new()
  }

  size(s, threshold){ _random.int(s-threshold*2) + threshold }
  range(a,b,threshold){ a + size(b-a, threshold) }
  color(){ [_random.int(255),_random.int(255),_random.int(255),255] }
  float(s,e){ _random.float(s,e) }
  select(list){ list[_random.int(list.count)] }
}