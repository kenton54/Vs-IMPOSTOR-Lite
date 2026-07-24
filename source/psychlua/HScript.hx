package psychlua;

#if HSCRIPT_ALLOWED
import crowplexus.hscript.Expr.Error as IrisError;
import crowplexus.hscript.Interp;
import crowplexus.hscript.Printer;
import crowplexus.iris.Iris;
import crowplexus.iris.IrisConfig;

import flixel.FlxBasic;

import haxe.ValueException;

import objects.Character;

import psychlua.CustomSubstate;
import psychlua.LuaUtils;
#if LUA_ALLOWED
import psychlua.FunkinLua;
#end

typedef HScriptInfos =
{
	> haxe.PosInfos,
	var ?functionName:String;
	var ?showLine:Bool;

	#if LUA_ALLOWED
	var ?isLua:Bool;
	#end
}

class HScript extends Iris
{
	public var filePath:String;
	public var returnValue:Dynamic;

	#if LUA_ALLOWED
	public var parentLua:FunkinLua;

	public static function initHaxeModule(parent:FunkinLua)
	{
		if (parent.hscript == null)
		{
			trace('initializing haxe interp for: ${parent.scriptName}');
			parent.hscript = new HScript(parent);
		}
	}

	public static function initHaxeModuleCode(parent:FunkinLua, code:String, varsToBring:Any = null)
	{
		var hs:HScript = try parent.hscript catch (e:Dynamic) null;
		if (hs == null)
		{
			try
			{
				parent.hscript = new HScript(parent, code, varsToBring);
			}
			catch (e:IrisError)
			{
				var pos:HScriptInfos = cast {fileName: parent.scriptName, isLua: true};
				if (parent.lastCalledFunction != "")
					pos.functionName = parent.lastCalledFunction;
				Iris.error(Printer.errorToString(e, false), pos);
				parent.hscript = null;
			}
		}
		else
		{
			try
			{
				hs.scriptCode = code;
				hs.varsToBring = varsToBring;
				hs.parse(true);
				var ret:Dynamic = hs.execute();
				hs.returnValue = ret;
			}
			catch (e:IrisError)
			{
				var pos:HScriptInfos = cast hs.interp.posInfos();
				pos.isLua = true;
				if (parent.lastCalledFunction != "")
					pos.functionName = parent.lastCalledFunction;
				Iris.error(Printer.errorToString(e, false), pos);
				hs.returnValue = null;
			}
		}
	}
	#end

	public var origin:String;

	override public function new(?parent:FunkinLua, ?file:String, ?varsToBring:Any, ?manualRun:Bool = false)
	{
		if (file == null)
			file = '';

		filePath = file;

		if (filePath.length > 0)
			origin = filePath;

		var scriptRaw:String = file;
		var scriptName:Null<String> = null;
		if (parent == null && file != null)
		{
			var filee:String = file.replace('\\', '/');
			scriptRaw = Assets.getText(filee);
			scriptName = filee;
		}

		#if LUA_ALLOWED
		if (scriptName == null && parent != null)
			scriptName = parent.scriptName;
		#end

		super(scriptRaw, new IrisConfig(scriptName, false, false));

		var customInterp:PsychInterp = new PsychInterp();
		customInterp.parentInstance = FlxG.state;
		customInterp.showPosOnLog = false;
		this.interp = customInterp;

		#if LUA_ALLOWED
		parentLua = parent;
		if (parent != null)
			this.origin = parent.scriptName;
		#end

		preset();
		this.varsToBring = varsToBring;

		if (!manualRun)
		{
			try
			{
				var ret:Dynamic = execute();
				returnValue = ret;
			}
			catch (e:IrisError)
			{
				returnValue = null;
				destroy();
				throw e;
			}
		}
	}

	var varsToBring(default, set):Any = null;

