# Organizational Standard Justfile Template
# Provides consistent interface across all language projects

# Default recipe - shows available commands
default:
    @just --list

# Development commands
dev:
    @echo "🚀 Starting development environment..."
    nix develop

# Build the project
build:
    @echo "🔨 Building project..."
    nix build

# Run the project
run:
    @echo "▶️  Running project..."
    nix run

# Run tests
test:
    @echo "🧪 Running tests..."
    nix develop --command cargo test

# Format code using Rust formatter
fmt:
    @echo "🎨 Formatting code..."
    nix develop --command cargo fmt

# Lint code
lint:
    @echo "🔍 Linting code..."
    nix develop --command cargo clippy -- -D warnings

# Check code (build + test + lint)
check: build test lint
    @echo "✅ All checks passed!"

# Clean build artifacts
clean:
    @echo "🧹 Cleaning build artifacts..."
    @rm -rf target/ bin/ obj/ node_modules/.cache/ __pycache__/ result result-* .mypy_cache/ .pytest_cache/ 2>/dev/null || true
    @echo "Clean completed!"

# Update dependencies
update:
    @echo "📦 Updating dependencies..."
    nix flake update
    @echo "Dependencies updated!"

# Update Cargo dependencies and regenerate lock file
update-cargo:
    @echo "📦 Updating Cargo dependencies..."
    nix develop --command cargo update
    @echo "Cargo dependencies updated!"

# Check for outdated dependencies
outdated:
    @echo "🔍 Checking for outdated dependencies..."
    nix develop --command cargo outdated

# Run tests with coverage
test-cov:
    @echo "🧪 Running tests with coverage..."
    nix develop --command bash -c 'cargo tarpaulin --out Html || echo "Install cargo-tarpaulin for coverage: cargo install cargo-tarpaulin"'

# Run specific checks used by CI/CD
ci-check: fmt lint test
    @echo "🚀 Running CI checks..."
    nix develop --command cargo check --all-targets
    @echo "✅ All CI checks passed!"

# Show project info
info:
    @echo "📋 Project Information"
    @echo "===================="
    @echo "Working directory: $(pwd)"
    @echo "Flake status:"
    @nix flake show 2>/dev/null || echo "No flake found"
    @echo ""
    @echo "Rust toolchain info:"
    @nix develop --command bash -c 'rustc --version && cargo --version' 2>/dev/null || echo "Rust toolchain not ready"
    @echo ""
    @echo "Project details:"
    @nix develop --command bash -c 'cargo metadata --no-deps --format-version 1 | jq -r ".packages[0] | \"Package: \" + .name + \" v\" + .version + \"\nEdition: \" + .edition + \"\nDependencies: \" + (.dependencies | length | tostring)"' 2>/dev/null || echo "Cargo metadata not available"

# Release build (optimized)
release:
    @echo "🎯 Building release version..."
    nix build

# Watch mode - rebuild on file changes
watch:
    @echo "👀 Watching for changes..."
    nix develop --command cargo watch -x build

# Benchmark (if supported)
bench:
    @echo "⚡ Running benchmarks..."
    nix develop --command cargo bench

# Quick security check
security:
    @echo "🔒 Running security checks..."
    nix develop --command cargo audit

# Generate documentation
docs:
    @echo "📚 Generating documentation..."
    nix develop --command cargo doc --open

# Set up pre-commit hooks (if available)
setup-hooks:
    @echo "🎣 Setting up pre-commit hooks..."
    @echo "# Pre-commit hook - run checks before commit" > .git/hooks/pre-commit
    @echo "just check" >> .git/hooks/pre-commit
    @chmod +x .git/hooks/pre-commit
    @echo "Pre-commit hook installed!"
