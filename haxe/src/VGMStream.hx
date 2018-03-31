package ;

import format.wav.Data.WAVE;
import format.wav.Reader;
import haxe.io.Path;
import sys.io.Process;
import systools.win.Tools;

/**
 * Class that interacts with vgmstream.
 */
class VGMStream
{
	/**
	 * The relative path to the vgmstream .exe. Must be set before calling convert.
	 */
	static public var exePath(default, default):String;
	
	/**
	 * Converts a file. Can either convert it to an external file directly, or get the file data directly as a WAVE object (from the format library).
	 * @param	path      Absolute path of the file to convert.
	 * @param	outDir    The directory to save the converted file in. If this is null, it will return the file data as a WAVE.
	 * @return            The file data WAVE. If outDir != null (file is saved externally) then this returns null.
	 */
	static public function convert(path:String, outDir:String = null):WAVE
	{
		if (exePath == null)
		{
			Sys.println("Must set path to vgmstream exe!");
			return null;
		}
		
		var inFile:String = "\"" + path + "\"";
		
		if (outDir == null) //Get file data as a WAVE
		{
			var process:Process = new Process(exePath, ["-p", "-i", inFile]);
			
			var inWav:WAVE = new Reader(process.stdout).read();
			
			process.close();
			
			return inWav;
		}
		
		//Otherwise let vgmstream save it
		var fileName:String = new Path(path).file;
		var outFile:String = "\"" + new Path(outDir).toString() + "\\" + fileName + ".wav\"";
		
		Sys.println("----------");
		var result:Int = Tools.createProcess(exePath, '-i -o $outFile $inFile', Sys.getCwd(), false, true);
		
		return null;
	}
}