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
      in {
        packages = {
          # Default package provides information about available examples
          default = pkgs.writeShellScript "glot-examples-info" ''
            echo "🚀 Glot Examples - Nix-Polyglot Showcase"
            echo ""
            echo "This repository demonstrates nix-polyglot capabilities across multiple"
            echo "programming languages, each with complete git history preserved."
            echo ""
            echo "Build individual examples:"
            echo "  cd rust-cli && nix build         - Rust CLI application"
            echo "  cd python-console && nix build   - Python console application"
            echo "  cd csharp-console && nix build   - C# console application"
            echo ""
            echo "Run individual examples:"
            echo "  cd rust-cli && nix run           - Run Rust example"
            echo "  cd python-console && nix run     - Run Python example"
            echo "  cd csharp-console && nix run     - Run C# example"
            echo ""
            echo "Each example is a complete, independent project with glot CLI integration."
          '';
        };

        # Development shell for working with examples
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [ 
              # Tools for working with all examples
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
              echo "  cd <example> && nix build   - Build specific example"
              echo "  cd <example> && nix run     - Run specific example"
              echo "  cd <example> && nix develop - Enter example dev shell"
              echo ""
              echo "Each example is a complete, independent project."
            '';
          };
        };

        # Default app shows information
        apps = {
          default = {
            type = "app";
            program = "${self.packages.${system}.default}";
          };
        };
      });
}