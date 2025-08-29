{
  description = "Hello World C#";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    # nix-polyglot.url = "github:ritzau/nix-polyglot";
    nix-polyglot.url = "path:/Users/ritzau/src/slask/nix/polyglot/nix-polyglot";
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
      project.defaultOutputs
    );
}
