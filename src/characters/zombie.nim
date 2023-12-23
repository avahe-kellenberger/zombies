import shade

type Zombie* = ref object of PhysicsBody
  # TODO: AnimationPlayer
  target*: Entity
  speed*: float

proc createCollisionShape(): CollisionShape =
  result = newCollisionShape(aabb(-8, -13, 8, 13))
  result.material = initMaterial(1, 0, 0.97)

proc newZombie*(speed: float = 20.0): Zombie =
  result = Zombie(kind: PhysicsBodyKind.KINEMATIC, speed: speed)
  var collisionShape = createCollisionShape()
  initPhysicsBody(PhysicsBody(result), collisionShape)

method update*(this: Zombie, deltaTime: float) =
  procCall update(PhysicsBody this, deltaTime)

  if this.target != nil:
    if this.target.x > this.x:
      this.velocity.x = this.speed
    else:
      this.velocity.x = -this.speed

Zombie.renderAsChildOf(PhysicsBody):
  this.collisionShape.fill(ctx, this.x + offsetX, this.y + offsetY)

