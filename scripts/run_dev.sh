#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../app"
dart pub get
PORT=${PORT:-8080} dart run bin/server.dart
