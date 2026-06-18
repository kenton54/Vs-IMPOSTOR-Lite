import objects.StrumNote;
import objects.VideoSprite;
import flixel.util.FlxSort;
import lime.app.Application;
import openfl.text.TextField;
import openfl.text.TextFormat;
import Main;

final MAX_MISSES:Int = 5;

var isLegacy:Bool = false;

var introVideo:VideoSprite;
var fadeSprite:FlxSprite;
var legacyFPSCounter:TextField;

function onCreate()
{
	introVideo = new VideoSprite(Paths.video("defeatIntro"), true);
	introVideo.cameras = [game.camHUD];
	introVideo.finishCallback = introFinished;
	add(introVideo);

	fadeSprite = new FlxSprite().makeGraphic(FlxG.width + 2, FlxG.height + 2, FlxColor.WHITE);
	fadeSprite.screenCenter();
	fadeSprite.cameras = [game.camHUD];
	fadeSprite.alpha = 0;
	fadeSprite.visible = false;
	add(fadeSprite);

	if (platformTarget == 'desktop')
	{
		prepareDesktop();
	}

	legacyFPSCounter = new TextField();
	legacyFPSCounter.x = 10;
	legacyFPSCounter.y = 3;
	legacyFPSCounter.selectable = legacyFPSCounter.mouseEnabled = false;
	legacyFPSCounter.defaultTextFormat = new TextFormat("_sans", 12, 0xFFFFFF);
	legacyFPSCounter.visible = ClientPrefs.data.showFPS;
	legacyFPSCounter.text = "FPS: 0";
	legacyFPSCounter.alpha = 0;
	FlxG.addChildBelowMouse(legacyFPSCounter);

	game.setOnScripts("isLegacy", isLegacy);
}

