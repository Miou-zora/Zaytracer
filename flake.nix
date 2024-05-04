{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ]
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          formatter = pkgs.nixpkgs-fmt;
          devShells.default = pkgs.mkShell {
            name = "Zaytracer";
            nativeBuildInputs = [
              pkgs.zig_0_12
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
            
            buildInputs = [ pkgs.raylib ];
            buildPhase = ''
              ${pkgs.zig_0_12}/bin/zig build -Doptimize=ReleaseFast
            '';

            installPhase = ''
              ${pkgs.zig_0_12}/bin/zig build install --prefix $out -Doptimize=ReleaseFast
              rm -rf $out/zig # remove cache
            '';
          };
        });
}
