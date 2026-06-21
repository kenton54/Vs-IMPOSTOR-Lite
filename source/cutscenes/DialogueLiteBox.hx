package cutscenes;

import flixel.util.typeLimit.OneOfTwo;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.group.FlxGroup;
import haxe.Json;
import shaders.RGBPalette;

class DialogueLiteBox extends FlxGroup
{
	public static inline function parseDialogue(path:String):DialogueData
	{
		return Assets.exists(path, TEXT) ? Json.parse(Assets.getText(path)) : getDefaultDialogue();
	}

	public static inline function getDefaultDialogue():DialogueData
	{
		return {
			portraits: [{id: "test1", character: "red", position: 0.25},],
			lines: [getDefaultLine()]
		};
	}

	@:allow(states.editors.DialogueEditorState)
	static inline function getDefaultLine():DialogueLineData
	{
		return {
			text: "Lorem ipsum dolor sit amet.",
			phoneColor: "#FF0000",
			portrait: "test1",
			expression: "neutral"
		};
	}

	public var dialogueLines:Array<DialogueLineData>;
	var dialogueMusic:FlxSound;

	/*
	var curType:String = '';
	var curCharacter:String = '';
	var curCharacterNames:Array<String> = ['', '', ''];
	var curAnim:String = '';
	*/
	public var curLine(default, set):Int = 0;

	/**
	 * Gets triggered every time the dialogue advances or changes line.
	 */
	public var onNextLine:Void->Void;

	/**
	 * Gets triggered when the dialogue finishes.
	 */
	public var onFinish:Void->Void;

	var group:FlxSpriteGroup;

	var phoneRGB:RGBPalette;

	public var bgFade(default, null):FlxSprite;
	var phoneBG:FlxSprite;
	var phone:FlxSprite;
	var chatBox:DialogueChatBox;
	var lastChatBox:DialogueChatBox;

	var dialoguePortraits:Map<String, DialogueCharacter> = [];
	var portraitsPositionTweens:Map<String, FlxTween> = [];
	var portraitsPositions:Map<String, Float> = [];
	var addedPortraits:Map<String, Bool> = [];

	var started:Bool = false;
	var ending:Bool = false;

	var controls(get, never):Controls;

	var startPos:Float = FlxG.height - 340;

	public function new(?dialogueFile:OneOfTwo<String, DialogueData>)
	{
		super();

		phoneRGB = new RGBPalette();
		phoneRGB.r = FlxColor.WHITE;

		dialogueMusic = new FlxSound();
		FlxG.sound.list.add(dialogueMusic);

		bgFade = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		bgFade.alpha = 0;
		add(bgFade);

		phone = new FlxSprite().loadGraphic(Paths.image('dialogue/phone'));
		phone.shader = phoneRGB.shader;
		phone.screenCenter(X);
		phone.y = FlxG.height;

		phoneBG = new FlxSprite().makeGraphic(Std.int(phone.width - 64), Std.int(phone.height - 64), FlxColor.WHITE);
		phoneBG.y = FlxG.height + 32;
		phoneBG.screenCenter(X);
		add(phoneBG);

		chatBox = new DialogueChatBox(0, startPos + 70);
		chatBox.screenCenter(X);
		chatBox.x -= 8;
		chatBox.visible = false;
		add(chatBox);

		lastChatBox = new DialogueChatBox(chatBox.x, chatBox.y + chatBox.height + 6);
		lastChatBox.visible = false;
		add(lastChatBox);

		add(phone);

		if (dialogueFile != null)
		{
			if (dialogueFile is String)
				loadFile(dialogueFile);
			else
				loadFromData(dialogueFile);
		}

		visible = false;
	}

	public function loadFile(file:String)
	{
		if (!Assets.exists(file))
		{
			FlxG.log.error('Could not find dialogue file at path "$file"!');
			return;
		}

		var dialogueData:DialogueData = Json.parse(Assets.getText(file));
		loadFromData(dialogueData);
	}

