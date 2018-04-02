using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Diagnostics;

namespace VGSC
{
    class Converter
    {
        private readonly string exePath = "vgmstream/vgmstream.exe";
        private Process process;
        private Action<bool> doneCallback;

        public Converter(Action<bool> doneCallback)
        {
            this.doneCallback = doneCallback;

            process = new Process();
            process.StartInfo.FileName = exePath;
            process.StartInfo.CreateNoWindow = true;
            process.StartInfo.RedirectStandardOutput = true;
            process.StartInfo.RedirectStandardError = true;
            process.StartInfo.UseShellExecute = false;
            process.EnableRaisingEvents = true;
            process.Exited += ConvertEnd;
        }

        public void Convert(string inPath, string outDir,
                            double loopCount = -1, double fadeTime = -1,
                            double fadeDelay = -1, bool ignoreLooping = false)
        {
            string outPath = Path.Combine(outDir, Path.GetFileNameWithoutExtension(inPath));
            outPath = Path.ChangeExtension(outPath, "wav");
            List<string> args = new List<string>();

            
            if (loopCount >= 0)
                args.Add("-l " + loopCount);
            if (fadeTime >= 0)
                args.Add("-f " + fadeTime);
            if (fadeDelay >= 0)
                args.Add("-d " + fadeDelay);
            if (ignoreLooping)
                args.Add("-i");

            args.Add(string.Format("-o \"{0}\"", outPath));
            args.Add(string.Format("\"{0}\"", inPath));

            string argString = String.Join(" ", args.ToArray<string>());
            process.StartInfo.Arguments = argString;
            process.Start();
        }

        private void ConvertEnd(object sender, EventArgs e)
        {
            string output = process.StandardOutput.ReadToEnd();
            string error = process.StandardError.ReadToEnd();

            bool success = !error.StartsWith("failed");

            doneCallback(success);
        }
    }
}
