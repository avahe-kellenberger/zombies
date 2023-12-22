import shade

proc createIdleAnimation(player: Sprite): Animation =
  const
    frameDuration = 0.10
    frameCount = 8
    animDuration = frameCount * frameDuration

  # Set up the idle animation
  let idleAnim = newAnimation(animDuration, true)

  # Change the spritesheet coordinate
  let animCoordFrames: seq[KeyFrame[IVector]] =
    @[
      (ivector(0, 5), 0.0),
      (ivector(10, 5), animDuration - frameDuration),
    ]
  idleAnim.addNewAnimationTrack(
    player.frameCoords,
    animCoordFrames
  )
  return idleAnim

proc createRunAnimation(player: Sprite): Animation =
  const
    frameDuration = 0.08
    frameCount = 8
    animDuration = frameCount * frameDuration

  # Set up the run animation
  var runAnim = newAnimation(animDuration, true)

  # Change the spritesheet coordinate
  let animCoordFrames: seq[KeyFrame[IVector]] =
    @[
      (ivector(0, 7), 0.0),
      (ivector(7, 7), animDuration - frameDuration),
    ]
  runAnim.addNewAnimationTrack(
    player.frameCoords,
    animCoordFrames
  )
  return runAnim

proc createPlayerSprite(): Sprite =
  let (_, image) = Images.loadImage("./assets/images/king.png", FILTER_NEAREST)
  result = newSprite(image, 11, 8)

proc createAnimPlayer(sprite: Sprite): AnimationPlayer =
  result = newAnimationPlayer()
  result.addAnimation("idle", createIdleAnimation(sprite))
  result.addAnimation("run", createRunAnimation(sprite))
  result.playAnimation("idle")

proc createCollisionShape(): CollisionShape =
  result = newCollisionShape(aabb(-8, -13, 8, 13))
  result.material = initMaterial(1, 0, 0.97)

type Player* = ref object of PhysicsBody
  animationPlayer: AnimationPlayer
  sprite*: Sprite

proc createNewPlayer*(): Player =
  result = Player()
  var collisionShape = createCollisionShape()
  initPhysicsBody(PhysicsBody(result), collisionShape)

  let sprite = createPlayerSprite()
  sprite.offset = vector(8.0, 1.0)
  result.sprite = sprite
  result.animationPlayer = createAnimPlayer(sprite)

proc playAnimation*(player: Player, name: string) =
  if player.animationPlayer.currentAnimationName != name:
    player.animationPlayer.playAnimation(name)

method update*(this: Player, deltaTime: float) =
  procCall PhysicsBody(this).update(deltaTime)
  this.animationPlayer.update(deltaTime)

Player.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx, this.x + offsetX, this.y + offsetY)