function prepareDesktop()
{
	var window = Application.current.window;

	window.borderless = true;
	window.maximized = false;
	window.resizable = false;
	FlxG.resizeWindow(1200, 900);

	window.x = (window.display.bounds.width - 1200) / 2;
	window.y = (window.display.bounds.height - 900) / 2;
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

var bfPosition:FlxPoint;
var blackPosition:FlxPoint;

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

	remove(game.dadGroup);
	insert(game.members.indexOf(game.boyfriendGroup) + 1, game.dadGroup);

	bfPosition = FlxPoint.get(boyfriend.x, boyfriend.y);
	blackPosition = FlxPoint.get(dad.x, dad.y);
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

var legacyFPSCount:Int = 0;
var legacyCacheCount:Int = 0;
var legacyFPSCurTime:Float = 0;
var legacyFPSTimes:Array<Float> = [];
var legacyLastFPSTxt:String = "";

function updateLegacyFPSCounter(elapsed:Float)
{
	legacyFPSCurTime += elapsed;
	legacyFPSTimes.push(legacyFPSCurTime);

	while (legacyFPSTimes[0] < legacyFPSCurTime - 1)
		legacyFPSTimes.shift();

	var curCount:Int = legacyFPSTimes.length;
	legacyFPSCount = Std.int((curCount + legacyCacheCount) / 2);

	if (curCount != legacyCacheCount)
	{
		var newText:String = "FPS: " + legacyFPSCount;

		if (newText != legacyLastFPSTxt)
		{
			legacyFPSCounter.text = newText;
			legacyLastFPSTxt = newText;
		}
	}

	legacyCacheCount = legacyFPSTimes.length;
}

function onUpdate(elapsed:Float)
{
	updateLegacyFPSCounter(elapsed);

	if (Conductor.songPosition >= -(Conductor.crochet * 1.65) && !introPlayed)
		introVideo.play();

	if (game.songMisses > MAX_MISSES && !isDead)
		game.health = 0;

	if (isLegacy)
		followCharacterMovement();

	game.setOnScripts("isLegacy", isLegacy);
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
	var bfIconAnim:String = game.songMisses >= MAX_MISSES ? 'losing' : (game.songMisses < 1 ? 'winning' : 'normal');
	var bfAnimIndex:Int = game.songMisses >= MAX_MISSES ? 1 : 0;
	var dadIconAnim:String = game.songMisses < 1 ? 'losing' : (game.songMisses >= MAX_MISSES ? 'winning' : 'normal');
	var dadAnimIndex:Int = game.songMisses < 1 ? 1 : 0;

	if (isLegacy)
	{
		bfIconAnim = dadIconAnim = 'normal';
		bfAnimIndex = dadAnimIndex = 0;
	}

	if (!game.iconP1.isAnimatedIcon)
		game.iconP1.animation.curAnim.curFrame = bfAnimIndex;
	else
		game.iconP1.animation.play(bfIconAnim);

	if (!game.iconP2.isAnimatedIcon)
		game.iconP2.animation.curAnim.curFrame = dadAnimIndex;
	else
		game.iconP2.animation.play(dadIconAnim);
}

function onPause()
{
	introVideo.pause();
}

function onResume()
{
	introVideo.resume();
}

function onFocusLost()
{
	if (!game.paused)
		introVideo.pause();
}

function onFocus()
{
	if (!game.paused)
		introVideo.resume();
}

function onGameOver()
{
	introVideo.destroy();
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

var positionFixLol:Array<Float> = [-500, -230];
var followCameraPos:Array<Float> = [750, 500];
var followIntensity:Float = 20;

function followCharacterMovement()
{
	if (mustHitSection)
	{
		switch (boyfriend.animation.curAnim.name)
		{
			case "singLEFT":
				game.camFollow.setPosition(followCameraPos[0] + positionFixLol[0], followCameraPos[1] + positionFixLol[1]);
				game.camFollow.x -= followIntensity;

			case "singDOWN":
				game.camFollow.setPosition(followCameraPos[0] + positionFixLol[0], followCameraPos[1] + positionFixLol[1]);
				game.camFollow.y += followIntensity;

			case "singUP":
				game.camFollow.setPosition(followCameraPos[0] + positionFixLol[0], followCameraPos[1] + positionFixLol[1]);
				game.camFollow.y -= followIntensity;

			case "singRIGHT":
				game.camFollow.setPosition(followCameraPos[0] + positionFixLol[0], followCameraPos[1] + positionFixLol[1]);
				game.camFollow.x += followIntensity;

			default:
				game.camFollow.setPosition(followCameraPos[0] + positionFixLol[0], followCameraPos[1] + positionFixLol[1]);
		}
	}
	else
	{
		switch (dad.animation.curAnim.name)
		{
			case "singLEFT":
				game.camFollow.setPosition(followCameraPos[0] + positionFixLol[0], followCameraPos[1] + positionFixLol[1]);
				game.camFollow.x -= followIntensity;

			case "singDOWN":
				game.camFollow.setPosition(followCameraPos[0] + positionFixLol[0], followCameraPos[1] + positionFixLol[1]);
				game.camFollow.y += followIntensity;

			case "singUP":
				game.camFollow.setPosition(followCameraPos[0] + positionFixLol[0], followCameraPos[1] + positionFixLol[1]);
				game.camFollow.y -= followIntensity;

			case "singRIGHT":
				game.camFollow.setPosition(followCameraPos[0] + positionFixLol[0], followCameraPos[1] + positionFixLol[1]);
				game.camFollow.x += followIntensity;

			default:
				game.camFollow.setPosition(followCameraPos[0] + positionFixLol[0], followCameraPos[1] + positionFixLol[1]);
		}
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
	game.scoreTxt.alpha = 0;
	FlxTween.tween(game.scoreTxt, {alpha: 1}, tweenDur);

	game.strumLineNotes.visible = true;

	for (strum in game.strumLineNotes.members)
	{
		strum.alpha = 0;
		var targetAlpha:Float = 1;

		if (strum.player < 1)
			targetAlpha = 0;

		FlxTween.tween(strum, {alpha: targetAlpha}, tweenDur);
	}

	repositionNotes();
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

	Main.fpsCounter.text.alpha = 1;
	Main.fpsCounter.underlay.alpha = 0x6F / 0xFF;
	FlxTween.tween(Main.fpsCounter.text, {alpha: 0}, sectionDur);
	FlxTween.tween(Main.fpsCounter.underlay, {alpha: 0}, sectionDur);

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

	fadeSprite.setGraphicSize(FlxG.width + 2, FlxG.height + 2);
	fadeSprite.updateHitbox();
	fadeSprite.screenCenter();

	game.scoreTxt.fieldWidth = FlxG.width;
	game.scoreTxt.font = Paths.font("vcr-real");
	game.scoreTxt.size = 20;
	game.scoreTxt.borderSize = 1.25;

	game.botplayTxt.y = ClientPrefs.data.downScroll ? timeBar.y - 78 : timeBar.y + 55;
	game.botplayTxt.fieldWidth = FlxG.width;
	game.botplayTxt.text = "BOTPLAY";
	game.botplayTxt.size = 32;
	game.botplayTxt.font = Paths.font("vcr-real");

	game.timeTxt.fieldWidth = FlxG.width;
	game.timeTxt.font = Paths.font("vcr-real");

	game.timeBar.screenCenter(0x01);
	game.timeBar.leftBar.color = 0xFFFF0000;
}

function repositionNotes()
{
	var strumX:Float = isLegacy ? -278 : PlayState.STRUM_X_MIDDLESCROLL;
	var strumY:Float = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 50;

	var strumIndex:Int = 0;
	for (strum in game.strumLineNotes.members)
	{
		strum.x = strumX;
		strum.y = strumY;

		if (strumIndex <= 3) // opponent
		{
			strum.x += 310;
			if (strumIndex > 1)
				strum.x += FlxG.width / 2 + 25;
		}

		postPositionStrum(strum);
		strumIndex += 1;
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

	changeBackground(true);
	FlxG.camera.zoom = game.defaultCamZoom = 0.5;

	game.camFollow.setPosition(followCameraPos[0] + positionFixLol[0], followCameraPos[1] + positionFixLol[1]);
	snapCameraToTarget();
	game.isCameraOnForcedPos = true;

	game.scoreTxt.color = FlxColor.RED;

	FlxTween.tween(fadeSprite, {alpha: 0}, 1);

	Main.fpsCounter.text.alpha = 0;
	Main.fpsCounter.underlay.alpha = 0;
	legacyFPSCounter.alpha = 0;
	FlxTween.tween(legacyFPSCounter, {alpha: 1}, 1);

	boyfriend.setPosition(1000 + positionFixLol[0], 100 + positionFixLol[1]);
	boyfriend.x += boyfriend.positionArray[0];
	boyfriend.y += boyfriend.positionArray[1];

	dad.setPosition(210 + positionFixLol[0], 100 + positionFixLol[1]);
	dad.x += dad.positionArray[0];
	dad.y += dad.positionArray[1];
}

function fadeToLite()
{
	game.canPause = false;

	var fadeDur:Float = (Conductor.stepCrochet / 1000) * 14;
	var halfSection:Float = (Conductor.stepCrochet / 1000) * 8;
	FlxTween.tween(fadeSprite, {alpha: 1}, fadeDur);

	legacyFPSCounter.alpha = 1;
	FlxTween.tween(legacyFPSCounter, {alpha: 0}, fadeDur);

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

				fadeSprite.setGraphicSize(FlxG.width + 2, FlxG.height + 2);
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

	fadeSprite.setGraphicSize(FlxG.width + 2, FlxG.height + 2);
	fadeSprite.updateHitbox();
	fadeSprite.screenCenter();

	game.scoreTxt.fieldWidth = FlxG.width;
	game.scoreTxt.font = Paths.font("vcr");
	game.scoreTxt.size = 26;
	game.scoreTxt.borderSize = 2;

	game.botplayTxt.y = ClientPrefs.data.downScroll ? game.timeBar.y - 78 : game.timeBar.y + 55;
	game.botplayTxt.fieldWidth = FlxG.width;
	game.botplayTxt.text = "AUTO";
	game.botplayTxt.font = Paths.font("vcr");

	game.timeTxt.fieldWidth = FlxG.width;
	game.timeTxt.font = Paths.font("vcr");

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

	changeBackground(false);
	FlxG.camera.zoom = game.defaultCamZoom = 0.5;
	game.isCameraOnForcedPos = false;

	FlxTween.tween(fadeSprite, {alpha: 0}, 1);

	Main.fpsCounter.text.alpha = 0;
	Main.fpsCounter.underlay.alpha = 0;
	legacyFPSCounter.alpha = 0;
	FlxTween.tween(Main.fpsCounter.text, {alpha: 1}, 1);
	FlxTween.tween(Main.fpsCounter.underlay, {alpha: 0x6F / 0xFF}, 1);

	boyfriend.setPosition(bfPosition.x, bfPosition.y);
	dad.setPosition(blackPosition.x, blackPosition.y);
}

function snapCameraToTarget()
{
	var camera:FlxCamera = FlxG.camera;

	var targetX:Float = game.camFollow.x;
	var targetY:Float = game.camFollow.y;
	var targetWidth:Float = game.camFollow.width;
	var targetHeight:Float = game.camFollow.height;

	if (camera.deadzone == null)
	{
		camera._scrollTarget.x = targetX + targetWidth * 0.5;
		camera._scrollTarget.y = targetY + targetHeight * 0.5;
	}
	else
	{
		var edgeL:Float = targetX - camera.deadzone.x;
		var edgeR:Float = targetX + targetWidth - camera.deadzone.x - camera.deadzone.width;
		var edgeU:Float = targetY - camera.deadzone.y;
		var edgeD:Float = targetY + targetHeight - camera.deadzone.x - camera.deadzone.width;

		if (camera._scrollTarget.x > edgeL)
			camera._scrollTarget.x = edgeL;

		if (camera._scrollTarget.x < edgeR)
			camera._scrollTarget.x = edgeR;

		if (camera._scrollTarget.y > edgeU)
			camera._scrollTarget.y = edgeU;

		if (camera._scrollTarget.y < edgeD)
			camera._scrollTarget.y = edgeD;
	}
}

function changeBackground(toLegacy:Bool)
{
	game.getLuaObject("mainBG").visible = !toLegacy;
	game.getLuaObject("bgCorpses").visible = !toLegacy;
	game.getLuaObject("light").visible = !toLegacy;
	game.getLuaObject("leftCorpses").visible = !toLegacy;
	game.getLuaObject("rightCorpses").visible = !toLegacy;
	game.getLuaObject("vignette").visible = !toLegacy;

	game.getLuaObject("legacyBG").visible = toLegacy;
	game.getLuaObject("legacyBGCorpses").visible = toLegacy;
	game.getLuaObject("legacyBackCorpses").visible = toLegacy;
	game.getLuaObject("legacyFrontCorpses").visible = toLegacy;
	game.getLuaObject("legacyLight").visible = toLegacy;
}

function onDestroy()
{
	Main.fpsCounter.text.alpha = 1;
	Main.fpsCounter.underlay.alpha = 0x6F / 0xFF;

	if (platformTarget == 'desktop')
	{
		restoreDesktop();
	}

	Note.swagWidth = 160 * 0.75;

	legacyFPSCounter = null;
	FlxG.removeChild(legacyFPSCounter);
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

	window.x = (window.display.bounds.width - 1200) / 2;
	window.y = (window.display.bounds.height - 900) / 2;
}