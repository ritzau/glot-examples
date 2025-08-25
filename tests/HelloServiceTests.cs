using Xunit;
using hello_csharp;

namespace HelloService.Tests;

public class HelloServiceTests
{
    private readonly hello_csharp.HelloService _service = new hello_csharp.HelloService();

    [Fact]
    public void GetGreeting_ReturnsCorrectMessage()
    {
        var result = _service.GetGreeting();
        Assert.Equal("Hello, World from C#! 🔷", result);
    }

    [Fact]
    public void GetDescription_ReturnsCorrectMessage()
    {
        var result = _service.GetDescription();
        Assert.Equal("This is a hello world program for AOC polyglot setup.", result);
    }

    [Fact]
    public void GetCountMessages_ReturnsCorrectCount()
    {
        var result = _service.GetCountMessages(5);
        Assert.Equal(5, result.Count);
    }

    [Fact]
    public void GetCountMessages_ReturnsCorrectContent()
    {
        var result = _service.GetCountMessages(3);
        Assert.Equal("i = 0", result[0]);
        Assert.Equal("i = 1", result[1]);
        Assert.Equal("i = 2", result[2]);
    }

    [Fact]
    public void GetCountMessages_EmptyForZeroCount()
    {
        var result = _service.GetCountMessages(0);
        Assert.Empty(result);
    }
}