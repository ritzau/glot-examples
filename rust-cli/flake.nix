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

      in
      project.defaultOutputs // {
        # Add packages - merge with existing packages from defaultOutputs
        packages = project.defaultOutputs.packages // {
          glot-cli = nix-polyglot.packages.${system}.glot;
        };
      }
    );
}
