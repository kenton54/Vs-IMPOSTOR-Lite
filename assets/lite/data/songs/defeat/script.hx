import backend.CoolUtil;
import objects.StrumNote;
import objects.VideoSprite;

import flixel.util.FlxSort;

import lime.app.Application;

import Main;

final MAX_MISSES:Int = 5;

var isLegacy:Bool = false;

var introVideo:VideoSprite;
var fadeSprite:FlxSprite;

function onCreate()
{
	introVideo = new VideoSprite(Paths.video("defeatIntro"), true);
	introVideo.cameras = [game.camHUD];
	introVideo.finishCallback = introFinished;
	add(introVideo);

	fadeSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
	fadeSprite.cameras = [game.camHUD];
	fadeSprite.alpha = 0;
	fadeSprite.visible = false;
	add(fadeSprite);

	if (platformTarget == 'desktop')
	{
		prepareDesktop();
	}
}

function prepareDesktop()
{
	var window = Application.current.window;

	window.borderless = true;
	window.maximized = false;
	window.resizable = false;
	FlxG.resizeWindow(1200, 900);

	window.x = (window.display.bounds.width - FlxG.stage.stageWidth) / 2;
	window.y = (window.display.bounds.height - FlxG.stage.stageHeight) / 2;
}

var events:Array<Dynamic> = [
	{
		section: 14,
		func: function()
		{
			introVideo.destroy();
			introFinished();
		}
	},
	{
		section: 15,
		func: function()
		{
			fadeInGameplay();
		}
	},
	{
		section: 33,
		func: function()
		{
			fadeInBackground();
		}
	},
	{
		section: 95,
		func: function()
		{
			fadeToLegacy();
		}
	},
	{
		section: 97,
		func: function()
		{
			fadeIntoLegacy();
		}
	},
	{
		section: 113,
		func: function()
		{
			fadeToLite();
		}
	},
	{
		section: 114,
		func: function()
		{
			fadeIntoLite();
		}
	}
];

function onCreatePost()
{
	game.timeBar.leftBar.color = 0xFFF03636;

	game.healthBar.visible = false;
	game.updateIconsPosition = defeatIconsPosition;
	game.updateIconsAnimation = defeatIconsAnimation;

	for (sprite in [game.iconP1, game.iconP2, game.scoreTxt, game.timeBar, game.timeTxt])
		sprite.visible = false;

	game.strumLineNotes.visible = false;

	events.sort((a, b) -> FlxSort.byValues(1, a.section, b.section));
}

var introPlayed:Bool = false;

function introFinished()
{
	introPlayed = true;
}

function preCountdownTick(swagCounter:Int)
{
	return Function_Stop;
}

function onKeyPressPre(key)
{
	if (!introPlayed)
		return Function_Stop;
}

function onUpdate(elapsed:Float)
{
	//updateLegacyFPSCounter();

	if (Conductor.songPosition >= -(Conductor.crochet * 1.65) && !introPlayed)
	{
		introVideo.play();
	}

	if (game.songMisses > MAX_MISSES && !isDead)
		game.health = 0;
}

function preUpdateScore(miss:Bool)
{
	var str:String = game.ratingName;
	if (totalPlayed != 0)
	{
		var percent:Float = CoolUtil.floorDecimal(game.ratingPercent * 100, 2);
		str += ' (' + percent + '%) - ' + game.ratingFC;
	}

	var scorStuff:String = "Score: " + game.songScore;

	if (!game.instakillOnMiss)
	{
		scorStuff += " | Misses: " + game.songMisses + " / " + MAX_MISSES;
	}

	scorStuff += " | Rating: " + str;
	scoreTxt.text = scorStuff + "\n";

	if (!miss && !game.cpuControlled)
		game.doScoreBop();

	return Function_Stop;
}

function defeatIconsPosition()
{
	var iconOffset:Int = 26;
	game.iconP1.x = game.healthBar.x + (game.healthBar.width / 2) + (150 * game.iconP1.scale.x - 150) / 2 - iconOffset;
	game.iconP2.x = game.healthBar.x + (game.healthBar.width / 2) - (150 * game.iconP2.scale.x) / 2 - iconOffset * 2;
}

