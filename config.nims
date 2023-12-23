import strformat

# NOTE: Must copy or symlink dependencies into ./.modules
const deps = [
  "shade"
]

for dep in deps:
  switch("path", fmt"./.modules/{dep}")

task runr, "Runs the game in release mode":
  exec "nim r -d:release src/zombies.nim"

task rund, "Runs the game in debug mode":
  exec "nim r -d:debug src/zombies.nim"

task release, "Builds the game in release mode":
  exec "nim c -d:release src/zombies.nim"

