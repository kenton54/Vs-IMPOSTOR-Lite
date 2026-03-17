package options;

import states.MainMenuState;
import backend.StageData;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Note Colors', 'Controls', 'Adjust Delay', 'Graphics', 'Visuals and UI', 'Gameplay'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var onPlayState:Bool = false;

	function openSelectedSubstate(label:String)
	{
		switch(label) {
			case 'Note Colors':
				openSubState(new options.NotesSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust Delay':
				FlxG.switchState(() -> new options.NoteOffsetState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Looking at the options menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('sketch2'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.ID = i;
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState()
	{
		super.closeSubState();
		ClientPrefs.saveSettings();
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Looking at the options menu", null);
		#end
		FlxG.camera.scroll.x = 0;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if mobile
		var overlap:Bool = false;
		grpOptions.forEach(function(spr) {
			for (touch in FlxG.touches.list)
			{
				if (touch.overlaps(spr))
				{
					overlap = true;

					var lastSelect:Int = curSelected;
					curSelected = spr.ID;
					if (lastSelect != curSelected) FlxG.sound.play(Paths.sound('scrollMenu'));

					updateOptions();

					if (touch.justReleased)
						openSelectedSubstate(options[curSelected]);
				}
			}
		});

		if (!overlap)
		{
			curSelected = -1;
			updateOptions();
		}

		#if android
		if (FlxG.android.justReleased.BACK)
			FlxG.switchState(() -> new MainMenuState());
		#end
		#else
		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if(onPlayState)
			{
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(() -> new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else FlxG.switchState(() -> new MainMenuState());
		}

		if (controls.ACCEPT)
			openSelectedSubstate(options[curSelected]);
		#end
	}

	function changeSelection(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
		updateOptions();
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function updateOptions()
	{
		var bullshit:Int = 0;
		for (item in grpOptions.members)
		{
			item.targetY = bullshit - curSelected;
			bullshit++;

			item.alpha = 0.6;
			selectorLeft.visible = curSelected >= 0;
			selectorRight.visible = curSelected >= 0;

			if (item.targetY == 0)
			{
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}