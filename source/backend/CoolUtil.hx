package backend;

import openfl.Lib;

#if sys
import sys.FileSystem;
#end

class CoolUtil
{
	inline public static function quantize(f:Float, snap:Float):Float
	{
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		return (m / snap);
	}

	inline public static function capitalize(text:String):String
	{
		return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();
	}

	inline public static function coolTextFile(path:String):Array<String>
	{
		var daList:String = null;

		if (Assets.exists(path))
			daList = Assets.getText(path);

		return daList != null ? listFromString(daList) : [];
	}

	inline public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();

		if (color.startsWith('0x'))
			color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if (colorNum == null)
			colorNum = FlxColor.fromString('#$color');

		return colorNum != null ? colorNum : FlxColor.WHITE;
	}

	inline public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if (decimals < 1)
			return Math.floor(value);

		var tempMult:Float = 1;
		for (i in 0...decimals)
			tempMult *= 10;

		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}

	public static function dominantColor(sprite:flixel.FlxSprite):FlxColor
	{
		var colorMap:Map<FlxColor, Int> = [];

		for (x in 0...sprite.pixels.width)
		{
			for (y in 0...sprite.pixels.height)
			{
				var color:FlxColor = sprite.pixels.getPixel32(x, y);
				if ((color >> 24 & 0xFF) == 0)
					continue;

				var count:Int = colorMap.exists(color) ? colorMap.get(color) + 1 : 1;
				colorMap.set(color, count);
			}
		}

		var maxCount:Int = 0;
		var domColor:FlxColor = 0;
		for (color => count in colorMap)
		{
			if (count >= maxCount)
			{
				maxCount = count;
				domColor = color;
			}
		}

		return domColor;
	}

	inline public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		return [for (i in min...max) i];
	}

	public inline static function boundInt(value:Int, min:Int, max:Int):Int
	{
		return value < min ? min : (value > max ? max : value);
	}

	public static inline function fpsLerp(a:Float, b:Float, ratio:Float):Float
	{
		return FlxMath.lerp(a, b, FlxMath.getElapsedLerp(ratio, FlxG.elapsed));
	}

	inline public static function browserLoad(site:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	inline public static function openFolder(folder:String, createIfNonExistent:Bool = true)
	{
		#if sys
		folder = folder.trim();

		if (createIfNonExistent && !FileSystem.exists(folder))
		{
			FileSystem.createDirectory(folder);
		}
		else if (!FileSystem.exists(folder))
		{
			FlxG.log.error("Cannot open a folder that doesn't exist!");
			return;
		}

		#if windows
		Sys.command('explorer', [folder.replace('/', '\\')]);
		#elseif mac
		Sys.command('open', [folder]);
		#elseif linux
		var exitCode:Int = Sys.command("xdg-open", [folder]);
		if (exitCode == 0)
			return;

		for (fileManager in ["dolphin", "nautilus", "nemo", "thunar", "caja", "konqueror", "spacefm", "pcmanfm"])
		{
			if (Sys.command("which", [fileManager]) == 0)
			{
				exitCode = Sys.command(fileManager, [folder]);
				if (exitCode == 0)
					return;
			}
		}

		FlxG.log.warn('No compatible file manager found for Linux.');
		#end
		#else
		FlxG.log.error("Platform is not supported for CoolUtil.openFolder!");
		#end
	}

	/**
		Helper Function to Fix Save Files for Flixel 5

		-- EDIT: [November 29, 2023] --

		this function is used to get the save path, period.
		since newer flixel versions are being enforced anyways.
		@crowplexus
	**/
	@:access(flixel.util.FlxSave.validate)
	inline public static function getSavePath():String
	{
		final company:String = FlxG.stage.application.meta.get('company');
		// #if (flixel < "5.0.0") return company; #else
		return '${company}/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
		// #end
	}

	public static function setTextBorderFromString(text:FlxText, border:String)
	{
		switch (border.toLowerCase().trim())
		{
			case 'shadow':
				text.borderStyle = SHADOW;

			case 'outline':
				text.borderStyle = OUTLINE;

			case 'outline_fast', 'outlinefast':
				text.borderStyle = OUTLINE_FAST;

			default:
				text.borderStyle = NONE;
		}
	}

	public static inline function centerWindowOnPoint(?point:FlxPoint)
	{
		Lib.application.window.x = Std.int(point.x - (Lib.application.window.width / 2));
		Lib.application.window.y = Std.int(point.y - (Lib.application.window.height / 2));
	}

	public static inline function getCenterWindowPoint():FlxPoint
	{
		return FlxPoint.get(Lib.application.window.x + (Lib.application.window.width / 2), Lib.application.window.y + (Lib.application.window.height / 2));
	}
}
