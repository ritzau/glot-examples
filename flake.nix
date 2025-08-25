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
          buildTarget = "hello-csharp.csproj";
        };
      in {
        devShells.default = project.devShell;
        packages.default = project.package;
        apps.default = project.app;
        
        checks = {
          # Build check  
          build = project.package;
          
          # Unit test check using solution file approach
          test = pkgs.writeShellApplication {
            name = "hello-csharp-unit-tests";
            runtimeInputs = [ pkgs.dotnet-sdk_8 ];
            text = ''
              echo "Running C# unit tests via development environment..."
              cd ${./.}
              
              # Check if tests can be run in dev environment
              if [ -f "tests/HelloService.Tests.csproj" ]; then
                echo "Running separate test project..."
                cd tests
                dotnet test HelloService.Tests.csproj --logger "console;verbosity=detailed"
                echo "✅ All C# unit tests completed successfully!"
              else
                echo "❌ Test project not found"
                exit 1
              fi
            '';
          };
        };
      });
}
