using Xunit;

namespace HelloService.Tests;

public class HelloService_Should
{
    private readonly HelloService _helloService = new HelloService();

    [Fact]
    public void ReturnCorrectGreetingMessage()
    {
        var result = _helloService.GetGreeting();
        Assert.Equal("Hello, World from C#! 🔷", result);
    }

    [Fact]
    public void ReturnCorrectDescriptionMessage()
    {
        var result = _helloService.GetDescription();
        Assert.Equal("This is a hello world program for AOC polyglot setup.", result);
    }

    [Fact]
    public void ReturnCorrectNumberOfCountMessages()
    {
        var result = _helloService.GetCountMessages(5);
        Assert.Equal(5, result.Count);
    }

    [Fact]
    public void ReturnCorrectCountMessageContent()
    {
        var result = _helloService.GetCountMessages(3);
        Assert.Equal("i = 0", result[0]);
        Assert.Equal("i = 1", result[1]);
        Assert.Equal("i = 2", result[2]);
    }

    [Fact]
    public void ReturnEmptyListForZeroCount()
    {
        var result = _helloService.GetCountMessages(0);
        Assert.Empty(result);
    }
}
