{
  inputs = {
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs";
      url = "github:hercules-ci/flake-parts";
    };
    git-hooks = {
      inputs = {
        flake-compat.follows = "";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:cachix/git-hooks.nix";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/treefmt-nix";
    };
  };
  outputs =
    inputs@{
      flake-parts,
      git-hooks,
      systems,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        git-hooks.flakeModule
        treefmt-nix.flakeModule
      ];
      perSystem =
        { pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              nvfetcher
            ];
          };
          pre-commit = {
            check.enable = true;
            settings = {
              hooks = {
                actionlint.enable = true;
                check-json.enable = true;
                check-toml.enable = true;
                editorconfig-checker = {
                  enable = true;
                  excludes = [
                    "flake.lock"
                  ];
                };
                luacheck.enable = true;
                markdownlint.enable = true;
                yamlfmt.enable = true;
                yamllint.enable = true;
              };
              src = ./.;
            };
          };
          treefmt = import ./treefmt.nix;
        };
      systems = import systems;
    };
}
