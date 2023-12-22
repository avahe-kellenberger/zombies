# Package

version       = "0.1.0"
author        = "Avahe Kellenberger"
description   = "Game about killing zombies"
license       = "GPL-2.0-only"
srcDir        = "src"
bin           = @["zombies"]


# Dependencies

requires "nim >= 2.0.0"
requires "https://github.com/einheit-tech/shade"

task runr, "Runs the game in release mode":
  exec "nim r -d:release src/zombies.nim"

task rund, "Runs the game in debug mode":
  exec "nim r -d:debug src/zombies.nim"

task release, "Builds the game in release mode":
  exec "nim c -d:release src/zombies.nim"

