import shade
import ../characters/player as playerPkg

type Terrain = ref object of PhysicsBody
  sprite: Sprite

proc newTerrain(shape: var CollisionShape, sprite: Sprite): Terrain =
  result = Terrain(kind: PhysicsBodyKind.STATIC, sprite: sprite)
  initPhysicsBody(PhysicsBody(result), shape)

proc newForestLevel*(): Scene =
  result = Scene()
  initScene(result)

  let layer = newPhysicsLayer()
  result.addLayer(layer)

  # Player
  let player = createNewPlayer()
  player.x = 1920 / 2
  player.y = 900

  # Track the player with the camera.
  let camera = newCamera(player, 0.25, easeInAndOutQuadratic)
  camera.z = 0.55
  result.camera = camera

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

  when not defined(debug):
    # Play some music
    let someSong = loadMusic("./assets/music/night_prowler.ogg")
    if someSong != nil:
      fadeInMusic(someSong, 2.0, 0.15)
    else:
      echo "Error playing music"

Terrain.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx, this.x + offsetX, this.y + offsetY)

