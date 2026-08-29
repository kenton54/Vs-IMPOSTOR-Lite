package;

import haxe.io.Path;
import sys.io.Process;
import sys.FileSystem;

using StringTools;

/**
 * The fact that this is necessary is stupid
*/
class CheckHXCPP
{
  public static function main()
  {
		var oldWD:String = Sys.getCwd();
    Sys.setCwd('../');
    var libProcess:Process = new Process('haxelib', ['libpath', 'hxcpp']);
    var path:String = libProcess.stdout.readLine();
    libProcess.close();

		if (path.toLowerCase().startsWith('error') || !FileSystem.exists(path))
		{
			Sys.println('[ERROR] Couldn\'t find the library "hxcpp", It needs to be installed!');
      Sys.exit(1);
      return;
		}

		if (FileSystem.exists(Path.join([path, 'hxcpp.n'])))
		{
				// hxcpp build tools were already set up
				return;
		}

		var toolsPath:String = Path.join([path, 'tools/hxcpp']);
		Sys.setCwd(toolsPath);

		var process:Process = new Process('haxe', ['compile.hxml']);
		if (process.exitCode() != 0)
		{
			Sys.println("[INFO] Couldn't compile HXCPP Tools. Is HXCPP installed properly?");
		}

		process.close();
		Sys.setCwd(oldWD);
  }
}