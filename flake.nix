{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig-overlay.url = "github:mitchellh/zig-overlay";
  };
  outputs = { self, nixpkgs, flake-utils, zig-overlay }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        # Refer to https://github.com/mitchellh/zig-overlay if you want to use a specific version of Zig
        zigPackage = zig-overlay.packages.${system}.default;
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          name = "Zaytracer";
          nativeBuildInputs = [
            zigPackage
            pkgs.linuxPackages_latest.perf
            pkgs.ffmpeg
            pkgs.hyperfine
            pkgs.raylib
          ];
        };
        packages.default = pkgs.stdenv.mkDerivation {
          name = "Zaytracer";
          src = ./.;

          XDG_CACHE_HOME = "${placeholder "out"}";

          buildPhase = ''
            ${zigPackage}/bin/zig build -Doptimize=ReleaseFast
          '';

          installPhase = ''
            ${zigPackage}/bin/zig build install --prefix $out -Doptimize=ReleaseFast
            rm -rf $out/zig # remove cache
          '';
        };
      });
}
