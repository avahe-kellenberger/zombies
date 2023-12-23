import shade

type Terrain* = ref object of PhysicsBody
  image*: Image
  scaleX*: float
  scaleY*: float

proc newTerrain*(image: Image, scaleX: float = 1.0, scaleY: float = 1.0): Terrain =
  result = Terrain(
    kind: PhysicsBodyKind.STATIC,
    image: image,
    scaleX: scaleX,
    scaleY: scaleY
  )

  let
    halfWidth = image.w.float / 2
    halfHeight = image.h.float / 2

  var shape = newCollisionShape(
    newPolygon([
      vector(halfWidth, halfHeight),
      vector(halfWidth, -halfHeight),
      vector(-halfWidth, -halfHeight),
      vector(-halfWidth, halfHeight)
    ])
  )
  shape.material = PLATFORM

  initPhysicsBody(PhysicsBody(result), shape)

Terrain.renderAsChildOf(PhysicsBody):
  # `blit` renders the image centered at the given location.
  blitScale(
    this.image,
    nil,
    ctx,
    this.x + offsetX,
    this.y + offsetY,
    this.scaleX,
    this.scaleY
  )

