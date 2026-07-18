package psychlua;

import Type;

import backend.StageData;

import flixel.FlxBasic;
import flixel.FlxState;
import flixel.group.FlxContainer;
import flixel.util.FlxAxes;
import flixel.util.FlxStringUtil;
import flixel.util.typeLimit.OneOfTwo;

import objects.Character;

import openfl.display.BlendMode;

import psychlua.functions.SpriteFunctions;

import substates.GameOverSubstate;

typedef LuaTweenOptions =
{
	type:FlxTweenType,
	startDelay:Float,
	onUpdate:Null<String>,
	onStart:Null<String>,
	onComplete:Null<String>,
	loopDelay:Float,
	ease:EaseFunction
}

@:access(psychlua.functions.SpriteFunctions)
class LuaUtils
{
	public static final Function_Stop:Dynamic = "##PSYCHLUA_FUNCTIONSTOP";
	public static final Function_Continue:Dynamic = "##PSYCHLUA_FUNCTIONCONTINUE";
	public static final Function_StopLua:Dynamic = "##PSYCHLUA_FUNCTIONSTOPLUA";
	public static final Function_StopHScript:Dynamic = "##PSYCHLUA_FUNCTIONSTOPHSCRIPT";
	public static final Function_StopAll:Dynamic = "##PSYCHLUA_FUNCTIONSTOPALL";

	public static function getLuaTween(?options:Dynamic):LuaTweenOptions
	{
		return options != null ? {
			type: getTweenTypeByString(options.type),
			startDelay: options.startDelay,
			onUpdate: options.onUpdate,
			onStart: options.onStart,
			onComplete: options.onComplete,
			loopDelay: options.loopDelay,
			ease: getTweenEaseByString(options.ease)
		} : null;
	}

	public static function getDynamicProperty(instance:Dynamic, variable:String, checkForMaps:Bool = false):Dynamic
	{
		var arrayCheck:Array<String> = variable.split('[');
		if (arrayCheck.length > 1)
		{
			var target:Dynamic = getDynamicProperty(instance, arrayCheck[0], false);

			for (i in 1...arrayCheck.length)
			{
				var j:Dynamic = arrayCheck[i].substr(0, arrayCheck[i].length - 1);
				target = target[j];
			}

			return target;
		}

		if (MusicBeatState.getVariables().exists(variable))
		{
			var val:Null<Dynamic> = MusicBeatState.getVariables().get(variable);
			if (val != null)
				return val;
		}

		if (checkForMaps && isMap(instance))
		{
			var map:Map<Dynamic, Dynamic> = cast instance;
			return map.get(variable);
		}

		return Reflect.getProperty(instance, variable);
	}

	public static function setDynamicProperty(instance:Dynamic, variable:String, value:Dynamic, checkForMaps:Bool = false):Dynamic
	{
		var arrayCheck:Array<String> = variable.split('[');
		if (arrayCheck.length > 1)
		{
			var target:Dynamic = getDynamicProperty(instance, arrayCheck[0], false);

			for (i in 1...arrayCheck.length)
			{
				var j:Dynamic = arrayCheck[i].substr(0, arrayCheck[i].length - 1);
				if (i == arrayCheck.length - 1)
					target[j] = value;
				else
					target = target[j];
			}

			return target;
		}

		if (MusicBeatState.getVariables().exists(variable))
		{
			MusicBeatState.getVariables().set(variable, value);
			return value;
		}

		if (checkForMaps && isMap(instance))
		{
			var map:Map<Dynamic, Dynamic> = cast instance;
			map.set(variable, value);
			return value;
		}

		Reflect.setProperty(instance, variable, value);
		return value;
	}

	public static function isMap(variable:Dynamic):Bool
	{
		return switch (Type.typeof(variable))
		{
			case ValueType.TClass(haxe.ds.StringMap) | ValueType.TClass(haxe.ds.ObjectMap) | ValueType.TClass(haxe.ds.IntMap) | ValueType.TClass(haxe.ds.EnumValueMap):
				true;
			default:
				false;
		}
	}

