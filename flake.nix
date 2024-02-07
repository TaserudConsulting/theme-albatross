{
  description = "Taserud Consulting AB Theme: Albatross";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable-small;
    flake-utils.url = "flake-utils";
    web-iso-flags.url = github:TaserudConsulting/web-iso-flags;
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

    packages = {
      # Expose the web iso flags for esay access.
      web-iso-flags = inputs.web-iso-flags.packages.${system}.default;

      # Expose the version of hugo used to build the theme along with
      # extra dependencies.
      hugo = pkgs.symlinkJoin {
        name = "hugo-${pkgs.hugo.version}-dart-sass-embedded-${pkgs.dart-sass.version}-bundle";

        buildInputs = [pkgs.makeWrapper];
        paths = [pkgs.hugo pkgs.dart-sass];

        postBuild = "wrapProgram $out/bin/hugo --prefix PATH : ${pkgs.dart-sass}/bin";

        meta.mainProgram = "hugo";
      };

      # Expose the theme files.
      theme = pkgs.stdenv.mkDerivation {
        name = "taserud-consulting-ab--theme-albatross";
        passthru.theme-name = "albatross";

        src = ./src;

        installPhase = ''
          cp -avr . $out

          # Install iso flags resources
          install -m 644 -D ${self.packages.${system}.web-iso-flags}/* -t $out/static/img/iso-flags

          # Install fontawesome resources
          install -m 644 -D ${self.packages.${system}.fontawesome}/scss/* -t $out/assets/scss/fontawesome
          install -m 644 -D ${self.packages.${system}.fontawesome}/webfonts/* -t $out/static/fonts/fontawesome
        '';
      };

      # Download and build fontawesome resources.
      fontawesome = let
        pname = "fontawesome-free";
        version = "6.5.1";
      in
        pkgs.stdenv.mkDerivation {
          inherit pname version;

          src = pkgs.fetchzip {
            url = "https://use.fontawesome.com/releases/v${version}/${pname}-${version}-web.zip";
            hash = "sha256-gXXhKyTDC/Q6PBzpWRFvx/TxcUd3msaRSdC3ZHFzCoc=";
          };

          buildPhase = ":";
          installPhase = "mkdir -p $out && cp -vr scss webfonts $out";
        };
    };

    # A test case to see that the theme builds.
    checks.test = pkgs.stdenv.mkDerivation {
      name = "taserud-consulting-ab-theme-albatross-test";

      src = ./.;

      buildInputs = [self.packages.${system}.hugo];

      buildPhase = "cd test && hugo --logLevel debug";
      installPhase = "cp -vr public/ $out";
    };
  }));
}
