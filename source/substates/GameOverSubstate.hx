package substates;

import backend.WeekData;

import objects.Character;
import flixel.FlxObject;
import flixel.FlxSubState;

import states.StoryMenuState;
import states.FreeplayState;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Character;
	var camFollow:FlxObject;
	public var camGameover:FlxCamera;
	var moveCamera:Bool = false;

	public static var characterName:String = 'bf';
	public static var deathSoundName:String = 'loss';

	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'bf';
		deathSoundName = 'loss';

		var _song = PlayState.SONG;
		if(_song != null)
		{
			if(_song.gameOverChar != null && _song.gameOverChar.trim().length > 0) characterName = _song.gameOverChar;
			if(_song.gameOverSound != null && _song.gameOverSound.trim().length > 0) deathSoundName = _song.gameOverSound;
		}
	}

	var charX:Float = 0;
	var charY:Float = 0;
	var bfLose:FlxSprite;
	var bgDarkS:FlxSprite;

	override function create()
	{
		instance = this;
		Conductor.songPosition = 0;

		camGameover = new FlxCamera();
		camGameover.bgColor.alpha = 0;
		FlxG.cameras.add(camGameover, false);

		bgDarkS = new FlxSprite();
		bgDarkS.antialiasing = ClientPrefs.data.antialiasing;
		bgDarkS.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bgDarkS.alpha = 0;
		bgDarkS.cameras = [camGameover];
		add(bgDarkS);

		bfLose = new FlxSprite().loadGraphic(Paths.image('ingame/gameover'));
		bfLose.setGraphicSize(0, FlxG.height);
		bfLose.updateHitbox();
		bfLose.screenCenter();
		bfLose.antialiasing = ClientPrefs.data.antialiasing;
		bfLose.y -= bfLose.height;
		bfLose.cameras = [camGameover];
		add(bfLose);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(PlayState.instance.boyfriend.getGraphicMidpoint().x, PlayState.instance.boyfriend.getGraphicMidpoint().y);
		// FlxG.camera.focusOn(new FlxPoint(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2)));
		add(camFollow);

		switch(PlayState.instance.boyfriend.curCharacter)
		{
			case 'bf-ghost':
				PlayState.instance.boyfriend.visible = false;
				PlayState.instance.gf.visible = false;

				for(i in 0...2)
				{
					var arrowSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('disconnectedArrow'));
					arrowSpr.antialiasing = true;
					arrowSpr.updateHitbox();
					arrowSpr.setPosition(25, FlxG.height - arrowSpr.height - 30);
					arrowSpr.alpha = 1;
					add(arrowSpr);

					var disTxt:FlxText = new FlxText(arrowSpr.x + arrowSpr.width + 5, arrowSpr.y, 0, ["Girlfriend", "Boyfriend"][i] + " left the game.");
					disTxt.setFormat(Paths.font("vcr"), 20, 0xffff4747, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					disTxt.borderSize = 1.5;
					add(disTxt);

					for(spr in [arrowSpr, disTxt]) {
						spr.cameras = [camGameover];

						if(i == 0) spr.y -= 45;
					}

					FlxTween.tween(arrowSpr, {alpha: 0}, 1.6, {startDelay: 6});
					FlxTween.tween(disTxt, {alpha: 0}, 1.6, {startDelay: 6});
				}

				FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.15}, 1, {ease: FlxEase.quadOut});
				deathSoundName = 'leftGame';

			default:
				PlayState.instance.boyfriend.playAnim('firstDeath');
				FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.2}, 1, {ease: FlxEase.quadOut});
		}
		moveItDown();

		FlxG.sound.play(Paths.sound(deathSoundName));

		PlayState.instance.setOnScripts('inGameOver', true);
		PlayState.instance.callOnScripts('onGameOverStart', []);

		super.create();
	}

	public var startedDeath:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnScripts('onUpdate', [elapsed]);

		if (controls.ACCEPT) {
			endBullshit();
		}

		if (controls.BACK)
		{
			#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;
			PlayState.chartingMode = false;

			Mods.loadTopMod();
			if (PlayState.isStoryMode)
				FlxG.switchState(() -> new StoryMenuState());
			else
				FlxG.switchState(() -> new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.instance.callOnScripts('onGameOverConfirm', [false]);
		}
		
		if (FlxG.sound.music.playing) {
			Conductor.songPosition = FlxG.sound.music.time;
		}

		PlayState.instance.callOnScripts('onUpdatePost', [elapsed]);
	}

	var isEnding:Bool = false;
	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			FlxG.sound.music.stop();
			new FlxTimer().start(0.7, _ ->
			{
				camGameover.fade(FlxColor.BLACK, 2, false, function() {
					FlxG.resetState();
				});
			});
			PlayState.instance.callOnScripts('onGameOverConfirm', [true]);
		}
	}

	function moveItDown()
	{
		PlayState.instance.moveCameraLite(true, (7.5 * (60 / FlxG.updateFramerate)), FlxEase.expoOut);
		new FlxTimer().start(1.4, _ ->
		{
			FlxG.sound.play(Paths.sound('gameOver'));
			FlxTween.tween(bfLose, {y: 0}, 1.1, {ease: FlxEase.smootherStepInOut});
			FlxTween.tween(bgDarkS, {alpha: 0.5}, 1.1, {ease: FlxEase.smootherStepInOut});
		});
	}

	override function destroy()
	{
		instance = null;
		super.destroy();
	}
}