	override function preset()
	{
		super.preset();

		// Some very commonly used classes

		set('FlxG', flixel.FlxG);
		set('FlxMath', flixel.math.FlxMath);
		set('FlxPoint', flixel.math.FlxBasePoint);
		set('FlxSprite', flixel.FlxSprite);
		set('FlxCamera', flixel.FlxCamera);
		set('FlxTimer', flixel.util.FlxTimer);
		set('FlxTween', flixel.tweens.FlxTween);
		set('FlxEase', flixel.tweens.FlxEase);
		set('FlxColor', CustomFlxColor);
		set('FlxEmitter', flixel.effects.particles.FlxEmitter);
		set('FlxSkewedSprite', flixel.addons.effects.FlxSkewedSprite);
		set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
		set('Countdown', backend.BaseStage.Countdown);
		set('PlayState', PlayState);
		set('Paths', Paths);
		set('Conductor', Conductor);
		set('ClientPrefs', ClientPrefs);
		set('CoolUtil', CoolUtil);

		#if ACHIEVEMENTS_ALLOWED
		set('Achievements', Achievements);
		#end

		set('Character', Character);
		set('Alphabet', Alphabet);
		set('Note', objects.Note);
		set('SnowEmitter', objects.SnowEmitter);
		set('CustomSubstate', CustomSubstate);
		set('ShaderFilter', openfl.filters.ShaderFilter);
		set('StringTools', StringTools);

		// Functions & Variables
		set('setVar', function(name:String, value:Dynamic):Dynamic
		{
			MusicBeatState.getVariables().set(name, value);
			return value;
		});
		set('getVar', function(name:String):Dynamic
		{
			if (MusicBeatState.getVariables().exists(name))
				return MusicBeatState.getVariables().get(name);

			return null;
		});
		set('removeVar', function(name:String):Bool
		{
			if (MusicBeatState.getVariables().exists(name))
			{
				MusicBeatState.getVariables().remove(name);
				return true;
			}

			return false;
		});
		set('debugPrint', function(text:String, ?color:FlxColor)
		{
			if (color == null)
				color = FlxColor.WHITE;

			PlayState.instance.addTextToDebug(text, color);
		});

		// Keyboard & Gamepads
		set('keyboardJustPressed', function(name:String):Bool return Reflect.getProperty(FlxG.keys.justPressed, name));
		set('keyboardPressed', function(name:String):Bool return Reflect.getProperty(FlxG.keys.pressed, name));
		set('keyboardReleased', function(name:String):Bool return Reflect.getProperty(FlxG.keys.justReleased, name));

		set('anyGamepadJustPressed', function(name:String):Bool return FlxG.gamepads.anyJustPressed(name));
		set('anyGamepadPressed', function(name:String):Bool return FlxG.gamepads.anyPressed(name));
		set('anyGamepadReleased', function(name:String):Bool return FlxG.gamepads.anyJustReleased(name));

		set('gamepadAnalogX', function(id:Int, leftStick:Bool = true):Float
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return 0.0;

			return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		set('gamepadAnalogY', function(id:Int, leftStick:Bool = true):Float
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return 0.0;

			return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		set('gamepadJustPressed', function(id:Int, name:String):Bool
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return false;

			return Reflect.getProperty(controller.justPressed, name);
		});
		set('gamepadPressed', function(id:Int, name:String):Bool
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return false;

			return Reflect.getProperty(controller.pressed, name);
		});
		set('gamepadReleased', function(id:Int, name:String):Bool
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return false;

			return Reflect.getProperty(controller.justReleased, name);
		});

		set('keyJustPressed', function(name:String = ''):Bool
		{
			name = name.toLowerCase();
			return switch (name)
			{
				case 'left':
					Controls.instance.NOTE_LEFT_P;
				case 'down':
					Controls.instance.NOTE_DOWN_P;
				case 'up':
					Controls.instance.NOTE_UP_P;
				case 'right':
					Controls.instance.NOTE_RIGHT_P;
				default:
					Controls.instance.justPressed(name);
			}
		});
		set('keyPressed', function(name:String = ''):Bool
		{
			name = name.toLowerCase();
			return switch (name)
			{
				case 'left':
					Controls.instance.NOTE_LEFT;
				case 'down':
					Controls.instance.NOTE_DOWN;
				case 'up':
					Controls.instance.NOTE_UP;
				case 'right':
					Controls.instance.NOTE_RIGHT;
				default:
					Controls.instance.pressed(name);
			}
		});
		set('keyReleased', function(name:String = ''):Bool
		{
			name = name.toLowerCase();
			return switch (name)
			{
				case 'left':
					Controls.instance.NOTE_LEFT_R;
				case 'down':
					Controls.instance.NOTE_DOWN_R;
				case 'up':
					Controls.instance.NOTE_UP_R;
				case 'right':
					Controls.instance.NOTE_RIGHT_R;
				default:
					Controls.instance.justReleased(name);
			}
		});

		// For adding your own callbacks
		// not very tested but should work
		#if LUA_ALLOWED
		set('createGlobalCallback', function(name:String, func:Dynamic)
		{
			for (script in PlayState.instance.luaArray)
				if (script != null && script.lua != null && !script.closed)
					Lua_helper.add_callback(script.lua, name, func);

			FunkinLua.customFunctions.set(name, func);
		});

		set('createCallback', function(name:String, func:Dynamic, ?funk:FunkinLua = null)
		{
			if (funk == null)
				funk = parentLua;

			if (funk != null)
				funk.addLocalCallback(name, func);
			else
				Iris.error('createCallback ($name): 3rd argument is null', interp.posInfos());
		});
		#end

