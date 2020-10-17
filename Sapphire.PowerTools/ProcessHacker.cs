using System;
using System.Diagnostics;
using System.Management.Automation; //<-Import from PowerShell 
using System.Runtime.InteropServices;

/* 
 * This is created in .NET Framework 3.8.
 * Other version will likly work as well.
 * Created for PowerShell version 5.1
 */


namespace Sapphire
{
    namespace PowerTools
    {
        public class ProcessHacker : Cmdlet
        {
            [DllImport("kernel32.dll")]
            public static extern IntPtr OpenProcess(ProcessAccessFlags dwDesiredAccess, [MarshalAs(UnmanagedType.Bool)] bool bInheritHandle, uint dwProcId);

            [DllImport("kernel32.dll")]
            public static extern bool ReadProcessMemory(IntPtr hProc, IntPtr lpBaseAddress, [In, Out] byte[] lpBuffer, uint dwSize, out IntPtr lpNumberOfBytesRead);

            [DllImport("kernel32.dll")]
            public static extern bool WriteProcessMemory(IntPtr hProc, IntPtr lpBaseAddress, [In, Out] byte[] lpBuffer, uint dwSize, out IntPtr lpNmberOfBytesWritten);

            [DllImport("kernel32.dll")]
            public static extern Int32 CloseHandle(IntPtr hProc);

            [Flags]
            public enum ProcessAccessFlags : uint
            {
                PROCESS_TERMINATE = 0x0001,
                PROCESS_CREATE_PROCESS = 0x0080,
                PROCESS_CREATE_THREAD = 0x0002,
                PROCESS_VM_OPERATION = 0x0008,
                PROCESS_VM_READ = 0x0010,
                PROCESS_VM_WRITE = 0x0020,
                PROCESS_DUP_HANDLE = 0x0040,
                PROCESS_SET_INFORMATION = 0x0200,
                PROCESS_QUERY_INFORMATION = 0x0400,
                PROCESS_QUERY_LIMITED_INFORMATION = 0x1000,
                SYNCHRONIZE = 0x00100000
            }


            //constructors
            public ProcessHacker(string processName) //Init process
            {
                this.processName = processName; //Store so PWSH can read the process name attached
                Process process = Process.GetProcessesByName(this.processName)[0];
                this.hProc = OpenProcess(ProcessAccessFlags.PROCESS_VM_READ | ProcessAccessFlags.PROCESS_VM_WRITE | ProcessAccessFlags.PROCESS_VM_OPERATION | ProcessAccessFlags.PROCESS_QUERY_INFORMATION, false, (uint)process.Id);
            }

            public ProcessHacker(int processId) //Init process
            {
                this.hProc = OpenProcess(ProcessAccessFlags.PROCESS_VM_READ | ProcessAccessFlags.PROCESS_VM_WRITE | ProcessAccessFlags.PROCESS_VM_OPERATION | ProcessAccessFlags.PROCESS_QUERY_INFORMATION, false, (uint)processId);
            }


            //methods
            public void WriteProcess(uint dwAddress, byte[] buffer)
            {
                IntPtr pWrite = IntPtr.Zero;
                WriteProcessMemory(this.hProc, (IntPtr)dwAddress, buffer, (uint)buffer.Length, out pWrite);
            }

            public void WriteInt16(uint dwAddress, Int16 val)
            {
                IntPtr pWrite = IntPtr.Zero;
                byte[] buffer = BitConverter.GetBytes(val);

                WriteProcessMemory(this.hProc, (IntPtr)dwAddress, buffer, (uint)buffer.Length, out pWrite);
            }

            public void WriteUInt16(uint dwAddress, UInt16 val)
            {
                IntPtr pWrite = IntPtr.Zero;
                byte[] buffer = BitConverter.GetBytes(val);

                WriteProcessMemory(this.hProc, (IntPtr)dwAddress, buffer, (uint)buffer.Length, out pWrite);
            }

            public void WriteInt32(uint dwAddress, Int32 val)
            {
                IntPtr pWrite = IntPtr.Zero;
                byte[] buffer = BitConverter.GetBytes(val);

                WriteProcessMemory(this.hProc, (IntPtr)dwAddress, buffer, (uint)buffer.Length, out pWrite);
            }

