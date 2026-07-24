package setup.scripts;

import sys.FileSystem;
import sys.io.File;
import sys.io.FileInput;

class BuildTimeTrackerFinish
{
	public static final BUILD_TIME_FILE:String = '.build_time';

	public static function main()
	{
		var endTime:Float = Sys.time();
		if (FileSystem.exists(BUILD_TIME_FILE))
		{
			var fileInput:FileInput = File.read(BUILD_TIME_FILE);
			var startTime:Float = fileInput.readDouble();

			fileInput.close();
			FileSystem.deleteFile(BUILD_TIME_FILE);

			Sys.println('');
			Sys.println('[BUILD SUCCESS]: The Build compiled in ${formatTime(endTime - startTime)}');
		}
	}

	static function formatTime(time:Float):String
	{
		var hours:Int = Std.int(time / 3600);
		var minutes:Int = Std.int((time % 3600) / 60);
		var seconds:Int = Std.int(time % 60);
		var milliseconds:Int = Std.int(time % 1);

		var result:Array<String> = [];

		if (hours > 0)
			result.push('${hours}h');

		if (minutes > 0)
			result.push('${minutes}m');

		if (seconds > 0)
			result.push('${seconds}s');

		if (milliseconds > 0)
			result.push('${milliseconds}ms');

		return result.join(' ');
	}
}
