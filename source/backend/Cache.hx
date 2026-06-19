package backend;

import flixel.util.FlxStringUtil;
import flixel.FlxState;
import openfl.media.Sound;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFLAssets;

@:access(openfl.display.BitmapData)
@:allow(backend.Assets)
class Cache
{
    public var graphics(default, null):Map<String, FlxGraphic>;
	public var sounds(default, null):Map<String, Sound>;

    public final permanentCache:Array<String> = [
		'assets/lite/images/cursor.png',
		'assets/lite/images/healthBar.png',
		'assets/lite/images/switchState.png',
		'assets/lite/images/runbfrun.png',
		'assets/lite/images/sketch.png',
		'assets/lite/images/sketch2.png',
		'assets/lite/images/noteSkins/NOTE_assets.png',
		'assets/lite/images/noteSplashes/noteSplashes.png',
		'assets/lite/images/ingame/1.png',
		'assets/lite/images/ingame/2.png',
		'assets/lite/images/ingame/3.png',
		'assets/lite/images/ingame/go.png',
		'assets/lite/images/ingame/sick.png',
		'assets/lite/images/ingame/good.png',
		'assets/lite/images/ingame/bad.png',
		'assets/lite/images/ingame/shit.png',
		'assets/lite/images/ingame/pause.png',
		'assets/lite/images/ingame/num0.png',
		'assets/lite/images/ingame/num1.png',
		'assets/lite/images/ingame/num2.png',
		'assets/lite/images/ingame/num3.png',
		'assets/lite/images/ingame/num4.png',
		'assets/lite/images/ingame/num5.png',
		'assets/lite/images/ingame/num6.png',
		'assets/lite/images/ingame/num7.png',
		'assets/lite/images/ingame/num8.png',
		'assets/lite/images/ingame/num9.png',
		'assets/lite/images/characters/bf.png',
        #if mobile
	    'assets/lite/images/backButton.png',
		'assets/lite/images/pauseButton.png',
        #end
		'assets/lite/sounds/confirmMenu.ogg',
		'assets/lite/sounds/scrollMenu.ogg',
		'assets/lite/sounds/cancelMenu.ogg',
		'assets/lite/sounds/intro3.ogg',
		'assets/lite/sounds/intro2.ogg',
		'assets/lite/sounds/intro1.ogg',
		'assets/lite/sounds/introGo.ogg',
		'assets/lite/sounds/missnote1.ogg',
		'assets/lite/sounds/missnote2.ogg',
		'assets/lite/sounds/missnote3.ogg',
		'assets/lite/music/freakyMenu.ogg',
		'assets/lite/music/pause.ogg',
    ];

    static var initialized:Bool = false;

    function startupCache()
    {
		if (initialized) return;

		for (asset2Cache in permanentCache)
        {
			var ext:String = haxe.io.Path.extension(asset2Cache);
            switch(ext)
            {
                case 'png':
					Assets.getGraphic(asset2Cache);

				case 'ogg' | 'wav':
					Assets.getSound(asset2Cache);
            }
        }

		initialized = true;
    }

    public function new()
    {
		graphics = new Map<String, FlxGraphic>();
		sounds = new Map<String, Sound>();

		FlxG.signals.preStateSwitch.add(prepareClearMemory);
		FlxG.signals.preStateCreate.add(clearMemoryOnStateSwitch);
    }

	var _lastState:Null<String> = null;

	function prepareClearMemory()
	{
		_lastState = FlxStringUtil.getClassName(@:privateAccess FlxG.game._state);
	}

	function clearMemoryOnStateSwitch(newState:FlxState)
	{
		var newStateStr:String = FlxStringUtil.getClassName(newState);

		if (_lastState == null || newStateStr != _lastState)
		{
			clearStoredMemory();
			_lastState = null;
		}
	}

    public function clearStoredMemory()
    {
		var allKeys:Array<String> = [for (key in graphics.keys()) key].concat([for (key in sounds.keys()) key]);

		for (key in allKeys)
		{
			if (!permanentCache.contains(key))
				removeFromCache(key);
		}

		#if !html5
		OpenFLAssets.cache.clear("songs");
		#end

		performGarbageCollection();
    }

    public function removeFromCache(key:String, dispose:Bool = true):Bool
    {
        if (graphics.exists(key))
        {
			if (dispose)
				disposeGraphic(graphics.get(key));

			graphics.remove(key);

            return true;
        }
		else if (sounds.exists(key))
		{
			if (dispose)
				OpenFLAssets.cache.clear(key);

			sounds.remove(key);

			return true;
		}

        return false;
    }

    public function cacheBitmap(key:String, bitmap:BitmapData, allowGPU:Bool = true):FlxGraphic
    {
		if (graphics.exists(key))
        {
			return graphics.get(key);
        }

        if (allowGPU && ClientPrefs.data.cacheOnGPU)
        {
            bitmap.disposeImage();
        }

		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key);
		newGraphic.persist = true;
		newGraphic.destroyOnNoUse = false;

		graphics.set(key, newGraphic);

		return newGraphic;
    }

    public function cacheSound(key:String, sound:Sound):Sound
    {
		if (sounds.exists(key))
		{
			return sounds.get(key);
		}

		sounds.set(key, sound);
        return sound;
    }

    public function disposeGraphic(graphic:FlxGraphic)
    {
		if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null)
			graphic.bitmap.__texture.dispose();

		FlxG.bitmap.remove(graphic);
    }

    function performGarbageCollection()
    {
        #if java
        // this one will probably never run lol, but just in case
        java.vm.Gc.run(true);
        #else
        // openfl garbage collection runs for Hashlink, Neko and C++
        openfl.system.System.gc();
        #end
    }
}