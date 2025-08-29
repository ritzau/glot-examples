{
  description = "Hello World Rust via Nix-Polyglot";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    # nix-polyglot.url = "github:ritzau/nix-polyglot";
    nix-polyglot.url = "git+file:///Users/ritzau/src/slask/nix/polyglot/nix-polyglot";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nix-polyglot,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        rustLib = nix-polyglot.lib.rust;

        project = rustLib {
          inherit pkgs self;
          # Hash for this specific Cargo.lock (no external dependencies)
          cargoHash = "sha256-2ZAe0DlF1X0nfELYmkdPSiVlbYYok+ZJ3Td/RBhv5FU=";
          binaryName = "hello-rust-polyglot";
        };

        # Create git hooks installer app
        install-hooks-script = pkgs.writeShellApplication {
          name = "install-git-hooks";
          text = ''
            echo "🎣 Installing git hooks..."
            
            # Create hooks directory if it doesn't exist
            mkdir -p .git/hooks
            
            # Install pre-commit hook (format only)
            cat > .git/hooks/pre-commit << 'EOF'
            #!/usr/bin/env bash
            echo "🎨 Running pre-commit formatting..."
            nix fmt
            EOF
            chmod +x .git/hooks/pre-commit
            
            # Install pre-push hook (comprehensive check)
            cat > .git/hooks/pre-push << 'EOF'
            #!/usr/bin/env bash
            echo "🚀 Running pre-push checks..."
            glot check
            EOF
            chmod +x .git/hooks/pre-push
            
            echo "✅ Git hooks installed successfully!"
          '';
        };

      in
      project.defaultOutputs // {
        # Add packages - merge with existing packages from defaultOutputs
        packages = project.defaultOutputs.packages // {
          glot-cli = nix-polyglot.packages.${system}.glot;
        };

        # Add install-hooks app - merge with existing apps from defaultOutputs
        apps = project.defaultOutputs.apps // {
          install-hooks = {
            type = "app";
            program = "${install-hooks-script}/bin/install-git-hooks";
            meta = {
              description = "Install git hooks for formatting and checking";
              platforms = nixpkgs.lib.platforms.all;
            };
          };
        };
      }
    );
}
