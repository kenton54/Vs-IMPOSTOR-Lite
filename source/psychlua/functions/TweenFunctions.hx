package psychlua.functions;

#if LUA_ALLOWED
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.util.FlxStringUtil;

import objects.StrumNote;

import psychlua.LuaUtils.LuaTweenOptions;

class TweenFunctions
{
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;
		var game:PlayState = PlayState.instance;

		// ----- main tweens ----- //

		Lua_helper.add_callback(lua, "startTween", function(tag:String, vars:String, values:Any = null, duration:Float, ?options:Dynamic)
		{
			var target:Dynamic = LuaUtils.tweenPrepare(tag, vars);
			if (target == null)
			{
				FunkinLua.luaTrace('startTween: Couldnt find object: ' + vars, false, false, FlxColor.RED);
				return;
			}

			if (values == null)
			{
				FunkinLua.luaTrace('startTween: No values on 2nd argument!', false, false, FlxColor.RED);
				return;
			}

			var myOptions:LuaTweenOptions = LuaUtils.getLuaTween(options);
			if (tag != null && tag.length > 0)
			{
				var originalTag:String = tag;
				tag = LuaUtils.formatVariable('tween_$tag');

				var variables = MusicBeatState.getVariables();
				variables.set(tag, FlxTween.tween(target, values, duration, myOptions != null ? {
					type: myOptions.type,
					ease: myOptions.ease,
					startDelay: myOptions.startDelay,
					loopDelay: myOptions.loopDelay,

					onUpdate: _ ->
					{
						if (myOptions.onUpdate != null)
							game.callOnLuas(myOptions.onUpdate, [originalTag, vars]);
					},
					onStart: _ ->
					{
						if (myOptions.onStart != null)
							game.callOnLuas(myOptions.onStart, [originalTag, vars]);
					},
					onComplete: function(twn:FlxTween)
					{
						if (twn.type == FlxTweenType.ONESHOT || twn.type == FlxTweenType.BACKWARD)
							variables.remove(tag);

						if (myOptions.onComplete != null)
							game.callOnLuas(myOptions.onComplete, [originalTag, vars]);
					}
				} : null));
			}
			else
				FlxTween.tween(target, values, duration, myOptions != null ? {
					type: myOptions.type,
					ease: myOptions.ease,
					startDelay: myOptions.startDelay,
					loopDelay: myOptions.loopDelay,

					onUpdate: _ ->
					{
						if (myOptions.onUpdate != null)
							game.callOnLuas(myOptions.onUpdate, [null, vars]);
					},
					onStart: _ ->
					{
						if (myOptions.onStart != null)
							game.callOnLuas(myOptions.onStart, [null, vars]);
					},
					onComplete: _ ->
					{
						if (myOptions.onComplete != null)
							game.callOnLuas(myOptions.onComplete, [null, vars]);
					}
				} : null);
		});

