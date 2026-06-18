package cutscenes;

import flixel.util.FlxDestroyUtil;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup;
import haxe.Json;
import objects.HealthIcon;
import shaders.RGBPalette;

class DialogueLiteBox extends FlxGroup
{
	public static inline function parseDialogue(path:String):DialogueData
	{
		#if MODS_ALLOWED
		return FileSystem.exists(path) ? Json.parse(File.getContent(path)) : getDefaultDialogue();
		#else
		return Assets.exists(path, TEXT) ? Json.parse(Assets.getText(path)) : getDefaultDialogue();
		#end
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

	var dialogueText:FlxTypeText;
	var lastDialogueText:FlxText;

	/*
	var curType:String = '';
	var curCharacter:String = '';
	var curCharacterNames:Array<String> = ['', '', ''];
	var curAnim:String = '';
	*/
	public var curLine(default, set):Int = 0;
	var lineEnded:Bool = false;

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
	var chatBox:FlxSprite;
	var lastChatBox:FlxSprite;
	var icon:HealthIcon;
	var lastIcon:HealthIcon;

	var portraits:Array<DialogueCharacter>;
	var portraitsPositionTweens:Map<String, FlxTween> = [];
	var portraitsPositions:Map<String, Float> = [];
	var portraitIDs:Map<String, String> = [];
	var addedPortraits:Map<String, Bool> = [];

	var started:Bool = false;
	var ending:Bool = false;

	var controls(get, never):Controls;

	var startPos:Float = FlxG.height - 380;

	public function new(?dialogueFile:String)
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

		chatBox = new FlxSprite().loadGraphic(Paths.image('dialogue/chatbox'));
		chatBox.scale.set(1.08, 1.08);
		chatBox.updateHitbox();
		chatBox.screenCenter(X);
		chatBox.x -= 8;
		chatBox.y = startPos + 80;
		chatBox.visible = false;
		add(chatBox);

		lastChatBox = new FlxSprite().loadGraphicFromSprite(chatBox);
		lastChatBox.scale.set(1.08, 1.08);
		lastChatBox.updateHitbox();
		lastChatBox.x = chatBox.x;
		lastChatBox.y = chatBox.y + chatBox.height + 30;
		lastChatBox.visible = false;
		add(lastChatBox);

		dialogueText = new FlxTypeText(chatBox.x + 120, chatBox.y + 36, Std.int(chatBox.width - 132));
		dialogueText.setFormat(Paths.font("vcr"), 24, FlxColor.BLACK, LEFT);
		add(dialogueText);

		lastDialogueText = new FlxText(dialogueText.x, lastChatBox.y + 36, dialogueText.fieldWidth);
		lastDialogueText.setFormat(Paths.font("vcr"), 24, FlxColor.BLACK, LEFT);
		lastDialogueText.visible = false;
		add(lastDialogueText);

		add(phone);

		if (dialogueFile != null)
			load(dialogueFile);

		visible = false;
	}

	public function load(file:String)
	{
		#if MODS_ALLOWED
		if (!FileSystem.exists(file))
		#else
		if (!Assets.exists(file))
		#end
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
		portraits = FlxDestroyUtil.destroyArray(portraits);
		portraits = [];

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

			insert(members.indexOf(phoneBG), portraitChar);
			portraits.push(portraitChar);
			addedPortraits.set(portrait.id, false);
			portraitsPositions.set(portrait.id, 200);
		}

		for (line in data.lines)
		{
			var lineData:DialogueLineData = {
				text: line.text ?? '',
				formats: line.formats ?? [],
				speed: line.speed ?? 0.05,
				portrait: line.portrait ?? portraits[0].dialogueID,
				expression: line.expression ?? 'neutral',
				phoneColor: line.phoneColor ?? 'FFFFFF',
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
		character.x = pos - character.width / 2;
	}

	public function addLine(line:DialogueLineData, ?pos:Int)
	{
		var lineData:DialogueLineData = {
			text: line.text ?? '',
			formats: line.formats ?? [],
			speed: line.speed ?? 0.05,
			portrait: line.portrait ?? portraits[0].dialogueID,
			expression: line.expression ?? 'neutral',
			phoneColor: line.phoneColor ?? 'FFFFFF',
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

		if (!lineEnded)
			skipLine();

		if (curLine >= dialogueLines.length)
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

		if (!lineEnded)
			skipLine();

		updateLine();

		if (onNextLine != null)
			onNextLine();

		var portraitIDs:Array<String> = [for (character in portraits) character.dialogueID];
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
		lineEnded = false;

		if (!chatBox.visible)
		{
			chatBox.visible = true;
		}

		if (curLine > 0)
		{
			lastChatBox.visible = true;
			lastDialogueText.visible = true;
			lastDialogueText.text = dialogueLines[curLine - 1].text;
		}
		else if (curLine <= 0)
		{
			lastChatBox.visible = false;
			lastDialogueText.visible = false;
		}

		checkPortraits();

		var lineData:DialogueLineData = dialogueLines[curLine];

		var portraitChar:DialogueCharacter = getPortraitMatchingID(lineData.portrait);
		portraitChar.changeExpression(lineData.expression);

		dialogueText.clearFormats();
		dialogueText.resetText(lineData.text);

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
					dialogueText.addFormat(textFormat, format.start, format.start + format.length);
				}
			}
		}

		if (lineData.sounds != null && lineData.sounds.length > 0)
			dialogueText.sounds = [for (sound in lineData.sounds) FlxG.sound.load(Paths.sound(sound))];
		else
			dialogueText.sounds = [FlxG.sound.load(Paths.sound('dialogue'))];

		dialogueText.completeCallback = () -> lineEnded = true;
		dialogueText.start(lineData.speed, true);
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

		portraitsPositionTweens[id] = FlxTween.num(0, 200, 1, {ease: FlxEase.expoOut}, function(value:Float) {
			portraitsPositions[id] = value;
		});
		FlxTween.tween(character, {alpha: 0}, 1, {ease: FlxEase.expoOut, onComplete: _ -> {
			addedPortraits[id] = false;
		}});
	}

	public function getPortraitMatchingID(id:String):Null<DialogueCharacter>
	{
		for (character in portraits)
		{
			if (character.dialogueID == id)
				return character;
		}

		return null;
	}

	public function rearrangePortraits()
	{
		var min:Float = phone.x + 30;
		var max:Float = phone.x + phone.width - 30;
	}

	public function repeatLine(force:Bool = false)
	{
		dialogueText.start(dialogueText.delay, force);
	}

	function skipLine()
	{
		lineEnded = true;
		dialogueText.skip();
	}

	public function end()
	{
		started = false;
		ending = true;

		FlxTween.tween(bgFade, {alpha: 0}, 1, {onComplete: _ -> {
			if (onFinish != null)
				onFinish();

			visible = false;
		}});
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
				if (lineEnded)
					advanceDialogue();
				else
					skipLine();
			}
		}

		super.update(elapsed);
	}

	function updatePortraitsPosition()
	{
		for (character in portraits)
			character.y = phone.y + 10 + portraitsPositions.get(character.dialogueID) - character.height;
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

		portraits = FlxDestroyUtil.destroyArray(portraits);
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
}

typedef DialogueLineData =
{
	/**
	 * The text to display.
	 * 
	 * Defaults to a blank string.
	 */
	var ?text:String;

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
	 * The portrait to show for this dialogue line.
	 * 
	 * Defaults to the first entry in `portraits`.
	 */
	var ?portrait:String;

	/**
	 * The expression of the portrait.
	 * 
	 * Defaults to `neutral`.
	 */
	var ?expression:String;

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