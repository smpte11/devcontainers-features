#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "cs is on the PATH" command -v cs
check "scala is on the PATH" command -v scala
check "sbt is not on the PATH" bash -c '! command -v sbt'

# Report results
reportResults
