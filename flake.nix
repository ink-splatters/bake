{
  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:ink-splatters/nix-systems";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} (top @ {lib, ...}: let
      systems = import inputs.systems;
      flakeModules.default = import ./nix;
    in {
      imports = [
        flakeModules.default
        flake-parts.flakeModules.partitions
      ];

      options = {
        name = lib.mkOption {
          type = lib.types.str;
        };
        src = lib.mkOption {
          type = lib.types.path;
        };
      };
      config = {
        name = "mbake";

        src = builtins.path {
          path = ./.;
          inherit (top.config) name;
        };

        inherit systems;

        partitionedAttrs = {
          apps = "dev";
          checks = "dev";
          devShells = "dev";
          formatter = "dev";
        };
        partitions.dev = {
          extraInputsFlake = ./nix/dev;
          module = {
            imports = [./nix/dev];
          };
        };
        perSystem = {config, ...}: {
          packages.default = config.packages.bake;
          apps.default = config.apps.bake;
        };

        flake = {
          inherit flakeModules;
        };
      };
    });
}
