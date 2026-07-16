package psychlua;

#if LUA_ALLOWED
import backend.FunkinRuntimeShader;
import backend.Highscore;
import backend.Song;
import backend.WeekData;

import cutscenes.DialogueLiteBox;

import flixel.FlxBasic;
import flixel.addons.transition.FlxTransitionableState;

import objects.Note;
import objects.NoteSplash;
import objects.StrumNote;

import psychlua.functions.*;

import states.FreeplayState;
import states.MainMenuState;
import states.StoryMenuState;

import substates.GameOverSubstate;
import substates.PauseSubState;

#if HSCRIPT_ALLOWED
import psychlua.HScript;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class FunkinLua
{
	public var lua:State = null;
	public var camTarget:FlxCamera;
	public var scriptName:String = '';
	public var modFolder:String = null;
	public var closed:Bool = false;

	#if HSCRIPT_ALLOWED
	public var hscript:HScript = null;
	#end

	public var callbacks:Map<String, Dynamic> = new Map<String, Dynamic>();

	public static var customFunctions:Map<String, Dynamic> = new Map<String, Dynamic>();

	public function new(scriptName:String)
	{
		lua = LuaL.newstate();
		LuaL.openlibs(lua);

		this.scriptName = scriptName.trim();
		var game:PlayState = PlayState.instance;
		if (game != null)
			game.luaArray.push(this);

		// Lua shit
		set('Function_StopLua', LuaUtils.Function_StopLua);
		set('Function_StopHScript', LuaUtils.Function_StopHScript);
		set('Function_StopAll', LuaUtils.Function_StopAll);
		set('Function_Stop', LuaUtils.Function_Stop);
		set('Function_Continue', LuaUtils.Function_Continue);
		set('luaDebugMode', false);
		set('luaDeprecatedWarnings', true);
		set('version', MainMenuState.psychEngineVersion.trim());
		set('modFolder', this.modFolder);

		// Song/Week shit
		set('curBpm', Conductor.bpm);
		set('bpm', PlayState.SONG.bpm);
		set('scrollSpeed', PlayState.SONG.speed);
		set('crochet', Conductor.crochet);
		set('stepCrochet', Conductor.stepCrochet);
		set('songLength', FlxG.sound.music.length);
		set('songName', PlayState.SONG.song);
		set('songPath', Paths.formatToSongPath(PlayState.SONG.song));
		set('startedCountdown', false);
		set('curStage', PlayState.SONG.stage);

		set('isStoryMode', PlayState.isStoryMode);
		set('difficulty', PlayState.storyDifficulty);

		set('difficultyName', Difficulty.getString());
		set('difficultyPath', Paths.formatToSongPath(Difficulty.getString()));
		set('weekRaw', PlayState.storyWeek);
		set('week', WeekData.weeksList[PlayState.storyWeek]);
		set('seenCutscene', PlayState.seenCutscene);
		set('hasVocals', PlayState.SONG.needsVoices);

		// Screen stuff
		set('screenWidth', FlxG.width);
		set('screenHeight', FlxG.height);

		// PlayState variables
		if (game != null)
		{
			var curSectionData:backend.Section.SwagSection = PlayState.SONG.notes[game.curSection];

			set('curSection', game.curSection);
			set('curBeat', game.curBeat);
			set('curStep', game.curStep);
			set('curDecBeat', @:privateAccess game.curDecBeat);
			set('curDecStep', @:privateAccess game.curDecStep);

			set('score', game.songScore);
			set('misses', game.songMisses);
			set('hits', game.songHits);
			set('combo', game.combo);
			set('deaths', PlayState.deathCounter);

			set('rating', game.ratingPercent);
			set('ratingName', game.ratingName);
			set('ratingFC', game.ratingFC);

			set('inGameOver', GameOverSubstate.instance != null);
			set('mustHitSection', curSectionData != null ? (curSectionData.mustHitSection == true) : false);
			set('altAnim', curSectionData != null ? (curSectionData.altAnim == true) : false);
			set('gfSection', curSectionData != null ? (curSectionData.gfSection == true) : false);

			// Gameplay settings
			set('healthGainMult', game.healthGain);
			set('healthLossMult', game.healthLoss);

			#if FLX_PITCH
			set('playbackRate', game.playbackRate);
			#else
			set('playbackRate', 1);
			#end

			set('guitarHeroSustains', game.guitarHeroSustains);
			set('instakillOnMiss', game.instakillOnMiss);
			set('botPlay', game.cpuControlled);
			set('practice', game.practiceMode);

			for (i in 0...4)
			{
				set('defaultPlayerStrumX' + i, 0);
				set('defaultPlayerStrumY' + i, 0);
				set('defaultOpponentStrumX' + i, 0);
				set('defaultOpponentStrumY' + i, 0);
			}

			// Default character
			set('defaultBoyfriendX', game.BF_X);
			set('defaultBoyfriendY', game.BF_Y);
			set('defaultOpponentX', game.DAD_X);
			set('defaultOpponentY', game.DAD_Y);
			set('defaultGirlfriendX', game.GF_X);
			set('defaultGirlfriendY', game.GF_Y);

			// Character shit
			set('boyfriendName', game.boyfriend != null ? game.boyfriend.curCharacter : PlayState.SONG.player1);
			set('dadName', game.dad != null ? game.dad.curCharacter : PlayState.SONG.player2);
			set('gfName', game.gf != null ? game.gf.curCharacter : PlayState.SONG.gfVersion);
		}

		// Other settings
		set('downscroll', ClientPrefs.data.downScroll);
		set('middlescroll', ClientPrefs.data.middleScroll);
		set('framerate', ClientPrefs.data.framerate);
		set('ghostTapping', ClientPrefs.data.ghostTapping);
		set('hideHud', ClientPrefs.data.hideHud);
		set('timeBarType', ClientPrefs.data.timeBarType);
		set('scoreZoom', ClientPrefs.data.scoreZoom);
		set('cameraZoomOnBeat', ClientPrefs.data.camZooms);
		set('flashingLights', ClientPrefs.data.flashing);
		set('noteOffset', ClientPrefs.data.noteOffset);
		set('healthBarAlpha', ClientPrefs.data.healthBarAlpha);
		set('noResetButton', ClientPrefs.data.noReset);
		set('lowQuality', ClientPrefs.data.lowQuality);
		set('shadersEnabled', ClientPrefs.data.shaders);
		set('scriptName', scriptName);

		// Noteskin/Splash
		set('noteSkin', ClientPrefs.data.noteSkin);
		set('noteSkinPostfix', Note.getNoteSkinPostfix());
		set('splashSkin', ClientPrefs.data.splashSkin);
		set('splashSkinPostfix', NoteSplash.getSplashSkinPostfix());
		set('splashAlpha', ClientPrefs.data.splashAlpha);

		// build target (windows, mac, linux, etc.)
		set('buildTarget', LuaUtils.getBuildTarget());
		set('platformTarget', LuaUtils.getPlatformTarget());

		//
		Lua_helper.add_callback(lua, "getRunningScripts", function()
		{
			var runningScripts:Array<String> = [];
			for (script in game.luaArray)
				runningScripts.push(script.scriptName);

			return runningScripts;
		});

		addLocalCallback("setOnScripts", function(varName:String, arg:Dynamic, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null)
		{
			if (exclusions == null)
				exclusions = [];
			if (ignoreSelf && !exclusions.contains(scriptName))
				exclusions.push(scriptName);
			game.setOnScripts(varName, arg, exclusions);
		});
		addLocalCallback("setOnHScript", function(varName:String, arg:Dynamic, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null)
		{
			if (exclusions == null)
				exclusions = [];
			if (ignoreSelf && !exclusions.contains(scriptName))
				exclusions.push(scriptName);
			game.setOnHScript(varName, arg, exclusions);
		});
		addLocalCallback("setOnLuas", function(varName:String, arg:Dynamic, ?ignoreSelf:Bool = false, ?exclusions:Array<String> = null)
		{
			if (exclusions == null)
				exclusions = [];
			if (ignoreSelf && !exclusions.contains(scriptName))
				exclusions.push(scriptName);
			game.setOnLuas(varName, arg, exclusions);
		});

		addLocalCallback("callOnScripts", function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops = false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null, ?excludeValues:Array<Dynamic> = null)
		{
			if (excludeScripts == null)
				excludeScripts = [];
			if (ignoreSelf && !excludeScripts.contains(scriptName))
				excludeScripts.push(scriptName);
			return game.callOnScripts(funcName, args, ignoreStops, excludeScripts, excludeValues);
		});
		addLocalCallback("callOnLuas", function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops = false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null, ?excludeValues:Array<Dynamic> = null)
		{
			if (excludeScripts == null)
				excludeScripts = [];
			if (ignoreSelf && !excludeScripts.contains(scriptName))
				excludeScripts.push(scriptName);
			return game.callOnLuas(funcName, args, ignoreStops, excludeScripts, excludeValues);
		});
		addLocalCallback("callOnHScript", function(funcName:String, ?args:Array<Dynamic> = null, ?ignoreStops = false, ?ignoreSelf:Bool = true, ?excludeScripts:Array<String> = null, ?excludeValues:Array<Dynamic> = null)
		{
			if (excludeScripts == null)
				excludeScripts = [];
			if (ignoreSelf && !excludeScripts.contains(scriptName))
				excludeScripts.push(scriptName);
			return game.callOnHScript(funcName, args, ignoreStops, excludeScripts, excludeValues);
		});

		Lua_helper.add_callback(lua, "callScript", function(luaFile:String, funcName:String, ?args:Array<Dynamic> = null)
		{
			if (args == null)
				args = [];

			var luaPath:String = findScript(luaFile);
			if (luaPath != null)
				for (luaInstance in game.luaArray)
					if (luaInstance.scriptName == luaPath)
						return luaInstance.call(funcName, args);

			return null;
		});
		Lua_helper.add_callback(lua, "isRunning", function(scriptFile:String)
		{
			var luaPath:String = findScript(scriptFile);
			if (luaPath != null)
			{
				for (luaInstance in game.luaArray)
					if (luaInstance.scriptName == luaPath)
						return true;
			}

			#if HSCRIPT_ALLOWED
			var hscriptPath:String = findScript(scriptFile, '.hx');
			if (hscriptPath != null)
			{
				for (hscriptInstance in game.hscriptArray)
					if (hscriptInstance.origin == hscriptPath)
						return true;
			}
			#end
			return false;
		});

		Lua_helper.add_callback(lua, "setVar", function(varName:String, value:Dynamic)
		{
			MusicBeatState.getVariables().set(varName, ReflectionFunctions.parseSingleInstance(value));
			return value;
		});
		Lua_helper.add_callback(lua, "getVar", function(varName:String)
		{
			return MusicBeatState.getVariables().get(varName);
		});

		Lua_helper.add_callback(lua, "addLuaScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false)
		{ // would be dope asf.
			var foundScript:String = findScript(luaFile);
			if (foundScript != null)
			{
				if (!ignoreAlreadyRunning)
					for (luaInstance in game.luaArray)
						if (luaInstance.scriptName == foundScript)
						{
							luaTrace('addLuaScript: The script "' + foundScript + '" is already running!');
							return;
						}

				new FunkinLua(foundScript);
				return;
			}
			luaTrace("addLuaScript: Script doesn't exist!", false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "addHScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false)
		{
			#if HSCRIPT_ALLOWED
			var foundScript:String = findScript(luaFile, '.hx');
			if (foundScript != null)
			{
				if (!ignoreAlreadyRunning)
					for (script in game.hscriptArray)
						if (script.origin == foundScript)
						{
							luaTrace('addHScript: The script "' + foundScript + '" is already running!');
							return;
						}

				PlayState.instance.initHScript(foundScript);
				return;
			}
			luaTrace("addHScript: Script doesn't exist!", false, false, FlxColor.RED);
			#else
			luaTrace("addHScript: HScript is not supported on this platform!", false, false, FlxColor.RED);
			#end
		});
		Lua_helper.add_callback(lua, "removeLuaScript", function(luaFile:String)
		{
			var luaPath:String = findScript(luaFile);
			if (luaPath != null)
			{
				var foundAny:Bool = false;
				for (luaInstance in game.luaArray)
				{
					if (luaInstance.scriptName == luaPath)
					{
						trace('Closing lua script $luaPath');
						luaInstance.stop();
						foundAny = true;
					}
				}
				if (foundAny)
					return true;
			}
			luaTrace('removeLuaScript: Script $luaFile isn\'t running!', false, false, FlxColor.RED);
			return false;
		});
		Lua_helper.add_callback(lua, "removeHScript", function(scriptFile:String)
		{
			#if HSCRIPT_ALLOWED
			var scriptPath:String = findScript(scriptFile, '.hx');
			if (scriptPath != null)
			{
				var foundAny:Bool = false;
				for (script in game.hscriptArray)
				{
					if (script.origin == scriptPath)
					{
						trace('Closing hscript $scriptPath');
						script.destroy();
						foundAny = true;
					}
				}
				if (foundAny)
					return true;
			}
			luaTrace('removeHScript: Script $scriptFile isn\'t running!', false, false, FlxColor.RED);
			return false;
			#else
			luaTrace("removeHScript: HScript is not supported on this platform!", false, false, FlxColor.RED);
			#end
		});

		Lua_helper.add_callback(lua, "loadSong", function(?name:String = null, ?difficultyNum:Int = -1)
		{
			if (name == null || name.length < 1)
				name = PlayState.SONG.song;
			if (difficultyNum == -1)
				difficultyNum = PlayState.storyDifficulty;

			var poop = Highscore.formatSong(name, difficultyNum);
			PlayState.SONG = Song.loadFromJson(poop, name);
			PlayState.storyDifficulty = difficultyNum;
			FlxG.state.persistentUpdate = false;
			LoadingState.loadState(() -> new PlayState(), true);

			FlxG.sound.music.pause();
			FlxG.sound.music.volume = 0;
			if (game != null && game.vocals != null)
			{
				game.vocals.pause();
				game.vocals.volume = 0;
			}
			FlxG.camera.followLerp = 0;
			if (game.cameraTween != null)
				game.cameraTween.active = false;
		});

		Lua_helper.add_callback(lua, "mouseClicked", function(?button:String)
		{
			switch (button.toLowerCase().trim())
			{
				case 'middle':
					return FlxG.mouse.justPressedMiddle;
				case 'right':
					return FlxG.mouse.justPressedRight;
			}
			return PointerUtil.justPressed;
		});
		Lua_helper.add_callback(lua, "mousePressed", function(button:String)
		{
			switch (button.toLowerCase().trim())
			{
				case 'middle':
					return FlxG.mouse.pressedMiddle;
				case 'right':
					return FlxG.mouse.pressedRight;
			}
			return PointerUtil.pressed;
		});
		Lua_helper.add_callback(lua, "mouseReleased", function(button:String)
		{
			switch (button.toLowerCase().trim())
			{
				case 'middle':
					return FlxG.mouse.justReleasedMiddle;
				case 'right':
					return FlxG.mouse.justReleasedRight;
			}
			return PointerUtil.justReleased;
		});

		Lua_helper.add_callback(lua, "runTimer", function(tag:String, time:Float = 1, loops:Int = 1)
		{
			LuaUtils.cancelTimer(tag);
			var variables = MusicBeatState.getVariables();

			var originalTag:String = tag;
			tag = LuaUtils.formatVariable('timer_$tag');
			variables.set(tag, new FlxTimer().start(time, function(tmr:FlxTimer)
			{
				if (tmr.finished)
					variables.remove(tag);
				game.callOnLuas('onTimerCompleted', [originalTag, tmr.loops, tmr.loopsLeft]);
				// trace('Timer Completed: ' + tag);
			}, loops));
			return tag;
		});
		Lua_helper.add_callback(lua, "cancelTimer", function(tag:String)
		{
			LuaUtils.cancelTimer(tag);
		});

		// stupid bietch ass functions
		Lua_helper.add_callback(lua, "addScore", function(value:Int = 0)
		{
			game.songScore += value;
			game.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "addMisses", function(value:Int = 0)
		{
			game.songMisses += value;
			game.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "addHits", function(value:Int = 0)
		{
			game.songHits += value;
			game.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setScore", function(value:Int = 0)
		{
			game.songScore = value;
			game.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setMisses", function(value:Int = 0)
		{
			game.songMisses = value;
			game.RecalculateRating();
		});
		Lua_helper.add_callback(lua, "setHits", function(value:Int = 0)
		{
			game.songHits = value;
			game.RecalculateRating();
		});

		Lua_helper.add_callback(lua, "setHealth", function(value:Float = 0)
		{
			game.health = value;
		});
		Lua_helper.add_callback(lua, "addHealth", function(value:Float = 0)
		{
			game.health += value;
		});
		Lua_helper.add_callback(lua, "getHealth", function()
		{
			return game.health;
		});

		// Identical functions
		Lua_helper.add_callback(lua, "FlxColor", function(color:String) return FlxColor.fromString(color));
		Lua_helper.add_callback(lua, "getColorFromName", function(color:String) return FlxColor.fromString(color));
		Lua_helper.add_callback(lua, "getColorFromString", function(color:String) return FlxColor.fromString(color));
		Lua_helper.add_callback(lua, "getColorFromHex", function(color:String) return FlxColor.fromString('#$color'));

		// precaching
		Lua_helper.add_callback(lua, "addCharacterToList", function(name:String, type:String)
		{
			var charType:Int = 0;
			switch (type.toLowerCase())
			{
				case 'dad':
					charType = 1;
				case 'gf' | 'girlfriend':
					charType = 2;
			}
			game.addCharacterToList(name, charType);
		});
		Lua_helper.add_callback(lua, "precacheImage", function(name:String, ?allowGPU:Bool = true)
		{
			Paths.image(name, allowGPU);
		});
		Lua_helper.add_callback(lua, "precacheSound", function(name:String)
		{
			Paths.sound(name);
		});
		Lua_helper.add_callback(lua, "precacheMusic", function(name:String)
		{
			Paths.music(name);
		});

		// others
		Lua_helper.add_callback(lua, "triggerEvent", function(name:String, value1:Dynamic, value2:Dynamic)
		{
			game.triggerEvent(name, value1, value2, Conductor.songPosition);
			return true;
		});

		Lua_helper.add_callback(lua, "startCountdown", function()
		{
			game.startCountdown();
			return true;
		});
		Lua_helper.add_callback(lua, "endSong", function()
		{
			game.KillNotes();
			game.endSong();
			return true;
		});
		Lua_helper.add_callback(lua, "restartSong", function(?skipTransition:Bool = false)
		{
			game.persistentUpdate = false;
			FlxG.camera.followLerp = 0;
			if (game.cameraTween != null)
				game.cameraTween.active = false;
			PauseSubState.restartSong(skipTransition);
			return true;
		});
		Lua_helper.add_callback(lua, "exitSong", function(?skipTransition:Bool = false)
		{
			if (skipTransition)
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
			}

			if (PlayState.isStoryMode)
				FlxG.switchState(() -> new StoryMenuState());
			else
				FlxG.switchState(() -> new FreeplayState());

			#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.changedDifficulty = false;
			PlayState.chartingMode = false;
			game.transitioning = true;

			FlxG.camera.followLerp = 0;
			if (game.cameraTween != null)
				game.cameraTween.active = false;

			return true;
		});
		Lua_helper.add_callback(lua, "getSongPosition", function()
		{
			return Conductor.songPosition;
		});

		Lua_helper.add_callback(lua, "getCharacterX", function(type:String)
		{
			switch (type.toLowerCase())
			{
				case 'dad' | 'opponent':
					return game.dadGroup.x;
				case 'gf' | 'girlfriend':
					return game.gfGroup.x;
				default:
					return game.boyfriendGroup.x;
			}
		});
		Lua_helper.add_callback(lua, "setCharacterX", function(type:String, value:Float)
		{
			switch (type.toLowerCase())
			{
				case 'dad' | 'opponent':
					game.dadGroup.x = value;
				case 'gf' | 'girlfriend':
					game.gfGroup.x = value;
				default:
					game.boyfriendGroup.x = value;
			}
		});
		Lua_helper.add_callback(lua, "getCharacterY", function(type:String)
		{
			switch (type.toLowerCase())
			{
				case 'dad' | 'opponent':
					return game.dadGroup.y;
				case 'gf' | 'girlfriend':
					return game.gfGroup.y;
				default:
					return game.boyfriendGroup.y;
			}
		});
		Lua_helper.add_callback(lua, "setCharacterY", function(type:String, value:Float)
		{
			switch (type.toLowerCase())
			{
				case 'dad' | 'opponent':
					game.dadGroup.y = value;
				case 'gf' | 'girlfriend':
					game.gfGroup.y = value;
				default:
					game.boyfriendGroup.y = value;
			}
		});
		Lua_helper.add_callback(lua, "cameraSetTarget", function(target:String)
		{
			switch (target.trim().toLowerCase())
			{
				case 'dad', 'opponent':
					game.moveCamera(true);
				default:
					game.moveCamera(false);
			}
		});
		Lua_helper.add_callback(lua, "cameraShake", function(camera:String, intensity:Float, duration:Float)
		{
			LuaUtils.cameraFromString(camera).shake(intensity, duration);
		});

		Lua_helper.add_callback(lua, "cameraFlash", function(camera:String, color:String, duration:Float, forced:Bool)
		{
			LuaUtils.cameraFromString(camera).flash(CoolUtil.colorFromString(color), duration, null, forced);
		});
		Lua_helper.add_callback(lua, "cameraFade", function(camera:String, color:String, duration:Float, forced:Bool)
		{
			LuaUtils.cameraFromString(camera).fade(CoolUtil.colorFromString(color), duration, false, null, forced);
		});
		Lua_helper.add_callback(lua, "setRatingPercent", function(value:Float)
		{
			game.ratingPercent = value;
			game.setOnScripts('rating', game.ratingPercent);
		});
		Lua_helper.add_callback(lua, "setRatingName", function(value:String)
		{
			game.ratingName = value;
			game.setOnScripts('ratingName', game.ratingName);
		});
		Lua_helper.add_callback(lua, "setRatingFC", function(value:String)
		{
			game.ratingFC = value;
			game.setOnScripts('ratingFC', game.ratingFC);
		});
		Lua_helper.add_callback(lua, "getMouseX", function(camera:String):Float
		{
			var cam:FlxCamera = LuaUtils.cameraFromString(camera);
			return PointerUtil.getViewPosition(cam)?.x ?? 0;
		});
		Lua_helper.add_callback(lua, "getMouseY", function(camera:String):Float
		{
			var cam:FlxCamera = LuaUtils.cameraFromString(camera);
			return PointerUtil.getViewPosition(cam)?.y ?? 0;
		});

		Lua_helper.add_callback(lua, "characterDance", function(character:String)
		{
			switch (character.toLowerCase())
			{
				case 'dad':
					game.dad.dance();
				case 'gf' | 'girlfriend':
					if (game.gf != null)
						game.gf.dance();
				default:
					game.boyfriend.dance();
			}
		});

		Lua_helper.add_callback(lua, "setHealthBarColors", function(left:String, right:String)
		{
			var left_color:Null<FlxColor> = null;
			var right_color:Null<FlxColor> = null;
			if (left != null && left != '')
				left_color = CoolUtil.colorFromString(left);
			if (right != null && right != '')
				right_color = CoolUtil.colorFromString(right);
			game.healthBar.setColors(left_color, right_color);
		});
		Lua_helper.add_callback(lua, "setTimeBarColors", function(left:String, right:String)
		{
			var left_color:Null<FlxColor> = null;
			var right_color:Null<FlxColor> = null;
			if (left != null && left != '')
				left_color = CoolUtil.colorFromString(left);
			if (right != null && right != '')
				right_color = CoolUtil.colorFromString(right);
			game.timeBar.setColors(left_color, right_color);
		});

		Lua_helper.add_callback(lua, "setObjectCamera", function(obj:String, camera:String = '')
		{
			var real:FlxBasic = game.getLuaObject(obj);
			if (real != null)
			{
				real.cameras = [LuaUtils.cameraFromString(camera)];
				return true;
			}

			var split:Array<String> = obj.split('.');
			var object:FlxBasic = LuaUtils.getObjectDirectly(split[0]);
			if (split.length > 1)
			{
				object = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
			}

			if (object != null)
			{
				object.cameras = [LuaUtils.cameraFromString(camera)];
				return true;
			}
			luaTrace("setObjectCamera: Object " + obj + " doesn't exist!", false, false, FlxColor.RED);
			return false;
		});

		Lua_helper.add_callback(lua, "changeUIStyle", function(?style:String)
		{
			game.changeUIStyle(style);
		});

		Lua_helper.add_callback(lua, "startDialogue", function(dialogueFile:String)
		{
			var path:String;
			var songPath:String = Paths.formatToSongPath(PlayState.SONG.song);
			#if TRANSLATIONS_ALLOWED
			path = Paths.getPath('data/$songPath/${dialogueFile}_${ClientPrefs.data.language}.json');
			if (!Assets.exists(path, TEXT))
			#end
			path = Paths.getPath('data/$songPath/$dialogueFile.json');

			luaTrace('startDialogue: Trying to load dialogue: ' + path);

			if (Assets.exists(path, TEXT))
			{
				var shit:DialogueData = DialogueLiteBox.parseDialogue(path);
				if (shit.lines.length > 0)
				{
					game.startDialogue(shit);
					luaTrace('startDialogue: Successfully loaded dialogue', false, false, FlxColor.GREEN);
					return true;
				}
				else
					luaTrace('startDialogue: Your dialogue file is badly formatted!', false, false, FlxColor.RED);
			}
			else
			{
				luaTrace('startDialogue: Dialogue file not found', false, false, FlxColor.RED);
				if (game.endingSong)
					game.endSong();
				else
					game.startCountdown();
			}
			return false;
		});
		Lua_helper.add_callback(lua, "startVideo", function(videoFile:String, ?canSkip:Bool = true, ?forMidSong:Bool = false)
		{
			#if VIDEOS_ALLOWED
			if (FileSystem.exists(Paths.video(videoFile)))
			{
				if (game.videoCutscene != null)
				{
					game.remove(game.videoCutscene);
					game.videoCutscene.destroy();
				}
				game.videoCutscene = game.startVideo(videoFile, forMidSong, canSkip);
				return true;
			}
			else
			{
				luaTrace('startVideo: Video file not found: ' + videoFile, false, false, FlxColor.RED);
			}
			return false;
			#else
			PlayState.instance.inCutscene = true;
			new FlxTimer().start(0.1, _ ->
			{
				PlayState.instance.inCutscene = false;
				if (game.endingSong)
					game.endSong();
				else
					game.startCountdown();
			});
			return true;
			#end
		});

		Lua_helper.add_callback(lua, "debugPrint", function(text:Dynamic = '', color:String = 'WHITE')
		{
			PlayState.instance.addTextToDebug(text, CoolUtil.colorFromString(color));
		});

		addLocalCallback("close", function()
		{
			closed = true;
			trace('Closing script $scriptName');
			return closed;
		});

		SpriteFunctions.implement(this);
		TextFunctions.implement(this);
		SoundFunctions.implement(this);
		ShaderFunctions.implement(this);
		TweenFunctions.implement(this);
		CustomSubstate.implement(this);
		ReflectionFunctions.implement(this);
		#if DISCORD_ALLOWED DiscordClient.addLuaCallbacks(lua); #end
		#if HSCRIPT_ALLOWED HScript.implement(this); #end
		#if ACHIEVEMENTS_ALLOWED Achievements.addLuaCallbacks(lua); #end
		ExtraFunctions.implement(this);
		DeprecatedFunctions.implement(this);

		for (name => func in customFunctions)
		{
			if (func != null)
				Lua_helper.add_callback(lua, name, func);
		}

		try
		{
			var result:Int = LuaL.dostring(lua, Assets.getText(scriptName));
			var resultStr:String = Lua.tostring(lua, result);
			if (resultStr != null && result != 0)
			{
				trace(resultStr);
				lime.app.Application.current.window.alert(resultStr, 'Error on lua script!');
				lua = null;
				return;
			}
		}
		catch (e:Dynamic)
		{
			trace(e);
			return;
		}
		trace('LOADED LUA FILE: [' + scriptName + "]");

		call('onCreate', []);
	}

	// main
	public var lastCalledFunction:String = '';

	public static var lastCalledScript:FunkinLua = null;

	public function call(func:String, args:Array<Dynamic>):Dynamic
	{
		if (closed)
			return LuaUtils.Function_Continue;

		lastCalledFunction = func;
		lastCalledScript = this;
		try
		{
			if (lua == null)
				return LuaUtils.Function_Continue;

			Lua.getglobal(lua, func);
			var type:Int = Lua.type(lua, -1);

			if (type != Lua.LUA_TFUNCTION)
			{
				if (type > Lua.LUA_TNIL)
					luaTrace("ERROR (" + func + "): attempt to call a " + LuaUtils.typeToString(type) + " value", false, false, FlxColor.RED);

				Lua.pop(lua, 1);
				return LuaUtils.Function_Continue;
			}

			for (arg in args)
				Convert.toLua(lua, arg);
			var status:Int = Lua.pcall(lua, args.length, 1, 0);

			// Checks if it's not successful, then show a error.
			if (status != Lua.LUA_OK)
			{
				var error:String = getErrorMessage(status);
				luaTrace("ERROR (" + func + "): " + error, false, false, FlxColor.RED);
				return LuaUtils.Function_Continue;
			}

			// If successful, pass and then return the result.
			var result:Dynamic = cast Convert.fromLua(lua, -1);
			if (result == null)
				result = LuaUtils.Function_Continue;

			Lua.pop(lua, 1);
			if (closed)
				stop();
			return result;
		}
		catch (e:Dynamic)
		{
			trace(e);
		}
		return LuaUtils.Function_Continue;
	}

	public function set(variable:String, data:Dynamic)
	{
		if (lua == null)
			return;

		Convert.toLua(lua, data);
		Lua.setglobal(lua, variable);
	}

	public function stop()
	{
		closed = true;

		if (lua == null)
			return;

		Lua.close(lua);
		lua = null;

		#if HSCRIPT_ALLOWED
		if (hscript != null)
		{
			hscript.destroy();
			hscript = null;
		}
		#end
	}

	public static function luaTrace(text:String, ignoreCheck:Bool = false, deprecated:Bool = false, color:FlxColor = FlxColor.WHITE)
	{
		if (ignoreCheck || getBool('luaDebugMode'))
		{
			if (deprecated && !getBool('luaDeprecatedWarnings'))
			{
				return;
			}
			PlayState.instance.addTextToDebug(text, color);
		}
	}

	public static function getBool(variable:String)
	{
		if (lastCalledScript == null)
			return false;

		var lua:State = lastCalledScript.lua;
		if (lua == null)
			return false;

		var result:String = null;
		Lua.getglobal(lua, variable);
		result = Convert.fromLua(lua, -1);
		Lua.pop(lua, 1);

		if (result == null)
		{
			return false;
		}
		return (result == 'true');
	}

	function findScript(scriptFile:String, ext:String = '.lua')
	{
		if (!scriptFile.endsWith(ext))
			scriptFile += ext;
		var path:String = Paths.getPath(scriptFile);
		if (Assets.exists(path, TEXT))
		{
			return path;
		}
		else if (Assets.exists(scriptFile, TEXT))
		{
			return scriptFile;
		}
		return null;
	}

	public function getErrorMessage(status:Int):String
	{
		var v:String = Lua.tostring(lua, -1);
		Lua.pop(lua, 1);

		if (v != null)
			v = v.trim();
		if (v == null || v == "")
		{
			switch (status)
			{
				case Lua.LUA_ERRRUN:
					return "Runtime Error";
				case Lua.LUA_ERRMEM:
					return "Memory Allocation Error";
				case Lua.LUA_ERRERR:
					return "Critical Error";
			}
			return "Unknown Error";
		}

		return v;
		return null;
	}

	public function addLocalCallback(name:String, myFunction:Dynamic)
	{
		callbacks.set(name, myFunction);
		Lua_helper.add_callback(lua, name, null); // just so that it gets called
	}

	public var runtimeShaders:Map<String, LuaShaderData> = new Map<String, LuaShaderData>();

	public function initLuaShader(name:String, ?glslVersion:Int = 120):Bool
	{
		if (!ClientPrefs.data.shaders)
			return false;

		if (runtimeShaders.exists(name))
		{
			luaTrace('Shader $name was already initialized!');
			return true;
		}

		if (!FunkinRuntimeShader.VALID_GLSL_VERSIONS.contains(glslVersion))
		{
			luaTrace('Invalid GLSL version of shader $name!');
			return false;
		}

		var frag:String = Paths.shaderFragment(name);
		var vert:String = Paths.shaderVertex(name);
		var found:Bool = false;
		if (Assets.exists(frag))
		{
			frag = Assets.getText(frag);
			found = true;
		}
		else
			frag = null;

		if (Assets.exists(vert))
		{
			vert = Assets.getText(vert);
			found = true;
		}
		else
			vert = null;

		if (found)
		{
			runtimeShaders.set(name, {frag: frag, vert: vert, glslVersion: glslVersion});
			return true;
		}

		luaTrace('Missing shader $name .frag AND .vert files!', false, false, FlxColor.RED);
		return false;
	}
}

typedef LuaShaderData =
{
	@:optional var frag:String;
	@:optional var vert:String;
	@:optional var glslVersion:Int;
}
#end
