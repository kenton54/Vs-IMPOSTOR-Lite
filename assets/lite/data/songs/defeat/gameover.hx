import lime.app.Application;
import psychlua.CustomSubstate;
import states.FreeplayState;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxObject;

var canInput:Bool = false;

function onGameOver()
{
	FlxG.animationTimeScale = 1;
	boyfriend.stunned = true;
	PlayState.deathCounter += 1;

	game.vocals.stop();
	game.opponentVocals.stop();
	FlxG.sound.music.stop();

	FlxTimer.globalManager.clear();
	FlxTween.globalManager.clear();

	Conductor.songPosition = 0;

	game.isDead = true;

	if (isLegacy)
		playLegacyGameOver();
    else
		playLiteGameOver();

	return Function_Stop;
}

function playLiteGameOver()
{
	CustomSubstate.openCustomSubstate("liteGameOver", true);
}

function playLegacyGameOver()
{
    game.KillNotes();

	FlxG.sound.play(Paths.sound("killFanfare"));

	game.isCameraOnForcedPos = true;
	game.camFollow.setPosition(550 - 500, 500 - 230);
	game.defaultCamZoom = 0.65;

	FlxTween.tween(game.camHUD, {alpha: 0}, 0.7, {ease: FlxEase.quadInOut});

    dad.playAnim("kill1");
    dad.stunned = true;

	new FlxTimer().start(1.8, _ ->
	{
		dad.playAnim("kill2");
		game.defaultCamZoom = 0.5;

		game.camFollow.setPosition(750 - 500, 450 - 230);
	});

	new FlxTimer().start(2.7, _ ->
	{
		dad.playAnim("kill3");
	});

    new FlxTimer().start(3.4, _ ->
    {
		CustomSubstate.openCustomSubstate("legacyGameOver", true);
    });
}

var liteGameOverGraphic:FlxSprite;
var deadBoyfriend:Character;
var camFollowGameOver:FlxObject;
var camFollowTarget:FlxObject;

var ballsDeath:Bool = false;

function onCustomSubstateCreate(name:String)
{
	if (name == "liteGameOver")
    {
		game.camGame.visible = game.camHUD.visible = false;

        FlxG.sound.play(Paths.sound("kill"));

		CustomSubstate.instance.cameras = [game.camPause];

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		CustomSubstate.instance.add(bg);

		liteGameOverGraphic = new FlxSprite().loadGraphic(Paths.image("bg/defeat/gameover"));
		liteGameOverGraphic.setGraphicSize(0, FlxG.height);
		liteGameOverGraphic.updateHitbox();
		liteGameOverGraphic.screenCenter();
		liteGameOverGraphic.alpha = 0;
		CustomSubstate.instance.add(liteGameOverGraphic);

		new FlxTimer().start(3, _ -> startLiteGameOver());
    }
	else if (name == "legacyGameOver")
    {
		ballsDeath = FlxG.random.bool(10);
		game.camHUD.visible = false;

		FlxG.sound.play(Paths.sound(ballsDeath ? "defeatKillBalls" : "defeatKill"));

		CustomSubstate.instance.cameras = [game.camGame];

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width * 4, FlxG.height * 4);
		bg.updateHitbox();
		bg.setPosition(FlxG.camera.scroll.x - (FlxG.camera.width / 2), FlxG.camera.scroll.y - (FlxG.camera.width / 2));
		bg.scrollFactor.set();
		CustomSubstate.instance.add(bg);

		deadBoyfriend = new Character(boyfriend.x, boyfriend.y, boyfriend.curCharacter, true);
		deadBoyfriend.playAnim("firstDeath" + (ballsDeath ? "-balls" : ""));
		deadBoyfriend.animation.finishCallback = startLegacyGameOver;
		CustomSubstate.instance.add(deadBoyfriend);

		camFollowGameOver = new FlxObject(0, 0, 1, 1);
		camFollowGameOver.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		CustomSubstate.instance.add(camFollowGameOver);

		var bfMidpoint:FlxPoint = deadBoyfriend.getMidpoint();

		camFollowTarget = new FlxObject(0, 0, 1, 1);
		camFollowTarget.setPosition(bfMidpoint.x, bfMidpoint.y);
		CustomSubstate.instance.add(camFollowTarget);

		bfMidpoint.put();
    }
}