	public function loadFromData(data:DialogueData)
	{
		dialogueLines = [];
		addedPortraits.clear();
		portraitsPositions.clear();
		destroyPortraits();

		var musicPath = (data.music != null && data.music != "") ? Paths.music('dialogues/' + data.music) : Paths.music('offsetSong');
		loadMusic(musicPath);

		if (data.portraits.length < 1)
			data.portraits = [{id: "default", character: "bf", position: 0.5}];

		for (portrait in data.portraits)
		{
			var portraitChar:DialogueCharacter = new DialogueCharacter(0, 0, portrait.character);
			portraitChar.dialogueID = portrait.id;
			positionPortrait(portrait.position, portraitChar);
			portraitChar.alpha = 0;
			portraitChar.flipX = portrait.flipX ?? false;

			insert(members.indexOf(phoneBG), portraitChar);
			dialoguePortraits.set(portrait.id, portraitChar);
			addedPortraits.set(portrait.id, false);
			portraitsPositions.set(portrait.id, 200);
		}

		for (line in data.lines)
		{
			var lineData:DialogueLineData = {
				text: line.text,
				portrait: line.portrait,
				expression: line.expression,
				speed: line.speed ?? 0.05,
				phoneColor: line.phoneColor ?? '#FFFFFF',
				formats: line.formats ?? [],
				sounds: line.sounds ?? []
			};
			dialogueLines.push(lineData);
		}
	}

	function positionPortrait(position:Float, character:DialogueCharacter)
	{
		var min:Float = phone.x + 30;
		var max:Float = phone.x + phone.width - 30;
		var percent:Float = FlxMath.bound(position, 0, 1);

		var pos:Float = min + max * percent;
		character.x = character.positionArray[0] + pos - character.width / 2;
	}

	public function addLine(line:DialogueLineData, ?pos:Int)
	{
		var lineData:DialogueLineData = {
			text: line.text,
			portrait: line.portrait,
			expression: line.expression,
			speed: line.speed ?? 0.05,
			phoneColor: line.phoneColor ?? '#FFFFFF',
			formats: line.formats ?? [],
			sounds: line.sounds ?? []
		};

		if (pos != null)
			dialogueLines.insert(pos, lineData);
		else
			dialogueLines.push(lineData);
	}

	public function loadMusic(music:FlxSoundAsset)
	{
		dialogueMusic.loadEmbedded(music, true);
	}

	public function start(force:Bool = false)
	{
		visible = true;

		started = true;
		ending = false;

		dialogueMusic.volume = 0;
		dialogueMusic.play();
		dialogueMusic.fadeIn();

		curLine = 0;

		FlxTween.tween(bgFade, {alpha: 0.6}, 1, {startDelay: 0.2});

		var duration:Float = 0.5;
		if (force)
		{
			phoneBG.y = startPos + 32;
			phone.y = startPos;
			updateLine();
		}
		else
		{
			FlxTween.tween(phoneBG, {y: startPos + 32}, duration, {ease: FlxEase.quadOut});
			FlxTween.tween(phone, {y: startPos}, duration, {ease: FlxEase.quadOut, onComplete: _ -> updateLine()});
		}
	}

	public function advanceDialogue(endDialogue:Bool = true)
	{
		curLine++;

		if (!chatBox.finishedTyping)
			skipLine();

		if (curLine >= (dialogueLines.length - 1))
		{
			if (endDialogue) end();
			return;
		}

		updateLine();

		if (onNextLine != null)
			onNextLine();
	}

