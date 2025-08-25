{
  description = "Hello World C#";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    # nix-polyglot.url = "github:ritzau/nix-polyglot";
    nix-polyglot.url = "git+file:///Users/ritzau/src/slask/aoc/nix-polyglot";
  };

  outputs = { self, nixpkgs, flake-utils, nix-polyglot }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        csharpLib = nix-polyglot.lib.csharp;

        project = csharpLib {
          inherit pkgs self;
          sdk = pkgs.dotnet-sdk_8;
          buildTarget = "HelloService/HelloService.csproj";
          testProject = "HelloService.Tests/HelloService.Tests.csproj";
          nugetDeps = ./deps.json;
        };
      in {
        devShells.default = project.devShell;
        packages.default = project.package;
        apps.default = project.app;

        # Use checks from the enhanced csharp.nix (includes auto-detected tests)
        checks = project.checks;
      });
}
