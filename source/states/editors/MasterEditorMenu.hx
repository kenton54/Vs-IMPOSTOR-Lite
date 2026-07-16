package states.editors;

#if EDITORS_ALLOWED
import backend.WeekData;

import objects.Character;

import states.FreeplayState;
import states.MainMenuState;

class MasterEditorMenu extends MusicBeatState
{
	var options:Array<String> = [
		'Chart Editor',
		'Character Editor',
		'Dialogue Editor',
		'Note Splash Editor'
	];

	var grpTexts:FlxTypedGroup<Alphabet>;
	var directories:Array<String> = [null];

	static var curSelected = 0;

	var curDirectory = 0;
	var directoryTxt:FlxText;

	override function create()
	{
		persistentUpdate = true;

		// FlxG.camera.bgColor = FlxColor.BLACK;
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Editors Main Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('sketch2'));
		bg.scrollFactor.set();
		bg.color = 0xFF353535;
		add(bg);

		grpTexts = new FlxTypedGroup<Alphabet>();
		add(grpTexts);

		for (i in 0...options.length)
		{
			var leText:Alphabet = new Alphabet(90, 320, options[i], true);
			leText.isMenuItem = true;
			leText.targetY = i;
			grpTexts.add(leText);
			leText.snapToPosition();
		}

		changeSelection();

		FlxG.mouse.visible = false;
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.switchState(() -> new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			persistentUpdate = false;

			switch (curSelected)
			{
				case 0:
					LoadingState.loadState(() -> new ChartingState(), true);
				case 1:
					LoadingState.loadState(() -> new CharacterEditorState(Character.DEFAULT_CHARACTER, false));
				case 2:
					LoadingState.loadState(() -> new DialogueEditorState(), true);
				case 3:
					LoadingState.loadState(() -> new NoteSplashDebugState(), true);
			}
			FlxG.sound.music.volume = 0;
			FreeplayState.destroyFreeplayVocals();
		}

		var bullShit:Int = 0;
		for (item in grpTexts.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
	}
}
#end
