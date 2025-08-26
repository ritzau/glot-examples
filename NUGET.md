# NuGet Dependency Management Guide

This document explains how to manage NuGet dependencies in your C# project using Nix.

## Overview

Your project uses the `nix-polyglot` library for C# development, which provides consistent build patterns across multiple languages. NuGet dependencies are managed through a `deps.json` file that specifies exact package versions and hashes for reproducible builds using the official nixpkgs approach.

## Current Setup

- **deps.json**: Contains NuGet package definitions in JSON format (compatible with buildDotnetModule)
- **flake.nix**: References the deps.json file and passes it to the C# library
- **generate-deps.py**: Python script to automatically generate deps.json using official nixpkgs tools
- **justfile**: Contains `update-nuget` command for easy regeneration

## Dependency Management Approach

### Automated Generation (Recommended)

Use the provided Python script that follows the official nixpkgs approach:

```bash
# Regenerate NuGet dependencies
just update-nuget
# or
python3 generate-deps.py
```

This approach:

- ✅ Uses official nixpkgs `nuget-to-json` tool
- ✅ Automatically discovers all dependencies including runtime-specific packages
- ✅ Generates correct hash format compatible with buildDotnetModule
- ✅ Includes support for multiple target platforms (linux-x64, etc.)
- ✅ Easy to maintain when dependencies change

### Alternative: Null Dependencies (For Simple Projects)

For projects without dependencies or for quick development, you can set `nugetDeps = null`:

```nix
nugetDeps = null;
```

This approach:

- ✅ Minimal configuration
- ✅ Works for simple projects without NuGet dependencies
- ❌ Less reproducible builds
- ❌ No offline builds
- ❌ May fail with complex dependency trees

## Working with Dependencies

### Adding New Dependencies

1. Add the package reference to your `.csproj` file:

   ```xml
   <PackageReference Include="Newtonsoft.Json" Version="13.0.3" />
   ```

2. If using manual deps.nix, add the corresponding fetchNuGet entry:

   ```nix
   (fetchNuGet { pname = "Newtonsoft.Json"; version = "13.0.3"; hash = "sha256-[HASH]"; })
   ```

3. If using automated generation, run:
   ```bash
   just update-nuget
   ```

### Finding Package Hashes

To find the correct hash for a NuGet package:

```bash
nix-shell -p nix-prefetch --run "nix-prefetch-url --type sha256 https://api.nuget.org/v3-flatcontainer/[PACKAGE]/[VERSION]/[PACKAGE].[VERSION].nupkg"
```

For example:

```bash
nix-shell -p nix-prefetch --run "nix-prefetch-url --type sha256 https://api.nuget.org/v3-flatcontainer/newtonsoft.json/13.0.3/newtonsoft.json.13.0.3.nupkg"
```

### Troubleshooting

**Hash format errors**: The NuGet lock file uses a different hash format than Nix expects. If you encounter hash format errors, try:

1. Using the manual approach with known working hashes
2. Using `null` dependencies for development
3. Converting the hash format (complex, requires base64 to hex conversion)

**Missing packages**: If packages are missing from the automatically generated deps.nix:

1. Ensure all project files are properly restored with `dotnet restore --use-lock-file`
2. Check that packages.lock.json files are generated
3. Verify the package is actually referenced in your .csproj files

**Build failures**: If builds fail with dependency issues:

1. Try `nix build --show-trace` for detailed error information
2. Check if all referenced packages are in deps.nix
3. Consider using `nugetDeps = null` for development

## Recommended Workflow

For most projects, we recommend:

1. **Development**: Use `nugetDeps = null` for quick iteration
2. **CI/Production**: Use manually curated deps.nix for reproducibility
3. **Dependency Updates**: Use the automated script to discover new dependencies, then manually curate the results

## Commands Reference

```bash
# Regenerate dependencies
just update-nuget

# Build the project
just build

# Run tests
just test

# Check everything
just check

# Clean build artifacts
just clean
```

## Current Status

Your project is currently configured with:

- Manual deps.nix with core test dependencies
- Python script for automated generation (may need hash format fixes)
- Justfile command for easy regeneration
- Working build and test pipeline
