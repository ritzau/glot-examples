"""Tests for the main module."""

from click.testing import CliRunner

from myapp.main import get_description, get_greeting, main


def test_get_greeting_no_name() -> None:
    """Test greeting without a name."""
    result = get_greeting()
    assert "Hello, World from Python!" in result
    assert "🐍" in result


def test_get_greeting_with_name() -> None:
    """Test greeting with a name."""
    result = get_greeting("Alice")
    assert "Hello, Alice from Python!" in result
    assert "🐍" in result


def test_get_description() -> None:
    """Test description function."""
    result = get_description()
    assert "Python console application" in result
    assert "nix-polyglot" in result


def test_main_command_default() -> None:
    """Test main command with default arguments."""
    runner = CliRunner()
    result = runner.invoke(main, [])

    assert result.exit_code == 0
    assert "Hello, World from Python!" in result.output
    assert "nix-polyglot" in result.output


def test_main_command_with_name() -> None:
    """Test main command with name argument."""
    runner = CliRunner()
    result = runner.invoke(main, ["--name", "Bob"])

    assert result.exit_code == 0
    assert "Hello, Bob from Python!" in result.output


def test_main_command_with_count() -> None:
    """Test main command with count argument."""
    runner = CliRunner()
    result = runner.invoke(main, ["--count", "3"])

    assert result.exit_code == 0
    assert "Greeting 3 times:" in result.output
    assert result.output.count("Hello, World from Python!") >= 3
