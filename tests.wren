import "augur" for Augur
import "platform" for Application, Severity

import "./tests/memory.spec"
import "./tests/image.spec"
import "./tests/geometry.spec"
import "./tests/graphics.spec"
import "./tests/gltf.spec"

Application.onLoad {
  //Application.logLevel(Severity.Debug)
  Augur.run()
  Application.quit()
}