function startLiteGameOver()
{
	FlxTween.tween(liteGameOverGraphic, {alpha: 1}, 2);
	FlxG.sound.playMusic(Paths.music('blackPause'));

	canInput = true;
}

function startLegacyGameOver()
{
	if (StringTools.startsWith(deadBoyfriend.animation.curAnim.name, "firstDeath"))
	{
		FlxG.sound.playMusic(Paths.music('legacyGameOver-loop'));
		deadBoyfriend.playAnim("deathLoop" + (ballsDeath ? "-balls" : ""));

		canInput = true;
	}
}

var canUpdateCamera:Bool = false;
var isEnding:Bool = false;

function onCustomSubstateUpdate(name:String, elapsed:Float)
{
	if (name == "liteGameOver")
    {
        if (canInput)
        {
            if (controls.BACK)
				exitSong();

            if (controls.ACCEPT)
				transitionLiteOut();
        }
    }
	else if (name == "legacyGameOver")
    {
		if (canUpdateCamera)
		{
			camFollowGameOver.x = CoolUtil.fpsLerp(camFollowGameOver.x, camFollowTarget.x, 0.01);
			camFollowGameOver.y = CoolUtil.fpsLerp(camFollowGameOver.y, camFollowTarget.y, 0.01);
		}

		if (StringTools.startsWith(deadBoyfriend.animation.curAnim.name, "firstDeath") && deadBoyfriend.animation.curAnim.curFrame >= 12 && !canUpdateCamera)
        {
			FlxG.camera.follow(camFollowGameOver, FlxCameraFollowStyle.LOCKON, 1);
			canUpdateCamera = true;
        }

		if (canInput)
		{
			if (controls.ACCEPT)
				transitionLegacyOutConfirm();

			if (controls.BACK)
				transitionLegacyOutDeny();
		}
    }
}

function transitionLiteOut()
{
	canInput = false;

	FlxG.sound.music.fadeOut(2);
	FlxTween.cancelTweensOf(liteGameOverGraphic);
	FlxTween.tween(liteGameOverGraphic, {alpha: 0}, 2, {onComplete: _ -> FlxG.resetState()});
}

function transitionLegacyOutConfirm()
{
	canInput = false;

	FlxG.sound.playMusic(Paths.music('legacyGameOver-end'), 1, false);
	deadBoyfriend.playAnim("deathConfirm" + (ballsDeath ? "-balls" : ""));

	new FlxTimer().start(0.7, _ ->
	{
		CustomSubstate.instance.camera.fade(FlxColor.BLACK, 2, false, () ->
		{
			fixWindowRect(() -> FlxG.resetState());
		});
	});
}

function transitionLegacyOutDeny()
{
	canInput = false;

	FlxG.sound.music.fadeOut(2);
	CustomSubstate.instance.camera.fade(FlxColor.BLACK, 2, false, () ->
	{
		fixWindowRect(exitSong);
	});
}

function fixWindowRect(finishCall:Void->Void)
{
	if (platformTarget == "desktop")
	{
		var window = Application.current.window;
		var windowMidPoint:FlxPoint = FlxPoint.get(window.x + window.width / 2, window.y + window.height / 2);
		FlxTween.tween(window, {width: 1200, height: 900}, 1, {
			ease: FlxEase.quartInOut,
			onUpdate: _ ->
			{
				FlxG.width = FlxG.initialWidth = window.width;
				FlxG.height = FlxG.initialHeight = window.height;
				FlxG.resizeGame(window.width, window.height);
				CustomSubstate.instance.camera.setSize(window.width, window.height);

				window.x = windowMidPoint.x - window.width / 2;
				window.y = windowMidPoint.y - window.height / 2;
			},
			onComplete: _ ->
			{
				FlxG.resizeGame(1200, 900);
				new FlxTimer().start(0.1, _ -> finishCall());
			}
		});
	}
	else
	{
		finishCall();
	}
}

function exitSong()
{
	canInput = false;

	FlxG.switchState(() -> new FreeplayState());

	FlxG.sound.playMusic(Paths.music('freakyMenu'));
	PlayState.changedDifficulty = false;
	PlayState.chartingMode = false;
	game.transitioning = true;

	FlxG.camera.followLerp = 0;
	if (game.cameraTween != null) game.cameraTween.active = false;
}