	public static function setGroupStuff(leArray:Dynamic, variable:String, value:Dynamic, ?allowMaps:Bool = false)
	{
		var split:Array<String> = variable.split('.');
		if (split.length > 1)
		{
			var obj:Dynamic = Reflect.getProperty(leArray, split[0]);
			for (i in 1...split.length - 1)
				obj = Reflect.getProperty(obj, split[i]);

			leArray = obj;
			variable = split[split.length - 1];
		}
		if (allowMaps && isMap(leArray))
			leArray.set(variable, value);
		else
			Reflect.setProperty(leArray, variable, value);

		return value;
	}

	public static function getGroupStuff(leArray:Dynamic, variable:String, ?allowMaps:Bool = false)
	{
		var split:Array<String> = variable.split('.');
		if (split.length > 1)
		{
			var obj:Dynamic = Reflect.getProperty(leArray, split[0]);
			for (i in 1...split.length - 1)
				obj = Reflect.getProperty(obj, split[i]);

			leArray = obj;
			variable = split[split.length - 1];
		}

		if (allowMaps && isMap(leArray))
			return leArray.get(variable);

		return Reflect.getProperty(leArray, variable);
	}

	// TODO: get rid of this
	public static function getPropertyLoop(split:Array<String>, getProperty:Bool = true, ?checkForMaps:Bool = false):Dynamic
	{
		var obj:Dynamic = getObject(split[0]);

		if (split.length == 2 && getProperty)
			obj = getDynamicProperty(obj, split[1], checkForMaps);
		else if (split.length > 1)
		{
			var endIndex:Int = split.length - 1;

			if (getProperty)
				endIndex--;

			for (i in 1...endIndex)
			{
				obj = getDynamicProperty(obj, split[i], checkForMaps);
			}
		}

		return obj;
	}

	public static function getObject(variable:String, ?checkForMaps:Bool = false):Null<Dynamic>
	{
		switch (variable)
		{
			case 'this' | 'instance' | 'game':
				return getTargetInstance();

			default:
				var obj:Dynamic = MusicBeatState.getVariables().get(variable);

				if (obj == null)
					obj = getDynamicProperty(getTargetInstance(), variable, checkForMaps);

				return obj;
		}

		return null;
	}

	public static function getLuaProperty(variable:String, ?checkForMaps:Bool = false):Dynamic
	{
		var split:Array<String> = variable.split('.');
		if (split.length > 1)
		{
			if (split.length == 2)
			{
				var target:Dynamic = getObject(split[0], checkForMaps);
				return getDynamicProperty(target, split[1], checkForMaps);
			}
			else
			{
				var target:Dynamic = getObject(split[0], checkForMaps);
				for (i in 1...(split.length - 1))
					target = getDynamicProperty(target, split[i], checkForMaps);

				return getDynamicProperty(target, split[split.length - 1], checkForMaps);
			}
		}
		else
			return getObject(variable, checkForMaps);
	}

	public static function setLuaProperty(variable:String, value:Dynamic, ?checkForMaps:Bool = false):Dynamic
	{
		var split:Array<String> = variable.split('.');
		if (split.length > 1)
		{
			if (split.length == 2)
			{
				var target:Dynamic = getObject(split[0], checkForMaps);
				return setDynamicProperty(target, split[1], value, checkForMaps);
			}
			else
			{
				var target:Dynamic = getObject(split[0], checkForMaps);
				for (i in 1...(split.length - 1))
					target = getDynamicProperty(target, split[i], checkForMaps);

				return setDynamicProperty(target, split[split.length - 1], value, checkForMaps);
			}
		}
		else
			return setDynamicProperty(getTargetInstance(), variable, value, checkForMaps);
	}

	public static function isOfTypes(value:Any, types:Array<Dynamic>):Bool
	{
		for (type in types)
		{
			if (Std.isOfType(value, type))
				return true;
		}

		return false;
	}

	public static function isLuaSupported(value:Any):Bool
	{
		return (value == null || isOfTypes(value, [Bool, Int, Float, String, Array]) || Type.typeof(value) == ValueType.TObject);
	}

