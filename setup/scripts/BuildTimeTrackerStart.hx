package setup.scripts;

import sys.io.File;
import sys.io.FileOutput;

class BuildTimeTrackerStart
{
	public static final BUILD_TIME_FILE:String = '.build_time';

	public static function main()
	{
		var fileOutput:FileOutput = File.write(BUILD_TIME_FILE);
		var curTime:Float = Sys.time();

		fileOutput.writeDouble(curTime);
		fileOutput.close();
	}
}
