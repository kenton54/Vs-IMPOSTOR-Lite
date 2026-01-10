package cutscenes;

import flixel.addons.text.FlxTypeText;
import objects.HealthIcon;
import flixel.group.FlxGroup;

import shaders.RGBPalette;

class DialogueLiteBox extends FlxSpriteGroup
{
	var curType:String = '';
	var curCharacter:String = '';
	var curCharacterNames:Array<String> = ['', '', ''];
	var curAnim:String = '';

	var dialogueMusic:FlxSound;

	var dadAnimOffsets:Map<String, Array<Dynamic>> = [];
	var gfAnimOffsets:Map<String, Array<Dynamic>> = [];
	var bfAnimOffsets:Map<String, Array<Dynamic>> = [];

	var iconSplitInfo:Array<Dynamic> = [];
	var iconInfo:Array<Dynamic> = [];
	var portraitInfo:Array<Dynamic> = [];
	var dialogueList:Array<String> = [];

	var swagDialogue:FlxText;
	var dialogueName:FlxText;

	public var finishThing:Void->Void;

	var tabletGrp:FlxSpriteGroup;

	var bgFade:FlxSprite;
	var icon:FlxSprite;

	var portraitLeft:FlxSprite;
	var portraitMiddle:FlxSprite;
	var portraitRight:FlxSprite;

	var addedPortraitsB:Array<Bool> = [false, false, false];
	var addedPortraitsT:Array<String> = ['', '', ''];
	var defaultPortraitTypes:Array<String> = ['dad', 'gf', 'bf'];

	var isEnding:Bool = false;

	public function new(?dialogueList:Array<String>)
	{
		super();
		this.dialogueList = dialogueList;

		dialogueMusic = new FlxSound();
		dialogueMusic.loadEmbedded(Paths.music('dialogues/${PlayState.SONG.song.toLowerCase()}/Inst'), true, true);
		dialogueMusic.volume = 0;
		dialogueMusic.play();
		FlxG.sound.list.add(dialogueMusic);

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB4B4B4);
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			bgFade.alpha += 0.15;
			if (bgFade.alpha > 0.7) {
				bgFade.alpha = 0.7;
			}

			if(bgFade.alpha >= 0.45) {
				dialogueStarted = true;
			}
		}, 5);
	}

	var dialogueStarted:Bool = false;
	var allowEnterKey:Bool = true;
	var getElapsed:Float = 0;
	override function update(elapsed:Float)
	{
		getElapsed += elapsed;
		if (!isEnding && dialogueMusic != null && dialogueMusic.volume < 0.7)
			dialogueMusic.volume += 0.02 * elapsed;


		super.update(elapsed);
	}

	override function destroy()
	{
		dialogueMusic.destroy();
	}
}