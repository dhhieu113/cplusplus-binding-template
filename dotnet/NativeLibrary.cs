using System;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;

namespace CppBindingTemplate
{
    internal static class NativeLibrary
    {
        public static IntPtr Load(string libraryPath)
        {
            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            {
                return LoadWindowsLibrary(libraryPath);
            }
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
            {
                return LoadLinuxLibrary(libraryPath);
            }
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
            {
                return LoadMacLibrary(libraryPath);
            }
            else
            {
                throw new PlatformNotSupportedException("Unsupported platform");
            }
        }

        public static void SetDllImportResolver(Assembly assembly, DllImportResolver resolver)
        {
            NativeLibrary_SetDllImportResolver(assembly, resolver);
        }

        // Native library loading for Windows
        private static IntPtr LoadWindowsLibrary(string libraryPath)
        {
            IntPtr handle = Win32.LoadLibrary(libraryPath);
            if (handle == IntPtr.Zero)
            {
                throw new DllNotFoundException($"Failed to load native library: {libraryPath}");
            }
            return handle;
        }

        // Native library loading for Linux
        private static IntPtr LoadLinuxLibrary(string libraryPath)
        {
            IntPtr handle = Linux.dlopen(libraryPath, Linux.RTLD_NOW);
            if (handle == IntPtr.Zero)
            {
                throw new DllNotFoundException($"Failed to load native library: {libraryPath}");
            }
            return handle;
        }

        // Native library loading for macOS
        private static IntPtr LoadMacLibrary(string libraryPath)
        {
            IntPtr handle = Mac.dlopen(libraryPath, Mac.RTLD_NOW);
            if (handle == IntPtr.Zero)
            {
                throw new DllNotFoundException($"Failed to load native library: {libraryPath}");
            }
            return handle;
        }

        // Windows Native Methods
        private static class Win32
        {
            [DllImport("kernel32", SetLastError = true, CharSet = CharSet.Ansi)]
            public static extern IntPtr LoadLibrary([MarshalAs(UnmanagedType.LPStr)] string lpFileName);
        }

        // Linux Native Methods
        private static class Linux
        {
            public const int RTLD_NOW = 2;

            [DllImport("libdl.so.2", SetLastError = true)]
            public static extern IntPtr dlopen(string filename, int flags);
        }

        // macOS Native Methods
        private static class Mac
        {
            public const int RTLD_NOW = 2;

            [DllImport("libSystem.dylib", SetLastError = true)]
            public static extern IntPtr dlopen(string filename, int flags);
        }

        // Use the built-in NativeLibrary class if available (from .NET Core 3.0+)
        // This is a wrapper that works with .NET Standard 2.0
        private static void NativeLibrary_SetDllImportResolver(Assembly assembly, DllImportResolver resolver)
        {
            // In .NET Standard 2.0, we don't have direct access to the NativeLibrary class
            // So we'll use reflection to access it if available, otherwise we'll implement
            // a basic version for our needs
            try
            {
                Type nativeLibraryType = Type.GetType("System.Runtime.InteropServices.NativeLibrary, System.Runtime.InteropServices", throwOnError: false);
                
                if (nativeLibraryType != null)
                {
                    // The type exists, so use reflection to call the method
                    var method = nativeLibraryType.GetMethod("SetDllImportResolver", 
                        BindingFlags.Public | BindingFlags.Static);
                    
                    if (method != null)
                    {
                        method.Invoke(null, new object[] { assembly, resolver });
                        return;
                    }
                }
                
                // If we got here, either the type or method wasn't found
                // We'll register our resolver in a basic way
                RegisterBasicResolver(assembly, resolver);
            }
            catch
            {
                // Fallback to basic implementation
                RegisterBasicResolver(assembly, resolver);
            }
        }
        
        // Basic implementation for platforms/runtimes where the NativeLibrary class isn't available
        private static void RegisterBasicResolver(Assembly assembly, DllImportResolver resolver)
        {
            // Note: In a real implementation, we would do something here
            // However, for .NET Standard 2.0, we can't hook into the DllImport resolution process
            // without using the NativeLibrary class which isn't available
            // This is just a placeholder that allows the code to compile
            Console.WriteLine("Warning: Full DllImport resolver registration not available in this runtime.");
        }
    }
    
    // Delegate for resolving native libraries
    public delegate IntPtr DllImportResolver(string libraryName, Assembly assembly, DllImportSearchPath? searchPath);
    
    // SearchPath enum for compatibility with .NET Core 3.0+
    public enum DllImportSearchPath
    {
        ApplicationDirectory = 2,
        UseDllDirectoryForDependencies = 0x100,
        UserDirectories = 0x200,
        System32 = 0x400,
        SafeDirectories = 0x800,
        AssemblyDirectory = 0x1000,
    }
}