            public void WriteUInt32(uint dwAddress, UInt32 val)
            {
                IntPtr pWrite = IntPtr.Zero;
                byte[] buffer = BitConverter.GetBytes(val);

                WriteProcessMemory(this.hProc, (IntPtr)dwAddress, buffer, (uint)buffer.Length, out pWrite);
            }

            public void WriteInt64(uint dwAddress, Int64 val)
            {
                IntPtr pWrite = IntPtr.Zero;
                byte[] buffer = BitConverter.GetBytes(val);

                WriteProcessMemory(this.hProc, (IntPtr)dwAddress, buffer, (uint)buffer.Length, out pWrite);
            }

            public void WriteUInt64(uint dwAddress, UInt64 val)
            {
                IntPtr pWrite = IntPtr.Zero;
                byte[] buffer = BitConverter.GetBytes(val);

                WriteProcessMemory(this.hProc, (IntPtr)dwAddress, buffer, (uint)buffer.Length, out pWrite);
            }

            public void WriteFloat(uint dwAddress, float val)
            {
                IntPtr pWrite = IntPtr.Zero;
                byte[] buffer = BitConverter.GetBytes(val);

                WriteProcessMemory(this.hProc, (IntPtr)dwAddress, buffer, (uint)buffer.Length, out pWrite);
            }

            public void WriteDouble(uint dwAddress, double val)
            {
                IntPtr pWrite = IntPtr.Zero;
                byte[] buffer = BitConverter.GetBytes(val);

                WriteProcessMemory(this.hProc, (IntPtr)dwAddress, buffer, (uint)buffer.Length, out pWrite);
            }

            public byte[] ReadProcess(uint dwAddress, uint bytesToRead)
            {
                byte[] buffer = new byte[bytesToRead];
                IntPtr pRead = IntPtr.Zero;

                ReadProcessMemory(this.hProc, (IntPtr)dwAddress, buffer, bytesToRead, out pRead);

                return buffer;
            }

            public Int16 ReadInt16(uint dwAddress)
            {
                byte[] buffer = new byte[sizeof(Int16)];
                IntPtr pRead = IntPtr.Zero;

                ReadProcessMemory(this.hProc, (IntPtr)dwAddress, buffer, sizeof(Int16), out pRead);

                return BitConverter.ToInt16(buffer, 0);
            }

            public Int32 ReadInt32(uint dwAddress)
            {
                byte[] buffer = new byte[sizeof(Int32)];
                IntPtr pRead = IntPtr.Zero;

                ReadProcessMemory(this.hProc, (IntPtr)dwAddress, buffer, sizeof(Int32), out pRead);

                return BitConverter.ToInt32(buffer, 0);
            }

            public Int64 ReadInt64(uint dwAddress)
            {
                byte[] buffer = new byte[sizeof(Int64)];
                IntPtr pRead = IntPtr.Zero;

                ReadProcessMemory(this.hProc, (IntPtr)dwAddress, buffer, sizeof(Int64), out pRead);

                return BitConverter.ToInt64(buffer, 0);
            }

            public double ReadFloat(uint dwAddress)
            {
                byte[] buffer = new byte[sizeof(float)];
                IntPtr pRead = IntPtr.Zero;

                ReadProcessMemory(this.hProc, (IntPtr)dwAddress, buffer, sizeof(float), out pRead);

                return BitConverter.ToSingle(buffer, 0);
            }

            public double ReadDouble(uint dwAddress)
            {
                byte[] buffer = new byte[sizeof(double)];
                IntPtr pRead = IntPtr.Zero;

                ReadProcessMemory(this.hProc, (IntPtr)dwAddress, buffer, sizeof(double), out pRead);

                return BitConverter.ToDouble(buffer, 0);
            }


            public void Close()
            {
                CloseHandle(hProc);
            }


            //Accessors
            public string ProcessName
            {
                get { return this.processName; }
            }

            public IntPtr ProcessHandle
            {
                get { return this.hProc; }
            }


            //vars 
            //private System.Diagnostics.Process procName;
            private string processName;
            private IntPtr hProc;
        }
    }
}
