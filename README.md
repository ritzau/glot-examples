# Glot Examples

A collection of example projects demonstrating nix-polyglot capabilities across multiple programming languages.

## Usage

Build all examples:
```bash
nix build
```

Build specific example:
```bash  
nix build .#rust-cli
nix build .#python-console
nix build .#csharp-console
nix build .#cpp-cli
```

## Examples

- **rust-cli**: Rust CLI application with Cargo integration
- **python-console**: Python console app with Poetry
- **csharp-console**: C# console app with .NET 8
- **cpp-cli**: C++ CLI application with CMake

Each example demonstrates:
- Complete nix-polyglot integration
- Glot CLI usage patterns
- Language-specific best practices
- Development environment setup

