package backend;

#if CRASH_HANDLER
import lime.system.System;
import openfl.errors.Error;
import openfl.events.ErrorEvent;
import openfl.events.UncaughtErrorEvent;
import openfl.Lib;

#if hl
import hl.Api;
#end

final class CrashHandler
{
    public static function init()
    {
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);

        #if cpp
		untyped __global__.__hxcpp_set_critical_error_handler(onCriticalError);
        #elseif hl
		Api.setErrorHandler(onCriticalError);
        #end
    }

	static function onUncaughtError(error:UncaughtErrorEvent)
	{
		try
		{
            var message:String = generateErrorMessage(error);
			lime.app.Application.current.window.alert(message, 'Impostor Lite Crash Handler');
            saveCrashLog(message);
		}
		catch (e:Dynamic) {}

		#if DISCORD_ALLOWED
		DiscordClient.shutdown();
		#end
		System.exit(1);
	}

	static function onCriticalError(error:Dynamic)
	{
		try
		{
			lime.app.Application.current.window.alert(error, 'CRITICAL ERROR');
		}
		catch (e:Dynamic) {}

		#if DISCORD_ALLOWED
		DiscordClient.shutdown();
		#end
		System.exit(1);
	}

	static function generateErrorMessage(error:UncaughtErrorEvent):String
	{
		var errorMsg:String = '';
		var callStack:Array<haxe.CallStack.StackItem> = haxe.CallStack.exceptionStack(true); // for some reason importing "CallStack" doesnt work

		if (Std.isOfType(error.error, Error))
			errorMsg = 'ERROR: ${cast(error.error, Error).message}\n\n';
		else if (Std.isOfType(error.error, ErrorEvent))
			errorMsg = 'ERROR: ${cast(error.error, ErrorEvent).text}\n\n';
		else
			errorMsg = 'ERROR: ${error.error}\n\n';

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case CFunction:
					errorMsg += 'C Function';

				case Module(module):
					errorMsg += 'Module $module';

				case FilePos(stackItem, file, line, column):
					errorMsg += 'File: $file (Line #$line)';

					if (column != null)
						errorMsg += ' (Column #$column)';

				case Method(classname, method):
					errorMsg += '$classname.$method';

				case LocalFunction(value):
					errorMsg += 'Local Function $value';
			}

			errorMsg += '\n';
		}

		trace('\n$errorMsg');

		return errorMsg;
	}

    static function saveCrashLog(message:String)
    {
        var curDate:String = DateTools.format(Date.now(), "%Y-%m-%d_%H-%M-%S");
		var crashSavepath:String = './crash/$curDate.txt';

        #if sys
        if (!FileSystem.exists("./crash/"))
            FileSystem.createDirectory("./crash/");

        File.saveContent(crashSavepath, message + "\n");
        #else
        trace("Can't save crash log in this system!");
        #end
    }
}
#end