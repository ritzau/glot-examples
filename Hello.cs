namespace hello_csharp;

public class HelloService
{
    public string GetGreeting()
    {
        return "Hello, World from C#! 🔷";
    }

    public string GetDescription()
    {
        return "This is a hello world program for AOC polyglot setup.";
    }

    public List<string> GetCountMessages(int count)
    {
        var messages = new List<string>();
        for (int i = 0; i < count; i++)
        {
            messages.Add($"i = {i}");
        }
        return messages;
    }
}

class Hello
{
    static void Main(string[] args)
    {
        var service = new HelloService();
        
        Console.WriteLine(service.GetGreeting());
        Console.WriteLine(service.GetDescription());

        var countMessages = service.GetCountMessages(10);
        foreach (var message in countMessages)
        {
            Console.WriteLine(message);
        }
    }
}
