import shade
import ../objects/terrain as terrainPkg
import ../characters/player as playerPkg
import ../characters/zombie as zombiePkg

proc newForestLevel*(): Scene =
  result = Scene()
  initScene(result)

  Game.clearColor = newColor(16, 32, 38)

  let layer = newPhysicsLayer()
  result.addLayer(layer)

  let player = newPlayer()
  player.x = 1920 / 2
  player.y = 900
  layer.addChild(player)

  # Track the player with the camera.
  result.camera = newCamera(player, 0.15, easeInAndOutQuadratic)
  result.camera.setLocation(player.getLocation())
  result.camera.z = 0.60
  result.camera.offset.y = -30

  let
    (_, groundImage) = Images.loadImage("./assets/images/ground.png", FILTER_NEAREST)
    (_, wallImage) = Images.loadImage("./assets/images/wall.png", FILTER_NEAREST)

  let ground = newTerrain(groundImage)
  ground.x = 1920 / 2
  ground.y = 1080 - ground.height / 2
  layer.addChild(ground)

  let leftWall = newTerrain(wallImage)
  leftWall.x = ground.x - ground.width / 2 + leftWall.width / 2
  leftWall.y = ground.y - ground.height / 2 - leftWall.height / 2
  layer.addChild(leftWall)

  let rightWall = newTerrain(wallImage, scaleX = -1.0)
  rightWall.x = ground.x + ground.width / 2 - rightWall.width / 2
  rightWall.y = leftWall.y
  layer.addChild(rightWall)

  let zombie = newZombie()
  zombie.x = player.x - 200
  zombie.y = ground.y - ground.height / 2 - zombie.collisionShape.height / 2
  zombie.target = player
  layer.addChild(zombie)

  when not defined(debug):
    # Play some music
    let someSong = loadMusic("./assets/music/night_prowler.ogg")
    if someSong != nil:
      fadeInMusic(someSong, 2.0, 0.15)
    else:
      echo "Error playing music"

