{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    bf-nix.url = "github:water-sucks/brainfuck.nix";
    bf-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    flake-parts,
    bf-nix,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      perSystem = {
        pkgs,
        system,
        ...
      }: {
        _module.args = {
          pkgs = import nixpkgs {
            inherit system;
            overlays = [bf-nix.overlays.default];
          };
        };

        packages.default = pkgs.writeBFBin "hello-world" (builtins.readFile ./hello-world.bf);
      };
    };
}
