{
  description = "Hello World C#";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Define tool lists once
        generalTools = with pkgs; [
          tree
          bat
          bottom
          jq
        ];

        buildTools = with pkgs; [
          dotnet-sdk_8
          fastfetch
          tree
          figlet
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          packages = generalTools ++ buildTools;

          shellHook = ''
            echo bananas
          '';
        };

        packages.default =
          let
            csprojFiles = builtins.filter (file: nixpkgs.lib.hasSuffix ".csproj" file) (builtins.attrNames (builtins.readDir self));
            name =
              if builtins.length csprojFiles == 1
              then nixpkgs.lib.removeSuffix ".csproj" (builtins.head csprojFiles)
              else throw "Expected exactly one .csproj file in root, found: ${builtins.toString (builtins.length csprojFiles)}";
          in
            pkgs.stdenv.mkDerivation {
              inherit name;

              src = self;

              buildInputs = buildTools;

              preUnpack = ''
                figlet "System Info"
                fastfetch
              '';

              buildPhase = ''
                figlet Building
                runHook preBuild
                dotnet publish -o build --self-contained true $name.csproj
                runHook postBuild
              '';

              installPhase = ''
                figlet Installing
                runHook preInstall
                tree
                mkdir -p $out/bin
                cp -apv build/* $out/bin/
                runHook postInstall
              '';

              postInstall = ''
                figlet "Build succesful!"
              '';

              runPhase = ''
                figlet Running
                runHook preRun
                $out/bin/$name
                runHook postRun
              '';
            };
      });
}
