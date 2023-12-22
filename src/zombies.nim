import shade
import levels/forest

initEngineSingleton(
  "Physics Example",
  1920,
  1080,
  fullscreen = true,
  clearColor = newColor(91, 188, 228)
)

Input.addKeyPressedListener(
  K_ESCAPE,
  proc(key: Keycode, state: KeyState) =
    Game.stop()
)

# TODO: Set up controls in a dedicated file
Input.registerCustomAction("jump")
Input.addCustomActionTrigger("jump", MouseButton.LEFT)
Input.addCustomActionTrigger("jump", ControllerButton.A)
Input.addCustomActionTrigger("jump", K_SPACE)
Input.addCustomActionTrigger("jump", ControllerStick.RIGHT, Direction.UP)
Input.addCustomActionTrigger("jump", ControllerTrigger.RIGHT)

let scene = newForestLevel()
Game.scene = scene

Game.start()

