package psychlua.functions;

#if LUA_ALLOWED
import flixel.FlxBasic;

import psychlua.functions.SpriteFunctions;

/**
 * This is simply to store deprecated lua functions for backwards compatibility.
 */
@:access(psychlua.functions.SpriteFunctions)
class DeprecatedFunctions
{
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;

		// DEPRECATED, DONT MESS WITH THESE SHITS, ITS JUST THERE FOR BACKWARD COMPATIBILITY
		Lua_helper.add_callback(lua, "addAnimationByIndicesLoop", function(tag:String, name:String, prefix:String, indices:String, framerate:Int = 24):Bool
		{
			FunkinLua.luaTrace("addAnimationByIndicesLoop is deprecated! Use addAnimationByIndices instead", false, true);
			return LuaUtils.addAnimDynamic(tag, name, prefix, indices, framerate, true);
		});

		Lua_helper.add_callback(lua, "objectPlayAnimation", function(tag:String, name:String, forced:Bool = false, ?startFrame:Int = 0):Bool
		{
			FunkinLua.luaTrace("objectPlayAnimation is deprecated! Use playAnim instead", false, true);

			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null || Std.isOfType(basic, FlxSprite))
				return false;

			cast(basic, FlxSprite).animation.play(name, forced, false, startFrame);
			return true;
		});
		Lua_helper.add_callback(lua, "characterPlayAnim", function(character:String, anim:String, ?forced:Bool = false)
		{
			FunkinLua.luaTrace("characterPlayAnim is deprecated! Use playAnim instead", false, true);

			if (PlayState.instance == null)
				return;

			switch (character.toLowerCase())
			{
				case 'dad':
					PlayState.instance.dad.playAnim(anim, forced);
				case 'gf' | 'girlfriend':
					if (PlayState.instance.gf != null)
						PlayState.instance.gf.playAnim(anim, forced);
				default:
					PlayState.instance.boyfriend.playAnim(anim, forced);
			}
		});
		Lua_helper.add_callback(lua, "luaSpriteMakeGraphic", function(tag:String, width:Int, height:Int, color:String)
		{
			FunkinLua.luaTrace("luaSpriteMakeGraphic is deprecated! Use makeGraphic instead", false, true);

			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null || !Std.isOfType(basic, FlxSprite))
				return;

			cast(basic, FlxSprite).makeGraphic(width, height, CoolUtil.colorFromString(color));
		});
		Lua_helper.add_callback(lua, "luaSpriteAddAnimationByPrefix", function(tag:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true):Bool
		{
			FunkinLua.luaTrace("luaSpriteAddAnimationByPrefix is deprecated! Use addAnimationByPrefix instead", false, true);
			return LuaUtils.addAnimDynamic(tag, name, prefix, null, framerate, loop);
		});
		Lua_helper.add_callback(lua, "luaSpriteAddAnimationByIndices", function(tag:String, name:String, prefix:String, indices:String, framerate:Int = 24):Bool
		{
			FunkinLua.luaTrace("luaSpriteAddAnimationByIndices is deprecated! Use addAnimationByIndices instead", false, true);
			return LuaUtils.addAnimDynamic(tag, name, prefix, indices, framerate);
		});
		Lua_helper.add_callback(lua, "luaSpritePlayAnimation", function(tag:String, name:String, forced:Bool = false)
		{
			FunkinLua.luaTrace("luaSpritePlayAnimation is deprecated! Use playAnim instead", false, true);
			SpriteFunctions.luaPlayAnim(tag, name, forced);
		});
		Lua_helper.add_callback(lua, "setLuaSpriteCamera", function(tag:String, camera:String = ''):Bool
		{
			FunkinLua.luaTrace("setLuaSpriteCamera is deprecated! Use setObjectCamera instead", false, true);

			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null)
			{
				FunkinLua.luaTrace("Lua sprite with tag: " + tag + " doesn't exist!");
				return false;
			}

			basic.camera = LuaUtils.cameraFromString(camera);
			return true;
		});
		Lua_helper.add_callback(lua, "setLuaSpriteScrollFactor", function(tag:String, scrollX:Float, scrollY:Float):Bool
		{
			FunkinLua.luaTrace("setLuaSpriteScrollFactor is deprecated! Use setScrollFactor instead", false, true);

			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null || !Std.isOfType(basic, FlxSprite))
				return false;

			cast(basic, FlxSprite).scrollFactor.set(scrollX, scrollY);
			return true;
		});
		Lua_helper.add_callback(lua, "scaleLuaSprite", function(tag:String, x:Float, y:Float):Bool
		{
			FunkinLua.luaTrace("scaleLuaSprite is deprecated! Use scaleObject instead", false, true);

			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null || !Std.isOfType(basic, FlxSprite))
				return false;

			var spr:FlxSprite = cast basic;
			spr.scale.set(x, y);
			spr.updateHitbox();
			return true;
		});
		Lua_helper.add_callback(lua, "getPropertyLuaSprite", function(tag:String, variable:String):Dynamic
		{
			FunkinLua.luaTrace("getPropertyLuaSprite is deprecated! Use getProperty instead", false, true);

			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null)
				return null;

			var split:Array<String> = variable.split('.');
			if (split.length > 1)
			{
				var iVal:Dynamic = Reflect.getProperty(basic, split[0]);
				for (i in 1...split.length)
					iVal = Reflect.getProperty(iVal, split[i]);

				return iVal;
			}

			return Reflect.getProperty(basic, variable);
		});
		Lua_helper.add_callback(lua, "setPropertyLuaSprite", function(tag:String, variable:String, value:Dynamic):Bool
		{
			FunkinLua.luaTrace("setPropertyLuaSprite is deprecated! Use setProperty instead", false, true);

			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null)
			{
				FunkinLua.luaTrace("setPropertyLuaSprite: Lua sprite with tag: " + tag + " doesn't exist!");
				return false;
			}

			var split:Array<String> = variable.split('.');
			if (split.length > 1)
			{
				var iVal:Dynamic = Reflect.getProperty(basic, split[0]);
				for (i in 1...split.length)
					iVal = Reflect.getProperty(iVal, split[i]);

				Reflect.setProperty(iVal, split[split.length - 1], value);
				return true;
			}

			Reflect.setProperty(basic, variable, value);
			return true;
		});
		Lua_helper.add_callback(lua, "musicFadeIn", function(duration:Float, fromValue:Float = 0, toValue:Float = 1)
		{
			FunkinLua.luaTrace('musicFadeIn is deprecated! Use soundFadeIn instead.', false, true);
			FlxG.sound.music.fadeIn(duration, fromValue, toValue);
		});
		Lua_helper.add_callback(lua, "musicFadeOut", function(duration:Float, toValue:Float = 0)
		{
			FunkinLua.luaTrace('musicFadeOut is deprecated! Use soundFadeOut instead.', false, true);
			FlxG.sound.music.fadeOut(duration, toValue);
		});
		Lua_helper.add_callback(lua, "updateHitboxFromGroup", function(group:String, index:Int)
		{
			FunkinLua.luaTrace('updateHitboxFromGroup is deprecated! Use updateHitbox instead.', false, true);

			if (Std.isOfType(Reflect.getProperty(LuaUtils.getTargetInstance(), group), FlxTypedGroup))
				Reflect.getProperty(LuaUtils.getTargetInstance(), group).members[index].updateHitbox();
			else
				Reflect.getProperty(LuaUtils.getTargetInstance(), group)[index].updateHitbox();
		});
	}
}
#end
