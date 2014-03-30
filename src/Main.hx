package ;

import haxe.io.Path;
import sys.FileSystem;
import systools.Clipboard;
import systools.Dialogs;

class Main 
{
	static private inline var USAGE:String = "Command line usage: VGSC inDir outDir [options]\n    inDir: Path to directory containing files to convert\n    outDir: Path to directory where converted files will be saved";
	
	static private var _args:Array<String>;
	
	static function main() 
	{
		_args = Sys.args();
		
		if (_args.length == 0)
		{
			Sys.println(USAGE + "\n");
			selectFiles();
		}
		else
		if (_args.length == 1)
		{
			end(1, USAGE);
		}
		else
		if (_args.length > 1)
		{
			parseArgs(_args);
		}
	}
	
	static private function selectFiles()
	{
		Sys.println("Select the files you wish to convert");
		
		var allFilter:FILEFILTERS = { count:1, descriptions:["All Files"], extensions:["*"] };
		var files:Array<String> = Dialogs.openFile("Choose files", "Choose files", allFilter);
		
		if (files == null)
		{
			end(2, "No files selected!");
			return;
		}
		
		Sys.println("Select the folder you want the converted files to be saved in");
		
		var outDir:String = Dialogs.folder("Choose folder", "Choose folder");
		
		if (outDir == null)
		{
			end(2, "No folder selected!");
			return;
		}
		
		convert(files, outDir);
	}
	
	static private function parseArgs(args:Array<String>)
	{
		var inDir:String = new Path(args[0]).toString();
		
		if (!FileSystem.exists(inDir) || !FileSystem.isDirectory(inDir))
		{
			end(3, "First argument must be an existing directory");
			return;
		}
		
		inDir = FileSystem.fullPath(inDir);
		
		var inFiles:Array<String> = FileSystem.readDirectory(inDir);
		
		if (inFiles.length == 0)
		{
			end(3, "First argument must contain files");
			return;
		}
		
		for (i in 0...inFiles.length)
		{
			inFiles[i] = inDir + "\\" + inFiles[i];
		}
		
		var outDir:String = new Path(args[1]).toString();
		
		if (!FileSystem.exists(outDir) || !FileSystem.isDirectory(outDir))
		{
			end(3, "Second argument must be an existing directory");
			return;
		}
		
		outDir = FileSystem.fullPath(outDir);
		
		convert(inFiles, outDir);
	}
	
	static private function convert(fileList:Array<String>, outDir:String)
	{
		VGMStream.exePath = "vgmstream/vgmstream.exe";
		
		for (file in fileList)
		{
			VGMStream.convert(file, false, outDir);
		}
		
		end(0, "Done");
	}
	
	static private function end(errCode:Int, ?msg:String)
	{
		if (msg != null)
		{
			Sys.println(msg);
		}
		else
		{
			Sys.println("Press any key to end...");
		}
		
		Sys.getChar(false);
		Sys.exit(errCode);
	}
}