.PHONY: test

test:
	cd test && nix run .#hugo -- --logLevel debug
