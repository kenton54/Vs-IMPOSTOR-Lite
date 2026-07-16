package psychlua.functions;

#if LUA_ALLOWED
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.util.typeLimit.OneOfTwo;

import substates.GameOverSubstate;

class SpriteFunctions
{
	@:access(flixel.group.FlxTypedGroup)
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;

		// ----- sprite creation ----- //

		Lua_helper.add_callback(lua, "makeLuaSprite", function(tag:String, image:String = null, x:Float = 0, y:Float = 0)
		{
			makeLuaSprite(tag, x, y, image);
		});
		Lua_helper.add_callback(lua, "makeAnimatedLuaSprite", function(tag:String, image:String = null, x:Float = 0, y:Float = 0, spriteType:String = "auto")
		{
			makeLuaSprite(tag, x, y, image, spriteType);
		});
		Lua_helper.add_callback(lua, "loadGraphic", function(tag:String, image:String, ?gridX:Int = 0, ?gridY:Int = 0)
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if ((basic == null || !Std.isOfType(basic, FlxSprite)) && image != null && image.length > 0)
				return;

			var animated:Bool = gridX > 0 || gridY > 0;
			cast(basic, FlxSprite).loadGraphic(Paths.image(image), animated, gridX, gridY);
		});
		Lua_helper.add_callback(lua, "loadFrames", function(tag:String, image:String, spriteType:String = "sparrow")
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if ((basic == null || !Std.isOfType(basic, FlxSprite)) && image != null && image.length > 0)
				return;

			LuaUtils.loadFrames(cast basic, image, spriteType);
		});
		Lua_helper.add_callback(lua, "loadMultipleFrames", function(tag:String, images:Array<String>)
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if ((basic == null || !Std.isOfType(basic, FlxSprite)) && images != null && images.length > 0)
				return;

			cast(basic, FlxSprite).frames = Paths.getMultiAtlas(images);
		});
		Lua_helper.add_callback(lua, "makeGraphic", function(tag:String, width:Int = 256, height:Int = 256, color:String = 'FFFFFF')
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null || !Std.isOfType(basic, FlxSprite))
				return;

			cast(basic, FlxSprite).makeGraphic(width, height, CoolUtil.colorFromString(color));
		});
		Lua_helper.add_callback(lua, "makeSolid", function(tag:String, width:Int = 256, height:Int = 256, color:String = 'FFFFFF')
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null)
				return;

			if (Std.isOfType(basic, FlxSprite))
			{
				var spr:FlxSprite = cast basic;

				spr.makeGraphic(1, 1, CoolUtil.colorFromString(color));
				spr.scale.set(width, height);
				spr.updateHitbox();
			}
		});

		// ----- animations ----- //

		Lua_helper.add_callback(lua, "addAnimationByPrefix", function(tag:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true, flipX:Bool = false, flipY:Bool = false):Bool
		{
			return LuaUtils.addAnimDynamic(tag, name, prefix, null, framerate, loop, flipX, flipY);
		});
		Lua_helper.add_callback(lua, "addAnimation", function(tag:String, name:String, frames:Array<Int>, framerate:Int = 24, loop:Bool = true, flipX:Bool = false, flipY:Bool = false):Bool
		{
			return LuaUtils.addAnimDynamic(tag, name, null, frames, framerate, loop, flipX, flipY);
		});
		Lua_helper.add_callback(lua, "addAnimationByIndices", function(tag:String, name:String, prefix:String, indices:Any, framerate:Int = 24, loop:Bool = false, flipX:Bool = false, flipY:Bool = false):Bool
		{
			return LuaUtils.addAnimDynamic(tag, name, prefix, indices, framerate, loop, flipX, flipY);
		});
		Lua_helper.add_callback(lua, "playAnim", function(tag:String, name:String, forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0):Bool
		{
			return luaPlayAnim(tag, name, forced, reverse, startFrame);
		});
		Lua_helper.add_callback(lua, "addOffset", function(tag:String, anim:String, x:Float, y:Float):Bool
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null || !Std.isOfType(basic, ModchartSprite))
				return false;

			cast(basic, ModchartSprite).addOffset(anim, x, y);

			return true;
		});

		// ----- sprite modification ----- //

		Lua_helper.add_callback(lua, "setScrollFactor", function(tag:String, scrollX:Float, scrollY:Float)
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null || !Std.isOfType(basic, FlxSprite))
				return;

			cast(basic, FlxSprite).scrollFactor.set(scrollX, scrollY);
		});
		Lua_helper.add_callback(lua, "setGraphicSize", function(tag:String, x:Float, ?y:Float, updateHitbox:Bool = true)
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic != null && Std.isOfType(basic, FlxSprite))
			{
				var spr:FlxSprite = cast basic;

				if (y == null)
					y = x;

				spr.setGraphicSize(x, y);

				if (updateHitbox)
					spr.updateHitbox();

				return;
			}

			FunkinLua.luaTrace('setGraphicSize: Couldnt find object: $tag', false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "scaleObject", function(tag:String, x:Float, ?y:Float, updateHitbox:Bool = true)
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic != null && Std.isOfType(basic, FlxSprite))
			{
				var spr:FlxSprite = cast basic;

				if (y == null)
					y = x;

				spr.scale.set(x, y);

				if (updateHitbox)
					spr.updateHitbox();

				return;
			}

			FunkinLua.luaTrace('scaleObject: Couldnt find object: $tag', false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "updateHitbox", function(tag:String)
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic != null && Std.isOfType(basic, FlxSprite))
			{
				cast(basic, FlxSprite).updateHitbox();
				return;
			}

			FunkinLua.luaTrace('updateHitbox: Couldnt find object: $tag', false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "setBlendMode", function(tag:String, blend:String = '')
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic != null && Std.isOfType(basic, FlxSprite))
			{
				cast(basic, FlxSprite).blend = LuaUtils.blendModeFromString(blend);
				return;
			}

			FunkinLua.luaTrace('setBlendMode: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
		});

		// --- sprite addition --- //

		Lua_helper.add_callback(lua, "addLuaSprite", function(tag:String, inFront:Bool = false)
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null)
				return;

			var instance:FlxState = LuaUtils.getTargetInstance();

			if (inFront)
				instance.add(basic);
			else if ((instance is PlayState) || (instance is GameOverSubstate))
			{
				if (instance is PlayState)
					instance.insert(instance.members.indexOf(LuaUtils.getLowestCharacterGroup()), basic);
				else
					instance.insert(instance.members.indexOf(cast(instance, GameOverSubstate).boyfriend), basic);
			}
		});
		Lua_helper.add_callback(lua, "insertLuaSprite", function(tag:String, position:Int)
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null)
				return;

			LuaUtils.getTargetInstance().insert(position, basic);
		});
		Lua_helper.add_callback(lua, "removeLuaSprite", function(tag:String, destroy:Bool = true, ?group:String = null)
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null)
				return;

			var groupObj:FlxGroup = null;

			if (group == null)
				groupObj = LuaUtils.getTargetInstance();
			else
				groupObj = FlxTypedGroup.resolveGroup(LuaUtils.getObject(group));

			if (groupObj != null)
				groupObj.remove(basic, true);

			if (destroy)
			{
				MusicBeatState.getVariables().remove(tag);
				basic.destroy();
			}
		});

		// --- helper functions --- //

		Lua_helper.add_callback(lua, "getMidpointX", function(tag:String):Float
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null)
				return 0;

			if (Std.isOfType(basic, FlxObject))
			{
				var obj:FlxObject = cast basic;
				return obj.x + obj.width / 2;
			}

			return 0;
		});
		Lua_helper.add_callback(lua, "getMidpointY", function(tag:String):Float
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null)
				return 0;

			if (Std.isOfType(basic, FlxObject))
			{
				var obj:FlxObject = cast basic;
				return obj.y + obj.height / 2;
			}

			return 0;
		});
		Lua_helper.add_callback(lua, "getGraphicMidpointX", function(tag:String):Float
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null)
				return 0;

			if (Std.isOfType(basic, FlxSprite))
			{
				var spr:FlxSprite = cast basic;

				var point:FlxPoint = spr.getGraphicMidpoint();
				var result:Float = point.x;
				point.put();

				return result;
			}

			return 0;
		});
		Lua_helper.add_callback(lua, "getGraphicMidpointY", function(tag:String):Float
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null)
				return 0;

			if (Std.isOfType(basic, FlxSprite))
			{
				var spr:FlxSprite = cast basic;

				var point:FlxPoint = spr.getGraphicMidpoint();
				var result:Float = point.y;
				point.put();

				return result;
			}

			return 0;
		});
		Lua_helper.add_callback(lua, "getScreenPositionX", function(tag:String, ?camera:String):Float
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null)
				return 0;

			if (Std.isOfType(basic, FlxObject))
			{
				var obj:FlxObject = cast basic;

				var point:FlxPoint = obj.getScreenPosition(null, LuaUtils.cameraFromString(camera));
				var result:Float = point.x;
				point.put();

				return result;
			}

			return 0;
		});
		Lua_helper.add_callback(lua, "getScreenPositionY", function(tag:String, ?camera:String):Float
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null)
				return 0;

			if (Std.isOfType(basic, FlxObject))
			{
				var obj:FlxObject = cast basic;

				var point:FlxPoint = obj.getScreenPosition(null, LuaUtils.cameraFromString(camera));
				var result:Float = point.x;
				point.put();

				return result;
			}

			return 0;
		});
		Lua_helper.add_callback(lua, "screenCenter", function(tag:String, pos:String = 'xy')
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic == null || !Std.isOfType(basic, FlxObject))
			{
				FunkinLua.luaTrace('screenCenter: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
				return;
			}

			cast(basic, FlxObject).screenCenter(LuaUtils.axesFromString(pos));
		});
		Lua_helper.add_callback(lua, "getObjectOrder", function(tag:String, ?group:String = null):Int
		{
			var basic:FlxBasic = LuaUtils.getObjectDirectly(tag);

			if (basic == null)
			{
				FunkinLua.luaTrace('getObjectOrder: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
				return -1;
			}

			var instance:FlxState = LuaUtils.getTargetInstance();

			if (group != null)
			{
				var groupOrArray:OneOfTwo<Array<FlxBasic>, FlxGroup> = Reflect.getProperty(instance, group);
				if (groupOrArray == null)
				{
					FunkinLua.luaTrace('getObjectOrder: Group $group doesn\'t exist!', false, false, FlxColor.RED);
					return -1;
				}

				switch (Type.typeof(groupOrArray))
				{
					case TClass(Array): // Is Array
						var arr:Array<FlxBasic> = cast groupOrArray;
						return arr.indexOf(basic);

					default: // Is Group
						var grp:FlxGroup = FlxTypedGroup.resolveGroup(cast groupOrArray);
						return grp != null ? grp.members.indexOf(basic) : -1;
				}
			}

			var state:FlxState = CustomSubstate.instance != null ? CustomSubstate.instance : instance;
			return state.members.indexOf(basic);
		});
		Lua_helper.add_callback(lua, "setObjectOrder", function(tag:String, position:Int, ?group:String = null)
		{
			var basic:FlxBasic = LuaUtils.getObjectDirectly(tag);

			if (basic == null)
			{
				FunkinLua.luaTrace('setObjectOrder: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
				return;
			}

			var instance:FlxState = LuaUtils.getTargetInstance();

			if (group != null)
			{
				var groupOrArray:OneOfTwo<Array<FlxBasic>, FlxGroup> = Reflect.getProperty(instance, group);
				if (groupOrArray != null)
				{
					switch (Type.typeof(groupOrArray))
					{
						case TClass(Array): // Is Array
							var arr:Array<FlxBasic> = cast groupOrArray;
							arr.remove(basic);
							arr.insert(position, basic);

						default: // Is Group
							var grp:FlxGroup = FlxTypedGroup.resolveGroup(cast groupOrArray);
							if (grp != null)
							{
								grp.remove(basic, true);
								grp.insert(position, basic);
							}
					}
				}
				else
					FunkinLua.luaTrace('setObjectOrder: Group $group doesn\'t exist!', false, false, FlxColor.RED);

				return;
			}

			var state:FlxState = CustomSubstate.instance != null ? CustomSubstate.instance : instance;
			state.remove(basic, true);
			state.insert(position, basic);
		});
		Lua_helper.add_callback(lua, "getPixelColor", function(tag:String, x:Int, y:Int):FlxColor
		{
			var basic:FlxBasic = LuaUtils.getObject(tag);

			if (basic != null && Std.isOfType(basic, FlxSprite))
			{
				return cast(basic, FlxSprite).pixels.getPixel32(x, y);
			}

			return FlxColor.BLACK;
		});
		Lua_helper.add_callback(lua, "objectsOverlap", function(tag1:String, tag2:String):Bool
		{
			var basic1:FlxBasic = LuaUtils.getObject(tag1);
			var basic2:FlxBasic = LuaUtils.getObject(tag2);

			if (basic1 == null || basic2 == null || !Std.isOfType(basic1, FlxObject) || !Std.isOfType(basic2, FlxObject))
				return false;

			return FlxG.overlap(cast basic1, cast basic2);
		});
		Lua_helper.add_callback(lua, "objectsCollide", function(tag1:String, tag2:String):Bool
		{
			var basic1:FlxBasic = LuaUtils.getObject(tag1);
			var basic2:FlxBasic = LuaUtils.getObject(tag2);

			if (basic1 == null || basic2 == null || !Std.isOfType(basic1, FlxObject) || !Std.isOfType(basic2, FlxObject))
				return false;

			return FlxG.collide(cast basic1, cast basic2);
		});

		Lua_helper.add_callback(lua, "luaSpriteExists", function(tag:String)
		{
			return luaObjectExists(tag, ModchartSprite);
		});
		Lua_helper.add_callback(lua, "luaTextExists", function(tag:String)
		{
			return luaObjectExists(tag, FlxText);
		});
		Lua_helper.add_callback(lua, "luaSoundExists", function(tag:String)
		{
			return luaObjectExists('sound_$tag', FlxSound);
		});
	}

	static function makeLuaSprite(tag:String, x:Float = 0, y:Float = 0, ?image:String, ?spriteType:String):ModchartSprite
	{
		tag = LuaUtils.formatVariable(tag);
		LuaUtils.destroyObject(tag);

		var sprite:ModchartSprite = new ModchartSprite(x, y);

		if (image != null && image.length > 0)
		{
			if (spriteType != null)
				LuaUtils.loadFrames(sprite, image, spriteType);
			else
				sprite.loadGraphic(Paths.image(image));
		}

		MusicBeatState.getVariables().set(tag, sprite);

		return sprite;
	}

	static function luaPlayAnim(tag:String, name:String, forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0):Bool
	{
		var basic:FlxBasic = LuaUtils.getObject(tag);

		if (basic == null || !Std.isOfType(basic, FlxSprite))
			return false;

		var spr:FlxSprite = cast basic;

		if (Std.isOfType(spr, ModchartSprite))
			cast(spr, ModchartSprite).playAnim(name, forced, reverse, startFrame);
		else
			spr.animation.play(name, forced, reverse, startFrame);

		return true;
	}

	static function luaObjectExists(tag:String, ?typeCheck:Dynamic):Bool
	{
		var obj:Dynamic = MusicBeatState.getVariables().get(tag);
		var result:Bool = obj != null;

		if (typeCheck != null)
			result = result && Std.isOfType(obj, typeCheck);

		return result;
	}
}
#end
