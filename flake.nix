{
  description = "Taserud Consulting AB Theme: Albatross";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable-small;
    flake-utils.url = "flake-utils";
    web-iso-flags.url = git+ssh://git@github.com/TaserudConsulting/web-iso-flags;
    web-iso-flags.inputs.flake-utils.follows = "flake-utils";
    web-iso-flags.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  } @ inputs: (flake-utils.lib.eachDefaultSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system};
    version = "0.0.0";
  in {
    # Specify formatter package for "nix fmt ." and "nix fmt . -- --check"
    formatter = pkgs.alejandra;

    # Expose the web iso flags for esay access.
    packages.web-iso-flags = inputs.web-iso-flags.packages.${system}.default;

    # Expose the version of hugo used to build the theme along with
    # extra dependencies.
    packages.hugo = pkgs.symlinkJoin {
      name = "hugo-${pkgs.hugo.version}-dart-sass-embedded-${pkgs.dart-sass-embedded.version}-bundle";

      buildInputs = [pkgs.makeWrapper];
      paths = [pkgs.hugo pkgs.dart-sass-embedded];

      postBuild = "wrapProgram $out/bin/hugo --prefix PATH : ${pkgs.dart-sass-embedded}/bin";

      meta.mainProgram = "hugo";
    };

    # Expose the theme files.
    packages.theme = pkgs.stdenv.mkDerivation {
      pname = "taserud-consulting-ab--theme-albatross";
      inherit version;

      src = ./src;

      passthru.theme-name = "albatross";

      installPhase = ''
        cp -avr . $out

        install -m 644 -D ${self.packages.${system}.web-iso-flags}/* -t $out/static/img/iso-flags
      '';
    };

    # A test case to see that the theme builds.
    checks.test = pkgs.stdenv.mkDerivation {
      pname = "taserud-consulting-ab-theme-albatross-test";
      inherit version;

      src = ./.;

      buildInputs = [self.packages.${system}.hugo];

      buildPhase = "cd test && hugo --logLevel debug";
      installPhase = "cp -vr public/ $out";
    };
  }));
}
