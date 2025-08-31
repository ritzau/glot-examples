{
  description = "Glot Examples - Showcase of nix-polyglot capabilities across multiple languages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-polyglot.url = "github:ritzau/nix-polyglot";
  };

  outputs = { self, nixpkgs, nix-polyglot, ... }:
    let
      system = "x86_64-darwin"; # Update based on your system
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Import each example's flake outputs
      rustExample = import ./rust-cli/flake.nix { inherit nixpkgs nix-polyglot; };
      pythonExample = import ./python-console/flake.nix { inherit nixpkgs nix-polyglot; };
      csharpExample = import ./csharp-console/flake.nix { inherit nixpkgs nix-polyglot; };
      
      # Helper to get outputs for current system
      getOutputs = flake: flake.outputs { inherit self nixpkgs nix-polyglot; };
    in {
      packages.${system} = 
        let
          rustOutputs = getOutputs rustExample;
          pythonOutputs = getOutputs pythonExample;  
          csharpOutputs = getOutputs csharpExample;
        in {
          # Individual example packages
          rust-cli = rustOutputs.packages.${system}.default;
          rust-cli-release = rustOutputs.packages.${system}.release;
          
          python-console = pythonOutputs.packages.${system}.default;
          python-console-release = pythonOutputs.packages.${system}.release;
          
          csharp-console = csharpOutputs.packages.${system}.default;
          csharp-console-release = csharpOutputs.packages.${system}.release;
          
          # Default package builds all examples
          default = pkgs.symlinkJoin {
            name = "glot-examples";
            paths = [
              rustOutputs.packages.${system}.default
              pythonOutputs.packages.${system}.default
              csharpOutputs.packages.${system}.default
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
              rustOutputs.packages.${system}.release
              pythonOutputs.packages.${system}.release  
              csharpOutputs.packages.${system}.release
            ];
            meta = {
              description = "All glot examples (release builds)";
            };
          };
        };

      # Development shells for each example
      devShells.${system} = 
        let
          rustOutputs = getOutputs rustExample;
          pythonOutputs = getOutputs pythonExample;
          csharpOutputs = getOutputs csharpExample;
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [ 
              # Tools for working with all examples
              glot
              direnv
              git
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
              echo "  cd <example> && glot build   - Build using glot CLI"
            '';
          };
          
          rust = rustOutputs.devShells.${system}.default;
          python = pythonOutputs.devShells.${system}.default;
          csharp = csharpOutputs.devShells.${system}.default;
        };

      # Apps to run examples
      apps.${system} = {
        rust-cli = {
          type = "app";
          program = "${self.packages.${system}.rust-cli}/bin/hello-rust-polyglot";
        };
        
        python-console = {
          type = "app"; 
          program = "${self.packages.${system}.python-console}/bin/python-polyglot";
        };
        
        csharp-console = {
          type = "app";
          program = "${self.packages.${system}.csharp-console}/bin/CSharpPolyglot";
        };
        
        # Default app shows all available examples
        default = {
          type = "app";
          program = pkgs.writeShellScript "glot-examples" ''
            echo "🚀 Glot Examples"
            echo ""
            echo "Available examples:"
            echo "  nix run .#rust-cli        - Run Rust CLI example"
            echo "  nix run .#python-console  - Run Python console example"
            echo "  nix run .#csharp-console  - Run C# console example"
            echo ""
            echo "Build examples:"
            echo "  nix build                 - Build all examples"
            echo "  nix build .#rust-cli      - Build specific example"
            echo ""
            echo "Development:"
            echo "  nix develop               - Enter development shell"
            echo "  cd <example> && glot help - Use glot CLI in example"
          '';
        };
      };
    };
}