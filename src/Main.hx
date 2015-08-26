package ;

import easyconsole.Begin;
import easyconsole.End;
import haxe.io.Path;
import sys.FileSystem;
import systools.Dialogs;

/**
 * Main class. Initialises program, takes input.
 */
class Main 
{
	static private inline var TITLE:String = "==========\nVGSC v2.1 - by puggsoy (puggsoy.wordpress.com)\nUses vgmstream r1040 - by hcs (www.hcs64.com)\n==========\n";
	static private inline var USAGE:String = "Command line usage: VGSC inDir outDir\n    inDir: Path to directory containing files to convert\n    outDir: Path to directory where converted files will be saved";
	
	static private var _args:Array<String>;
	
	/**
	 * Entry point. Initialise stuff, parse arguments.
	 */
	static function main() 
	{
		Begin.init();
		Begin.usage = USAGE;
		Begin.functions = [selectFiles, null, parseArgs]; //0 arguments, show UI. Needs 2 otherwise.
		Begin.parseArgs();
	}
	
	/**
	 * Called when no arguments are passed in. Gives selection windows for input files and output directory.
	 */
	static private function selectFiles()
	{
		Sys.println(TITLE);
		Sys.println(USAGE + "\n");
		Sys.println("Select the files you wish to convert");
		
		var allFilter:FILEFILTERS = { count:1, descriptions:["All Files"], extensions:["*"] };
		var files:Array<String> = Dialogs.openFile("Choose files", "Choose files", allFilter);
		
		if (files == null)
		{
			End.anyKeyExit(2, "No files selected!");
			return;
		}
		
		Sys.println("Select the folder you want the converted files to be saved in");
		
		var outDir:String = Dialogs.folder("Choose folder", "Choose folder");
		
		if (outDir == null)
		{
			End.anyKeyExit(2, "No folder selected!");
			return;
		}
		
		convert(files, outDir);
	}
	
	/**
	 * Called when 2 or more arguments are passed in. Parses first argument as input directory, second as output directory. Both must exist.
	 */
	static private function parseArgs()
	{
		Sys.println(TITLE);
		
		var inDir:String = new Path(Begin.args[0]).toString();
		
		if (!FileSystem.exists(inDir) || !FileSystem.isDirectory(inDir))
		{
			End.anyKeyExit(3, "First argument must be an existing directory!");
			return;
		}
		
		inDir = FileSystem.fullPath(inDir);
		Sys.println('Input folder: $inDir');
		
		var inFiles:Array<String> = FileSystem.readDirectory(inDir);
		
		if (inFiles.length == 0)
		{
			End.anyKeyExit(3, "Input folder must contain files!");
			return;
		}
		
		for (i in 0...inFiles.length)
		{
			inFiles[i] = inDir + "\\" + inFiles[i];
		}
		
		var outDir:String = new Path(Begin.args[1]).toString();
		
		if (!FileSystem.exists(outDir) || !FileSystem.isDirectory(outDir))
		{
			End.anyKeyExit(3, "Second argument must be an existing directory");
			return;
		}
		
		outDir = FileSystem.fullPath(outDir);
		Sys.println('Output folder: $outDir');
		
		convert(inFiles, outDir);
	}
	
	/**
	 * Converts the files using VGMStream.
	 * @param	fileList    List of input files.
	 * @param	outDir      Output directory.
	 */
	static private function convert(fileList:Array<String>, outDir:String)
	{
		VGMStream.exePath = "vgmstream/vgmstream.exe";
		
		for (file in fileList)
		{
			VGMStream.convert(file, outDir);
		}
		
		Sys.println("");
		End.anyKeyExit(0, "Done");
	}
}