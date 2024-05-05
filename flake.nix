{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig-gamedev = {
      url = "github:zig-gamedev/zig-gamedev";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
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
    in rec {
      formatter = pkgs.alejandra;
      devShells.default = pkgs.mkShell {
        name = "Zaytracer";
        inputsFrom = pkgs.lib.attrsets.attrValues packages;
        nativeBuildInputs = with pkgs; [
          linuxPackages_latest.perf
          ffmpeg
          hyperfine
        ];
      };

      packages.default = pkgs.stdenv.mkDerivation {
        name = "Zaytracer";
        src = pkgs.lib.cleanSource ./.;

        XDG_CACHE_HOME = "${placeholder "out"}";

        prePatch = ''
          mkdir -p libs

          cp -r ${zig-gamedev} libs/zgamedev
        '';

        buildInputs = [pkgs.raylib];
        nativeBuildInputs = [pkgs.zig_0_12];
        buildPhase = ''
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
