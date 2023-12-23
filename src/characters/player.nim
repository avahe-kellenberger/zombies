import shade

# Custom physics handling for the player
const
  maxSpeed = 200.0
  acceleration = 100.0
  jumpForce = -250.0

type Player* = ref object of PhysicsBody
  animationPlayer: AnimationPlayer
  sprite*: Sprite

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

proc physicsProcess(this: Player, deltaTime: float) =
  let
    leftStickX = Input.leftStick.x
    leftPressed = Input.isKeyPressed(K_LEFT) or leftStickX < 0
    rightPressed = Input.isKeyPressed(K_RIGHT) or leftStickX > 0

  var
    x: float = this.velocityX
    y: float = this.velocityY

  proc run(x, y: var float) =
    ## Handles player running
    if leftPressed == rightPressed:
      this.playAnimation("idle")
      return

    let accel =
      if leftStickX == 0.0:
        acceleration
      else:
        acceleration * abs(leftStickX)

    if rightPressed:
      x = min(this.velocityX + accel, maxSpeed)
      if this.sprite.scale.x < 0.0:
        this.sprite.scale = vector(abs(this.sprite.scale.x), this.sprite.scale.y)
    else:
      x = max(this.velocityX - accel, -maxSpeed)
      if this.sprite.scale.y > 0.0:
        this.sprite.scale = vector(-1 * abs(this.sprite.scale.x), this.sprite.scale.y)

    this.playAnimation("run")

  proc friction() =
    x *= 0.85

  friction()
  run(x, y)

  if this.isOnGround and Input.wasActionJustPressed("jump"):
    y += jumpForce

  this.velocity = vector(x, y)

method update*(this: Player, deltaTime: float) =
  this.physicsProcess(deltaTime)
  procCall PhysicsBody(this).update(deltaTime)
  this.animationPlayer.update(deltaTime)

Player.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx, this.x + offsetX, this.y + offsetY)