function defeatIconsAnimation()
{
	if (!iconP1.isAnimatedIcon)
		game.iconP1.animation.curAnim.curFrame = (game.songMisses >= MAX_MISSES) ? 1 : 0;
	else
		game.iconP1.animation.play((game.songMisses >= MAX_MISSES) ? 'losing' : (game.songMisses < 1 ? 'winning' : 'normal'));

	if (!iconP2.isAnimatedIcon)
		game.iconP2.animation.curAnim.curFrame = (game.songMisses < MAX_MISSES) ? 1 : 0;
	else
		game.iconP2.animation.play((game.songMisses < 1) ? 'losing' : (game.songMisses >= MAX_MISSES ? 'winning' : 'normal'));
}

function onPause()
{
	introVideo.pause();
}

function onResume()
{
	introVideo.resume();
}

function onSectionHit()
{
	if (events.length > 0 && curSection >= events[events.length - 1].section)
	{
		var data:Dynamic = events.pop();

		if (data.func != null)
			data.func();
	}
}

function fadeInGameplay()
{
	var tweenDur:Float = (Conductor.stepCrochet / 1000) * 16;

	for (sprite in [game.iconP1, game.iconP2])
	{
		sprite.visible = !ClientPrefs.data.hideHud;
		sprite.alpha = 0;
		FlxTween.tween(sprite, {alpha: ClientPrefs.data.healthBarAlpha}, tweenDur);
	}

	game.scoreTxt.visible = !ClientPrefs.data.hideHud;

	for (sprite in [game.timeBar, game.timeTxt])
		sprite.visible = true;

	for (sprite in [game.scoreTxt, game.timeBar, game.timeTxt])
	{
		sprite.alpha = 0;
		FlxTween.tween(sprite, {alpha: 1}, tweenDur);
	}

	game.strumLineNotes.visible = true;

	for (strum in game.strumLineNotes.members)
	{
		strum.alpha = 0;
		var targetAlpha:Float = 1;

		if (strum.player < 1)
		{
			if (!ClientPrefs.data.opponentStrums)
				targetAlpha = 0;
			else if (ClientPrefs.data.middleScroll)
				targetAlpha = 0.35;
		}

		FlxTween.tween(strum, {alpha: targetAlpha}, tweenDur);
	}
}

function fadeInBackground()
{
	var bgCorpses:FlxSprite = game.getLuaObject("bgCorpses");
	var leftCorpses:FlxSprite = game.getLuaObject("leftCorpses");
	var rightCorpses:FlxSprite = game.getLuaObject("rightCorpses");
	var light:FlxSprite = game.getLuaObject("light");

	for (spr in [bgCorpses, leftCorpses, rightCorpses, light])
	{
		FlxTween.tween(spr, {alpha: 1}, 1);
	}
}

function fadeToLegacy()
{
	game.canPause = false;

	fadeSprite.visible = true;

	var sectionDur:Float = (Conductor.stepCrochet / 1000) * 16;
	FlxTween.tween(fadeSprite, {alpha: 1}, sectionDur);

	//Main.fpsCounter.alpha = 1;
	//FlxTween.tween(Main.fpsCounter, {alpha: 0}, sectionDur);

	if (platformTarget == "desktop")
	{
		var window = Application.current.window;
		var windowMidPoint:FlxPoint = FlxPoint.get(window.x + window.width / 2, window.y + window.height / 2);
		FlxTween.tween(window, {width: 1280, height: 720}, sectionDur, {
			startDelay: sectionDur,
			ease: FlxEase.quartInOut,
			onUpdate: _ ->
			{
				window.x = windowMidPoint.x - window.width / 2;
				window.y = windowMidPoint.y - window.height / 2;
			},
			onComplete: _ -> setUpLegacy()
		});
	}
	else
	{
		new FlxTimer().start(sectionDur, _ -> setUpLegacy());
	}
}

