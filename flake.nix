{
  description = "Glot Examples - Showcase of nix-polyglot capabilities across multiple languages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    # Point to local nix-polyglot for development
    nix-polyglot.url = "git+file:///Users/ritzau/src/slask/nix/polyglot/nix-polyglot";
  };

  outputs = { self, nixpkgs, flake-utils, nix-polyglot, ... }:
    flake-utils.lib.eachDefaultSystem (system: 
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Import each example flake, creating a proper self reference
        rustFlakeFunc = import (./rust-cli + "/flake.nix");
        rustExample = rustFlakeFunc.outputs { 
          self = rustFlakeFunc // { outPath = ./rust-cli; }; 
          inherit nixpkgs flake-utils nix-polyglot; 
        };
        
        pythonFlakeFunc = import (./python-console + "/flake.nix");
        pythonExample = pythonFlakeFunc.outputs { 
          self = pythonFlakeFunc // { outPath = ./python-console; }; 
          inherit nixpkgs flake-utils nix-polyglot; 
        };
        
        csharpFlakeFunc = import (./csharp-console + "/flake.nix");
        csharpExample = csharpFlakeFunc.outputs { 
          self = csharpFlakeFunc // { outPath = ./csharp-console; }; 
          inherit nixpkgs flake-utils nix-polyglot; 
        };
      in {
        packages = {
          # Individual example packages
          rust-cli = rustExample.packages.${system}.default;
          rust-cli-release = rustExample.packages.${system}.release;
          
          python-console = pythonExample.packages.${system}.default;
          python-console-release = pythonExample.packages.${system}.release;
          
          csharp-console = csharpExample.packages.${system}.default;
          csharp-console-release = csharpExample.packages.${system}.release;
          
          # Default package builds all examples
          default = pkgs.symlinkJoin {
            name = "glot-examples";
            paths = [
              rustExample.packages.${system}.default
              pythonExample.packages.${system}.default
              csharpExample.packages.${system}.default
            ];
            meta = {
              description = "All glot examples combined";
              longDescription = ''
                This package combines all glot examples into a single output,
                demonstrating nix-polyglot's multi-language capabilities.
              '';
            };
          };
          
          # Release version with all optimized builds
          release = pkgs.symlinkJoin {
            name = "glot-examples-release";
            paths = [
              rustExample.packages.${system}.release
              pythonExample.packages.${system}.release  
              csharpExample.packages.${system}.release
            ];
            meta = {
              description = "All glot examples (release builds)";
            };
          };
        };

        # Development shells for each example plus a root shell
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [ 
              # Tools for working with all examples
              nix-polyglot.packages.${system}.glot
              direnv
              git
              just  # For legacy samples that still use justfiles
            ];
            shellHook = ''
              echo "🚀 Glot Examples Development Environment"
              echo ""
              echo "Available examples:"
              echo "  rust-cli/       - Rust CLI application"
              echo "  python-console/ - Python console application"  
              echo "  csharp-console/ - C# console application"
              echo ""
              echo "Commands:"
              echo "  nix build                    - Build all examples"
              echo "  nix build .#rust-cli         - Build specific example"
              echo "  cd <example> && direnv allow - Enable glot CLI in example"
              echo "  cd <example> && glot build   - Build using glot CLI"
              echo ""
              echo "Run examples:"
              echo "  nix run .#rust-cli           - Run Rust example"
              echo "  nix run .#python-console     - Run Python example"
              echo "  nix run .#csharp-console     - Run C# example"
            '';
          };
          
          rust = rustExample.devShells.${system}.default;
          python = pythonExample.devShells.${system}.default;
          csharp = csharpExample.devShells.${system}.default;
        };

        # Apps to run examples
        apps = {
          rust-cli = {
            type = "app";
            program = "${self.packages.${system}.rust-cli}/bin/hello-rust-polyglot";
          };
          
          python-console = {
            type = "app"; 
            program = "${self.packages.${system}.python-console}/bin/myapp";
          };
          
          csharp-console = {
            type = "app";
            program = "${self.packages.${system}.csharp-console}/bin/HelloService";
          };
          
          # Default app shows all available examples
          default = {
            type = "app";
            program = "${pkgs.writeShellScript "glot-examples" ''
              echo "🚀 Glot Examples - Nix-Polyglot Showcase"
              echo ""
              echo "This repository demonstrates nix-polyglot capabilities across multiple"
              echo "programming languages, each with complete git history preserved."
              echo ""
              echo "Available examples:"
              echo "  nix run .#rust-cli        - Rust CLI application"
              echo "  nix run .#python-console  - Python console application"
              echo "  nix run .#csharp-console  - C# console application"
              echo ""
              echo "Build examples:"
              echo "  nix build                 - Build all examples"
              echo "  nix build .#rust-cli      - Build specific example"
              echo "  nix build .#release       - Build all examples (optimized)"
              echo ""
              echo "Development:"
              echo "  nix develop               - Enter root development shell"
              echo "  nix develop .#rust        - Enter Rust development shell"
              echo "  cd <example> && direnv allow - Setup glot CLI in example"
              echo ""
              echo "Each example includes full glot CLI integration for unified development."
            ''}";
          };
        };
      });
}