package ;

import format.wav.Data.WAVE;
import format.wav.Reader;
import haxe.io.Path;
import sys.io.Process;
import systools.win.Tools;

class VGMStream
{
	static private var _exePath:String;
	
	static public function convert(path:String, pipe:Bool, ?outDir:String):WAVE
	{
		if (_exePath == null)
		{
			Sys.println("Must set path to vgmstream exe!");
			return null;
		}
		
		var inFile:String = "\"" + path + "\"";
		
		if (pipe)
		{
			var process:Process = new Process(_exePath, ["-p", inFile]);
			
			var inWav:WAVE = new Reader(process.stdout).read();
			
			process.close();
			return inWav;
		}
		else
		if (outDir != null)
		{
			var fileName:String = new Path(path).file;
			var outFile:String = "\"" + new Path(outDir).toString() + "\\" + fileName + ".wav\"";
			
			var result:Int = Tools.createProcess(_exePath, "-o " + outFile + " " + inFile, Sys.getCwd(), false, true);
		}
		
		return null;
	}
	
	static function get_exePath():String 
	{
		return _exePath;
	}
	
	static function set_exePath(value:String):String 
	{
		return _exePath = value;
	}
	
	static public var exePath(get_exePath, set_exePath):String;
}