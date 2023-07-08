#! /usr/bin/env nix-shell
#! nix-shell -i bash -p xdg_utils

set -euo pipefail

cd test/

sleep 1 && xdg-open "http://localhost:1313/" &

hugo server --logLevel debug --disableFastRender
