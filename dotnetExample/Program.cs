using CppBindingTemplate;
using System;

namespace Example
{
    class Program
    {
        static void Main(string[] args)
        {
            // Get and print the Hello World message with platform info
            string message = HelloWorldProvider.GetHelloWorld();
            Console.WriteLine(message);
        }
    }
}
