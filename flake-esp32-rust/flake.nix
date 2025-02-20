{
  inputs = {
    esp32-rust = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:svelterust/esp32";
    };
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs";
      url = "github:hercules-ci/flake-parts";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };
  outputs =
    inputs@{ flake-parts, systems, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      perSystem =
        { inputs', pkgs, ... }:
        let
          sources = import ./_sources/generated.nix {
            inherit (pkgs)
              dockerTools
              fetchFromGitHub
              fetchgit
              fetchurl
              ;
          };
        in
        {
          devShells.default =
            let
              esp32-rust = inputs'.esp32-rust.packages.esp32.overrideAttrs (
                _: _: {
                  inherit (sources.idf-rust) src;
                }
              );
            in
            pkgs.mkShell {
              LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (
                with pkgs;
                [
                  libxml2
                  stdenv.cc.cc.lib
                  zlib
                ]
              );
              packages =
                [
                  esp32-rust
                ]
                ++ (with pkgs; [
                  espflash
                  ldproxy
                  nvfetcher
                ]);
              shellHook = ''
                export PATH="${esp32-rust}/.rustup/toolchains/esp/bin:$PATH"
                export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
              '';
            };
        };
      systems = import systems;
    };
}