	public function retractDialogue()
	{
		curLine--;

		if (!chatBox.finishedTyping)
			skipLine();

		updateLine();

		if (onNextLine != null)
			onNextLine();

		var portraitIDs:Array<String> = [for (id in dialoguePortraits.keys()) id];
		var earliestAppearances:Array<Int> = [for (id in portraitIDs) -1];

		for (i => portraitID in portraitIDs)
		{
			for (j in 0...dialogueLines.length)
			{
				if (dialogueLines[j].portrait == portraitID && earliestAppearances[i] < 0)
					earliestAppearances[i] = j;
			}
		}

		for (i => portraitID in portraitIDs)
		{
			if (earliestAppearances[i] > curLine && addedPortraits.get(portraitID) == true)
			{
				dissapearPortrait(getPortraitMatchingID(portraitID));
				addedPortraits[portraitID] = false;
			}
		}
	}

	public function updateLine()
	{
		if (!chatBox.visible)
		{
			chatBox.visible = true;
		}

		if (curLine > 0)
		{
			lastChatBox.visible = true;

			var char:DialogueCharacter = getPortraitMatchingID(dialogueLines[curLine - 1].portrait);
			lastChatBox.changeDisplay(dialogueLines[curLine - 1].text, char.icon, char.name);
			lastChatBox.startText();
			lastChatBox.finishText();
		}
		else if (curLine <= 0)
		{
			lastChatBox.visible = false;
		}

		checkPortraits();

		var lineData:DialogueLineData = dialogueLines[curLine];

		var portraitChar:DialogueCharacter = getPortraitMatchingID(lineData.portrait);
		portraitChar.changeExpression(lineData.expression);

		chatBox.changeDisplay(lineData.text, portraitChar.icon, portraitChar.name);

		phoneRGB.r = FlxColor.fromString(lineData.phoneColor);

		if (lineData.formats != null && lineData.formats.length > 0)
		{
			for (format in lineData.formats)
			{
				if (format.length > 0)
				{
					var textFormat:FlxTextFormat = new FlxTextFormat(format.color, format.bold, format.italic, null, format.underline);
					@:privateAccess {
						textFormat.format.size = format.size;
						textFormat.format.font = Paths.font(format.font);
					}
					chatBox.addFormat(textFormat, format.start, format.start + format.length);
				}
			}
		}

		if (lineData.sounds != null && lineData.sounds.length > 0)
			chatBox.text.sounds = [for (sound in lineData.sounds) FlxG.sound.load(Paths.sound(sound))];
		else
			chatBox.text.sounds = [FlxG.sound.load(Paths.sound('dialogue'))];

		chatBox.startText(lineData.speed);
	}

	function checkPortraits()
	{
		for (i => line in dialogueLines)
		{
			if (i > curLine) break;

			var portraitID:String = line.portrait;
			if (addedPortraits.get(portraitID) == false)
			{
				var character:DialogueCharacter = getPortraitMatchingID(portraitID);
				if (portraitsPositionTweens[portraitID] != null) portraitsPositionTweens[portraitID].cancel();
				FlxTween.cancelTweensOf(character);

				FlxTween.tween(character, {alpha: 1}, 1, {ease: FlxEase.expoOut});
				portraitsPositionTweens[portraitID] = FlxTween.num(200, 0, 1, {ease: FlxEase.expoOut}, function(value:Float) {
					portraitsPositions[portraitID] = value;
				});

				addedPortraits[portraitID] = true;
			}
		}
	}

	function dissapearPortrait(character:DialogueCharacter)
	{
		var id:String = character.dialogueID;
		if (portraitsPositionTweens[id] != null) portraitsPositionTweens[id].cancel();
		FlxTween.cancelTweensOf(character);

		portraitsPositionTweens[id] = FlxTween.num(0, 200, 0.5, {ease: FlxEase.expoOut}, function(value:Float) {
			portraitsPositions[id] = value;
		});
		FlxTween.tween(character, {alpha: 0}, 0.5, {ease: FlxEase.expoOut, onComplete: _ -> {
			addedPortraits[id] = false;
		}});
	}

	public function getPortraitMatchingID(id:String):Null<DialogueCharacter>
	{
		return dialoguePortraits.get(id);
	}

	public function repeatLine(force:Bool = false)
	{
		chatBox.startText(chatBox.text.delay, force);
	}

	function skipLine()
	{
		chatBox.finishText();
	}

