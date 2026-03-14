package states;

import objects.VideoSprite;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import states.editors.MasterEditorMenu;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3'; // This is also used for Discord RPC
	static var curSelected:Int = 0;

	/**
	 * Whether to allow the user to access debug features.
	 */
	public static final ALLOW_DEBUG_ACCESS:Bool = true;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'gallery',
		'credits',
		'options'
	];

	var steginiteLol:FlxText;

	override function create()
	{
		FlxG.camera.scroll.y = 0;
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Looking at the main menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		persistentUpdate = persistentDraw = true;

		var red:FlxSprite = new FlxSprite();
		red.frames = Paths.getSparrowAtlas('mainmenu/redmenu');
		red.animation.addByPrefix('idlered', 'redmenu', 4);
		red.animation.play('idlered');
		red.antialiasing = false;
		red.scale.set(1.2, 1.2);
		red.updateHitbox();
		red.x = FlxG.width - red.width + 125;
		red.y = FlxG.height - red.height + 75;
		add(red);

		var green:FlxSprite = new FlxSprite();
		green.frames = Paths.getSparrowAtlas('mainmenu/greenmenu');
		green.animation.addByPrefix('idlegreen', 'greenmenu', 4);
		green.animation.play('idlegreen');
		green.antialiasing = false;
		green.scale.set(1.2, 1.2);
		green.updateHitbox();
		green.x = -125;
		green.y = FlxG.height - green.height + 175;
		add(green);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 275 + (i * 112.5));
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu');
			menuItem.animation.addByPrefix('idle', optionShit[i], 24);
			menuItem.animation.addByPrefix('selected', "sel_" + optionShit[i], 24);
			menuItem.animation.play('idle');
			menuItem.antialiasing = false;
			menuItem.scale.x = menuItem.scale.y = 0.55;
			menuItem.updateHitbox();
			menuItem.screenCenter(X);
			menuItem.alpha = 0.5;
			menuItems.add(menuItem);
		}

		var logo:FlxSprite = new FlxSprite(0, 10).loadGraphic(Paths.image('title/logo'));
		logo.antialiasing = false;
		logo.scale.set(0.8, 0.8);
		logo.updateHitbox();
		logo.screenCenter(X);
		add(logo);

		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Vs. Impostor: Lite", 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		add(fnfVer);

		var psychVer:FlxText = new FlxText(0, FlxG.height - 24, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		psychVer.x = FlxG.width - psychVer.width - 12;
		add(psychVer);

		if (TitleState.isSteginiteBuildLol)
		{
			steginiteLol = new FlxText(logo.x + 580, logo.y + logo.height - 40, 320, "The Steginite\nBuild!", 36);
			steginiteLol.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
			steginiteLol.borderSize = 2.4;
			steginiteLol.angle = -16;
			add(steginiteLol);

			tweenSteginite();
		}

		#if !mobile
		changeItem(0);
		#end
		super.create();
	}

	var selectedSomethin:Bool = false;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			#if mobile
			handleTouch();
			#else
			handleKeyboard();
			#end
		}

		super.update(elapsed);
	}

	#if mobile
	function handleTouch()
	{
		var overlapping:Bool = false;
		var lastTouched:Int = -1;

		for (touch in FlxG.touches.list)
		{
			for (i => item in menuItems)
			{
				if (touch.overlaps(item))
				{
					overlapping = true;
					lastTouched = i;

					item.animation.play('selected');
					item.alpha = 1;
					item.screenCenter(X);
				}
				else
				{
					item.animation.play('idle');
					item.alpha = 0.5;
					item.screenCenter(X);
				}
			}

			if (overlapping)
				if (touch.justReleased)
					checkSelection(lastTouched);
		}
	}
	#else
	function handleKeyboard()
	{
		if (controls.UI_UP_P)
			changeItem(-1);
		if (controls.UI_DOWN_P)
			changeItem(1);

		if (controls.BACK || FlxG.mouse.justPressedRight)
		{
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(() -> new TitleState());
		}

		if (controls.ACCEPT)
			checkSelection(curSelected);

		#if EDITORS_ALLOWED
		if (ALLOW_DEBUG_ACCESS && controls.justPressed('debug_1'))
		{
			selectedSomethin = true;
			FlxG.switchState(() -> new MasterEditorMenu());
		}
		#end

		secretsWololo();
	}

	var secretsVideo:VideoSprite;
	var secretsBG:FlxSprite;

	function secretsWololo()
	{
		if (FlxG.keys.justPressed.ANY)
		{
			leroyCodeStuff(FlxG.keys.firstJustPressed());
			gay(FlxG.keys.firstJustPressed());

			//trace("pressed key ID " + FlxG.keys.firstJustPressed());
		}
	}

	var leroyCode:Array<FlxKey> = [L, E, R, O, Y];
	var leroyPos:Int = 0;
	function leroyCodeStuff(input:FlxKey)
	{
		if (input == leroyCode[leroyPos])
		{
			leroyPos++;
			if (leroyPos >= leroyCode.length) playLeroy();
		}
		else
			leroyPos = 0;
	}

	var gayGay:Array<FlxKey> = [G, A, Y];
	var garry:Int = 0;
	function gay(gayy:FlxKey)
	{
		if (gayy == gayGay[garry])
		{
			garry++;
			if (garry >= gayGay.length) thenImGay();
		}
		else
			garry = 0;
	}

	function playLeroy()
	{
		selectedSomethin = true;

		FlxG.sound.music.pause();
		if (FreeplayState.vocals != null) FreeplayState.vocals.pause();

		secretsBG = new FlxSprite().makeGraphic(FlxG.width + 1, FlxG.height + 1, FlxColor.WHITE);
		secretsBG.scrollFactor.set();
		add(secretsBG);

		secretsVideo = new VideoSprite(Paths.getPath("videos/secrets/leroy.mov"), true);
		secretsVideo.finishCallback = closeSecretVideo;
		add(secretsVideo);

		secretsVideo.play();
		leroyPos = 0;
	}

	function thenImGay()
	{
		selectedSomethin = true;

		FlxG.sound.music.pause();
		if (FreeplayState.vocals != null) FreeplayState.vocals.pause();

		secretsBG = new FlxSprite().makeGraphic(FlxG.width + 1, FlxG.height + 1, FlxColor.WHITE);
		secretsBG.scrollFactor.set();
		add(secretsBG);

		secretsVideo = new VideoSprite(Paths.getPath("videos/secrets/gay.mov"), true);
		secretsVideo.finishCallback = closeSecretVideo;
		add(secretsVideo);

		secretsVideo.play();
		garry = 0;
	}

	function closeSecretVideo()
	{
		selectedSomethin = false;

		secretsBG.destroy();
		remove(secretsBG);

		secretsVideo = null;
		secretsBG = null;

		FlxG.sound.music.resume();
		if (FreeplayState.vocals != null) FreeplayState.vocals.resume();
	}

	function changeItem(huh:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + huh, 0, menuItems.length - 1);

		if (huh != 0) FlxG.sound.play(Paths.sound('scrollMenu'));

		for (i => item in menuItems.members)
		{
			if (i == curSelected)
			{
				item.animation.play('selected');
				item.alpha = 1;
				item.screenCenter(X);
			}
			else
			{
				item.animation.play('idle');
				item.alpha = 0.5;
				item.screenCenter(X);
			}
		}
	}
	#end

	function checkSelection(sus:Int)
	{
		if (optionShit[sus] == 'gallery')
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		}

		FlxG.sound.play(Paths.sound('confirmMenu'));
		selectedSomethin = true;

		FlxFlicker.flicker(menuItems.members[sus], 1, 0.06, false, false, _ ->
		{
			switch (optionShit[sus])
			{
				case 'story_mode':
					FlxG.switchState(() -> new StoryMenuState());
				case 'freeplay':
					FlxG.switchState(() -> new FreeplayState());
				case 'gallery':
					selectedSomethin = false;
				case 'credits':
					FlxG.switchState(() -> new SelectCreditsState());
				case 'options':
					FlxG.switchState(() -> new OptionsState());
					OptionsState.onPlayState = false;
					if (PlayState.SONG != null)
					{
						PlayState.SONG.arrowSkin = null;
						PlayState.SONG.splashSkin = null;
						PlayState.stageUI = 'normal';
					}
			}
		});

		for (i in 0...menuItems.members.length)
		{
			if (i == curSelected) continue;

			FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.4, {
				ease: FlxEase.quadOut,
				onComplete: function(twn:FlxTween)
				{
					menuItems.members[i].kill();
				}
			});
		}
	}

	var steginiteTween:FlxTween;

	function tweenSteginite()
	{
		steginiteTween = FlxTween.tween(steginiteLol, {"scale.x": 1.1, "scale.y": 1.1}, 0.2, {startDelay: 0.08, ease: FlxEase.quadIn});
		steginiteTween.then(FlxTween.tween(steginiteLol, {"scale.x": 1, "scale.y": 1}, 0.2, {ease: FlxEase.quadOut, onComplete: _ -> tweenSteginite()}));
	}

	override public function destroy()
	{
		super.destroy();

		if (steginiteTween != null)
		{
			steginiteTween.cancel();
			steginiteTween.cancelChain();
			steginiteTween.destroy();
		}
	}
}
