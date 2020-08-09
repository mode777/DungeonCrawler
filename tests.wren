import "augur" for Augur
import "platform" for Application, Severity

import "./tests/memory.spec"
import "./tests/image.spec"
import "./tests/geometry.spec"
import "./tests/graphics.spec"
import "./tests/gltf.spec"
import "./tests/math.spec"
import "./tests/font.spec"
import "./tests/perf.spec"
import "./tests/data.spec"

import "./tests/game/infrastructure.spec"

Application.onLoad {
  //Application.logLevel(Severity.Debug)
  Augur.run()
  Application.quit()
}