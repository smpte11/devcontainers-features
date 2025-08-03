#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "cs is on the PATH" command -v cs
check "scala is on the PATH" command -v scala
check "scalac is on the PATH" command -v scalac
check "sbt is on the PATH" command -v sbt
check "amm is on the PATH" command -v amm
check "scalafmt is on the PATH" command -v scalafmt
check "scala-cli is on the PATH" command -v scala-cli

check "cs version" cs --version
check "scala version" scala -version
check "sbt version" sbt --version

# Report results
reportResults