		set('addHaxeLibrary', function(libName:String, ?libPackage:String = '')
		{
			try
			{
				var str:String = '';
				if (libPackage.length > 0)
					str = libPackage + '.';

				set(libName, Type.resolveClass(str + libName));
			}
			catch (e:IrisError)
			{
				Iris.error(Printer.errorToString(e, false), this.interp.posInfos());
			}
		});

		#if LUA_ALLOWED
		set('parentLua', parentLua);
		#else
		set('parentLua', null);
		#end

		set('this', this);
		set('game', LuaUtils.getTargetInstance());
		set('controls', Controls.instance);

		set('buildTarget', LuaUtils.getBuildTarget());
		set('platformTarget', LuaUtils.getPlatformTarget());
		set('customSubstate', CustomSubstate.instance);
		set('customSubstateName', CustomSubstate.name);

		set('Function_Stop', LuaUtils.Function_Stop);
		set('Function_Continue', LuaUtils.Function_Continue);
		set('Function_StopLua', LuaUtils.Function_StopLua); // doesnt do much cuz HScript has a lower priority than Lua
		set('Function_StopHScript', LuaUtils.Function_StopHScript);
		set('Function_StopAll', LuaUtils.Function_StopAll);

		set('add', LuaUtils.getTargetInstance().add);
		set('insert', LuaUtils.getTargetInstance().insert);
		set('remove', LuaUtils.getTargetInstance().remove);
	}

	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua)
	{
		funk.addLocalCallback("runHaxeCode", function(codeToRun:String, ?varsToBring:Any, ?funcToRun:String, ?funcArgs:Array<Dynamic>):Dynamic
		{
			initHaxeModuleCode(funk, codeToRun, varsToBring);
			if (funk.hscript != null)
			{
				final retVal:IrisCall = funk.hscript.call(funcToRun, funcArgs);
				if (retVal != null)
				{
					return LuaUtils.isLuaSupported(retVal.returnValue) ? retVal.returnValue : null;
				}
				else if (funk.hscript.returnValue != null)
				{
					return funk.hscript.returnValue;
				}
			}

			return null;
		});

		funk.addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic>):Dynamic
		{
			if (funk.hscript != null)
			{
				final retVal:IrisCall = funk.hscript.call(funcToRun, funcArgs);
				if (retVal != null)
				{
					return LuaUtils.isLuaSupported(retVal.returnValue) ? retVal.returnValue : null;
				}
			}
			else
			{
				var pos:HScriptInfos = cast {fileName: funk.scriptName, showLine: false};
				if (funk.lastCalledFunction != '')
					pos.functionName = funk.lastCalledFunction;

				Iris.error("runHaxeFunction: HScript has not been initialized yet! Use \"runHaxeCode\" to initialize it", pos);
			}

			return null;
		});
		// This function is unnecessary because import already exists in SScript as a native feature
		funk.addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = '')
		{
			var str:String = '';
			if (libPackage.length > 0)
				str = libPackage + '.';
			else if (libName == null)
				libName = '';

			var c:Dynamic = Type.resolveClass(str + libName);
			if (c == null)
				c = Type.resolveEnum(str + libName);

			if (funk.hscript == null)
				initHaxeModule(funk);

			var pos:HScriptInfos = cast funk.hscript.interp.posInfos();
			pos.showLine = false;
			if (funk.lastCalledFunction != '')
				pos.functionName = funk.lastCalledFunction;

			try
			{
				if (c != null)
					funk.hscript.set(libName, c);
			}
			catch (e:IrisError)
			{
				Iris.error(Printer.errorToString(e, false), pos);
			}
			FunkinLua.lastCalledScript = funk;

			if (FunkinLua.getBool('luaDebugMode') && FunkinLua.getBool('luaDeprecatedWarnings'))
				Iris.warn("addHaxeLibrary is deprecated! Import classes through \"import\" in HScript!", pos);
		});
	}
	#end

	override function call(funcToRun:String, ?args:Array<Dynamic>):IrisCall
	{
		if (funcToRun == null || interp == null)
			return null;

		if (!exists(funcToRun))
		{
			Iris.error('No function named: $funcToRun', this.interp.posInfos());
			return null;
		}

		try
		{
			var func:Dynamic = interp.variables.get(funcToRun); // function signature
			final ret = Reflect.callMethod(null, func, args ?? []);
			return {funName: funcToRun, signature: func, returnValue: ret};
		}
		catch (e:IrisError)
		{
			var pos:HScriptInfos = cast this.interp.posInfos();
			pos.functionName = funcToRun;

			#if LUA_ALLOWED
			if (parentLua != null)
			{
				pos.isLua = true;
				if (parentLua.lastCalledFunction != '')
					pos.functionName = parentLua.lastCalledFunction;
			}
			#end

			Iris.error(Printer.errorToString(e, false), pos);
		}
		catch (e:ValueException)
		{
			var pos:HScriptInfos = cast this.interp.posInfos();
			pos.functionName = funcToRun;
			#if LUA_ALLOWED
			if (parentLua != null)
			{
				pos.isLua = true;
				if (parentLua.lastCalledFunction != '')
					pos.functionName = parentLua.lastCalledFunction;
			}
			#end
			Iris.error('$e', pos);
		}
		return null;
	}

	override public function destroy()
	{
		origin = null;

		#if LUA_ALLOWED
		parentLua = null;
		#end

		super.destroy();
	}

	function set_varsToBring(values:Any)
	{
		if (varsToBring != null)
			for (key in Reflect.fields(varsToBring))
				if (exists(key.trim()))
					interp.variables.remove(key.trim());

		if (values != null)
		{
			for (key in Reflect.fields(values))
			{
				key = key.trim();
				set(key, Reflect.field(values, key));
			}
		}

		return varsToBring = values;
	}
}

