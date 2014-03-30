package ;

import systools.Clipboard;
import systools.Dialogs;

class Main 
{
	static private var _args:Array<String>;
	
	static function main() 
	{
		_args = Sys.args();
		
		switch(_args.length)
		{
			case 0:
				selectFiles();
				end();
			default:
				end();
		}
	}
	
	static function selectFiles()
	{
		Sys.println("Select the files you wish to convert");
		
		var allFilter:FILEFILTERS = { count:1, descriptions:["All Files"], extensions:["*"] };
		var files:Array<String> = Dialogs.openFile("Choose files", "Choose files", allFilter);
		
		Sys.println("Select the folder you want the converted files to be saved in");
		
		var outDir:String = Dialogs.folder("Choose folder", "Choose folder");
		
		VGMStream.exePath = "vgmstream/vgmstream.exe";
		
		for (file in files)
		{
			VGMStream.convert(file, false, outDir);
		}
	}
	
	static function end(?msg:String)
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
	}
}