		Lua_helper.add_callback(lua, "doTweenX", function(tag:String, vars:String, value:Float, duration:Float, ease:String)
		{
			commonTween(tag, vars, {x: value}, duration, ease, 'doTweenX');
		});
		Lua_helper.add_callback(lua, "doTweenY", function(tag:String, vars:String, value:Float, duration:Float, ease:String)
		{
			commonTween(tag, vars, {y: value}, duration, ease, 'doTweenY');
		});
		Lua_helper.add_callback(lua, "doTweenAngle", function(tag:String, vars:String, value:Float, duration:Float, ease:String)
		{
			commonTween(tag, vars, {angle: value}, duration, ease, 'doTweenAngle');
		});
		Lua_helper.add_callback(lua, "doTweenAlpha", function(tag:String, vars:String, value:Float, duration:Float, ease:String)
		{
			commonTween(tag, vars, {alpha: value}, duration, ease, 'doTweenAlpha');
		});
		Lua_helper.add_callback(lua, "doTweenZoom", function(tag:String, camera:String, value:Float, duration:Float, ease:String)
		{
			switch (camera.toLowerCase())
			{
				case 'camgame' | 'game':
					camera = 'camGame';

				case 'camhud' | 'hud':
					camera = 'camHUD';

				case 'camother' | 'other':
					camera = 'camOther';

				case 'camcountdown' | 'countdown':
					camera = 'camCountdown';

				case 'camdialogue' | 'dialogue':
					camera = 'camDialogue';

				case 'campause' | 'pause':
					camera = 'camPause';

				default:
					var cam:FlxCamera = MusicBeatState.getVariables().get('cam_$camera');
					if (cam == null || !Std.isOfType(cam, FlxCamera))
						camera = 'camGame';
			}

			commonTween(tag, camera, {zoom: value}, duration, ease, 'doTweenZoom');
		});
		Lua_helper.add_callback(lua, "doTweenColor", function(tag:String, vars:String, targetColor:String, duration:Float, ease:String)
		{
			var target:Dynamic = LuaUtils.tweenPrepare(tag, vars);
			if (target == null || !Std.isOfType(target, FlxSprite))
			{
				FunkinLua.luaTrace('doTweenColor: Couldnt find object: ' + vars, false, false, FlxColor.RED);
				return;
			}

			var sprite:FlxSprite = cast target;

			var curColor:FlxColor = sprite.color;
			curColor.alphaFloat = sprite.alpha;

			if (tag != null && tag.length > 0)
			{
				var originalTag:String = tag;
				tag = LuaUtils.formatVariable('tween_$tag');

				var variables = MusicBeatState.getVariables();
				variables.set(tag, FlxTween.color(sprite, duration, curColor, CoolUtil.colorFromString(targetColor), {
					ease: LuaUtils.getTweenEaseByString(ease),
					onComplete: _ ->
					{
						variables.remove(tag);

						if (game != null)
							game.callOnLuas('onTweenCompleted', [originalTag, vars]);
					}
				}));
			}
			else
				FlxTween.color(sprite, duration, curColor, CoolUtil.colorFromString(targetColor), {ease: LuaUtils.getTweenEaseByString(ease)});
		});
		Lua_helper.add_callback(lua, "doTweenShake", function(tag:String, vars:String, intensity:Float, duration:Float, axes:String, ease:String)
		{
			var target:Dynamic = LuaUtils.tweenPrepare(tag, vars);
			if (target == null || !Std.isOfType(target, FlxSprite))
			{
				FunkinLua.luaTrace('doTweenShake: Couldnt find object: ' + vars, false, false, FlxColor.RED);
				return;
			}

			var sprite:FlxSprite = cast target;

			if (tag != null && tag.length > 0)
			{
				var originalTag:String = tag;
				tag = LuaUtils.formatVariable('tween_$tag');

				var variables = MusicBeatState.getVariables();
				variables.set(tag, FlxTween.shake(sprite, intensity, duration, LuaUtils.axesFromString(axes), {
					ease: LuaUtils.getTweenEaseByString(ease),
					onComplete: _ ->
					{
						variables.remove(tag);

						if (game != null)
							game.callOnLuas('onTweenCompleted', [originalTag, vars]);
					}
				}));
			}
			else
				FlxTween.shake(sprite, intensity, duration, LuaUtils.axesFromString(axes), {ease: LuaUtils.getTweenEaseByString(ease)});
		});
		Lua_helper.add_callback(lua, "doTweenFlicker", function(tag:String, vars:String, period:Float, duration:Float, endVisibility:Bool, ease:String)
		{
			var target:Dynamic = LuaUtils.tweenPrepare(tag, vars);
			if (target == null || !Std.isOfType(target, FlxBasic))
			{
				FunkinLua.luaTrace('doTweenFlicker: Couldnt find object: ' + vars, false, false, FlxColor.RED);
				return;
			}

			var basic:FlxBasic = cast target;

			if (tag != null && tag.length > 0)
			{
				var originalTag:String = tag;
				tag = LuaUtils.formatVariable('tween_$tag');

				var variables = MusicBeatState.getVariables();
				variables.set(tag, FlxTween.flicker(basic, duration, period, {
					endVisibility: endVisibility,
					ease: LuaUtils.getTweenEaseByString(ease),
					onComplete: _ ->
					{
						variables.remove(tag);

						if (game != null)
							game.callOnLuas('onTweenCompleted', [originalTag, vars]);
					}
				}));
			}
			else
				FlxTween.flicker(basic, duration, period, {
					endVisibility: endVisibility,
					ease: LuaUtils.getTweenEaseByString(ease)
				});
		});
		Lua_helper.add_callback(lua, "doTweenLinearMotion", function(tag:String, vars:String, start:Array<Float>, end:Array<Float>, duration:Float, durationAsSpeed:Bool, ease:String)
		{
			var target:Dynamic = LuaUtils.tweenPrepare(tag, vars);
			if (target == null || !Std.isOfType(target, FlxObject))
			{
				FunkinLua.luaTrace('doTweenLinearMotion: Couldnt find object: ' + vars, false, false, FlxColor.RED);
				return;
			}

			var object:FlxObject = cast target;

			if (tag != null && tag.length > 0)
			{
				var originalTag:String = tag;
				tag = LuaUtils.formatVariable('tween_$tag');

				var variables = MusicBeatState.getVariables();
				variables.set(tag, FlxTween.linearMotion(object, start[0], start[1], end[0], end[1], duration, !durationAsSpeed, {
					ease: LuaUtils.getTweenEaseByString(ease),
					onComplete: _ ->
					{
						variables.remove(tag);

						if (game != null)
							game.callOnLuas('onTweenCompleted', [originalTag, vars]);
					}
				}));
			}
			else
				FlxTween.linearMotion(object, start[0], start[1], end[0], end[1], duration, !durationAsSpeed, {ease: LuaUtils.getTweenEaseByString(ease)});
		});
		Lua_helper.add_callback(lua, "doTweenLinearPath", function(tag:String, vars:String, points:Array<Array<Float>>, duration:Float, durationAsSpeed:Bool, ease:String)
		{
			var target:Dynamic = LuaUtils.tweenPrepare(tag, vars);
			if (target == null || !Std.isOfType(target, FlxObject))
			{
				FunkinLua.luaTrace('doTweenLinearPath: Couldnt find object: ' + vars, false, false, FlxColor.RED);
				return;
			}

			var object:FlxObject = cast target;

			if (tag != null && tag.length > 0)
			{
				var originalTag:String = tag;
				tag = LuaUtils.formatVariable('tween_$tag');

				var variables = MusicBeatState.getVariables();
				variables.set(tag, FlxTween.linearPath(object, [for (p in points) FlxPoint.get(p[0], p[1])], duration, !durationAsSpeed, {
					ease: LuaUtils.getTweenEaseByString(ease),
					onComplete: _ ->
					{
						variables.remove(tag);

						if (game != null)
							game.callOnLuas('onTweenCompleted', [originalTag, vars]);
					}
				}));
			}
			else
				FlxTween.linearPath(object, [for (p in points) FlxPoint.get(p[0], p[1])], duration, !durationAsSpeed, {ease: LuaUtils.getTweenEaseByString(ease)});
		});
		Lua_helper.add_callback(lua, "doTweenQuadMotion", function(tag:String, vars:String, start:Array<Float>, control:Array<Float>, end:Array<Float>, duration:Float, durationAsSpeed:Bool, ease:String)
		{
			var target:Dynamic = LuaUtils.tweenPrepare(tag, vars);
			if (target == null || !Std.isOfType(target, FlxObject))
			{
				FunkinLua.luaTrace('doTweenQuadMotion: Couldnt find object: ' + vars, false, false, FlxColor.RED);
				return;
			}

			var object:FlxObject = cast target;

			if (tag != null && tag.length > 0)
			{
				var originalTag:String = tag;
				tag = LuaUtils.formatVariable('tween_$tag');

				var variables = MusicBeatState.getVariables();
				variables.set(tag, FlxTween.quadMotion(object, start[0], start[1], control[0], control[1], end[0], end[1], duration, !durationAsSpeed, {
					ease: LuaUtils.getTweenEaseByString(ease),
					onComplete: _ ->
					{
						variables.remove(tag);

						if (game != null)
							game.callOnLuas('onTweenCompleted', [originalTag, vars]);
					}
				}));
			}
			else
				FlxTween.quadMotion(object, start[0], start[1], control[0], control[1], end[0], end[1], duration, !durationAsSpeed, {ease: LuaUtils.getTweenEaseByString(ease)});
		});
		Lua_helper.add_callback(lua, "doTweenQuadPath", function(tag:String, vars:String, points:Array<Array<Float>>, duration:Float, durationAsSpeed:Bool, ease:String)
		{
			var target:Dynamic = LuaUtils.tweenPrepare(tag, vars);
			if (target == null || !Std.isOfType(target, FlxObject))
			{
				FunkinLua.luaTrace('doTweenQuadPath: Couldnt find object: ' + vars, false, false, FlxColor.RED);
				return;
			}

			var object:FlxObject = cast target;

			if (tag != null && tag.length > 0)
			{
				var originalTag:String = tag;
				tag = LuaUtils.formatVariable('tween_$tag');

				var variables = MusicBeatState.getVariables();
				variables.set(tag, FlxTween.quadPath(object, [for (p in points) FlxPoint.get(p[0], p[1])], duration, !durationAsSpeed, {
					ease: LuaUtils.getTweenEaseByString(ease),
					onComplete: _ ->
					{
						variables.remove(tag);

						if (game != null)
							game.callOnLuas('onTweenCompleted', [originalTag, vars]);
					}
				}));
			}
			else
				FlxTween.quadPath(object, [for (p in points) FlxPoint.get(p[0], p[1])], duration, !durationAsSpeed, {ease: LuaUtils.getTweenEaseByString(ease)});
		});