class PsychInterp extends Interp
{
	public var parentInstance(default, set):Dynamic = [];

	private var _instanceFields:Array<String>;

	function set_parentInstance(inst:Dynamic):Dynamic
	{
		parentInstance = inst;
		if (parentInstance == null)
		{
			_instanceFields = [];
			return inst;
		}
		_instanceFields = Type.getInstanceFields(Type.getClass(inst));
		return inst;
	}

	public function new()
	{
		super();
	}

	override function fcall(o:Dynamic, funcToRun:String, args:Array<Dynamic>):Dynamic
	{
		for (_using in usings)
		{
			var v = _using.call(o, funcToRun, args);
			if (v != null)
				return v;
		}

		var f = get(o, funcToRun);

		if (f == null)
		{
			Iris.error('Tried to call null function $funcToRun', posInfos());
			return null;
		}

		return Reflect.callMethod(o, f, args);
	}

	override function resolve(id:String):Dynamic
	{
		if (locals.exists(id))
		{
			var l = locals.get(id);
			return l.r;
		}

		if (variables.exists(id))
		{
			var v = variables.get(id);
			return v;
		}

		if (imports.exists(id))
		{
			var v = imports.get(id);
			return v;
		}

		if (parentInstance != null && _instanceFields.contains(id))
		{
			var v = Reflect.getProperty(parentInstance, id);
			return v;
		}

		error(EUnknownVariable(id));

		return null;
	}
}

class CustomFlxColor
{
	public static var TRANSPARENT(default, null):Int = FlxColor.TRANSPARENT;
	public static var BLACK(default, null):Int = FlxColor.BLACK;
	public static var WHITE(default, null):Int = FlxColor.WHITE;
	public static var GRAY(default, null):Int = FlxColor.GRAY;

	public static var GREEN(default, null):Int = FlxColor.GREEN;
	public static var LIME(default, null):Int = FlxColor.LIME;
	public static var YELLOW(default, null):Int = FlxColor.YELLOW;
	public static var ORANGE(default, null):Int = FlxColor.ORANGE;
	public static var RED(default, null):Int = FlxColor.RED;
	public static var PURPLE(default, null):Int = FlxColor.PURPLE;
	public static var BLUE(default, null):Int = FlxColor.BLUE;
	public static var BROWN(default, null):Int = FlxColor.BROWN;
	public static var PINK(default, null):Int = FlxColor.PINK;
	public static var MAGENTA(default, null):Int = FlxColor.MAGENTA;
	public static var CYAN(default, null):Int = FlxColor.CYAN;

	public static function fromInt(Value:Int):Int
		return cast FlxColor.fromInt(Value);

	public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Int
		return cast FlxColor.fromRGB(Red, Green, Blue, Alpha);

	public static function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Int
		return cast FlxColor.fromRGBFloat(Red, Green, Blue, Alpha);

	public static inline function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):Int
		return cast FlxColor.fromCMYK(Cyan, Magenta, Yellow, Black, Alpha);

	public static function fromHSB(Hue:Float, Sat:Float, Brt:Float, Alpha:Float = 1):Int
		return cast FlxColor.fromHSB(Hue, Sat, Brt, Alpha);

	public static function fromHSL(Hue:Float, Sat:Float, Light:Float, Alpha:Float = 1):Int
		return cast FlxColor.fromHSL(Hue, Sat, Light, Alpha);

	public static function fromString(str:String):Int
		return cast FlxColor.fromString(str);
}
#end
