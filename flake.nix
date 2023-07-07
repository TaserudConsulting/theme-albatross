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

    packages.hugo = pkgs.hugo;
    packages.theme = (pkgs.stdenv.mkDerivation {
      pname = "weblizard-theme-albatross";
      version = "0.0.0";
      src = ./src;
      installPhase = ''
        mkdir $out
        cp -avr . $out
      '';
    });

    devShells.default = pkgs.mkShell {
      buildInputs = [
        pkgs.gnumake
        pkgs.hugo
      ];
    };
  }));
}
