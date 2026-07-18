package debug;

import flixel.FlxG;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class FPSCounter extends Sprite
{
	public var updating:Bool = true;

	public var text:TextField;
	public var underlay:Bitmap;

	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	/**
		The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	**/
	public var memoryMegas(get, never):Float;

	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		underlay = new Bitmap();
		underlay.bitmapData = new BitmapData(1, 1, true, 0x6F000000);
		addChild(underlay);

		text = new TextField();
		addChild(text);

		currentFPS = 0;
		text.selectable = false;
		text.mouseEnabled = false;
		text.defaultTextFormat = new TextFormat(FlxG.assets.getFont(Paths.font("vcr")).fontName, 14, color);
		text.autoSize = LEFT;
		text.multiline = true;
		text.text = "";

		times = [];

		FlxG.signals.postStateSwitch.add(() -> updateText = __updateTxt);
	}

	var deltaTimeout:Float = 0.0;

	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void
	{
		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000)
			times.shift();

		// prevents the overlay from updating every frame, why would you need to anyways @crowplexus
		if (deltaTimeout < 100)
		{
			deltaTimeout += deltaTime;
			return;
		}

		currentFPS = times.length; // times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;

		updateText();
		underlay.width = text.width + 10;
		underlay.height = text.height + 10;
		text.x = 5;
		text.y = 5;

		deltaTimeout = 0.0;
	}

	dynamic function updateText():Void
	{
		__updateTxt();
	}

	function __updateTxt()
	{
		if (!updating)
			return;

		text.text = 'FPS: $currentFPS';

		#if !web
		text.text += '\nMEMORY: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}';
		#end

		text.textColor = 0xFFFFFFFF;
		if (currentFPS < FlxG.drawFramerate * 0.5)
			text.textColor = 0xFFFF0000;
	}

	inline function get_memoryMegas():Float
	{
		return System.totalMemoryNumber;
	}
}
