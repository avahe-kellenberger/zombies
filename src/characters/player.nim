import shade

import ../weapons

# Custom physics handling for the player
const
  maxSpeed = 100.0
  acceleration = 100.0
  jumpForce = -250.0
  weaponPixelOffset = 18.0

type Player* = ref object of PhysicsBody
  animationPlayer: AnimationPlayer
  sprite*: Sprite
  weapon*: Weapon

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
      (ivector(0, 1), 0.0),
      (ivector(7, 1), animDuration - frameDuration),
    ]
  idleAnim.addNewAnimationTrack(
    player.frameCoords,
    animCoordFrames
  )
  return idleAnim

proc createRunAnimation(player: Sprite): Animation =
  const
    frameDuration = 0.12
    frameCount = 8
    animDuration = frameCount * frameDuration

  # Set up the run animation
  var runAnim = newAnimation(animDuration, true)

  # Change the spritesheet coordinate
  let animCoordFrames: seq[KeyFrame[IVector]] =
    @[
      (ivector(0, 0), 0.0),
      (ivector(7, 0), animDuration - frameDuration),
    ]
  runAnim.addNewAnimationTrack(
    player.frameCoords,
    animCoordFrames
  )
  return runAnim

proc createJumpAnimation(player: Sprite): Animation =
  const
    frameDuration = 0.12
    frameCount = 2
    animDuration = frameCount * frameDuration

  var anim = newAnimation(animDuration, false)

  # Change the spritesheet coordinate
  let animCoordFrames: seq[KeyFrame[IVector]] =
    @[
      (ivector(0, 2), 0.0),
      (ivector(1, 2), animDuration - frameDuration),
    ]
  anim.addNewAnimationTrack(
    player.frameCoords,
    animCoordFrames
  )
  return anim

proc createFallAnimation(player: Sprite): Animation =
  const
    frameDuration = 0.12
    frameCount = 2
    animDuration = frameCount * frameDuration

  var anim = newAnimation(animDuration, false)

  # Change the spritesheet coordinate
  let animCoordFrames: seq[KeyFrame[IVector]] =
    @[
      (ivector(2, 2), 0.0),
      (ivector(3, 2), animDuration - frameDuration),
    ]
  anim.addNewAnimationTrack(
    player.frameCoords,
    animCoordFrames
  )
  return anim

proc createLandAnimation(player: Sprite): Animation =
  const
    frameDuration = 0.12
    frameCount = 2
    animDuration = frameCount * frameDuration

  var anim = newAnimation(animDuration, false)

  # Change the spritesheet coordinate
  let animCoordFrames: seq[KeyFrame[IVector]] =
    @[
      (ivector(4, 2), 0.0),
      (ivector(5, 2), animDuration - frameDuration),
    ]
  anim.addNewAnimationTrack(
    player.frameCoords,
    animCoordFrames
  )
  return anim

proc createHurtAnimation(player: Sprite): Animation =
  const
    frameDuration = 0.12
    frameCount = 8
    animDuration = frameCount * frameDuration

  var anim = newAnimation(animDuration, false)

  # Change the spritesheet coordinate
  let animCoordFrames: seq[KeyFrame[IVector]] =
    @[
      (ivector(6, 2), 0.0),
      (ivector(7, 2), frameDuration * 2),
      (ivector(6, 2), frameDuration * 3),
      (ivector(7, 2), frameDuration * 4),
      (ivector(6, 2), frameDuration * 5),
      (ivector(7, 2), frameDuration * 6),
      (ivector(6, 2), frameDuration * 7),
      (ivector(7, 2), frameDuration * 8)
    ]
  anim.addNewAnimationTrack(
    player.frameCoords,
    animCoordFrames
  )
  return anim

proc createPlayerSprite(): Sprite =
  let (_, image) = Images.loadImage("./assets/images/man.png", FILTER_NEAREST)
  result = newSprite(image, 8, 4)

proc createAnimPlayer(sprite: Sprite): AnimationPlayer =
  result = newAnimationPlayer()
  result.addAnimation("idle", createIdleAnimation(sprite))
  result.addAnimation("run", createRunAnimation(sprite))
  result.addAnimation("jump", createJumpAnimation(sprite))
  result.addAnimation("fall", createFallAnimation(sprite))
  result.addAnimation("land", createLandAnimation(sprite))
  result.addAnimation("hurt", createHurtAnimation(sprite))
  result.playAnimation("idle")

proc createCollisionShape(): CollisionShape =
  result = newCollisionShape(aabb(-9, -18, 9, 18))
  result.material = initMaterial(1, 0, 0.97)

proc newPlayer*(): Player =
  result = Player()
  var collisionShape = createCollisionShape()
  initPhysicsBody(PhysicsBody(result), collisionShape)

  let sprite = createPlayerSprite()
  sprite.offset = vector(0.0, 0.0)
  result.sprite = sprite
  result.animationPlayer = createAnimPlayer(sprite)

  result.weapon = newPistol()

proc playAnimation*(player: Player, name: string) =
  if player.animationPlayer.currentAnimationName != name:
    player.animationPlayer.playAnimation(name)

proc physicsProcess(this: Player, deltaTime: float) =
  let
    leftPressed = Input.isActionPressed("run_left")
    rightPressed = Input.isActionPressed("run_right")

  var
    x: float = this.velocityX
    y: float = this.velocityY

  proc run(x, y: var float) =
    ## Handles player running
    if leftPressed == rightPressed:
      this.playAnimation("idle")
      return

    if rightPressed:
      x = min(this.velocityX + acceleration, maxSpeed)
      if this.sprite.scale.x < 0.0:
        this.sprite.scale = vector(abs(this.sprite.scale.x), this.sprite.scale.y)
    else:
      x = max(this.velocityX - acceleration, -maxSpeed)
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

  if this.weapon != nil:
    # Render weapon sprite rotated and flipped about the player's center, with an offset
    this.weapon.sprite.render(ctx, this.x + offsetX, this.y + offsetY)
    let mouseLocInWorld = Game.scene.camera.screenToWorldCoord(Input.mouseLocation(), 1.0 - Game.scene.camera.z)
    let angleToCursor = this.getLocation().getAngleTo(mouseLocInWorld)
    this.weapon.sprite.rotation = angleToCursor

    if mouseLocInWorld.x > this.x:
      this.weapon.sprite.scale.y = 1.0
      this.weapon.sprite.offset = fromAngle(angleToCursor) * weaponPixelOffset
    else:
      this.weapon.sprite.scale.y = -1.0
      this.weapon.sprite.offset = fromAngle(-angleToCursor) * weaponPixelOffset

