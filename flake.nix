{
  description = "Hello World Rust via Nix-Polyglot";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    nix-polyglot.url = "git+file:///Users/ritzau/src/slask/aoc/nix-polyglot";
  };

  outputs = { self, nixpkgs, flake-utils, nix-polyglot }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        rustLib = nix-polyglot.lib.rust;

        project = rustLib {
          inherit pkgs self;
          # Hash for this specific Cargo.lock (no external dependencies)
          cargoHash = "sha256-2ZAe0DlF1X0nfELYmkdPSiVlbYYok+ZJ3Td/RBhv5FU=";
          binaryName = "hello-rust-polyglot";
        };

      in {
        devShells.default = project.devShell;
        packages.default = project.package;
        apps.default = project.app;
      });
}