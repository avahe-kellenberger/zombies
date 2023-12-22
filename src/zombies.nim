import shade
import characters/player as playerPkg

type Terrain = ref object of PhysicsBody
  sprite: Sprite

proc newTerrain(shape: var CollisionShape, sprite: Sprite): Terrain =
  result = Terrain(kind: PhysicsBodyKind.STATIC, sprite: sprite)
  initPhysicsBody(PhysicsBody(result), shape)

Terrain.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx, this.x + offsetX, this.y + offsetY)

initEngineSingleton(
  "Physics Example",
  1920,
  1080,
  fullscreen = true,
  clearColor = newColor(91, 188, 228)
)

let layer = newPhysicsLayer()
Game.scene.addLayer layer

# Player
let player = createNewPlayer()
player.x = 1920 / 2
player.y = 900

# Track the player with the camera.
Game.scene.camera = newCamera(player, 0.25, easeInAndOutQuadratic)
Game.scene.camera.z = 0.55

let
  (_, groundImage) = Images.loadImage("./assets/images/ground.png", FILTER_NEAREST)
  (_, wallImage) = Images.loadImage("./assets/images/wall.png", FILTER_NEAREST)

# Ground
let
  halfGroundWidth = groundImage.w.float / 2
  halfGroundHeight = groundImage.h.float / 2

var groundShape = newCollisionShape(
  newPolygon([
    vector(halfGroundWidth, halfGroundHeight),
    vector(halfGroundWidth, -halfGroundHeight),
    vector(-halfGroundWidth, -halfGroundHeight),
    vector(-halfGroundWidth, halfGroundHeight)
  ])
)
groundShape.material = PLATFORM

let
  groundSprite = newSprite(groundImage)
  ground = newTerrain(groundShape, groundSprite)

ground.x = 1920 / 2
ground.y = 1080 - groundShape.getBounds().height / 2

ground.collisionShape = groundShape

let wallShapePolygon = newPolygon([
  vector(wallImage.w.float / 2, wallImage.h.float / 2),
  vector(wallImage.w.float / 2, -wallImage.h.float / 2),
  vector(-wallImage.w.float / 2, -wallImage.h.float / 2),
  vector(-wallImage.w.float / 2, wallImage.h.float / 2),
])


let
  leftWallSprite = newSprite(wallImage)
  rightWallSprite = newSprite(wallImage)

rightWallSprite.scale.x = -1

var wallShape = newCollisionShape(wallShapePolygon)
wallShape.material = PLATFORM

let leftWall = newTerrain(wallShape, leftWallSprite)
leftWall.x = ground.x - ground.width / 2 + leftWall.width / 2
leftWall.y = ground.y - ground.height / 2 - leftWall.height / 2

let rightWall = newTerrain(wallShape, rightWallSprite)
rightWall.x = ground.x + ground.width / 2 - rightWall.width / 2
rightWall.y = leftWall.y

layer.addChild(ground)
layer.addChild(leftWall)
layer.addChild(rightWall)
layer.addChild(player)

# Custom physics handling for the player
const
  maxSpeed = 400.0
  acceleration = 100.0
  jumpForce = -350.0

proc physicsProcess(this: Node, deltaTime: float) =
  if Input.wasKeyJustPressed(K_ESCAPE):
    Game.stop()
    return

  let
    leftStickX = Input.leftStick.x
    leftPressed = Input.isKeyPressed(K_LEFT) or leftStickX < 0
    rightPressed = Input.isKeyPressed(K_RIGHT) or leftStickX > 0

  var
    x: float = player.velocityX
    y: float = player.velocityY

  proc run(x, y: var float) =
    ## Handles player running
    if leftPressed == rightPressed:
      player.playAnimation("idle")
      return

    let accel =
      if leftStickX == 0.0:
        acceleration
      else:
        acceleration * abs(leftStickX)

    if rightPressed:
      x = min(player.velocityX + accel, maxSpeed)
      if player.sprite.scale.x < 0.0:
        player.sprite.scale = vector(abs(player.sprite.scale.x), player.sprite.scale.y)
    else:
      x = max(player.velocityX - accel, -maxSpeed)
      if player.sprite.scale.y > 0.0:
        player.sprite.scale = vector(-1 * abs(player.sprite.scale.x), player.sprite.scale.y)

    player.playAnimation("run")

  proc friction() =
    x *= (1 - ground.collisionShape.material.friction)

  friction()
  run(x, y)

  if player.isOnGround and Input.wasActionJustPressed("jump"):
    y += jumpForce

  player.velocity = vector(x, y)

  Game.scene.camera.z += Input.wheelScrolledLastFrame.float * 0.03

player.onUpdate = physicsProcess

# Toggle transparency upon pressing "t"
var isTransparent = false
Input.addKeyPressedListener(
  K_t,
  proc(key: Keycode, state: KeyState) =
    if state.justPressed:
      if isTransparent:
        player.sprite.alpha = 1.0
      else:
        player.sprite.alpha = 0.5

      isTransparent = not isTransparent
  )

when not defined(debug):
  # Play some music
  let someSong = loadMusic("./assets/music/night_prowler.ogg")
  if someSong != nil:
    fadeInMusic(someSong, 2.0, 0.15)
  else:
    echo "Error playing music"

# NOTE: Testing custom input events
Input.registerCustomAction("jump")
Input.addCustomActionTrigger("jump", MouseButton.LEFT)
Input.addCustomActionTrigger("jump", ControllerButton.A)
Input.addCustomActionTrigger("jump", K_SPACE)
Input.addCustomActionTrigger("jump", ControllerStick.RIGHT, Direction.UP)
Input.addCustomActionTrigger("jump", ControllerTrigger.RIGHT)

Game.start()

