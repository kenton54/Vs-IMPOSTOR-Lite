package backend;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

import haxe.io.Path;

import openfl.media.Sound;
import openfl.utils.AssetType;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class Paths
{
	public static function getPath(file:String, ?library:String):String
	{
		if (library != null)
			return getLibraryPath(file, library);

		return getLitePath(file);
	}

	static public function getLibraryPath(file:String, library:String = "default"):String
	{
		return (library == "default" || library == "shared") ? getLitePath(file) : getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String):String
	{
		var returnPath = '$library:assets/$library/$file';
		return returnPath;
	}

	inline public static function getLitePath(file:String = ''):String
	{
		return 'assets/lite/$file';
	}

	inline static public function txt(key:String, ?library:String):String
	{
		return getPath('data/$key.txt', library);
	}

	inline static public function xml(key:String, ?library:String):String
	{
		return getPath('data/$key.xml', library);
	}

	inline static public function json(key:String, ?library:String):String
	{
		return getPath('data/$key.json', library);
	}

	inline static public function shaderFragment(key:String, ?library:String):String
	{
		return getPath('shaders/$key.frag', library);
	}

	inline static public function shaderVertex(key:String, ?library:String):String
	{
		return getPath('shaders/$key.vert', library);
	}

	inline static public function lua(key:String, ?library:String):String
	{
		return getPath('$key.lua', library);
	}

	inline static public function video(key:String, ?library:String):String
	{
		return findFileExtensions('videos/$key', ['mp4', 'mov'], library);
	}

	static public function sound(key:String, ?library:String):Sound
	{
		return Assets.getSound(soundPath(key, library));
	}

	public static inline function soundPath(key:String, ?library:String):String
	{
		return findFileExtensions('sounds/$key', ['ogg', 'wav'], library);
	}

	inline static public function soundRandom(key:String, min:Int = 0, max:Int = 0, ?library:String):Sound
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Sound
	{
		return Assets.getMusic(musicPath(key, library));
	}

	public static inline function musicPath(key:String, ?library:String):String
	{
		return findFileExtensions('music/$key', ['ogg', 'wav'], library);
	}

	inline static public function voices(song:String, ?suffix:String):Sound
	{
		return Assets.getMusic(voicesPath(song, suffix));
	}

	inline static public function inst(song:String):Sound
	{
		return Assets.getMusic(instPath(song));
	}

	public static inline function voicesPath(song:String, ?suffix:String):String
	{
		var songKey:String = '${formatToSongPath(song)}/Voices';
		if (suffix != null)
			songKey += '-' + suffix;
		return getPath('data/songs/$songKey.ogg');
	}

	public static inline function instPath(song:String):String
	{
		var songKey:String = '${formatToSongPath(song)}/Inst';
		return getPath('data/songs/$songKey.ogg');
	}

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];

	public inline static function image(key:String, ?library:String, ?allowGPU:Bool = #if web false #else true #end):FlxGraphic
	{
		return Assets.getGraphic(imagePath(key, library), true, allowGPU);
	}

	public inline static function imagePath(key:String, ?library:String):String
	{
		return getPath('images/$key.png', library);
	}

	static public function getTextFromFile(key:String, ?library:String):String
	{
		var fullPath:String = getPath(key, library);
		return Assets.exists(fullPath, TEXT) ? Assets.getText(fullPath) : '';
	}

	public static function font(key:String):String
	{
		var path:String = 'assets/fonts';

		for (ext in ['ttf', 'otf'])
		{
			var fontPath:String = '$path/$key.$ext';
			if (Assets.exists(fontPath))
				return fontPath;
		}

		return '$path/$key.ttf';
	}

	public inline static function fileExists(key:String, type:AssetType, ?library:String = null):Bool
	{
		return Assets.exists(getPath(key, library), type);
	}

	static public function getAtlas(key:String, ?library:String = null, ?allowGPU:Bool = #if web false #else true #end):FlxAtlasFrames
	{
		var filePath:String = getPath('images/$key', library);

		if (Assets.exists('$filePath.xml', TEXT))
			return getSparrowAtlas(key, library, allowGPU);
		else if (Assets.exists('$filePath.json', TEXT))
			return getAsepriteAtlas(key, library, allowGPU);
		else if (Assets.exists('$filePath.txt', TEXT))
			return getPackerAtlas(key, library, allowGPU);

		return null;
	}

	static public function getMultiAtlas(keys:Array<String>, ?library:String = null, ?allowGPU:Bool = #if web false #else true #end):FlxAtlasFrames
	{
		var parentFrames:FlxAtlasFrames = Paths.getAtlas(keys[0].trim());
		if (keys.length > 1)
		{
			var original:FlxAtlasFrames = parentFrames;
			parentFrames = new FlxAtlasFrames(parentFrames.parent);
			parentFrames.addAtlas(original, true);
			for (i in 1...keys.length)
			{
				var extraFrames:FlxAtlasFrames = Paths.getAtlas(keys[i].trim(), library, allowGPU);
				if (extraFrames != null)
					parentFrames.addAtlas(extraFrames, true);
			}
		}
		return parentFrames;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String = null, ?allowGPU:Bool = #if web false #else true #end):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSparrow(image(key, library, allowGPU), getPath('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String = null, ?allowGPU:Bool = #if web false #else true #end):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library, allowGPU), getPath('images/$key.txt', library));
	}

	inline static public function getAsepriteAtlas(key:String, ?library:String = null, ?allowGPU:Bool = #if web false #else true #end):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromTexturePackerJson(image(key, library, allowGPU), getPath('images/$key.json', library));
	}

	inline static public function formatToSongPath(path:String):String
	{
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars = ~/[.,'"%?!]/;

		var path = invalidChars.split(path.replace(' ', '-')).join("-");
		return hideChars.split(path).join("").toLowerCase();
	}

	public static function findFileExtensions(key:String, exts:Array<String>, ?library:String):String
	{
		// if the key already has an extension, return the whole path immediately
		if (Path.extension(key) != '')
			return getPath(key, library);

		for (ext in exts)
		{
			var extPath:String = getPath('$key.$ext', library);
			if (Assets.exists(extPath))
				return extPath;
		}

		return getPath('$key.${exts[0]}', library);
	}
}
