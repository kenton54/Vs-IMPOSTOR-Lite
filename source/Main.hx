package;

import backend.CrashHandler;
import debug.FPSCounter;

import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

import states.InitState;

#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
import psychlua.HScript.HScriptInfos;
#end

#if linux
import hxgamemode.GamemodeClient;
#end

class Main extends Sprite
{
	var gameData = {
		width: #if mobile 0 #else 1200 #end, // WINDOW width
		height: #if mobile 0 #else 900 #end, // WINDOW height
		initialState: InitState, // initial game state
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static function main()
	{
		#if android
		Sys.setCwd(haxe.io.Path.addTrailingSlash(extension.androidtools.content.Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(haxe.io.Path.addTrailingSlash(lime.system.System.documentsDirectory));
		#end

		#if linux
		GamemodeClient.request_start();
		#end

		#if CRASH_HANDLER
		CrashHandler.init();
		#end

		Lib.current.addChild(new Main());
	}

	public static var fpsCounter(default, null):FPSCounter;

	public function new()
	{
		super();

		#if windows
		backend.native.Windows.setWindowDarkMode(true);
		#end

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event)
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		#if (sys && !mobile)
		Lib.current.stage.window.onClose.add(function()
		{
			#if hxvlc
			hxvlc.util.Handle.dispose();
			#end

			#if linux
			GamemodeClient.request_end();
			#end

			Sys.exit(0);
		});
		#end

		setupGame();
	}

	private function setupGame()
	{
		// we're a pixelated mod
		FlxSprite.defaultAntialiasing = false;

		#if hxvlc
		hxvlc.util.Handle.initAsync(null, function(success:Bool)
		{
			if (success)
				trace("LibVLC initialized successfully.");
			else
				trace("Failed to initialize LibVLC.");
		});
		#end

		#if HSCRIPT_ALLOWED
		Iris.warn = function(x, ?pos:haxe.PosInfos)
		{
			Iris.logLevel(WARN, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.functionName != null ? '(${newPos.functionName}) - ' : '') + '${newPos.fileName}:';

			#if LUA_ALLOWED
			if (newPos.isLua == true)
			{
				msgInfo += 'HScript:';
				newPos.showLine = false;
			}
			#end

			if (newPos.showLine == true)
			{
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('WARNING: $msgInfo', FlxColor.YELLOW);
		}
		Iris.error = function(x, ?pos:haxe.PosInfos)
		{
			Iris.logLevel(ERROR, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.functionName != null ? '(${newPos.functionName}) - ' : '') + '${newPos.fileName}:';

			#if LUA_ALLOWED
			if (newPos.isLua == true)
			{
				msgInfo += 'HScript:';
				newPos.showLine = false;
			}
			#end

			if (newPos.showLine == true)
			{
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('ERROR: $msgInfo', FlxColor.RED);
		}
		Iris.fatal = function(x, ?pos:haxe.PosInfos)
		{
			Iris.logLevel(FATAL, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.functionName != null ? '(${newPos.functionName}) - ' : '') + '${newPos.fileName}:';

			#if LUA_ALLOWED
			if (newPos.isLua == true)
			{
				msgInfo += 'HScript:';
				newPos.showLine = false;
			}
			#end

			if (newPos.showLine == true)
			{
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('FATAL: $msgInfo', 0xFFBB0000);
		}
		#end

		#if LUA_ALLOWED
		Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call));
		#end

		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.load();
		#end

		addChild(new FlxGame(gameData.width, gameData.height, gameData.initialState, gameData.framerate, gameData.framerate, gameData.skipSplash, gameData.startFullscreen));

		fpsCounter = new FPSCounter(0, 0, 0xFFFFFF);
		fpsCounter.visible = #if mobile false #else ClientPrefs.data.showFPS #end;
		addChild(fpsCounter);

		#if linux
		Lib.current.stage.window.setIcon(lime.graphics.Image.fromFile("icon.png"));
		#end

		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end

		// shader coords fix
		FlxG.signals.gameResized.add(function (w, h) {
		     if (FlxG.cameras != null) {
			   for (cam in FlxG.cameras.list) {
				if (cam != null && cam.filters != null)
					resetSpriteCache(cam.flashSprite);
			   }
			}

			if (FlxG.game != null)
			resetSpriteCache(FlxG.game);
		});
	}

	static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
		        sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	public static function getFPS():Int
	{
		return fpsCounter.currentFPS;
	}

	public static function getMemory():Float
	{
		return fpsCounter.memoryMegas;
	}
}