		// ----- note tweens ----- //

		Lua_helper.add_callback(lua, "noteTweenX", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
		{
			noteTween(tag, note, {x: value}, duration, ease);
		});
		Lua_helper.add_callback(lua, "noteTweenY", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
		{
			noteTween(tag, note, {y: value}, duration, ease);
		});
		Lua_helper.add_callback(lua, "noteTweenAlpha", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
		{
			noteTween(tag, note, {alpha: value}, duration, ease);
		});
		Lua_helper.add_callback(lua, "noteTweenAngle", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
		{
			noteTween(tag, note, {angle: value}, duration, ease);
		});
		Lua_helper.add_callback(lua, "noteTweenDirection", function(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)
		{
			noteTween(tag, note, {direction: value}, duration, ease);
		});

		// ----- tween checks ----- //

		Lua_helper.add_callback(lua, "isTweening", function(tag:String):Bool
		{
			return MusicBeatState.getVariables().get(LuaUtils.formatVariable('tween_$tag')) != null;
		});
		Lua_helper.add_callback(lua, "isTweeningObject", function(vars:String):Bool
		{
			var result:Bool = false;
			var obj:Dynamic = LuaUtils.getLuaProperty(vars);

			if (obj == null)
				return false;

			FlxTween.globalManager.forEach((twn:FlxTween) ->
			{
				@:privateAccess
				{
					if (twn.isTweenOf(obj))
						result = true;
				}
			});

			return result;
		});

