package options;

import backend.StageData;
import objects.Character;
import objects.Bar;
import flixel.addons.display.shapes.FlxShapeCircle;

import states.stages.StageWeek1 as BackgroundStage;

#if mobile
import objects.BackButton;
#end

class NoteOffsetState extends MusicBeatState
{
	static inline final DELAY_MAX:Int = 500;

	var stageDirectory:String = '';
	var boyfriend:Character;
	var gf:Character;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;

	var coolText:FlxText;
	var rating:FlxSprite;
	var comboNums:FlxSpriteGroup;
	var dumbTexts:FlxTypedGroup<FlxText>;

	var barPercent:Float = 0;
	var timeBar:Bar;
	var timeTxt:FlxText;
	var beatText:Alphabet;
	var beatTween:FlxTween;

	var changeModeText:FlxText;

	override public function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Adjusting Offsets", null);
		#end

		// Cameras
		camGame = initPsychCamera();
 
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);

		camOther = new FlxCamera();
		camOther.bgColor.alpha = 0;
		FlxG.cameras.add(camOther, false);

		FlxG.camera.scroll.set(-375, 130);

		persistentUpdate = true;
		FlxG.sound.pause();

		// Stage
		new BackgroundStage();

		// Characters
		gf = new Character(-200, 120, 'gf');
		gf.x += gf.positionArray[0];
		gf.y += gf.positionArray[1];
		gf.antialiasing = false;
		gf.scrollFactor.set(1, 1);
		boyfriend = new Character(420, 120, 'bf', true);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		boyfriend.antialiasing = false;
		add(gf);
		add(boyfriend);

		// Note delay stuff
		beatText = new Alphabet(0, 0, 'Wa Sans!', true);
		beatText.setScale(0.6, 0.6);
		beatText.x -= 400;
		beatText.alpha = 0;
		beatText.acceleration.y = 250;
		add(beatText);

		timeTxt = new FlxText(0, FlxG.height, FlxG.width, "", 32);
		timeTxt.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.borderSize = 2;
		timeTxt.cameras = [camHUD];
		timeTxt.y -= timeTxt.height + 100;

		barPercent = ClientPrefs.data.noteOffset;
		updateNoteDelay();

		timeBar = new Bar(0, timeTxt.y + timeTxt.height / 2, 'healthBar', function() return barPercent, -DELAY_MAX, DELAY_MAX);
		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.y -= timeBar.height / 2;
		timeBar.cameras = [camHUD];
		timeBar.leftBar.color = 0xFF43e390;

		add(timeBar);
		add(timeTxt);

		///////////////////////

		var blackBox:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 40, 0x6F000000);
		blackBox.scrollFactor.set();
		blackBox.cameras = [camHUD];
		add(blackBox);

		changeModeText = new FlxText(0, 1, FlxG.width, "Note / Beat Delay", 32);
		changeModeText.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, CENTER);
		changeModeText.scrollFactor.set();
		changeModeText.cameras = [camHUD];
		add(changeModeText);

		#if mobile
		var backButton:BackButton = new BackButton(0, 0, FlxColor.WHITE);
		backButton.x = FlxG.width - backButton.width - 60;
		backButton.y = FlxG.height - backButton.height - 28;
		backButton.onConfirmEnd.add(exitMenu);
		backButton.cameras = [camHUD];
		add(backButton);
		#end

		Conductor.bpm = 128.0;
		FlxG.sound.playMusic(Paths.music('offsetSong'), 1, true);

		super.create();
		FlxG.camera.zoom = 0.7;

		Main.fpsCounter.y = blackBox.y + blackBox.height;
	}

	var holdTime:Float = 0;
	#if mobile
	var moveLength:Float = 0;
	#end
	override public function update(elapsed:Float)
	{
		#if mobile
		if (PointerUtil.pressed)
		{
			final fpsMult:Float = FlxG.updateFramerate / 60;
			final delta:Float = PointerUtil.pointer.deltaViewX * fpsMult;

			if (Math.isFinite(delta) && Math.abs(delta) >= 2)
			{
				var dpiScale:Float = FlxG.stage.window.display.dpi / 160;
				dpiScale = FlxMath.bound(dpiScale, 0.5, #if android 1 #else 2 #end);

				var _moveLength:Float = delta / FlxG.updateFramerate / dpiScale * 2;
				moveLength += Math.abs(_moveLength);
				barPercent -= FlxMath.bound(_moveLength, -DELAY_MAX, DELAY_MAX);
				updateNoteDelay();
			}
		}
		#end

		var addNum:Int = 1;
		if (FlxG.keys.pressed.SHIFT || FlxG.gamepads.anyPressed(LEFT_SHOULDER))
			addNum = 3;

		if (controls.UI_LEFT_P)
		{
			barPercent = FlxMath.bound(ClientPrefs.data.noteOffset - 1, -DELAY_MAX, DELAY_MAX);
			updateNoteDelay();
		}
		else if (controls.UI_RIGHT_P)
		{
			barPercent = FlxMath.bound(ClientPrefs.data.noteOffset + 1, -DELAY_MAX, DELAY_MAX);
			updateNoteDelay();
		}

		var mult:Int = 1;
		if (controls.UI_LEFT || controls.UI_RIGHT)
		{
			holdTime += elapsed;
			if(controls.UI_LEFT) mult = -1;
		}

		if (controls.UI_LEFT_R || controls.UI_RIGHT_R) holdTime = 0;

		if (holdTime > 0.5)
		{
			barPercent += 100 * addNum * elapsed * mult;
			barPercent = FlxMath.bound(barPercent, -DELAY_MAX, DELAY_MAX);
			updateNoteDelay();
		}

		if (controls.RESET)
		{
			holdTime = 0;
			barPercent = 0;
			updateNoteDelay();
		}

		if (controls.BACK)
			exitMenu();

		#if android
		if (FlxG.android.justReleased.BACK)
			exitMenu();
		#end

		Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);
	}

	var zoomTween:FlxTween;
	var lastBeatHit:Int = -1;
	override public function beatHit()
	{
		super.beatHit();

		if (lastBeatHit == curBeat)
		{
			return;
		}

		if (curBeat % 2 == 0)
			boyfriend.dance();
		if (curBeat % 1 == 0)
			gf.dance();
		
		if (curBeat % 4 == 2)
		{
			// FlxG.camera.zoom = 1.15;
			FlxTween.cancelTweensOf(FlxG.camera);
			FlxTween.tween(FlxG.camera, {zoom: 0.74}, 0.12, {ease: FlxEase.cubeOut, onComplete: function(_) {
				FlxTween.tween(FlxG.camera, {zoom: 0.7}, 1, {ease: FlxEase.circOut});
			}});

			beatText.alpha = 1;
			beatText.y = 320;
			beatText.velocity.y = -150;
			if(beatTween != null) beatTween.cancel();
			beatTween = FlxTween.tween(beatText, {alpha: 0}, 1, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween)
				{
					beatTween = null;
				}
			});
		}

		lastBeatHit = curBeat;
	}

	function updateNoteDelay()
	{
		ClientPrefs.data.noteOffset = Math.round(barPercent);
		timeTxt.text = 'Current offset: ' + Math.floor(barPercent) + ' ms';
	}

	function exitMenu()
	{
		if (zoomTween != null) zoomTween.cancel();
		if (beatTween != null) beatTween.cancel();

		persistentUpdate = false;
		FlxG.switchState(() -> new options.OptionsState());

		if (OptionsState.onPlayState)
		{
			if (ClientPrefs.data.pauseMusic != 'None')
				FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)));
			else
				FlxG.sound.music.volume = 0;
		}
		else
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		PointerUtil.visible = false;
	}

	override function destroy()
	{
		super.destroy();
		Main.fpsCounter.y = 0;
	}
}