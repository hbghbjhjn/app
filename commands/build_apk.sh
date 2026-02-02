#!/usr/bin/env bash
set -euo pipefail

# We expect Gradle to be installed by the workflow and available as `gradle`
gradle --version

# Build Debug APK
gradle :app:assembleDebug

# Show outputs (for debugging)
ls -lah app/build/outputs/apk/debug || true
