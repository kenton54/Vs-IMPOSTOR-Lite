package psychlua.functions;

#if LUA_ALLOWED
class TextFunctions
{
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;
		var game:PlayState = PlayState.instance;

		Lua_helper.add_callback(lua, "makeLuaText", function(tag:String, text:String, width:Int, x:Float, y:Float)
		{
			tag = LuaUtils.formatVariable(tag);
			LuaUtils.destroyObject(tag);

			var textObj:FlxText = new FlxText(x, y, width, text, 16);
			textObj.setFormat(Paths.font("vcr"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

			if (game != null)
				textObj.cameras = [game.camHUD];

			textObj.scrollFactor.set();
			textObj.borderSize = 2;

			MusicBeatState.getVariables().set(tag, textObj);
		});

		// ----- setters ----- //

		Lua_helper.add_callback(lua, "setTextString", function(tag:String, text:String):Bool
		{
			var obj:FlxText = getTextObject(tag);

			if (obj != null)
			{
				obj.text = text;
				return true;
			}

			FunkinLua.luaTrace('setTextString: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextSize", function(tag:String, size:Int):Bool
		{
			var obj:FlxText = getTextObject(tag);

			if (obj != null)
			{
				obj.size = size;
				return true;
			}

			FunkinLua.luaTrace('setTextSize: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextWidth", function(tag:String, width:Float):Bool
		{
			var obj:FlxText = getTextObject(tag);

			if (obj != null)
			{
				obj.fieldWidth = width;
				return true;
			}

			FunkinLua.luaTrace('setTextWidth: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextHeight", function(tag:String, height:Float):Bool
		{
			var obj:FlxText = getTextObject(tag);

			if (obj != null)
			{
				obj.fieldHeight = height;
				return true;
			}

			FunkinLua.luaTrace('setTextHeight: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextAutoSize", function(tag:String, value:Bool):Bool
		{
			var obj:FlxText = getTextObject(tag);

			if (obj != null)
			{
				obj.autoSize = value;
				return true;
			}

			FunkinLua.luaTrace('setTextAutoSize: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextBorder", function(tag:String, size:Float, color:String, ?style:String = 'outline'):Bool
		{
			var obj:FlxText = getTextObject(tag);

			if (obj != null)
			{
				CoolUtil.setTextBorderFromString(obj, (size > 0 ? style : 'none'));

				if (size > 0)
					obj.borderSize = size;

				obj.borderColor = CoolUtil.colorFromString(color);

				return true;
			}

			FunkinLua.luaTrace('setTextBorder: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextColor", function(tag:String, color:String):Bool
		{
			var obj:FlxText = getTextObject(tag);

			if (obj != null)
			{
				obj.color = CoolUtil.colorFromString(color);
				return true;
			}

			FunkinLua.luaTrace('setTextColor: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextFont", function(tag:String, newFont:String):Bool
		{
			var obj:FlxText = getTextObject(tag);

			if (obj != null)
			{
				obj.font = Paths.font(newFont);
				return true;
			}

			FunkinLua.luaTrace('setTextFont: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextBold", function(tag:String, bold:Bool):Bool
		{
			var obj:FlxText = getTextObject(tag);

			if (obj != null)
			{
				obj.bold = bold;
				return true;
			}

			FunkinLua.luaTrace('setTextBold: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextItalic", function(tag:String, italic:Bool):Bool
		{
			var obj:FlxText = getTextObject(tag);

			if (obj != null)
			{
				obj.italic = italic;
				return true;
			}

			FunkinLua.luaTrace('setTextItalic: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextUnderline", function(tag:String, underline:Bool):Bool
		{
			var obj:FlxText = getTextObject(tag);

			if (obj != null)
			{
				obj.underline = underline;
				return true;
			}

			FunkinLua.luaTrace('setTextUnderline: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextStrikethrough", function(tag:String, strikethrough:Bool):Bool
		{
			var obj:FlxText = getTextObject(tag);

			if (obj != null)
			{
				@:privateAccess
				{
					obj._defaultFormat.strikethrough = strikethrough;
					obj.updateDefaultFormat();
				}
				return true;
			}

			FunkinLua.luaTrace('setTextStrikethrough: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "setTextAlignment", function(tag:String, alignment:String = 'left'):Bool
		{
			var obj:FlxText = getTextObject(tag);

			if (obj != null)
			{
				switch (alignment.trim().toLowerCase())
				{
					case 'right':
						obj.alignment = RIGHT;

					case 'center':
						obj.alignment = CENTER;

					case 'justify':
						obj.alignment = JUSTIFY;

					default:
						obj.alignment = LEFT;
				}

				return true;
			}

			FunkinLua.luaTrace('setTextAlignment: Object $tag doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});

		// ----- getters ----- //

		Lua_helper.add_callback(lua, "getTextString", function(tag:String):String
		{
			return getTextObject(tag)?.text ?? '';
		});
		Lua_helper.add_callback(lua, "getTextSize", function(tag:String):Int
		{
			return getTextObject(tag)?.size ?? -1;
		});
		Lua_helper.add_callback(lua, "getTextFont", function(tag:String):String
		{
			return getTextObject(tag)?.font ?? '';
		});
		Lua_helper.add_callback(lua, "getTextWidth", function(tag:String):Float
		{
			return getTextObject(tag)?.fieldWidth ?? 0;
		});
		Lua_helper.add_callback(lua, "getTextHeight", function(tag:String):Float
		{
			return getTextObject(tag)?.fieldHeight ?? 0;
		});

		Lua_helper.add_callback(lua, "addLuaText", function(tag:String)
		{
			var text:FlxText = getTextObject(tag);

			if (text != null)
				LuaUtils.getTargetInstance().add(text);
		});
		Lua_helper.add_callback(lua, "removeLuaText", function(tag:String, destroy:Bool = true)
		{
			var text:FlxText = getTextObject(tag);

			if (text == null)
				return;

			var instance = CustomSubstate.instance != null ? CustomSubstate.instance : LuaUtils.getTargetInstance();
			instance.remove(text, true);

			if (destroy)
			{
				text.destroy();
				MusicBeatState.getVariables().remove(tag);
			}
		});
		Lua_helper.add_callback(lua, "luaTextExists", function(tag:String)
		{
			return LuaUtils.luaObjectExists(tag, FlxText);
		});
	}

	static function getTextObject(tag:String):Null<FlxText>
	{
		var obj:Dynamic = LuaUtils.getLuaProperty(tag);

		if (obj == null || !Std.isOfType(obj, FlxText))
			return null;

		return cast obj;
	}
}
#end
