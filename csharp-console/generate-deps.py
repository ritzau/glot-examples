#!/usr/bin/env python3
"""Generate deps.json from NuGet dependencies using the official nixpkgs approach."""

import subprocess
import sys
import os
from pathlib import Path


def restore_packages_to_directory() -> bool:
    """Restore NuGet packages to a packages directory with runtime support."""
    packages_dir = "nuget-packages"

    try:
        print("Cleaning previous packages directory...")
        if os.path.exists(packages_dir):
            subprocess.run(["rm", "-rf", packages_dir], check=True)

        print("Restoring NuGet packages with runtime support...")
        # Restore for linux-x64 to get all runtime-specific packages
        result = subprocess.run(
            ["dotnet", "restore", "--packages", packages_dir, "--runtime", "linux-x64"],
            capture_output=True,
            text=True,
        )

        if result.returncode != 0:
            print(f"dotnet restore failed: {result.stderr}")
            return False

        print("Packages restored successfully!")
        return True

    except FileNotFoundError:
        print("dotnet command not found. Make sure .NET SDK is installed.")
        return False
    except subprocess.CalledProcessError as e:
        print(f"Command failed: {e}")
        return False


def generate_deps_json() -> bool:
    """Generate deps.json using nuget-to-json from nixpkgs."""
    packages_dir = "nuget-packages"
    output_file = "deps.json"

    try:
        print("Generating deps.json using nixpkgs nuget-to-json...")

        # Use nix-shell to run nuget-to-json
        cmd = f'nix-shell -p nuget-to-json --run "nuget-to-json {packages_dir} > {output_file}"'
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)

        if result.returncode != 0:
            print(f"nuget-to-json failed: {result.stderr}")
            return False

        # Check if output file was generated and has content
        if not os.path.exists(output_file):
            print(f"Output file {output_file} was not generated")
            return False

        # Get file size to verify it's not empty
        file_size = os.path.getsize(output_file)
        if file_size == 0:
            print(f"Output file {output_file} is empty")
            return False

        print(f"Generated {output_file} ({file_size} bytes)")
        return True

    except Exception as e:
        print(f"Error generating deps.json: {e}")
        return False


def main():
    """Main function."""
    print("=== NuGet Dependencies Generator ===")
    print("Using official nixpkgs approach: dotnet restore + nuget-to-json")
    print()

    # Step 1: Restore packages to directory with runtime support
    if not restore_packages_to_directory():
        print("❌ Failed to restore packages")
        sys.exit(1)

    # Step 2: Generate deps.json using nuget-to-json
    if not generate_deps_json():
        print("❌ Failed to generate deps.json")
        sys.exit(1)

    print()
    print("✅ Successfully generated deps.json!")
    print("   This file contains all NuGet dependencies with correct hashes")
    print("   for use with buildDotnetModule in your flake.nix")


if __name__ == "__main__":
    main()
