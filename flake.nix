{
  description = "Hello World C#";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    nix-polyglot.url = "github:ritzau/nix-polyglot";
    # nix-polyglot.url = "git+file:///Users/ritzau/src/slask/aoc/nix-polyglot";
  };

  outputs = { self, nixpkgs, flake-utils, nix-polyglot }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        csharpLib = nix-polyglot.lib.csharp;

        project = csharpLib {
          inherit pkgs self;
          # sdk = pkgs.dotnet-sdk_9;
        };

      in {
        devShells.default = project.devShell;
        packages.default = project.package;
        apps.default = project.app;
      });
}
