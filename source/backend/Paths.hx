package backend;

import haxe.io.Path;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;

import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.media.Sound;
import openfl.utils.AssetType;
import openfl.system.System;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

#if MODS_ALLOWED
import backend.Mods;
#end

class Paths
{
	public static function getPath(file:String, ?type:AssetType = TEXT, ?library:String, ?modsAllowed:Bool = false):String
	{
		#if MODS_ALLOWED
		if (modsAllowed)
		{
			var customFile:String = file;
			if (library != null)
				customFile = '$library/$file';

			var modded:String = modFolders(customFile);
			if (FileSystem.exists(modded)) return modded;
		}
		#end

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
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String):String
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String):String
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function shaderFragment(key:String, ?library:String):String
	{
		return getPath('shaders/$key.frag', TEXT, library);
	}
	inline static public function shaderVertex(key:String, ?library:String):String
	{
		return getPath('shaders/$key.vert', TEXT, library);
	}
	inline static public function lua(key:String, ?library:String):String
	{
		return getPath('$key.lua', TEXT, library);
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
		return findFileExtensions('sounds/$key', ['ogg', 'wav'], library, SOUND);
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
		return findFileExtensions('music/$key', ['ogg', 'wav'], library, MUSIC);
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
		if (suffix != null) songKey += '-' + suffix;
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
		return getPath('images/$key.png', IMAGE, library);
	}

	static public function getTextFromFile(key:String, ?library:String, allowMods:Bool = true):String
	{
		var fullPath:String = getPath(key, TEXT, library, allowMods);
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

	public inline static function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String = null)
	{
		return Assets.exists(getPath(key, type, library, !ignoreMods), type);
	}

	static public function getAtlas(key:String, ?library:String = null, ?allowGPU:Bool = #if web false #else true #end):FlxAtlasFrames
	{
		var useMod = false;
		var imageLoaded:FlxGraphic = image(key, library, allowGPU);

		var myXml:Dynamic = getPath('images/$key.xml', TEXT, library, true);
		if (Assets.exists(myXml) #if MODS_ALLOWED || (FileSystem.exists(myXml) && (useMod = true)) #end )
		{
			#if MODS_ALLOWED
			return FlxAtlasFrames.fromSparrow(imageLoaded, (useMod ? File.getContent(myXml) : myXml));
			#else
			return FlxAtlasFrames.fromSparrow(imageLoaded, myXml);
			#end
		}
		else
		{
			var myJson:Dynamic = getPath('images/$key.json', TEXT, library, true);
			if (Assets.exists(myJson) #if MODS_ALLOWED || (FileSystem.exists(myJson) && (useMod = true)) #end )
			{
				#if MODS_ALLOWED
				return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, (useMod ? File.getContent(myJson) : myJson));
				#else
				return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, myJson);
				#end
			}
		}
		return getPackerAtlas(key, library);
	}

	static public function getMultiAtlas(keys:Array<String>, ?parentFolder:String = null, ?allowGPU:Bool = #if web false #else true #end):FlxAtlasFrames
	{
		var parentFrames:FlxAtlasFrames = Paths.getAtlas(keys[0].trim());
		if (keys.length > 1)
		{
			var original:FlxAtlasFrames = parentFrames;
			parentFrames = new FlxAtlasFrames(parentFrames.parent);
			parentFrames.addAtlas(original, true);
			for (i in 1...keys.length)
			{
				var extraFrames:FlxAtlasFrames = Paths.getAtlas(keys[i].trim(), parentFolder, allowGPU);
				if (extraFrames != null)
					parentFrames.addAtlas(extraFrames, true);
			}
		}
		return parentFrames;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String = null, ?allowGPU:Bool = #if web false #else true #end):FlxAtlasFrames
	{
		var imageLoaded:FlxGraphic = image(key, library, allowGPU);
		#if MODS_ALLOWED
		var xmlExists:Bool = false;

		var xml:String = modsXml(key);
		if(FileSystem.exists(xml)) xmlExists = true;

		return FlxAtlasFrames.fromSparrow(imageLoaded, (xmlExists ? File.getContent(xml) : getPath('images/$key.xml', library)));
		#else
		return FlxAtlasFrames.fromSparrow(imageLoaded, getPath('images/$key.xml', library));
		#end
	}

	inline static public function getPackerAtlas(key:String, ?library:String = null, ?allowGPU:Bool = #if web false #else true #end):FlxAtlasFrames
	{
		var imageLoaded:FlxGraphic = image(key, library, allowGPU);
		#if MODS_ALLOWED
		var txtExists:Bool = false;
		
		var txt:String = modsTxt(key);
		if(FileSystem.exists(txt)) txtExists = true;

		return FlxAtlasFrames.fromSpriteSheetPacker(imageLoaded, (txtExists ? File.getContent(txt) : getPath('images/$key.txt', library)));
		#else
		return FlxAtlasFrames.fromSpriteSheetPacker(imageLoaded, getPath('images/$key.txt', library));
		#end
	}

	inline static public function getAsepriteAtlas(key:String, ?library:String = null, ?allowGPU:Bool = #if web false #else true #end):FlxAtlasFrames
	{
		var imageLoaded:FlxGraphic = image(key, library, allowGPU);
		#if MODS_ALLOWED
		var jsonExists:Bool = false;

		var json:String = modsImagesJson(key);
		if(FileSystem.exists(json)) jsonExists = true;

		return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, (jsonExists ? File.getContent(json) : getPath('images/$key.json', library)));
		#else
		return FlxAtlasFrames.fromTexturePackerJson(imageLoaded, getPath('images/$key.json', library));
		#end
	}

	inline static public function formatToSongPath(path:String):String
	{
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars = ~/[.,'"%?!]/;

		var path = invalidChars.split(path.replace(' ', '-')).join("-");
		return hideChars.split(path).join("").toLowerCase();
	}

	public static function findFileExtensions(key:String, exts:Array<String>, ?library:String, ?type:AssetType):String
	{
		// if the key already has an extension, return the whole path immediately
		if (Path.extension(key) != '')
		{
			return getPath(key, type, library);
		}

		for (ext in exts)
		{
			var extPath:String = getPath('$key.$ext', type, library);
			if (Assets.exists(extPath))
				return extPath;
		}

		return getPath('$key.${exts[0]}', type, library);
	}

	#if MODS_ALLOWED
	inline static public function mods(key:String = '') {
		return 'mods/$key';
	}

	inline static public function modsFont(key:String) {
		return modFolders('fonts/$key');
	}

	inline static public function modsJson(key:String) {
		return modFolders('data/$key.json');
	}

	inline static public function modsVideo(key:String) {
		return modFolders('videos/$key.mp4');
	}

	inline static public function modsSounds(path:String, key:String) {
		return modFolders('$path/$key.ogg');
	}

	inline static public function modsImages(key:String) {
		return modFolders('images/$key.png');
	}

	inline static public function modsXml(key:String) {
		return modFolders('images/$key.xml');
	}

	inline static public function modsTxt(key:String) {
		return modFolders('images/$key.txt');
	}

	inline static public function modsImagesJson(key:String) {
		return modFolders('images/$key.json');
	}

	/* Goes unused for now

	inline static public function modsShaderFragment(key:String, ?library:String)
	{
		return modFolders('shaders/'+key+'.frag');
	}
	inline static public function modsShaderVertex(key:String, ?library:String)
	{
		return modFolders('shaders/'+key+'.vert');
	}
	inline static public function modsAchievements(key:String) {
		return modFolders('achievements/' + key + '.json');
	}*/

	static public function modFolders(key:String) {
		if (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0) {
			var fileToCheck:String = mods(Mods.currentModDirectory + '/' + key);
			if (FileSystem.exists(fileToCheck))
				return fileToCheck;
		}

		for(mod in Mods.getGlobalMods()){
			var fileToCheck:String = mods(mod + '/' + key);
			if(FileSystem.exists(fileToCheck))
				return fileToCheck;
		}

		return 'mods/' + key;
	}
	#end
}
