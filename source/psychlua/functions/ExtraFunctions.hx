package psychlua.functions;

#if LUA_ALLOWED
import flixel.util.FlxSave;

//
// Things to trivialize some dumb stuff like splitting strings on older Lua
//
class ExtraFunctions
{
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;

		// ----- keyboard and gamepad ----- //

		Lua_helper.add_callback(lua, "keyboardJustPressed", function(name:String):Bool return Reflect.getProperty(FlxG.keys.justPressed, name));
		Lua_helper.add_callback(lua, "keyboardPressed", function(name:String):Bool return Reflect.getProperty(FlxG.keys.pressed, name));
		Lua_helper.add_callback(lua, "keyboardReleased", function(name:String):Bool return Reflect.getProperty(FlxG.keys.justReleased, name));

		Lua_helper.add_callback(lua, "anyGamepadJustPressed", function(name:String):Bool return FlxG.gamepads.anyJustPressed(name));
		Lua_helper.add_callback(lua, "anyGamepadPressed", function(name:String):Bool return FlxG.gamepads.anyPressed(name));
		Lua_helper.add_callback(lua, "anyGamepadReleased", function(name:String):Bool return FlxG.gamepads.anyJustReleased(name));

		Lua_helper.add_callback(lua, "gamepadAnalogX", function(id:Int, ?leftStick:Bool = true):Float
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return 0.0;

			return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		Lua_helper.add_callback(lua, "gamepadAnalogY", function(id:Int, ?leftStick:Bool = true):Float
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return 0.0;

			return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		Lua_helper.add_callback(lua, "gamepadJustPressed", function(id:Int, name:String):Bool
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return false;

			return Reflect.getProperty(controller.justPressed, name) == true;
		});
		Lua_helper.add_callback(lua, "gamepadPressed", function(id:Int, name:String):Bool
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return false;

			return Reflect.getProperty(controller.pressed, name) == true;
		});
		Lua_helper.add_callback(lua, "gamepadReleased", function(id:Int, name:String):Bool
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
				return false;

			return Reflect.getProperty(controller.justReleased, name) == true;
		});

		Lua_helper.add_callback(lua, "keyJustPressed", function(name:String = ''):Bool
		{
			name = name.trim().toLowerCase();
			return switch (name)
			{
				case 'left': PlayState.instance.controls.NOTE_LEFT_P;
				case 'down': PlayState.instance.controls.NOTE_DOWN_P;
				case 'up': PlayState.instance.controls.NOTE_UP_P;
				case 'right': PlayState.instance.controls.NOTE_RIGHT_P;
				default: PlayState.instance.controls.justPressed(name);
			}
		});
		Lua_helper.add_callback(lua, "keyPressed", function(name:String = ''):Bool
		{
			name = name.trim().toLowerCase();
			return switch (name)
			{
				case 'left': PlayState.instance.controls.NOTE_LEFT;
				case 'down': PlayState.instance.controls.NOTE_DOWN;
				case 'up': PlayState.instance.controls.NOTE_UP;
				case 'right': PlayState.instance.controls.NOTE_RIGHT;
				default: PlayState.instance.controls.pressed(name);
			}
		});
		Lua_helper.add_callback(lua, "keyReleased", function(name:String = ''):Bool
		{
			name = name.trim().toLowerCase();
			return switch (name)
			{
				case 'left': PlayState.instance.controls.NOTE_LEFT_R;
				case 'down': PlayState.instance.controls.NOTE_DOWN_R;
				case 'up': PlayState.instance.controls.NOTE_UP_R;
				case 'right': PlayState.instance.controls.NOTE_RIGHT_R;
				default: PlayState.instance.controls.justReleased(name);
			}
		});

		// ----- save data ----- //

		Lua_helper.add_callback(lua, "initSaveData", function(name:String, ?folder:String = 'psychenginemods')
		{
			var variables = MusicBeatState.getVariables();

			if (variables.exists('save_$name'))
			{
				FunkinLua.luaTrace('initSaveData: Save file already initialized: ' + name);
				return;
			}

			var save:FlxSave = new FlxSave();
			save.bind(name, folder);
			variables.set('save_$name', save);
		});
		Lua_helper.add_callback(lua, "flushSaveData", function(name:String)
		{
			var obj:Dynamic = MusicBeatState.getVariables().get('save_$name');

			if (obj == null || !Std.isOfType(obj, FlxSave))
			{
				FunkinLua.luaTrace('flushSaveData: Save file not initialized: ' + name, false, false, FlxColor.RED);
				return;
			}

			cast(obj, FlxSave).flush();
		});
		Lua_helper.add_callback(lua, "getDataFromSave", function(name:String, field:String, ?defaultValue:Dynamic):Dynamic
		{
			var obj:Dynamic = MusicBeatState.getVariables().get('save_$name');

			if (obj == null || !Std.isOfType(obj, FlxSave))
			{
				FunkinLua.luaTrace('getDataFromSave: Save file not initialized: ' + name, false, false, FlxColor.RED);
				return defaultValue;
			}

			var saveData:FlxSave = cast obj;
			if (Reflect.hasField(saveData.data, field))
				return Reflect.field(saveData.data, field);
			else
				return defaultValue;
		});
		Lua_helper.add_callback(lua, "setDataFromSave", function(name:String, field:String, value:Dynamic)
		{
			var obj:Dynamic = MusicBeatState.getVariables().get('save_$name');

			if (obj == null || !Std.isOfType(obj, FlxSave))
			{
				FunkinLua.luaTrace('setDataFromSave: Save file not initialized: ' + name, false, false, FlxColor.RED);
				return;
			}

			Reflect.setField(cast(obj, FlxSave).data, field, value);
		});
		Lua_helper.add_callback(lua, "eraseSaveData", function(name:String)
		{
			var obj:Dynamic = MusicBeatState.getVariables().get('save_$name');

			if (obj == null || !Std.isOfType(obj, FlxSave))
			{
				FunkinLua.luaTrace('eraseSaveData: Save file not initialized: ' + name, false, false, FlxColor.RED);
				return;
			}

			cast(obj, FlxSave).erase();
		});

		// ----- file management ----- //

		Lua_helper.add_callback(lua, "checkFileExists", function(filename:String, ?absolute:Bool = false)
		{
			if (absolute)
				return Assets.exists(filename);

			return Assets.exists(Paths.getPath(filename));
		});
		Lua_helper.add_callback(lua, "saveFile", function(path:String, content:String, ?absolute:Bool = false)
		{
			FunkinLua.luaTrace("saveFile: Function not available", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "deleteFile", function(path:String)
		{
			FunkinLua.luaTrace("deleteFile: Function not available", false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "getTextFromFile", function(path:String)
		{
			return Paths.getTextFromFile(path);
		});
		Lua_helper.add_callback(lua, "directoryFileList", function(folder:String)
		{
			return Assets.readDirectory(folder, false);
		});

		// ----- string tools ----- //

		Lua_helper.add_callback(lua, "stringStartsWith", function(str:String, start:String)
		{
			return str.startsWith(start);
		});
		Lua_helper.add_callback(lua, "stringEndsWith", function(str:String, end:String)
		{
			return str.endsWith(end);
		});
		Lua_helper.add_callback(lua, "stringSplit", function(str:String, split:String)
		{
			return str.split(split);
		});
		Lua_helper.add_callback(lua, "stringTrim", function(str:String)
		{
			return str.trim();
		});

		// ----- randomization ----- //

		Lua_helper.add_callback(lua, "getRandomInt", function(min:Int, max:Int = FlxMath.MAX_VALUE_INT, exclude:String = '')
		{
			return FlxG.random.int(min, max, LuaUtils.parseStringToIntArray(exclude));
		});
		Lua_helper.add_callback(lua, "getRandomFloat", function(min:Float, max:Float = 1, exclude:String = '')
		{
			return FlxG.random.float(min, max, LuaUtils.parseStringToFloatArray(exclude));
		});
		Lua_helper.add_callback(lua, "getRandomBool", function(chance:Float = 50)
		{
			return FlxG.random.bool(chance);
		});
	}
}
#end
