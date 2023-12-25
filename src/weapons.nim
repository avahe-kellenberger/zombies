import shade

type Weapon* = ref object
  name*: string
  sprite*: Sprite
  ammo*: int
  maxAmmo*: int
  magazineCapacity*: int
  ## Number of seconds between attacks
  attackCooldown*: float
  automatic*: bool

proc newWeapon(
  name: string,
  sprite: Sprite,
  ammo: int,
  maxAmmo: int,
  magazineCapacity: int,
  attackCooldown: float,
  automatic: bool
): Weapon =
  return Weapon(
    name: name,
    sprite: sprite,
    ammo: ammo,
    maxAmmo: maxAmmo,
    magazineCapacity: magazineCapacity,
    attackCooldown: attackCooldown,
    automatic: automatic,
  )

# Cached weapon images
var pistolImage: Image = nil

proc newPistol*(): Weapon =
  if pistolImage == nil:
    pistolImage = Images.loadImage("./assets/images/weapons/pistol.png", FILTER_NEAREST).image
  result = newWeapon("Pistol", newSprite(pistolImage), 0, 255, 8, 0.18, false)

