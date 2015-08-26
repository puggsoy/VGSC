package ;

import format.wav.Data.WAVE;
import format.wav.Reader;
import haxe.io.Path;
import sys.io.Process;
import systools.win.Tools;

class VGMStream
{
	static public var exePath(default, default):String;
	
	static public function convert(path:String, outDir:String = null):WAVE
	{
		if (exePath == null)
		{
			Sys.println("Must set path to vgmstream exe!");
			return null;
		}
		
		var inFile:String = "\"" + path + "\"";
		
		if (outDir == null)
		{
			var process:Process = new Process(exePath, ["-p", "-i", inFile]);
			
			var inWav:WAVE = new Reader(process.stdout).read();
			
			process.close();
			
			return inWav;
		}
		
		var fileName:String = new Path(path).file;
		var outFile:String = "\"" + new Path(outDir).toString() + "\\" + fileName + ".wav\"";
		
		Sys.println("----------");
		var result:Int = Tools.createProcess(exePath, '-i -o $outFile $inFile', Sys.getCwd(), false, true);
		
		return null;
	}
}