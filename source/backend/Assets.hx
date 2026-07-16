package backend;

import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets;

import haxe.io.Bytes;

import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFLAssets;

class Assets
{
	public static var cache(default, null):Cache = new Cache();

	@:allow(states.InitState)
	static function init()
	{
		cache.startupCache();
	}

	/**
	 * @param path The path where the asset is located.
	 * @param type The type of asset you're looking for.
	 * @return Whether the file exists or not.
	 */
	public static function exists(path:String, ?type:AssetType):Bool
	{
		return OpenFLAssets.exists(path, type);
	}

	/**
	 * @param path The path where the asset is located.
	 * @return The raw bytes of the asset.
	 */
	public static function getBytes(path:String):Bytes
	{
		return OpenFLAssets.getBytes(path);
	}

	/**
	 * @param path The path where the text asset is located.
	 * @return The content inside the text asset.
	 */
	public static function getText(path:String):String
	{
		return OpenFLAssets.getText(path);
	}

	/**
	 * @param path      The path where the image asset is located.
	 * @param useCache  Whether to store the bitmap in cache.
	 * @return A `BitmapData` object holding the data of the image asset.
	 */
	public static function getBitmapData(path:String, useCache:Bool = true):BitmapData
	{
		return OpenFLAssets.getBitmapData(path, useCache);
	}

	/**
	 * @param path 		The path where the image asset is located.
	 * @param useCache 	Whether to store the asset in the cache, or retrieve it.
	 * @param allowGPU 	Whether the graphic should be stored in VRAM.
	 * @return The `FlxGraphic` object holding the data of the image asset, or HaxeFlixel's logo if it failed.
	 */
	public static function getGraphic(path:String, useCache:Bool = true, allowGPU:Bool = true):FlxGraphic
	{
		if (useCache && cache.graphics.exists(path))
		{
			return cache.graphics.get(path);
		}

		var bitmapData:BitmapData = getBitmapData(path, useCache);

		if (bitmapData != null)
		{
			return cache.cacheBitmap(path, bitmapData, allowGPU);
		}

		return FlxG.bitmap.add('flixel/images/logo/default.png');
	}

	/**
	 * @param path      The path where the sound asset is located.
	 * @param useCache  Whether to store the sound in cache.
	 * @return A `Sound` object holding the data of the sound asset, or HaxeFlixel's beep sound if it failed.
	 */
	public static function getSound(path:String, useCache:Bool = true):Sound
	{
		if (useCache && cache.sounds.exists(path))
		{
			return cache.sounds.get(path);
		}

		var sound:Sound = OpenFLAssets.getSound(path, useCache);

		if (sound != null)
		{
			return cache.cacheSound(path, sound);
		}

		return FlxAssets.getSoundAddExtension('flixel/sounds/beep');
	}

	/**
	 * @param path      The path where the music asset is located.
	 * @param useCache  Whether to store the music in cache.
	 * @return A `Sound` object holding the data of the music asset.
	 */
	public static function getMusic(path:String, useCache:Bool = true):Sound
	{
		return OpenFLAssets.getMusic(path, useCache);
	}

	/**
	 * @param directory 	The directory to dissect the assets from.
	 * @param includePath 	Whether to include the path that leads to the files.
	 * @return All the files inside the given directory.
	 */
	public static function readDirectory(directory:String, includePath:Bool = true):Array<String>
	{
		if (!directory.endsWith('/'))
			directory += '/';

		var dir:Array<String> = OpenFLAssets.list().filter(file -> file.startsWith(directory));

		if (!includePath)
			dir = dir.map(file -> file.replace(directory, ''));

		return dir;
	}

	/**
	 * @param directory The supposed directory.
	 * @return Whether the given directory is actually a directory.
	 */
	public static function isDirectory(directory:String):Bool
	{
		return OpenFLAssets.list().filter(path -> path != directory && path.startsWith(directory)).length > 0;
	}
}
