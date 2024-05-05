{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig-gamedev = {
      url = "github:zig-gamedev/zig-gamedev";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, zig-gamedev }:
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
            nativeBuildInputs = with pkgs; [
              zig_0_12
              linuxPackages_latest.perf
              ffmpeg
              hyperfine
              raylib
            ];
          };
        packages.default = pkgs.stdenv.mkDerivation {
            name = "Zaytracer";
            src = ./.;

            XDG_CACHE_HOME = "${placeholder "out"}";
            
            prePatch = ''
              cp -r ${zig-gamedev} libs/zgamedev
            '';

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
