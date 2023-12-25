import shade

proc setupCustomActions*() =
  Input.registerCustomAction("run_left")
  Input.addCustomActionTrigger("run_left", K_A)

  Input.registerCustomAction("run_right")
  Input.addCustomActionTrigger("run_right", K_E)

  Input.registerCustomAction("jump")
  Input.addCustomActionTrigger("jump", K_SPACE)

  Input.registerCustomAction("shoot")
  Input.addCustomActionTrigger("shoot", MouseButton.LEFT)

