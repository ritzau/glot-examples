{
  description = "Hello World C#";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    nix-polyglot.url = "git+file:///Users/ritzau/src/slask/nix/polyglot/nix-polyglot";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , nix-polyglot
    ,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        csharpLib = nix-polyglot.lib.csharp;

        # Base project configuration
        project = csharpLib {
          inherit pkgs self system;
          sdk = pkgs.dotnetCorePackages.sdk_8_0;
          buildTarget = "HelloService/HelloService.csproj";
          testProject = "HelloService.Tests/HelloService.Tests.csproj";
          nugetDeps = ./deps.json;
        };
      in
      project.defaultOutputs // {
        # Add packages - merge with existing packages from defaultOutputs
        packages = project.defaultOutputs.packages // {
          glot-cli = nix-polyglot.packages.${system}.glot;
        };
      }
    );
}