		// ----- tween cancellation ----- //

		Lua_helper.add_callback(lua, "cancelTween", function(tag:String)
		{
			LuaUtils.cancelTween(tag);
		});
	}

	static function commonTween(tag:String, vars:String, tweenValue:Dynamic, duration:Float = 1, ease:String = '', ?funcName:String)
	{
		var target:Dynamic = LuaUtils.tweenPrepare(tag, vars);
		trace([FlxStringUtil.getClassName(target), tweenValue]);
		if (target == null)
		{
			FunkinLua.luaTrace('${funcName != null ? '$funcName: ' : ''}Couldn\'t find object: $vars', false, false, FlxColor.RED);
			return;
		}

		if (tag != null && tag.length > 0)
		{
			var originalTag:String = tag;
			tag = LuaUtils.formatVariable('tween_$tag');

			var variables = MusicBeatState.getVariables();
			variables.set(tag, FlxTween.tween(target, tweenValue, duration, {
				ease: LuaUtils.getTweenEaseByString(ease),
				onComplete: _ ->
				{
					variables.remove(tag);

					if (PlayState.instance != null)
						PlayState.instance.callOnLuas('onTweenCompleted', [originalTag, vars]);
				}
			}));
		}
		else
			FlxTween.tween(target, tweenValue, duration, {ease: LuaUtils.getTweenEaseByString(ease)});
	}

	static function noteTween(tag:String, note:Int, data:Dynamic, duration:Float, ease:String)
	{
		if (PlayState.instance == null)
			return;

		var strumNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];
		if (strumNote == null)
			return;

		if (tag != null && tag.length > 0)
		{
			var originalTag:String = tag;
			tag = LuaUtils.formatVariable('tween_$tag');
			LuaUtils.cancelTween(tag);

			var variables = MusicBeatState.getVariables();
			variables.set(tag, FlxTween.tween(strumNote, data, duration, {
				ease: LuaUtils.getTweenEaseByString(ease),
				onComplete: _ ->
				{
					variables.remove(tag);
					PlayState.instance.callOnLuas('onTweenCompleted', [originalTag]);
				}
			}));
		}
		else
			FlxTween.tween(strumNote, data, duration, {ease: LuaUtils.getTweenEaseByString(ease)});
	}
}
#end
