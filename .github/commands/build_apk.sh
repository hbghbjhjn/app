#!/usr/bin/env bash
set -euo pipefail

chmod +x ./gradlew
./gradlew :app:assembleDebug
ls -lah app/build/outputs/apk/debug || true
