#! /usr/bin/env nix-shell
#! nix-shell -i bash -p xdg_utils

set -euo pipefail

# Install the iso flags svgs
rm -rf src/static/img/iso-flags
mkdir -p src/static/img/iso-flags
install -m 644 -D $(nix build .#web-iso-flags --print-out-paths --no-link)/* -t src/static/img/iso-flags

cd test/

nix run .#hugo
