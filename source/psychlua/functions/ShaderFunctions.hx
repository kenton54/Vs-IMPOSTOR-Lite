package psychlua.functions;

#if LUA_ALLOWED
import backend.FunkinRuntimeShader;

import flixel.FlxBasic;

class ShaderFunctions
{
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;

		// ----- shader creation ----- //

		funk.addLocalCallback("initLuaShader", function(name:String, ?glslVersion:Int = 120):Bool
		{
			if (!ClientPrefs.data.shaders)
				return false;

			return funk.initLuaShader(name, glslVersion);
		});
		funk.addLocalCallback("setSpriteShader", function(tag:String, shader:String):Bool
		{
			if (!ClientPrefs.data.shaders)
				return false;

			if (!funk.runtimeShaders.exists(shader) && !funk.initLuaShader(shader))
			{
				FunkinLua.luaTrace('setSpriteShader: Shader $shader is missing!', false, false, FlxColor.RED);
				return false;
			}

			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null || !Std.isOfType(basic, FlxSprite))
				return false;

			var data = funk.runtimeShaders.get(shader);
			cast(basic, FlxSprite).shader = new FunkinRuntimeShader(data.frag, data.vert, data.glslVersion);
			return true;
		});
		Lua_helper.add_callback(lua, "removeSpriteShader", function(tag:String):Bool
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null || !Std.isOfType(basic, FlxSprite))
				return false;

			cast(basic, FlxSprite).shader = null;
			return true;
		});

		// ----- shader modification ----- //

		Lua_helper.add_callback(lua, "getShaderBool", function(tag:String, prop:String):Bool
		{
			var shader:FunkinRuntimeShader = getShader(tag);

			if (shader == null)
			{
				FunkinLua.luaTrace("getShaderBool: Shader is not FunkinRuntimeShader!", false, false, FlxColor.RED);
				return false;
			}

			return shader.getBool(prop);
		});
		Lua_helper.add_callback(lua, "getShaderBoolArray", function(tag:String, prop:String):Array<Bool>
		{
			var shader:FunkinRuntimeShader = getShader(tag);

			if (shader == null)
			{
				FunkinLua.luaTrace("getShaderBoolArray: Shader is not FunkinRuntimeShader!", false, false, FlxColor.RED);
				return [];
			}

			return shader.getBoolArray(prop);
		});
		Lua_helper.add_callback(lua, "getShaderInt", function(tag:String, prop:String):Int
		{
			var shader:FunkinRuntimeShader = getShader(tag);

			if (shader == null)
			{
				FunkinLua.luaTrace("getShaderInt: Shader is not FunkinRuntimeShader!", false, false, FlxColor.RED);
				return 0;
			}

			return shader.getInt(prop);
		});
		Lua_helper.add_callback(lua, "getShaderIntArray", function(tag:String, prop:String):Array<Int>
		{
			var shader:FunkinRuntimeShader = getShader(tag);

			if (shader == null)
			{
				FunkinLua.luaTrace("getShaderIntArray: Shader is not FunkinRuntimeShader!", false, false, FlxColor.RED);
				return [];
			}

			return shader.getIntArray(prop);
		});
		Lua_helper.add_callback(lua, "getShaderFloat", function(tag:String, prop:String):Float
		{
			var shader:FunkinRuntimeShader = getShader(tag);

			if (shader == null)
			{
				FunkinLua.luaTrace("getShaderFloat: Shader is not FunkinRuntimeShader!", false, false, FlxColor.RED);
				return 0;
			}

			return shader.getFloat(prop);
		});
		Lua_helper.add_callback(lua, "getShaderFloatArray", function(tag:String, prop:String):Array<Float>
		{
			var shader:FunkinRuntimeShader = getShader(tag);

			if (shader == null)
			{
				FunkinLua.luaTrace("getShaderFloatArray: Shader is not FunkinRuntimeShader!", false, false, FlxColor.RED);
				return [];
			}

			return shader.getFloatArray(prop);
		});

		Lua_helper.add_callback(lua, "setShaderBool", function(tag:String, prop:String, value:Bool):Bool
		{
			var shader:FunkinRuntimeShader = getShader(tag);

			if (shader == null)
			{
				FunkinLua.luaTrace("setShaderBool: Shader is not FunkinRuntimeShader!", false, false, FlxColor.RED);
				return false;
			}

			shader.setBool(prop, value);
			return true;
		});
		Lua_helper.add_callback(lua, "setShaderBoolArray", function(tag:String, prop:String, values:Array<Bool>):Bool
		{
			var shader:FunkinRuntimeShader = getShader(tag);

			if (shader == null)
			{
				FunkinLua.luaTrace("setShaderBoolArray: Shader is not FunkinRuntimeShader!", false, false, FlxColor.RED);
				return false;
			}

			shader.setBoolArray(prop, values);
			return true;
		});
		Lua_helper.add_callback(lua, "setShaderInt", function(tag:String, prop:String, value:Int):Bool
		{
			var shader:FunkinRuntimeShader = getShader(tag);

			if (shader == null)
			{
				FunkinLua.luaTrace("setShaderInt: Shader is not FunkinRuntimeShader!", false, false, FlxColor.RED);
				return false;
			}

			shader.setInt(prop, value);
			return true;
		});
		Lua_helper.add_callback(lua, "setShaderIntArray", function(tag:String, prop:String, values:Array<Int>):Bool
		{
			var shader:FunkinRuntimeShader = getShader(tag);

			if (shader == null)
			{
				FunkinLua.luaTrace("setShaderIntArray: Shader is not FunkinRuntimeShader!", false, false, FlxColor.RED);
				return false;
			}

			shader.setIntArray(prop, values);
			return true;
		});
		Lua_helper.add_callback(lua, "setShaderFloat", function(tag:String, prop:String, value:Float):Bool
		{
			var shader:FunkinRuntimeShader = getShader(tag);

			if (shader == null)
			{
				FunkinLua.luaTrace("setShaderFloat: Shader is not FunkinRuntimeShader!", false, false, FlxColor.RED);
				return false;
			}

			shader.setFloat(prop, value);
			return true;
		});
		Lua_helper.add_callback(lua, "setShaderFloatArray", function(tag:String, prop:String, values:Array<Float>):Bool
		{
			var shader:FunkinRuntimeShader = getShader(tag);

			if (shader == null)
			{
				FunkinLua.luaTrace("setShaderFloatArray: Shader is not FunkinRuntimeShader!", false, false, FlxColor.RED);
				return false;
			}

			shader.setFloatArray(prop, values);
			return true;
		});

		Lua_helper.add_callback(lua, "setShaderSampler2D", function(tag:String, prop:String, bitmapDataPath:String):Bool
		{
			var shader:FunkinRuntimeShader = getShader(tag);

			if (shader == null)
			{
				FunkinLua.luaTrace("setShaderSampler2D: Shader is not FunkinRuntimeShader!", false, false, FlxColor.RED);
				return false;
			}

			var graphic = Paths.image(bitmapDataPath);
			if (graphic != null && graphic.bitmap != null)
			{
				shader.setSampler2D(prop, graphic.bitmap);
				return true;
			}

			return false;
		});
	}

	public static function getShader(tag:String):FunkinRuntimeShader
	{
		var basic:FlxBasic = LuaUtils.getObject(tag);

		if (basic == null || !Std.isOfType(basic, FlxSprite))
		{
			FunkinLua.luaTrace('Error on getting shader: Object $tag not found', false, false, FlxColor.RED);
			return null;
		}

		var spr:FlxSprite = cast basic;

		if (spr.shader == null)
		{
			FunkinLua.luaTrace('The object $tag doesn\'t have an active shader', false, false, FlxColor.RED);
			return null;
		}

		return cast(spr.shader, FunkinRuntimeShader);
	}
}
#end