	public static function getTargetInstance():FlxState
	{
		if (PlayState.instance != null)
			return PlayState.instance.isDead ? GameOverSubstate.instance : PlayState.instance;

		return MusicBeatState.getState();
	}

	public static function getObjectParent(tag:String):FlxContainer
	{
		var object:Dynamic = getLuaProperty(tag);

		if (!Std.isOfType(object, FlxBasic))
			return null;

		var basic:FlxBasic = cast object;

		if (Std.isOfType(basic, FlxState))
			return cast basic;

		return basic.container;
	}

	public static function getLowestCharacterGroup():FlxSpriteGroup
	{
		var playstate:PlayState = PlayState.instance;
		if (playstate == null)
			return null;

		var stageData:StageFile = StageData.getStageFile(PlayState.SONG.stage);
		var group:FlxSpriteGroup = stageData.hide_girlfriend ? playstate.boyfriendGroup : playstate.gfGroup;
		var pos:Int = playstate.members.indexOf(group);

		var newPos:Int = playstate.members.indexOf(playstate.boyfriendGroup);
		if (newPos < pos)
		{
			group = playstate.boyfriendGroup;
			pos = newPos;
		}

		newPos = playstate.members.indexOf(playstate.dadGroup);
		if (newPos < pos)
		{
			group = playstate.dadGroup;
			pos = newPos;
		}

		return group;
	}

	public static function addAnimDynamic(obj:String, name:String, ?prefix:String, ?indices:Any, framerate:Float = 24, loop:Bool = false, flipX:Bool = false, flipY:Bool = false):Bool
	{
		var obj:FlxBasic = getObject(obj);

		if (obj == null || !Std.isOfType(obj, FlxSprite))
			return false;

		var spr:FlxSprite = cast obj;
		var parsedIndices:Array<Int> = [];

		if (indices != null)
		{
			if (indices is String)
				parsedIndices = parseStringToIntArray(indices);
			else
				parsedIndices = cast indices;
		}

		if (prefix != null)
		{
			if (parsedIndices.length > 0)
				spr.animation.addByIndices(name, prefix, parsedIndices, '', framerate, loop, flipX, flipY);
			else
				spr.animation.addByPrefix(name, prefix, framerate, loop, flipX, flipY);
		}
		else
			spr.animation.add(name, parsedIndices, framerate, loop, flipX, flipY);

		if (spr.animation.curAnim == null)
		{
			if (Std.isOfType(spr, Character))
				cast(spr, Character).playAnim(name, true);
			else
				spr.animation.play(name, true);
		}

		return true;
	}

	public static function loadFrames(spr:FlxSprite, image:String, spriteType:String)
	{
		switch (spriteType.trim().toLowerCase().replace(' ', ''))
		{
			case 'aseprite', 'ase', 'json':
				spr.frames = Paths.getAsepriteAtlas(image);

			case 'packer', 'packeratlas', 'pac':
				spr.frames = Paths.getPackerAtlas(image);

			case 'sparrow', 'sparrowv2', 'sparrowatlas', 'xml':
				spr.frames = Paths.getSparrowAtlas(image);

			default:
				spr.frames = Paths.getAtlas(image);
		}
	}

	public static function luaObjectExists(tag:String, ?typeCheck:Dynamic):Bool
	{
		var obj:Dynamic = MusicBeatState.getVariables().get(tag);
		var result:Bool = obj != null;

		if (typeCheck != null)
			result = result && Std.isOfType(obj, typeCheck);

		return result;
	}

	public static function destroyObject(tag:String):Bool
	{
		var variables = MusicBeatState.getVariables();
		if (!variables.exists(tag))
			return false;

		var object:Dynamic = variables.get(tag);
		if (object == null || !Std.isOfType(object, FlxBasic))
			return false;

		var basic:FlxBasic = cast object;
		var instance:FlxState = getTargetInstance();

		if (instance.members.indexOf(basic) != -1)
			instance.remove(basic, true);

		basic.destroy();
		variables.remove(tag);

		return true;
	}

