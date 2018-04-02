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
        public ObservableCollection<ConversionItem> ItemList { get; set; }

        private string[] filePaths;
        private string outDir;

        private int fileIndex;

        private Converter converter;

        public MainWindow()
        {
            ItemList = new ObservableCollection<ConversionItem>();
            converter = new Converter(ConvertDone);

            InitializeComponent();
        }

        private void OpenBtn_Click(object sender, RoutedEventArgs e)
        {
            OpenFileDialog dialog = new OpenFileDialog();
            dialog.Multiselect = true;
            dialog.Title = "Select files to open";
            bool? result = dialog.ShowDialog();

            if (result.HasValue && result.Value)
            {
                filePaths = dialog.FileNames;

                ItemList.Clear();

                foreach (string s in dialog.SafeFileNames)
                {
                    ItemList.Add(new ConversionItem { Name = s, Status = "Unconverted" });
                }
            }

            ConvertBtn.IsEnabled = ItemList.Count > 0;
        }

        private void ConvertBtn_Click(object sender, RoutedEventArgs e)
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
            fileIndex = 0;
            ConvertStart();
        }

        private void ConvertStart()
        {
            if (fileIndex >= filePaths.Length)
                return;

            ItemList[fileIndex].Status = "Converting";

            string inPath = filePaths[fileIndex];
            converter.Convert(inPath, outDir);
        }

        private void ConvertDone(bool success)
        {
            ItemList[fileIndex].Status = success ? "Success" : "Failed";

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
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
        }
    }
}