	public function end()
	{
		started = false;
		ending = true;

		dialogueMusic.fadeOut();

		FlxTween.tween(phone, {y: FlxG.height}, 0.5, {ease: FlxEase.quartIn});
		FlxTween.tween(phoneBG, {y: FlxG.height + 32}, 0.5, {ease: FlxEase.quartIn});
		FlxTween.tween(chatBox, {y: FlxG.height + 70}, 0.5, {ease: FlxEase.quartIn});
		FlxTween.tween(lastChatBox, {y: FlxG.height + chatBox.height + 6}, 0.5, {ease: FlxEase.quartIn});

		for (id in dialoguePortraits.keys())
			dissapearPortrait(getPortraitMatchingID(id));

		FlxTween.tween(bgFade, {alpha: 0}, 1, {onComplete: _ ->
			{
				if (onFinish != null)
					onFinish();

				visible = false;
			}
		});
	}

	public var allowControls:Bool = true;
	override function update(elapsed:Float)
	{
		updatePortraitsPosition();

		if (!started || ending) return;

		if (allowControls)
		{
			if (controls.ACCEPT)
			{
				if (chatBox.finishedTyping)
					advanceDialogue();
				else
					skipLine();
			}
		}

		super.update(elapsed);
	}

	function updatePortraitsPosition()
	{
		for (id => character in dialoguePortraits)
			character.y = phone.y + 10 + character.positionArray[1] + portraitsPositions.get(id) - character.height;
	}

	override function destroy()
	{
		super.destroy();

		dialogueMusic.destroy();

		for (key => tween in portraitsPositionTweens)
		{
			if (tween != null)
			{
				tween.cancel();
				tween.destroy();
			}
		}

		destroyPortraits();
	}

	function destroyPortraits()
	{
		for (id => portrait in dialoguePortraits)
			portrait.destroy();

		dialoguePortraits.clear();
	}

	function set_curLine(line:Int):Int
	{
		return curLine = Std.int(FlxMath.bound(line, 0, dialogueLines.length - 1));
	}

	function get_controls():Controls
	{
		return Controls.instance;
	}
}

typedef DialogueData =
{
	var portraits:Array<DialoguePortraitData>;
	var lines:Array<DialogueLineData>;
	var ?music:String;
}

typedef DialoguePortraitData =
{
	/**
	 * The unique ID.
	 */
	var id:String;

	/**
	 * The portrait character.
	 */
	var character:String;

	/**
	 * Where the portrait is positioned.
	 * 
	 * Must be a percentage value (a value between `0` and `1`).
	 * 
	 * Defaults to `0`.
	 */
	var ?position:Float;

	/**
	 * Whether the portrait should be flipped horizontally.
	 * 
	 * Defaults to `false`.
	 */
	var ?flipX:Bool;
}

typedef DialogueLineData =
{
	/**
	 * The text to display.
	 * 
	 * Defaults to a blank string.
	 */
	var text:String;

	/**
	 * The portrait to show for this dialogue line.
	 */
	var portrait:String;

	/**
	 * The expression of the portrait.
	 */
	var expression:String;

	/**
	 * The formats of the text.
	 * 
	 * Defaults to an empty array.
	 */
	var ?formats:Array<LineFormat>;

	/**
	 * The speed at which each character of the text appears (in seconds).
	 * 
	 * Defaults to `0.05` seconds (or `50` milliseconds).
	 */
	var ?speed:Float;

	/**
	 * The color of the phone.
	 * 
	 * Defaults to white.
	 */
	var ?phoneColor:String;

	/**
	 * An array of sounds to play for when each character of the text appears.
	 */
	var ?sounds:Array<String>;
}

typedef LineFormat =
{
	var ?start:Int;
	var ?length:Int;
	var ?size:Int;
	var ?color:FlxColor;
	var ?font:String;
	var ?bold:Bool;
	var ?italic:Bool;
	var ?underline:Bool;
}