function setUpLegacy()
{
	isLegacy = true;

	Note.swagWidth = 160 * 0.7;

	game.changeUIStyle("legacy");
	game.legacyCameraMove = true;

	if (platformTarget == "desktop")
	{
		FlxG.width = FlxG.initialWidth = 1280;
		FlxG.height = FlxG.initialHeight = 720;
		FlxG.resizeGame(1280, 720);
		game.camGame.setSize(1280, 720);
		game.camHUD.setSize(1280, 720);
		game.camOther.setSize(1280, 720);
	}

	repositionNotes();

	for (note in game.notes.members)
		note.rgbShader.g = 0xFFFFFFFF;
	for (note in game.unspawnNotes)
		note.rgbShader.g = 0xFFFFFFFF;

	for (strum in game.strumLineNotes.members)
		strum.rgbShader.g = 0xFFFFFFFF;

	game.healthBar.screenCenter(0x01);
	game.healthBar.y = FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11);
	game.iconP1.y = game.iconP2.y = game.healthBar.y - 70;
	game.scoreTxt.y = game.healthBar.y + 40;

	fadeSprite.setGraphicSize(FlxG.width, FlxG.height);
	fadeSprite.updateHitbox();
	fadeSprite.screenCenter();

	game.scoreTxt.fieldWidth = FlxG.width;
	game.scoreTxt.font = Paths.font("vcr-real.ttf");
	game.scoreTxt.size = 20;
	game.scoreTxt.borderSize = 1.25;

	game.botplayTxt.y = ClientPrefs.data.downScroll ? timeBar.y - 78 : timeBar.y + 55;
	game.botplayTxt.fieldWidth = FlxG.width;
	game.botplayTxt.text = "BOTPLAY";
	game.botplayTxt.font = Paths.font("vcr-real.ttf");

	game.timeTxt.fieldWidth = FlxG.width;
	game.timeTxt.font = Paths.font("vcr-real.ttf");

	game.timeBar.screenCenter(0x01);
	game.timeBar.leftBar.color = 0xFFFF0000;
}

function repositionNotes()
{
	var strumX:Float = ClientPrefs.data.middleScroll ? (isLegacy ? -278 : PlayState.STRUM_X_MIDDLESCROLL) : PlayState.STRUM_X;
	var strumY:Float = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 50;

	var strumIndex:Int = 0;
	for (strum in strumLineNotes.members)
	{
		strum.x = strumX;
		strum.y = strumY;

		if (strumIndex <= 3) // opponent
		{
			if (ClientPrefs.data.middleScroll)
			{
				strum.x += 310;
				if (strumIndex > 1)
					strum.x += FlxG.width / 2 + 25;
			}
		}

		postPositionStrum(strum);
		strumIndex++;
	}
}

function postPositionStrum(strum:StrumNote)
{
	strum.x += Note.swagWidth * strum.noteData;
	strum.x += isLegacy ? 50 : 17.5;
	strum.x += (FlxG.width / 2) * strum.player;
}

function fadeIntoLegacy()
{
	game.canPause = true;
	game.doIconScale = true;
	game.dynamicScoreColors = false;

	game.scoreTxt.color = FlxColor.RED;

	//Application.current.window.title = "Impostor Legacy";
	//Main.fpsCounter.visible = false;
	//legacyFPSCounter.visible = true;

	FlxTween.tween(fadeSprite, {alpha: 0}, 1);

	//legacyFPSCounter.alpha = 0;
	//FlxTween.tween(legacyFPSCounter, {alpha: 1}, 1);
}

function fadeToLite()
{
	game.canPause = false;

	var fadeDur:Float = (Conductor.stepCrochet / 1000) * 14;
	var halfSection:Float = (Conductor.stepCrochet / 1000) * 8;
	FlxTween.tween(fadeSprite, {alpha: 1}, fadeDur);

	//legacyFPSCounter.alpha = 1;
	//FlxTween.tween(legacyFPSCounter, {alpha: 0}, fadeDur);

	if (platformTarget == "desktop")
	{
		var window = Application.current.window;
		var windowMidPoint:FlxPoint = FlxPoint.get(window.x + window.width / 2, window.y + window.height / 2);
		FlxTween.tween(window, {width: 1200, height: 900}, halfSection, {
			startDelay: halfSection,
			ease: FlxEase.quartInOut,
			onUpdate: _ ->
			{
				FlxG.width = FlxG.initialWidth = window.width;
				FlxG.height = FlxG.initialHeight = window.height;
				FlxG.resizeGame(window.width, window.height);
				game.camGame.setSize(window.width, window.height);
				game.camHUD.setSize(window.width, window.height);
				game.camOther.setSize(window.width, window.height);
	
				repositionNotes();
	
				fadeSprite.setGraphicSize(FlxG.width, FlxG.height);
				fadeSprite.updateHitbox();
				fadeSprite.screenCenter();
	
				game.healthBar.screenCenter(0x01);
				game.healthBar.y = FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11);
				game.iconP1.y = game.iconP2.y = game.healthBar.y - 70;
				game.scoreTxt.y = game.healthBar.y + 40;
	
				scoreTxt.fieldWidth = FlxG.width;
	
				game.botplayTxt.y = ClientPrefs.data.downScroll ? game.timeBar.y - 78 : game.timeBar.y + 55;
				game.botplayTxt.fieldWidth = FlxG.width;
	
				game.timeTxt.fieldWidth = FlxG.width;
				game.timeBar.screenCenter(0x01);
	
				window.x = windowMidPoint.x - window.width / 2;
				window.y = windowMidPoint.y - window.height / 2;
			},
			onComplete: _ -> setUpLite()
		});
	}
	else
	{
		new FlxTimer().start(halfSection, _ -> setUpLite());
	}
}

