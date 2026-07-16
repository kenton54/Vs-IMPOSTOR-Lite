package psychlua.functions;

#if LUA_ALLOWED
import flixel.FlxBasic;

class SoundFunctions
{
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;
		var game:PlayState = PlayState.instance;

		// ----- sound playback ----- //

		Lua_helper.add_callback(lua, "playMusic", function(sound:String, volume:Float = 1, loop:Bool = false)
		{
			FlxG.sound.playMusic(Paths.music(sound), volume, loop);
		});
		Lua_helper.add_callback(lua, "playSound", function(sound:String, volume:Float = 1, ?tag:String, loop:Bool = false)
		{
			if (tag != null && tag.length > 0)
			{
				tag = LuaUtils.formatVariable(tag);
				LuaUtils.destroyObject(tag);

				MusicBeatState.getVariables().set(tag, FlxG.sound.play(Paths.sound(sound), volume, loop, null, true, function()
				{
					if (!loop)
						MusicBeatState.getVariables().remove(tag);

					if (game != null)
						game.callOnLuas('onSoundFinished', [tag]);
				}));
			}
			else
				FlxG.sound.play(Paths.sound(sound), volume);
		});
		Lua_helper.add_callback(lua, "stopSound", function(?tag:String)
		{
			if (tag == null || tag.length < 1)
				FlxG.sound.music?.stop();
			else
			{
				getSoundObject(tag)?.stop();
				LuaUtils.destroyObject(tag);
			}
		});
		Lua_helper.add_callback(lua, "pauseSound", function(?tag:String)
		{
			if (tag == null || tag.length < 1)
				FlxG.sound.music?.pause();
			else
				getSoundObject(tag)?.pause();
		});
		Lua_helper.add_callback(lua, "resumeSound", function(?tag:String)
		{
			if (tag == null || tag.length < 1)
				FlxG.sound.music?.resume();
			else
				getSoundObject(tag)?.resume();
		});

		// ----- sound fading ----- //

		Lua_helper.add_callback(lua, "soundFadeIn", function(?tag:String, duration:Float, fromValue:Float = 0, toValue:Float = 1)
		{
			if (tag == null || tag.length < 1)
				FlxG.sound.music?.fadeIn(duration, fromValue, toValue);
			else
				getSoundObject(tag)?.fadeIn(duration, fromValue, toValue);
		});
		Lua_helper.add_callback(lua, "soundFadeOut", function(?tag:String, duration:Float, toValue:Float = 0)
		{
			if (tag == null || tag.length < 1)
				FlxG.sound.music?.fadeOut(duration, toValue);
			else
				getSoundObject(tag)?.fadeOut(duration, toValue);
		});
		Lua_helper.add_callback(lua, "soundFadeCancel", function(?tag:String)
		{
			if (tag == null || tag.length < 1)
				FlxG.sound.music?.fadeTween?.cancel();
			else
			{
				getSoundObject(tag)?.fadeTween?.cancel();
			}
		});

		// ----- getters and setters ----- //

		Lua_helper.add_callback(lua, "getSoundVolume", function(?tag:String):Float
		{
			if (tag == null || tag.length < 1)
				return FlxG.sound.music?.volume ?? 0;
			else
				return getSoundObject(tag)?.volume ?? 0;
		});
		Lua_helper.add_callback(lua, "setSoundVolume", function(?tag:String, value:Float):Float
		{
			if (tag == null || tag.length < 1)
			{
				if (FlxG.sound.music != null)
					return FlxG.sound.music.volume = value;
			}
			else
			{
				var snd:FlxSound = getSoundObject(tag);
				if (snd != null)
					return snd.volume = value;
			}

			return value;
		});
		Lua_helper.add_callback(lua, "getSoundTime", function(?tag:String):Float
		{
			if (tag == null || tag.length < 1)
				return FlxG.sound.music?.time ?? 0;
			else
				return getSoundObject(tag)?.time ?? 0;
		});
		Lua_helper.add_callback(lua, "setSoundTime", function(?tag:String, value:Float):Float
		{
			if (tag == null || tag.length < 1)
			{
				if (FlxG.sound.music != null)
					return FlxG.sound.music.time = value;
			}
			else
			{
				var snd:FlxSound = getSoundObject(tag);
				if (snd != null)
					return snd.time = value;
			}

			return value;
		});
		Lua_helper.add_callback(lua, "getSoundPitch", function(?tag:String):Float
		{
			if (tag == null || tag.length < 1)
				return FlxG.sound.music?.pitch ?? 1;
			else
				return getSoundObject(tag)?.pitch ?? 1;
		});
		Lua_helper.add_callback(lua, "setSoundPitch", function(?tag:String, value:Float, doPause:Bool = false):Float
		{
			if (tag == null || tag.length < 1)
			{
				if (FlxG.sound.music != null)
				{
					FlxG.sound.music.pitch = value;

					if (doPause)
						FlxG.sound.music.pause();
				}
			}
			else
			{
				var snd:FlxSound = getSoundObject(tag);
				if (snd != null)
				{
					snd.pitch = value;

					if (doPause)
						snd.pause();
				}
			}

			return value;
		});
		Lua_helper.add_callback(lua, "getSoundLength", function(?tag:String):Float
		{
			if (tag == null || tag.length < 1)
				return FlxG.sound.music?.length ?? 0;
			else
				return getSoundObject(tag)?.length ?? 0;
		});
		Lua_helper.add_callback(lua, "setSoundLoopTime", function(?tag:String, value:Float):Float
		{
			if (tag == null || tag.length < 1)
			{
				if (FlxG.sound.music != null)
					return FlxG.sound.music.loopTime = value;
			}
			else
			{
				var snd:FlxSound = getSoundObject(tag);
				if (snd != null)
					return snd.loopTime = value;
			}

			return value;
		});
		Lua_helper.add_callback(lua, "getSoundPan", function(?tag:String):Float
		{
			if (tag == null || tag.length < 1)
				return FlxG.sound.music?.pan ?? 0;
			else
				return getSoundObject(tag)?.pan ?? 0;
		});
		Lua_helper.add_callback(lua, "setSoundPan", function(?tag:String, value:Float):Float
		{
			if (tag == null || tag.length < 1)
			{
				if (FlxG.sound.music != null)
					return FlxG.sound.music.pan = value;
			}
			else
			{
				var snd:FlxSound = getSoundObject(tag);
				if (snd != null)
					return snd.pan = value;
			}

			return value;
		});
		Lua_helper.add_callback(lua, "getSoundActualVolume", function(?tag:String):Float
		{
			if (tag == null || tag.length < 1)
				return FlxG.sound.music?.getActualVolume() ?? 0;
			else
				return getSoundObject(tag)?.getActualVolume() ?? 0;
		});
	}

	static function getSoundObject(tag:String):Null<FlxSound>
	{
		var basic:FlxBasic = LuaUtils.getObject('sound_$tag');

		if (basic == null || !Std.isOfType(basic, FlxSound))
			return null;

		return cast basic;
	}
}
#end