	public static function cancelTween(tag:String)
	{
		if (!tag.startsWith("tween_"))
			tag = "tween_" + formatVariable(tag);

		var variables = MusicBeatState.getVariables();
		var obj:Dynamic = variables.get(tag);

		if (obj == null || !Std.isOfType(obj, FlxTween))
			return;

		var tween:FlxTween = cast obj;
		tween.cancel();
		tween.destroy();
		variables.remove(tag);
	}

	public static function cancelTimer(tag:String)
	{
		if (!tag.startsWith("timer_"))
			tag = "timer_" + formatVariable(tag);

		var variables = MusicBeatState.getVariables();
		var timer:FlxTimer = cast variables.get(tag);

		if (timer != null)
		{
			timer.cancel();
			timer.destroy();
			variables.remove(tag);
		}
	}

	public static function tweenPrepare(tag:String, vars:String):Dynamic
	{
		cancelTween(tag);
		return getLuaProperty(vars);
	}

	public static function parseStringToIntArray(numArrStr:String):Array<Int>
	{
		if (numArrStr == null || numArrStr.length < 1 || !numArrStr.contains(','))
			return [];

		var indicesStr:Array<Null<Int>> = numArrStr.trim().split(',').map(i -> Std.parseInt(i.trim()));
		return indicesStr.filter(i -> i != null);
	}

	public static function parseStringToFloatArray(numArrStr:String):Array<Float>
	{
		if (numArrStr == null || numArrStr.length < 1 || !numArrStr.contains(','))
			return [];

		var indicesStr:Array<Null<Float>> = numArrStr.trim().split(',').map(i -> Std.parseFloat(i.trim()));
		return indicesStr.filter(i -> i != null);
	}

	public static function parseArguments(whatever:Dynamic):Array<Dynamic>
	{
		if (whatever == null)
			return [];

		if (whatever is Array)
		{
			var arr:Array<Dynamic> = cast whatever;
			return [for (i in arr) parseArgument(i)];
		}
		else
			return parseArgument(whatever);
	}

	public static function parseArgument(arg:Dynamic):Dynamic
	{
		var argStr:String = Std.string(arg);

		if (argStr != null && argStr.length > SpriteFunctions.instanceStr.length)
		{
			var i:Int = argStr.indexOf('::');
			if (i >= 0)
			{
				argStr = argStr.substr(i + 2);
				var j:Int = argStr.lastIndexOf('::');

				var split:Array<String> = j >= 0 ? argStr.substring(0, j).split('.') : argStr.split('.');
				arg = j >= 0 ? Type.resolveClass(argStr.substring(j + 2)) : getTargetInstance();

				for (p in 0...split.length)
					arg = getDynamicProperty(arg, split[p].trim());
			}
		}

		return arg;
	}

	public static inline function formatVariable(tag:String):String
	{
		return tag.trim().replace(' ', '_').replace('.', '');
	}

	public static function getBuildTarget():String
	{
		#if windows
		return 'windows';
		#elseif linux
		return 'linux';
		#elseif mac
		return 'mac';
		#elseif html5
		return 'browser';
		#elseif android
		return 'android';
		#elseif ios
		return 'ios';
		#elseif switch
		return 'switch';
		#else
		return 'unknown';
		#end
	}

	public static function getPlatformTarget():String
	{
		#if desktop
		return 'desktop';
		#elseif mobile
		return 'mobile';
		#elseif web
		return 'web';
		#elseif console
		return 'console';
		#else
		return 'unknown';
		#end
	}

	// buncho string stuffs
	public static function getTweenTypeByString(type:String = ''):FlxTweenType
	{
		return switch (type.toLowerCase().trim())
		{
			case 'backward': BACKWARD;
			case 'looping', 'loop': LOOPING;
			case 'persist': PERSIST;
			case 'pingpong': PINGPONG;
			default: ONESHOT;
		}
	}