function setUpLite()
{
	exitLegacy();

	Note.swagWidth = 160 * 0.75;

	game.changeUIStyle();
	game.legacyCameraMove = false;

	repositionNotes();

	for (note in game.notes.members)
		note.rgbShader.g = 0xFF000000;
	for (note in game.unspawnNotes)
		note.rgbShader.g = 0xFF000000;

	for (strum in game.strumLineNotes.members)
		strum.rgbShader.g = 0xFF000000;

	game.healthBar.screenCenter(0x01);
	game.healthBar.y = FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11);
	game.iconP1.y = game.iconP2.y = game.healthBar.y - 70;
	game.scoreTxt.y = game.healthBar.y + 40;

	fadeSprite.setGraphicSize(FlxG.width, FlxG.height);
	fadeSprite.updateHitbox();
	fadeSprite.screenCenter();

	game.scoreTxt.fieldWidth = FlxG.width;
	game.scoreTxt.font = Paths.font("vcr.ttf");
	game.scoreTxt.size = 26;
	game.scoreTxt.borderSize = 2;

	game.botplayTxt.y = ClientPrefs.data.downScroll ? game.timeBar.y - 78 : game.timeBar.y + 55;
	game.botplayTxt.fieldWidth = FlxG.width;
	game.botplayTxt.text = "AUTO";
	game.botplayTxt.font = Paths.font("vcr.ttf");

	game.timeTxt.fieldWidth = FlxG.width;
	game.timeTxt.font = Paths.font("vcr.ttf");

	game.timeBar.screenCenter(0x01);
	game.timeBar.leftBar.color = 0xFFF03636;
}

function exitLegacy()
{
	isLegacy = false;

	if (platformTarget == 'desktop')
	{
		FlxG.width = FlxG.initialWidth = 1200;
		FlxG.height = FlxG.initialHeight = 900;
		FlxG.resizeGame(1200, 900);
		game.camGame.setSize(1200, 900);
		game.camHUD.setSize(1200, 900);
		game.camOther.setSize(1200, 900);
	}
}

function fadeIntoLite()
{
	game.canPause = true;
	game.doIconScale = false;
	game.dynamicScoreColors = true;

	//Application.current.window.title = "Vs. Impostor: Lite";
	//Main.fpsCounter.visible = true;
	//legacyFPSCounter.visible = false;

	FlxTween.tween(fadeSprite, {alpha: 0}, 1);

	//Main.fpsCounter.alpha = 0;
	//FlxTween.tween(Main.fpsCounter, {alpha: 1}, 1);
}

function onDestroy()
{
	Main.fpsCounter.visible = true;

	if (platformTarget == 'desktop')
	{
		restoreDesktop();
	}

	Note.swagWidth = 160 * 0.75;
}

function restoreDesktop()
{
	var window = Application.current.window;

	window.borderless = false;
	window.maximized = false;
	window.resizable = true;
	FlxG.resizeWindow(1200, 900);

	FlxG.width = FlxG.initialWidth = 1200;
	FlxG.height = FlxG.initialHeight = 900;
	FlxG.resizeGame(1200, 900);
	game.camGame.setSize(1200, 900);
	game.camHUD.setSize(1200, 900);
	game.camOther.setSize(1200, 900);
	game.camCountdown.setSize(1200, 900);
	game.camDialogue.setSize(1200, 900);

	window.x = (window.display.bounds.width - FlxG.stage.stageWidth) / 2;
	window.y = (window.display.bounds.height - FlxG.stage.stageHeight) / 2;
}