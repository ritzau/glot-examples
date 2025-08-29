#!/usr/bin/env bash
# Glot CLI - Nix Polyglot Project Interface
# Version: 1.0.0

glot() {
    local cmd="$1"
    shift

    case "$cmd" in
        build)
            _glot_build "$@"
            ;;
        run)
            _glot_run "$@"
            ;;
        fmt|format)
            nix fmt
            ;;
        lint)
            nix develop --command cargo clippy -- -D warnings
            ;;
        test)
            nix develop --command cargo test
            ;;
        check)
            echo "🔍 Running comprehensive checks..."
            nix fmt && \
            nix develop --command cargo clippy -- -D warnings && \
            nix develop --command cargo test && \
            nix build
            ;;
        clean)
            echo "🧹 Cleaning build artifacts..."
            rm -rf target/ result result-* .cargo/
            echo "Clean completed!"
            ;;
        update)
            echo "📦 Updating dependencies..."
            nix flake update
            nix develop --command cargo update
            echo "Dependencies updated!"
            ;;
        info)
            _glot_info
            ;;
        shell)
            nix develop
            ;;
        help|--help|-h)
            _glot_help "$1"
            ;;
        "")
            _glot_help
            ;;
        *)
            echo "glot: unknown command '$cmd'"
            echo "Try 'glot help' for usage information."
            return 1
            ;;
    esac
}

_glot_build() {
    local target=""
    local variant="debug"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --variant)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --variant requires debug|release"
                    return 1
                fi
                case "$2" in
                    debug|release)
                        variant="$2"
                        shift 2
                        ;;
                    *)
                        echo "Error: variant must be debug or release, got: $2"
                        return 1
                        ;;
                esac
                ;;
            --debug)
                variant="debug"
                shift
                ;;
            --release)
                variant="release" 
                shift
                ;;
            *)
                if [[ -z "$target" ]]; then
                    target="$1"
                else
                    echo "Error: unexpected argument: $1"
                    return 1
                fi
                shift
                ;;
        esac
    done

    echo "🔨 Building..."
    if [[ "$variant" == "release" ]]; then
        nix build .#release
    else
        nix build .#dev
    fi
}

_glot_run() {
    local target=""
    local variant="debug"
    local run_args=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --variant)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --variant requires debug|release"
                    return 1
                fi
                case "$2" in
                    debug|release)
                        variant="$2"
                        shift 2
                        ;;
                    *)
                        echo "Error: variant must be debug or release, got: $2"
                        return 1
                        ;;
                esac
                ;;
            --debug)
                variant="debug"
                shift
                ;;
            --release)
                variant="release"
                shift
                ;;
            --)
                shift
                run_args+=("$@")
                break
                ;;
            *)
                if [[ -z "$target" ]]; then
                    target="$1"
                else
                    run_args+=("$1")
                fi
                shift
                ;;
        esac
    done

    echo "▶️  Running..."
    if [[ "$variant" == "release" ]]; then
        nix run .#release "${run_args[@]}"
    else
        nix run .#dev "${run_args[@]}"
    fi
}

_glot_info() {
    echo "📋 Project Information"
    echo "======================"
    echo "Working directory: $(pwd)"
    echo
    echo "Flake status:"
    nix flake show 2>/dev/null || echo "No flake found"
    echo
    echo "Rust toolchain info:"
    nix develop --command bash -c 'rustc --version && cargo --version' 2>/dev/null || echo "Rust toolchain not ready"
    echo
    echo "Project details:"
    if [[ -f Cargo.toml ]]; then
        nix develop --command bash -c 'cargo metadata --no-deps --format-version 1 | jq -r ".packages[0] | \"Package: \" + .name + \" v\" + .version + \"\nEdition: \" + .edition + \"\nDependencies: \" + (.dependencies | length | tostring)"' 2>/dev/null || echo "Cargo metadata not available"
    fi
}

_glot_help() {
    local subcmd="$1"
    
    if [[ -n "$subcmd" ]]; then
        case "$subcmd" in
            build)
                echo "glot build [target] [--variant debug|release]"
                echo ""
                echo "Build the project or specific target."
                echo ""
                echo "Options:"
                echo "  --variant debug     Build debug variant (default)"
                echo "  --variant release   Build release variant"
                echo "  --debug             Same as --variant debug"
                echo "  --release           Same as --variant release"
                ;;
            run)
                echo "glot run [target] [--variant debug|release] [-- args...]"
                echo ""
                echo "Run the project or specific target."
                echo ""
                echo "Options:"
                echo "  --variant debug     Run debug variant (default)"  
                echo "  --variant release   Run release variant"
                echo "  --debug             Same as --variant debug"
                echo "  --release           Same as --variant release"
                echo "  --                  Pass remaining args to program"
                ;;
            *)
                echo "No detailed help available for: $subcmd"
                ;;
        esac
        return
    fi

    echo "Glot - Nix Polyglot Project Interface"
    echo ""
    echo "Usage: glot <command> [options]"
    echo ""
    echo "Commands:"
    echo "  build [target] [--variant debug|release]    Build project"
    echo "  run [target] [--variant debug|release]      Run project"
    echo "  fmt                                          Format code"
    echo "  lint                                         Lint code"
    echo "  test                                         Run tests"
    echo "  check                                        Run all checks"
    echo "  clean                                        Clean artifacts"
    echo "  update                                       Update dependencies"
    echo "  info                                         Show project info"
    echo "  shell                                        Enter dev environment"
    echo "  help [command]                               Show help"
    echo ""
    echo "Use 'glot help <command>' for detailed help on specific commands."
}

# Export the function
export -f glot