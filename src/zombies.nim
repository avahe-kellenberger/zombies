import shade

initEngineSingleton("Physics Example", 960, 540, fullscreen = false)

import levels/forest
import controls

controls.setupCustomActions()

Input.onKeyPressed(K_ESCAPE):
  Game.stop()

let scene = newForestLevel()
Game.scene = scene

Game.start()

