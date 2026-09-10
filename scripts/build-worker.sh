#!/usr/bin/env bash
set -euo pipefail

case "${CODEC:-h264}" in
  h264) codec_feature="codec-h264" ;;
  h265) codec_feature="codec-h265" ;;
  *)
    echo "CODEC must be h264 or h265" >&2
    exit 2
    ;;
esac

if ! command -v cargo >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --profile minimal
  # shellcheck source=/dev/null
  source "$HOME/.cargo/env"
fi
if command -v rustup >/dev/null 2>&1; then
  rustup target add wasm32-unknown-unknown
fi
if ! command -v worker-build >/dev/null 2>&1; then
  cargo install --locked worker-build --version 0.8.5
fi

cd "$(dirname "${BASH_SOURCE[0]}")/.."
worker-build --locked --release --no-panic-recovery --no-default-features --features "$codec_feature"
