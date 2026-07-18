package psychlua.functions;

#if LUA_ALLOWED
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.util.typeLimit.OneOfTwo;

import substates.GameOverSubstate;

class SpriteFunctions
{
	static final instanceStr:String = "##PSYCHLUA_STRINGTOOBJ";

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
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if ((obj == null || !Std.isOfType(obj, FlxSprite)) && image != null && image.length > 0)
				return;

			var animated:Bool = gridX > 0 || gridY > 0;
			cast(obj, FlxSprite).loadGraphic(Paths.image(image), animated, gridX, gridY);
		});
		Lua_helper.add_callback(lua, "loadFrames", function(tag:String, image:String, spriteType:String = "auto")
		{
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if ((obj == null || !Std.isOfType(obj, FlxSprite)) && image != null && image.length > 0)
				return;

			LuaUtils.loadFrames(cast obj, image, spriteType);
		});
		Lua_helper.add_callback(lua, "loadMultipleFrames", function(tag:String, images:Array<String>)
		{
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if ((obj == null || !Std.isOfType(obj, FlxSprite)) && images != null && images.length > 0)
				return;

			cast(obj, FlxSprite).frames = Paths.getMultiAtlas(images);
		});
		Lua_helper.add_callback(lua, "makeGraphic", function(tag:String, width:Int = 256, height:Int = 256, color:String = 'FFFFFF')
		{
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj == null || !Std.isOfType(obj, FlxSprite))
				return;

			cast(obj, FlxSprite).makeGraphic(width, height, CoolUtil.colorFromString(color));
		});
		Lua_helper.add_callback(lua, "makeSolid", function(tag:String, width:Int = 256, height:Int = 256, color:String = 'FFFFFF')
		{
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj == null || !Std.isOfType(obj, FlxSprite))
				return;

			var spr:FlxSprite = cast obj;

			spr.makeGraphic(1, 1, CoolUtil.colorFromString(color));
			spr.scale.set(width, height);
			spr.updateHitbox();
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
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj == null || !Std.isOfType(obj, ModchartSprite))
				return false;

			cast(obj, ModchartSprite).addOffset(anim, x, y);

			return true;
		});

		// ----- sprite modification ----- //

		Lua_helper.add_callback(lua, "setScrollFactor", function(tag:String, scrollX:Float, scrollY:Float)
		{
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj == null || !Std.isOfType(obj, FlxSprite))
				return;

			cast(obj, FlxSprite).scrollFactor.set(scrollX, scrollY);
		});
		Lua_helper.add_callback(lua, "setGraphicSize", function(tag:String, x:Float, ?y:Float, updateHitbox:Bool = true)
		{
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj != null && Std.isOfType(obj, FlxSprite))
			{
				var spr:FlxSprite = cast obj;

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
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj != null && Std.isOfType(obj, FlxSprite))
			{
				var spr:FlxSprite = cast obj;

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
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj != null && Std.isOfType(obj, FlxSprite))
			{
				cast(obj, FlxSprite).updateHitbox();
				return;
			}

			FunkinLua.luaTrace('updateHitbox: Couldnt find object: $tag', false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "setObjectCamera", function(tag:String, camera:String = '')
		{
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj != null && Std.isOfType(obj, FlxBasic))
			{
				cast(obj, FlxBasic).cameras = [LuaUtils.cameraFromString(camera)];
				return;
			}

			FunkinLua.luaTrace('setObjectCamera: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "setBlendMode", function(tag:String, blend:String = '')
		{
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj != null && Std.isOfType(obj, FlxSprite))
			{
				cast(obj, FlxSprite).blend = LuaUtils.blendModeFromString(blend);
				return;
			}

			FunkinLua.luaTrace('setBlendMode: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
		});

		// --- sprite addition --- //

		Lua_helper.add_callback(lua, "addLuaSprite", function(tag:String, inFront:Bool = false)
		{
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj == null || !Std.isOfType(obj, FlxBasic))
				return;

			var basic:FlxBasic = cast obj;
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
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj == null || !Std.isOfType(obj, FlxBasic))
				return;

			LuaUtils.getTargetInstance().insert(position, cast obj);
		});
		Lua_helper.add_callback(lua, "removeLuaSprite", function(tag:String, destroy:Bool = true, ?group:String = null)
		{
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj == null || !Std.isOfType(obj, FlxBasic))
				return;

			var basic:FlxBasic = cast obj;
			var groupObj:FlxGroup = null;

			if (group == null)
				groupObj = LuaUtils.getTargetInstance();
			else
				groupObj = FlxTypedGroup.resolveGroup(LuaUtils.getLuaProperty(group));

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
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj == null || !Std.isOfType(obj, FlxObject))
				return 0;

			var object:FlxObject = cast obj;
			return object.x + object.width / 2;
		});
		Lua_helper.add_callback(lua, "getMidpointY", function(tag:String):Float
		{
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj == null || !Std.isOfType(obj, FlxObject))
				return 0;

			var object:FlxObject = cast obj;
			return object.y + object.height / 2;
		});
		Lua_helper.add_callback(lua, "getGraphicMidpointX", function(tag:String):Float
		{
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj == null || !Std.isOfType(obj, FlxSprite))
				return 0;

			var spr:FlxSprite = cast obj;

			var point:FlxPoint = spr.getGraphicMidpoint();
			var result:Float = point.x;
			point.put();

			return result;
		});
		Lua_helper.add_callback(lua, "getGraphicMidpointY", function(tag:String):Float
		{
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj == null || !Std.isOfType(obj, FlxSprite))
				return 0;

			var spr:FlxSprite = cast obj;

			var point:FlxPoint = spr.getGraphicMidpoint();
			var result:Float = point.y;
			point.put();

			return result;
		});
		Lua_helper.add_callback(lua, "getScreenPositionX", function(tag:String, ?camera:String):Float
		{
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj == null || !Std.isOfType(obj, FlxObject))
				return 0;

			var obj:FlxObject = cast obj;

			var point:FlxPoint = obj.getScreenPosition(null, LuaUtils.cameraFromString(camera));
			var result:Float = point.x;
			point.put();

			return result;
		});
		Lua_helper.add_callback(lua, "getScreenPositionY", function(tag:String, ?camera:String):Float
		{
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj == null || !Std.isOfType(obj, FlxObject))
				return 0;

			var obj:FlxObject = cast obj;

			var point:FlxPoint = obj.getScreenPosition(null, LuaUtils.cameraFromString(camera));
			var result:Float = point.y;
			point.put();

			return result;
		});
		Lua_helper.add_callback(lua, "screenCenter", function(tag:String, pos:String = 'xy')
		{
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj == null || !Std.isOfType(obj, FlxObject))
			{
				FunkinLua.luaTrace('screenCenter: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
				return;
			}

			cast(obj, FlxObject).screenCenter(LuaUtils.axesFromString(pos));
		});
		Lua_helper.add_callback(lua, "getObjectOrder", function(tag:String, ?group:String = null):Int
		{
			var obj:Dynamic = LuaUtils.getObject(tag);

			if (obj == null || !Std.isOfType(obj, FlxBasic))
			{
				FunkinLua.luaTrace('getObjectOrder: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
				return -1;
			}

			var basic:FlxBasic = cast obj;
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
			var obj:Dynamic = LuaUtils.getObject(tag);

			if (obj == null || !Std.isOfType(obj, FlxBasic))
			{
				FunkinLua.luaTrace('setObjectOrder: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
				return;
			}

			var basic:FlxBasic = cast obj;
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
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);

			if (obj == null || Std.isOfType(obj, FlxSprite))
				return FlxColor.BLACK;

			return cast(obj, FlxSprite).pixels.getPixel32(x, y);
		});
		Lua_helper.add_callback(lua, "setPixelColor", function(tag:String, x:Int, y:Int, color:String):FlxColor
		{
			var obj:Dynamic = LuaUtils.getLuaProperty(tag);
			var flxColor:FlxColor = CoolUtil.colorFromString(color);

			if (obj == null || Std.isOfType(obj, FlxSprite))
				return flxColor;

			cast(obj, FlxSprite).pixels.setPixel32(x, y, flxColor);
			return flxColor;
		});
		Lua_helper.add_callback(lua, "objectsOverlap", function(tag1:String, tag2:String):Bool
		{
			var obj1:Dynamic = LuaUtils.getLuaProperty(tag1);
			var obj2:Dynamic = LuaUtils.getLuaProperty(tag2);

			if (obj1 == null || obj2 == null || !Std.isOfType(obj1, FlxObject) || !Std.isOfType(obj2, FlxObject))
				return false;

			return FlxG.overlap(cast obj1, cast obj2);
		});
		Lua_helper.add_callback(lua, "objectsCollide", function(tag1:String, tag2:String):Bool
		{
			var obj1:Dynamic = LuaUtils.getLuaProperty(tag1);
			var obj2:Dynamic = LuaUtils.getLuaProperty(tag2);

			if (obj1 == null || obj2 == null || !Std.isOfType(obj1, FlxObject) || !Std.isOfType(obj2, FlxObject))
				return false;

			return FlxG.collide(cast obj1, cast obj2);
		});

		// --- custom class instances --- //

		Lua_helper.add_callback(lua, "createInstance", function(variableToSave:String, className:String, ?args:Dynamic):Bool
		{
			variableToSave = LuaUtils.formatVariable(variableToSave);

			if (MusicBeatState.getVariables().get(variableToSave) != null)
			{
				FunkinLua.luaTrace('createInstance: Variable $variableToSave is already being used and cannot be replaced!', false, false, FlxColor.RED);
				return false;
			}

			if (args == null)
				args = [];

			var myType:Class<Dynamic> = Type.resolveClass(className);

			if (myType == null)
			{
				FunkinLua.luaTrace('createInstance: Class $className not found!', false, false, FlxColor.RED);
				return false;
			}

			var obj:Dynamic = Type.createInstance(myType, LuaUtils.parseArguments(args));
			if (obj != null)
				MusicBeatState.getVariables().set(variableToSave, obj);
			else
				FunkinLua.luaTrace('createInstance: Failed to create $variableToSave, arguments are possibly wrong.', false, false, FlxColor.RED);

			return obj != null;
		});
		Lua_helper.add_callback(lua, "addInstance", function(objectName:String, ?inFront:Bool = false)
		{
			var savedObj:Dynamic = MusicBeatState.getVariables().get(objectName);
			if (savedObj != null)
			{
				var obj:Dynamic = savedObj;
				if (inFront)
					LuaUtils.getTargetInstance().add(obj);
				else
				{
					if (!PlayState.instance.isDead)
						PlayState.instance.insert(PlayState.instance.members.indexOf(LuaUtils.getLowestCharacterGroup()), obj);
					else
						GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), obj);
				}
			}
			else
				FunkinLua.luaTrace('addInstance: Can\'t add what doesn\'t exist~ ($objectName)', false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "instanceArg", function(instanceName:String, ?className:String = null):String
		{
			var retStr:String = '$instanceStr::$instanceName';

			if (className != null)
				retStr += '::$className';

			return retStr;
		});

		Lua_helper.add_callback(lua, "luaSpriteExists", function(tag:String)
		{
			return LuaUtils.luaObjectExists(tag, ModchartSprite);
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
		var obj:Dynamic = LuaUtils.getLuaProperty(tag);

		if (obj == null || !Std.isOfType(obj, FlxSprite))
			return false;

		var spr:FlxSprite = cast obj;

		if (Std.isOfType(spr, ModchartSprite))
			cast(spr, ModchartSprite).playAnim(name, forced, reverse, startFrame);
		else
			spr.animation.play(name, forced, reverse, startFrame);

		return true;
	}
}
#end
