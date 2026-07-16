package backend;

#if sys
import sys.FileSystem;
#end

typedef ModsList =
{
	enabled:Array<String>,
	disabled:Array<String>,
	all:Array<String>
}

class Mods
{
	static public var currentModDirectory:String = '';
	public static var ignoreModFolders:Array<String> = [
		'characters',
		'events',
		'notetypes',
		'data',
		'songs',
		'music',
		'sounds',
		'shaders',
		'videos',
		'images',
		'stages',
		'weeks',
		'fonts',
		'scripts',
		'achievements'
	];

	private static var globalMods:Array<String> = [];

	inline public static function getGlobalMods()
		return globalMods;

	inline public static function pushGlobalMods() // prob a better way to do this but idc
	{
		globalMods = [];
		for (mod in parseList().enabled)
		{
			var pack:Dynamic = getPack(mod);
			if (pack != null && pack.runsGlobally)
				globalMods.push(mod);
		}
		return globalMods;
	}

	inline public static function getModDirectories():Array<String>
	{
		return [];
	}

	inline public static function mergeAllTextsNamed(path:String, ?defaultDirectory:String, allowDuplicates:Bool = false)
	{
		if (defaultDirectory == null)
			defaultDirectory = Paths.getLitePath();
		defaultDirectory = defaultDirectory.trim();
		if (!defaultDirectory.startsWith('assets/'))
			defaultDirectory = 'assets/$defaultDirectory';
		if (!defaultDirectory.endsWith('/'))
			defaultDirectory += '/';

		var mergedList:Array<String> = [];
		var paths:Array<String> = directoriesWithFile(defaultDirectory, path);

		var defaultPath:String = defaultDirectory + path;
		if (paths.contains(defaultPath))
		{
			paths.remove(defaultPath);
			paths.insert(0, defaultPath);
		}

		for (file in paths)
		{
			var list:Array<String> = CoolUtil.coolTextFile(file);
			for (value in list)
				if ((allowDuplicates || !mergedList.contains(value)) && value.length > 0)
					mergedList.push(value);
		}
		return mergedList;
	}

	public static function directoriesWithFile(path:String, fileToFind:String, mods:Bool = true):Array<String>
	{
		return [path + fileToFind];
	}

	public static function getPack(?folder:String = null):Dynamic
	{
		return null;
	}

	public static var updatedOnState:Bool = true;

	inline public static function parseList():ModsList
	{
		return {enabled: [], disabled: [], all: []};
	}

	public static function loadTopMod()
	{
		Mods.currentModDirectory = '';
	}
}
