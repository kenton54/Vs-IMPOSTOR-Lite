package psychlua;

import Type;

import backend.StageData;

import flixel.FlxBasic;
import flixel.FlxState;
import flixel.group.FlxContainer;
import flixel.util.FlxAxes;

import objects.Character;

import openfl.display.BlendMode;

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

	public static function setVarInArray(instance:Dynamic, variable:String, value:Dynamic, allowMaps:Bool = false):Any
	{
		var splitProps:Array<String> = variable.split('[');
		if (splitProps.length > 1)
		{
			var target:Dynamic = null;
			if (MusicBeatState.getVariables().exists(splitProps[0]))
			{
				var retVal:Dynamic = MusicBeatState.getVariables().get(splitProps[0]);
				if (retVal != null)
					target = retVal;
			}
			else
				target = Reflect.getProperty(instance, splitProps[0]);

			for (i in 1...splitProps.length)
			{
				var j:Dynamic = splitProps[i].substr(0, splitProps[i].length - 1);
				if (i >= splitProps.length - 1) // Last array
					target[j] = value;
				else // Anything else
					target = target[j];
			}

			return target;
		}

		if (allowMaps && isMap(instance))
		{
			instance.set(variable, value);
			return value;
		}

		if (instance is MusicBeatState && MusicBeatState.getVariables().exists(variable))
		{
			MusicBeatState.getVariables().set(variable, value);
			return value;
		}

		Reflect.setProperty(instance, variable, value);
		return value;
	}

	public static function getVarInArray(instance:Dynamic, variable:String, allowMaps:Bool = false):Any
	{
		var splitProps:Array<String> = variable.split('[');
		if (splitProps.length > 1)
		{
			var target:Dynamic = null;
			if (MusicBeatState.getVariables().exists(splitProps[0]))
			{
				var retVal:Dynamic = MusicBeatState.getVariables().get(splitProps[0]);
				if (retVal != null)
					target = retVal;
			}
			else
				target = Reflect.getProperty(instance, splitProps[0]);

			for (i in 1...splitProps.length)
			{
				var j:Dynamic = splitProps[i].substr(0, splitProps[i].length - 1);
				target = target[j];
			}

			return target;
		}

		if (allowMaps && isMap(instance))
		{
			return instance.get(variable);
		}

		if ((instance is MusicBeatState) && MusicBeatState.getVariables().exists(variable))
		{
			var retVal:Dynamic = MusicBeatState.getVariables().get(variable);
			if (retVal != null)
				return retVal;
		}

		return Reflect.getProperty(instance, variable);
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

	public static function getPropertyLoop(split:Array<String>, ?getProperty:Bool = true, ?allowMaps:Bool = false):Dynamic
	{
		var obj:Dynamic = getObjectDirectly(split[0]);
		var end = split.length;

		if (getProperty)
			end = split.length - 1;

		for (i in 1...end)
			obj = getVarInArray(obj, split[i], allowMaps);

		return obj;
	}

	public static function getObjectDirectly(objectName:String, ?allowMaps:Bool = false):FlxBasic
	{
		switch (objectName)
		{
			case 'this' | 'instance' | 'game':
				return getTargetInstance();

			default:
				var obj:Dynamic = MusicBeatState.getVariables().get(objectName);

				if (obj == null)
					obj = getVarInArray(MusicBeatState.getState(), objectName, allowMaps);

				if (Std.isOfType(obj, FlxBasic))
					return cast obj;
		}

		return null;
	}

	public static function getObject(object:String, ?allowMaps:Bool = false):FlxBasic
	{
		var split:Array<String> = object.split('.');
		var basic:FlxBasic = getObjectDirectly(split[0], allowMaps);

		if (split.length > 1)
			basic = getVarInArray(getPropertyLoop(split), split[split.length - 1], allowMaps);

		return basic;
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
		var basic:FlxBasic = getObject(tag);

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
		var obj:FlxBasic = getObjectDirectly(obj);

		if (obj == null || !Std.isOfType(obj, FlxSprite))
			return false;

		var spr:FlxSprite = cast obj;

		var parsedIndices:Array<Int> = [];

		if (indices != null)
		{
			if (indices is String)
			{
				var indicesStr:Array<Null<Int>> = cast(indices, String).trim().split(',').map(i -> Std.parseInt(i.trim()));
				parsedIndices = indicesStr.filter(i -> i != null);
			}
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
		var tween:FlxTween = cast variables.get(tag);

		if (tween != null)
		{
			tween.cancel();
			tween.destroy();
			variables.remove(tag);
		}
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

	public static function tweenPrepare(tag:String, vars:String):FlxBasic
	{
		cancelTween(tag);
		return getObject(vars);
	}

	public static inline function formatVariable(tag:String):String
		return tag.trim().replace(' ', '_').replace('.', '');

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
