package states;

import flixel.addons.transition.FlxTransitionableState;
import lime.app.Promise;
import lime.app.Future;

import flixel.util.typeLimit.NextState;

import openfl.utils.Assets as OpenFLAssets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import backend.StageData;

import haxe.io.Path;

class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;

	// Browsers will load create(), you can make your song load a custom directory there
	// If you're compiling to desktop (or something that doesn't use NO_PRELOAD_ALL), search for getNextState instead
	// I'd recommend doing it on both actually lol

	// TO DO: Make this easier

	var target:NextState;
	var stopMusic = false;
	var callbacks:MultiCallback;

	function new(target:NextState, stopMusic:Bool)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
	}

	var loadBar:FlxSprite;

	override function create()
	{
		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1);
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		add(bg);

		var bf:FlxSprite = new FlxSprite();
		bf.frames = Paths.getSparrowAtlas('runbfrun');
		bf.animation.addByPrefix('run', "run", 24, false);
		bf.animation.addByPrefix('stop', "stop", 24, false);
		bf.animation.addByPrefix('loopedStop', "loop-stop", 24, true);
		bf.animation.play('run');
		bf.antialiasing = false;
		bf.screenCenter();
		bf.scale.set(1.5, 1.5);
		add(bf);

		loadBar = new FlxSprite(0, FlxG.height).makeGraphic(FlxG.width, 10, 0xFF9AE0FF);
		loadBar.y -= loadBar.height;
		loadBar.scale.x = 0;
		loadBar.updateHitbox();
		loadBar.screenCenter(X);
		add(loadBar);

		initSongsManifest().onComplete(function(lib:AssetLibrary)
		{
			callbacks = new MultiCallback(onLoad);

			if (PlayState.SONG != null)
			{
				checkLoadSong(getSongPath());

				if (PlayState.SONG.needsVoices)
					checkLoadSong(getVocalPath());
			}

			checkLibrary("videos");
		});
	}

	function checkLoadSong(path:String)
	{
		if (!OpenFLAssets.cache.hasSound(path))
		{
			var library:AssetLibrary = OpenFLAssets.getLibrary("data");
			final symbolPath = path.split(":").pop();
			// @:privateAccess
			// library.types.set(symbolPath, SOUND);
			// @:privateAccess
			// library.pathGroups.set(symbolPath, [library.__cacheBreak(symbolPath)]);
			var callback = callbacks?.add("song:" + path);
			OpenFLAssets.loadSound(path).onComplete(function (_)
			{
				if (callback != null)
					callback();
			});
		}
	}

	function checkLibrary(library:String)
	{
		if (OpenFLAssets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
				throw 'Missing library "$library"';

			var callback = callbacks?.add("library:" + library);
			OpenFLAssets.loadLibrary(library).onComplete(function (_)
			{
				if (callback != null)
					callback();
			});
		}
	}

	var targetShit:Float = 0;

	override function update(elapsed:Float)
	{
		if (callbacks != null)
		{
			targetShit = FlxMath.remapToRange(callbacks.numRemaining / callbacks.length, 1, 0, 0, 1);

			var lerpWidth:Float = FlxMath.lerp(loadBar.width, FlxG.width * targetShit, 0.2);
			if (lerpWidth > 0)
			{
				loadBar.scale.x = lerpWidth;
				loadBar.updateHitbox();
			}
		}

		super.update(elapsed);
	}

	function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			FlxG.sound.music = null;
		}

		FlxTransitionableState.skipNextTransIn = true;
		FlxG.switchState(target);
	}

	static function getSongPath():String
	{
		return Paths.instPath(PlayState.SONG.song);
	}

	static function getVocalPath():String
	{
		return Paths.voicesPath(PlayState.SONG.song);
	}

	public static function loadState(target:NextState, stopMusic:Bool = false)
	{
		//FlxTransitionableState.skipNextTransOut = true;
		FlxG.switchState(/*() -> new LoadingState(target, stopMusic)*/ target);
	}

	inline static public function loadAndSwitchState(target:NextState, stopMusic:Bool = false)
		FlxG.switchState(getNextState(target, stopMusic));

	static function getNextState(target:NextState, stopMusic:Bool = false):NextState
	{
		var directory:String = 'shared';
		var weekDir:String = StageData.forceNextDirectory;
		StageData.forceNextDirectory = null;

		if(weekDir != null && weekDir.length > 0 && weekDir != '') directory = weekDir;

		// trace('Setting asset folder to ' + directory);

		/*#if NO_PRELOAD_ALL
		var loaded:Bool = false;
		if (PlayState.SONG != null) {
			loaded = isSoundLoaded(getSongPath()) && (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath())) && isLibraryLoaded('week_assets');
		}
		
		if (!loaded)
			return new LoadingState(target, stopMusic, directory);
		#end*/
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		return target;
	}
	
	/*#if NO_PRELOAD_ALL
	static function isSoundLoaded(path:String):Bool
	{
		trace(path);
		return OpenFLAssets.cache.hasSound(path);
	}
	
	static function isLibraryLoaded(library:String):Bool
	{
		return OpenFLAssets.getLibrary(library) != null;
	}
	#end*/

	override function destroy()
	{
		super.destroy();
		
		callbacks = null;
	}

	static function initSongsManifest():Future<AssetLibrary>
	{
		final id:String = "songs";
		var promise = new Promise<AssetLibrary>();

		var library:AssetLibrary = LimeAssets.getLibrary(id);
		if (library != null)
		{
			return Future.withValue(library);
		}

		var path:String = id;
		var rootPath:String = null;

		@:privateAccess var libraryPaths = LimeAssets.libraryPaths;
		if (libraryPaths.exists(id))
		{
			path = libraryPaths[id] ?? path;
			rootPath = Path.directory(path);
		}
		else
		{
			if (path.endsWith(".bundle"))
			{
				rootPath = path;
				path += "/library.json";
			}
			else
			{
				rootPath = Path.directory(path);
			}

			@:privateAccess path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest:AssetManifest)
		{
			if (manifest == null)
			{
				promise.error('Cannot parse asset manifest for library "$id"');
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);

			if (library == null)
			{
				promise.error('Cannot open library "$id"');
			}
			else
			{
				@:privateAccess LimeAssets.libraries.set(id, library);
				library.onChange.add(LimeAssets.onChange.dispatch);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_)
		{
			promise.error("There is no asset library with an ID of \"" + id + "\"");
		});

		return promise.future;
	}
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:Null<String>;
	public var length(default, null):Int = 0;
	public var numRemaining(default, null):Int = 0;

	var unfired:Map<String, Void->Void> = new Map<String, Void->Void>();
	var fired:Array<String> = new Array<String>();

	public function new(callback:Void->Void, ?logId:String)
	{
		this.callback = callback;
		this.logId = logId;
	}

	public function add(id:String = "untitled"):Void->Void
	{
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function ()
		{
			if (unfired.exists(id))
			{
				unfired.remove(id);
				fired.push(id);
				numRemaining--;

				if (logId != null) log('fired $id, $numRemaining remaining');

				if (numRemaining == 0)
				{
					if (logId != null) log('all callbacks fired');
					callback();
				}
			}
			else
				log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}

	inline function log(msg):Void
	{
		if (logId != null)
			trace('$logId: $msg');
	}

	public function getFired():Array<String>
		return fired.copy();

	public function getUnfired():Array<Void->Void>
		return [for (i in unfired.iterator()) i];
}