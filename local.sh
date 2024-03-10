#! /usr/bin/env nix-shell
#! nix-shell -i bash -p xdg_utils

set -euo pipefail

# Install the iso flags svgs
rm -rf src/static/img/iso-flags
mkdir -p src/static/img/iso-flags
install -m 644 -D $(nix build .#web-iso-flags --print-out-paths --no-link)/* -t src/static/img/iso-flags

# Install the fontawesome files
rm -rf src/assets/scss/fontawesome src/static/fonts/fontawesome
mkdir -p src/assets/scss/fontawesome
mkdir -p src/static/fonts/fontawesome
install -m 644 -D $(nix build .#fontawesome --print-out-paths --no-link)/scss/* -t src/assets/scss/fontawesome
install -m 644 -D $(nix build .#fontawesome --print-out-paths --no-link)/webfonts/* -t src/static/fonts/fontawesome

cd test/

sleep 1 && xdg-open "http://localhost:1313/" &

nix run .#hugo -- server --logLevel debug --disableFastRender --gc
