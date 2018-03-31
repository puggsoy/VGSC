using System;
using System.Collections.ObjectModel;
using System.Windows;
using Microsoft.Win32;
using Microsoft.WindowsAPICodePack.Dialogs;
using System.Diagnostics;
using System.IO;
using System.ComponentModel;

namespace VGSC
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public ObservableCollection<ConversionItem> ConversionItems { get; set; }

        private string[] filePaths;
        private string outDir;

        private int fileIndex;

        private Process process;

        public MainWindow()
        {
            ConversionItems = new ObservableCollection<ConversionItem>();

            InitializeComponent();
        }

        private void openBtn_Click(object sender, RoutedEventArgs e)
        {
            OpenFileDialog dialog = new OpenFileDialog();
            dialog.Multiselect = true;
            dialog.Title = "Select files to open";
            bool? result = dialog.ShowDialog();

            if (result.HasValue && result.Value)
            {
                filePaths = dialog.FileNames;

                ConversionItems.Clear();

                foreach (string s in dialog.SafeFileNames)
                {
                    ConversionItems.Add(new ConversionItem { Name = s, Status = "Unconverted" });
                }
            }

            convertBtn.IsEnabled = ConversionItems.Count > 0;
        }

        private void convertBtn_Click(object sender, RoutedEventArgs e)
        {
            CommonOpenFileDialog dialog = new CommonOpenFileDialog();
            dialog.IsFolderPicker = true;
            dialog.Title = "Select folder to put converted files into";
            CommonFileDialogResult result = dialog.ShowDialog();

            if (result == CommonFileDialogResult.Ok)
            {
                outDir = dialog.FileName;
                ConvertFiles();
            }
        }

        private void ConvertFiles()
        {
            process = new Process();
            process.StartInfo.FileName = "vgmstream/vgmstream.exe";
            process.StartInfo.CreateNoWindow = true;
            process.StartInfo.RedirectStandardOutput = true;
            process.StartInfo.RedirectStandardError = true;
            process.StartInfo.UseShellExecute = false;
            process.EnableRaisingEvents = true;
            process.Exited += ConvertEnd;

            fileIndex = 0;

            ConvertStart();
        }

        private void ConvertStart()
        {
            if (fileIndex >= filePaths.Length)
                return;

            string inPath = filePaths[fileIndex];
            string outPath = Path.Combine(outDir, Path.GetFileName(inPath));
            outPath = Path.ChangeExtension(outPath, "wav");
            string args = string.Format("-o \"{0}\" -i \"{1}\"", outPath, inPath);

            ConversionItems[fileIndex].Status = "Converting";

            Console.WriteLine(process.StartInfo.FileName + " " + args);
            process.StartInfo.Arguments = args;
            process.Start();
        }

        private void ConvertEnd(object sender, System.EventArgs e)
        {
            
            string output = process.StandardOutput.ReadToEnd();
            string error = process.StandardError.ReadToEnd();

            bool failed = error.StartsWith("failed");

            ConversionItems[fileIndex].Status = failed ? "Failed" : "Success";

            fileIndex++;
            ConvertStart();
        }
    }

    public class ConversionItem : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        private string m_name;
        private string m_status;

        public string Name
        {
            get { return m_name; }
            set
            {
                m_name = value;
                OnPropertyChanged("Name");
            }
        }

        public string Status
        {
            get { return m_status; }
            set
            {
                m_status = value;
                OnPropertyChanged("Status");
            }
        }

        protected void OnPropertyChanged(string name)
        {
            if (PropertyChanged != null)
            {
                PropertyChanged(this, new PropertyChangedEventArgs(name));
            }
        }
    }
}
