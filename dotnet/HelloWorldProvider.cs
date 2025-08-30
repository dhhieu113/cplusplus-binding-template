using System;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;

namespace CppBindingTemplate
{
    /// <summary>
    /// Provides cross-platform Hello World functionality.
    /// </summary>
    public static class HelloWorldProvider
    {
        // Define the path to the native library
        private const string LibraryName = "cppbindingtemplate_dotnet";

        static HelloWorldProvider()
        {
            NativeLibrary.SetDllImportResolver(typeof(HelloWorldProvider).Assembly, ResolveDllImport);
        }

        private static IntPtr ResolveDllImport(string libraryName, Assembly assembly, DllImportSearchPath? searchPath)
        {
            // Only handle our specific library
            if (libraryName != LibraryName)
                return IntPtr.Zero;

            string libName = LibraryName;

            // Apply platform-specific naming conventions
            if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
                libName = $"lib{libName}.so";
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
                libName = $"lib{libName}.dylib";
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
                libName = $"{libName}.dll";
            
            // First try to load from the runtimes folder structure
            string arch = RuntimeInformation.ProcessArchitecture switch
            {
                Architecture.X64 => "x64",
                Architecture.Arm64 => "arm64",
                _ => throw new PlatformNotSupportedException($"Architecture {RuntimeInformation.ProcessArchitecture} is not supported")
            };

            string rid;
            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
                rid = $"win-{arch}";
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
                rid = $"linux-{arch}";
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
                rid = $"osx-{arch}";
            else
                throw new PlatformNotSupportedException("Unsupported operating system");

            // Try loading from the runtimes folder structure
            string runtimesPath = Path.Combine(AppContext.BaseDirectory, "runtimes", rid, "native", libName);
            if (File.Exists(runtimesPath))
            {
                return NativeLibrary.Load(runtimesPath);
            }

            // Try loading from the same directory as the assembly
            string assemblyPath = Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), libName);
            if (File.Exists(assemblyPath))
            {
                return NativeLibrary.Load(assemblyPath);
            }

            // Try using the default DLL import mechanism
            return NativeLibrary.Load(LibraryName);
        }

        /// <summary>
        /// Gets the Hello World message with platform information.
        /// </summary>
        /// <returns>A string containing the Hello World message.</returns>
        public static string GetHelloWorld()
        {
            try
            {
                // Print current directory and check if DLL exists
                Console.WriteLine($"Current directory: {Directory.GetCurrentDirectory()}");
                string dllPath = Path.Combine(Directory.GetCurrentDirectory(), "runtimes", "win-x64", "native", "cppbindingtemplate_dotnet.dll");
                Console.WriteLine($"Looking for DLL at: {dllPath}");
                Console.WriteLine($"DLL exists: {File.Exists(dllPath)}");
                
                IntPtr ptr = HelloWorld();
                if (ptr == IntPtr.Zero)
                    return "Failed to get Hello World message";

                string result = Marshal.PtrToStringAnsi(ptr);
                FreeHelloWorldString(ptr);
                return result;
            }
            catch (Exception ex)
            {
                return $"Error: {ex.Message}";
            }
        }

        [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
        private static extern IntPtr HelloWorld();

        [DllImport(LibraryName, CallingConvention = CallingConvention.Cdecl)]
        private static extern void FreeHelloWorldString(IntPtr ptr);
    }
}
