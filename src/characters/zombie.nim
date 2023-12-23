import shade

type Zombie* = ref object of PhysicsBody

proc createCollisionShape(): CollisionShape =
  result = newCollisionShape(aabb(-8, -13, 8, 13))
  result.material = initMaterial(1, 0, 0.97)

proc newZombie*(): Zombie =
  result = Zombie(kind: PhysicsBodyKind.KINEMATIC)
  var collisionShape = createCollisionShape()
  initPhysicsBody(PhysicsBody(result), collisionShape)

Zombie.renderAsChildOf(PhysicsBody):
  this.collisionShape.fill(ctx, this.x + offsetX, this.y + offsetY)