	public static function getTweenEaseByString(ease:String = ''):EaseFunction
	{
		return switch (ease.toLowerCase().trim())
		{
			case 'backin': FlxEase.backIn;
			case 'backinout': FlxEase.backInOut;
			case 'backout': FlxEase.backOut;
			case 'bouncein': FlxEase.bounceIn;
			case 'bounceinout': FlxEase.bounceInOut;
			case 'bounceout': FlxEase.bounceOut;
			case 'circin': FlxEase.circIn;
			case 'circinout': FlxEase.circInOut;
			case 'circout': FlxEase.circOut;
			case 'cubein': FlxEase.cubeIn;
			case 'cubeinout': FlxEase.cubeInOut;
			case 'cubeout': FlxEase.cubeOut;
			case 'elasticin': FlxEase.elasticIn;
			case 'elasticinout': FlxEase.elasticInOut;
			case 'elasticout': FlxEase.elasticOut;
			case 'expoin': FlxEase.expoIn;
			case 'expoinout': FlxEase.expoInOut;
			case 'expoout': FlxEase.expoOut;
			case 'quadin': FlxEase.quadIn;
			case 'quadinout': FlxEase.quadInOut;
			case 'quadout': FlxEase.quadOut;
			case 'quartin': FlxEase.quartIn;
			case 'quartinout': FlxEase.quartInOut;
			case 'quartout': FlxEase.quartOut;
			case 'quintin': FlxEase.quintIn;
			case 'quintinout': FlxEase.quintInOut;
			case 'quintout': FlxEase.quintOut;
			case 'sinein': FlxEase.sineIn;
			case 'sineinout': FlxEase.sineInOut;
			case 'sineout': FlxEase.sineOut;
			case 'smoothstepin': FlxEase.smoothStepIn;
			case 'smoothstepinout': FlxEase.smoothStepInOut;
			case 'smoothstepout': FlxEase.smoothStepInOut;
			case 'smootherstepin': FlxEase.smootherStepIn;
			case 'smootherstepinout': FlxEase.smootherStepInOut;
			case 'smootherstepout': FlxEase.smootherStepOut;
			default: FlxEase.linear;
		}
	}

	public static function blendModeFromString(blend:String):BlendMode
	{
		return switch (blend.toLowerCase().trim())
		{
			case 'add': ADD;
			case 'alpha': ALPHA;
			case 'darken': DARKEN;
			case 'difference': DIFFERENCE;
			case 'erase': ERASE;
			case 'hardlight': HARDLIGHT;
			case 'invert': INVERT;
			case 'layer': LAYER;
			case 'lighten': LIGHTEN;
			case 'multiply': MULTIPLY;
			case 'normal': NORMAL;
			case 'overlay': OVERLAY;
			case 'screen': SCREEN;
			case 'shader': SHADER;
			case 'subtract': SUBTRACT;
			default: null;
		}
	}

	public static function typeToString(type:Int):String
	{
		#if LUA_ALLOWED
		switch (type)
		{
			case Lua.LUA_TBOOLEAN:
				return "boolean";
			case Lua.LUA_TNUMBER:
				return "number";
			case Lua.LUA_TSTRING:
				return "string";
			case Lua.LUA_TTABLE:
				return "table";
			case Lua.LUA_TFUNCTION:
				return "function";
		}
		if (type <= Lua.LUA_TNIL)
			return "nil";
		#end
		return "unknown";
	}

	public static function cameraFromString(cam:String):FlxCamera
	{
		if (cam == null)
			return null;

		switch (cam.trim().toLowerCase())
		{
			case 'camgame' | 'game':
				return PlayState.instance.camGame;

			case 'camhud' | 'hud':
				return PlayState.instance.camHUD;

			case 'camother' | 'other':
				return PlayState.instance.camOther;

			case 'camcountdown' | 'countdown':
				return PlayState.instance.camCountdown;

			case 'camdialogue' | 'dialogue':
				return PlayState.instance.camDialogue;

			case 'campause' | 'pause':
				return PlayState.instance.camPause;
		}

		var camera:FlxCamera = cast MusicBeatState.getVariables().get('cam_' + cam);
		if (camera == null || !Std.isOfType(camera, FlxCamera))
			camera = FlxG.camera;

		return camera;
	}

	public static function axesFromString(axes:String):FlxAxes
	{
		return switch (axes.trim().toLowerCase())
		{
			case 'x':
				X;

			case 'y':
				Y;

			default:
				XY;
		}
	}
}
