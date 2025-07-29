#!/bin/bash
set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "cs command is available" bash -c "cs --help"
check "scala command is available" bash -c "scala -version"
check "sbt command is available" bash -c "sbt --version"

# Report results
reportResults
