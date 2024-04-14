{
  description = "Taserud Consulting AB Theme: Albatross";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-utils.url = "flake-utils";
    web-iso-flags.url = "github:TaserudConsulting/web-iso-flags";
    web-iso-flags.inputs.flake-utils.follows = "flake-utils";
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

          # Install model viewer resources
          install -m 644 -D ${self.packages.${system}.modelViewer}/* -t $out/static/js
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

          dontBuild = true;
          installPhase = "mkdir -p $out && cp -vr scss webfonts $out";
        };

      modelViewer = let
        pname = "model-viewer";
        version = "3.4.0";
      in
        pkgs.stdenv.mkDerivation {
          inherit pname version;
          src = builtins.fetchurl {
            url = "https://ajax.googleapis.com/ajax/libs/${pname}/${version}/${pname}.min.js";
            sha256 = "sha256:0xalmzv5ds908fh7jazmy8jjcnz240mlrll61ylfg2k6scm8jpjk";
          };
          dontUnpack = true;
          dontBuild = true;
          installPhase = "mkdir -p $out && cp -v $src $out/${pname}.min.js";
          meta.license = pkgs.lib.licenses.bsd3;
        };
    };

    # A test case to see that the theme builds.
    checks.test = pkgs.stdenv.mkDerivation {
      name = "taserud-consulting-ab-theme-albatross-test";

      src = ./.;

      buildInputs = [self.packages.${system}.hugo];

      buildPhase = ''
        # Install iso flags resources
        install -m 644 -D ${self.packages.${system}.web-iso-flags}/* -t src/static/img/iso-flags

        # Install fontawesome resources
        install -m 644 -D ${self.packages.${system}.fontawesome}/scss/* -t src/assets/scss/fontawesome
        install -m 644 -D ${self.packages.${system}.fontawesome}/webfonts/* -t src/static/fonts/fontawesome

        # Install model viewer resources
        install -m 644 -D ${self.packages.${system}.modelViewer}/* -t src/static/js

        cd test && hugo --logLevel debug
      '';
      installPhase = "cp -vr public/ $out";
    };
  }));
}
