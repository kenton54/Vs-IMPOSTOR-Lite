package backend;

import flixel.system.FlxAssets;
import flixel.graphics.FlxGraphic;
import openfl.media.Sound;
import openfl.display.BitmapData;
import haxe.io.Bytes;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFLAssets;

#if lime_vorbis
import lime.media.vorbis.VorbisFile;
import lime.media.AudioBuffer;
#end

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
		#if MODS_ALLOWED
        if (FileSystem.exists(path))
            return true;
        #end

		return OpenFLAssets.exists(path, type);
    }

	/**
	 * @param path The path where the asset is located.
	 * @return The raw bytes of the asset.
	 */
    public static function getBytes(path:String):Bytes
    {
		#if MODS_ALLOWED
		if (FileSystem.exists(path))
			return File.getBytes(path);
		#end

        return OpenFLAssets.getBytes(path);
    }

	/**
	 * @param path The path where the text asset is located.
	 * @return The content inside the text asset.
	 */
	public static function getText(path:String):String
	{
		#if MODS_ALLOWED
		if (FileSystem.exists(path))
			return File.getContent(path);
		#end

		return OpenFLAssets.getText(path);
	}

	/**
	 * @param path      The path where the image asset is located.
     * @param useCache  Whether to store the bitmap in cache.
	 * @return A `BitmapData` object holding the data of the image asset.
	 */
	public static function getBitmapData(path:String, useCache:Bool = true):BitmapData
	{
		#if MODS_ALLOWED
		if (FileSystem.exists(path))
			return BitmapData.fromFile(path);
		#end

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

		var sound:Null<Sound> = null;

		#if MODS_ALLOWED
		if (FileSystem.exists(path))
			sound = Sound.fromFile(path);
		#end

		sound = OpenFLAssets.getSound(path, useCache);

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
		#if MODS_ALLOWED
		if (FileSystem.exists(path))
        {
			#if lime_vorbis
			return Sound.fromAudioBuffer(AudioBuffer.fromVorbisFile(VorbisFile.fromFile(path)));
            #else
			return Sound.fromFile(path);
            #end
        }
		#end

		return OpenFLAssets.getMusic(path, useCache);
	}

	/**
	 * @param directory The directory to dissect the assets from.
	 * @return All the files inside the given directory.
	 */
	public static function readDirectory(directory:String):Array<String>
	{
		#if MODS_ALLOWED
		if (FileSystem.exists(directory) && FileSystem.isDirectory(directory))
			return FileSystem.readDirectory(directory);
		#end

		var dir:Array<String> = OpenFLAssets.list().filter(file -> file.startsWith(directory));
		return dir.map(file -> file.replace(directory, '').replace('/', ''));
	}

	/**
	 * @param directory The supposed directory.
	 * @return Whether the given directory is actually a directory.
	 */
    public static function isDirectory(directory:String):Bool
    {
		#if MODS_ALLOWED
		if (FileSystem.exists(directory))
			return FileSystem.isDirectory(directory)
		#end

		return OpenFLAssets.list().filter(path -> path != directory && path.startsWith(directory)).length > 0;
    }
}