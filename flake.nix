{
  description = "WebLizard Theme: Albatross";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable-small;
    flake-utils.url = "flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  } @ inputs: (flake-utils.lib.eachDefaultSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    # Specify formatter package for "nix fmt ." and "nix fmt . -- --check"
    formatter = pkgs.alejandra;

    # Expose the version of hugo used to build the theme along with
    # extra dependencies.
    packages.hugo = pkgs.symlinkJoin {
      name = "hugo-dart-sass-bundle";
      paths = [pkgs.hugo pkgs.dart-sass-embedded];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram "$out/bin/hugo" --prefix PATH : "${pkgs.dart-sass-embedded}"/bin
      '';
      meta.mainProgram = "hugo";
    };

    # Expose the theme files.
    packages.theme = pkgs.stdenv.mkDerivation {
      pname = "weblizard-theme-albatross";
      version = "0.0.0";
      src = ./src;

      passthru.theme-name = "albatross";

      installPhase = ''
        cp -avr . $out
      '';
    };

    # A test case to see that the theme builds.
    checks.test = pkgs.stdenv.mkDerivation {
      pname = "weblizard-theme-albatross-test";
      version = "0.0.0";
      src = ./.;

      buildInputs = [self.packages.${system}.hugo];

      buildPhase = ''
        cd test && hugo --logLevel debug
      '';

      installPhase = ''
        cp -vr public/ $out
      '';
    };
  }));
}