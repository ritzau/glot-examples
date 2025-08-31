{
  description = "Python project with nix-polyglot integration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    nix-polyglot.url = "git+file:///Users/ritzau/src/slask/nix/polyglot/nix-polyglot";
  };

  outputs = { self, nixpkgs, flake-utils, nix-polyglot, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Configure Python project
        pythonProject = nix-polyglot.lib.python {
          inherit pkgs self system;
          buildTarget = "./pyproject.toml";
          buildSystem = "poetry";
          mainModule = "myapp.main";
          enableTests = true;
          testRunner = "pytest";
        };
      in
      # Use the complete project structure
      pythonProject.defaultOutputs // {
        # Add packages - merge with existing packages from defaultOutputs
        packages = pythonProject.defaultOutputs.packages // {
          glot-cli = nix-polyglot.packages.${system}.glot;
        };
      }
    );
}
