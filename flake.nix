{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zig-gamedev = {
      url = "github:zig-gamedev/zig-gamedev";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    pre-commit-hooks,
    zig-gamedev,
  }:
    flake-utils.lib.eachSystem [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ]
    (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      zig = pkgs.zig_0_12;
    in rec {
      formatter = pkgs.alejandra;

      checks = let
        hooks = {
          alejandra.enable = true;
          zig-fmt = {
            enable = true;
            entry = "${zig}/bin/zig fmt --check .";
            files = "\\.z(ig|on)$";
          };
        };
      in {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          inherit hooks;
          src = ./.;
        };
      };

      devShells.default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;

        name = "Zaytracer";
        inputsFrom = pkgs.lib.attrsets.attrValues packages;
        packages = with pkgs;
          [
            ffmpeg
            hyperfine
          ]
          ++ (pkgs.lib.optionals
            pkgs.stdenv.isLinux
            [linuxPackages_latest.perf]);
      };

      packages.default = pkgs.stdenv.mkDerivation {
        name = "Zaytracer";
        src = pkgs.lib.cleanSource ./.;

        XDG_CACHE_HOME = "${placeholder "out"}";

        buildInputs = [pkgs.raylib];
        nativeBuildInputs = [zig];
        buildPhase = ''
          mkdir -p libs

          cp -r ${zig-gamedev} libs/zgamedev
          zig build -Doptimize=ReleaseFast
        '';

        doCheck = true;
        checkPhase = ''
          zig build test --summary all
        '';

        installPhase = ''
          zig build install --prefix $out -Doptimize=ReleaseFast
          rm -rf $out/zig # remove cache
        '';
      };
    });
}
