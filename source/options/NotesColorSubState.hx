package options;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.shapes.FlxShapeCircle;
import lime.system.Clipboard;
import flixel.util.FlxGradient;
import objects.StrumNote;
import objects.Note;

import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

#if mobile
import objects.BackButton;
#end

class NotesColorSubState extends MusicBeatSubstate
{
	var onModeColumn:Bool = true;
	var curSelectedMode:Int = 0;
	var curSelectedNote:Int = 0;
	var onPixel:Bool = false;
	var dataArray:Array<Array<FlxColor>>;

	var hexTypeLine:FlxSprite;
	var hexTypeNum:Int = -1;
	var hexTypeVisibleTimer:Float = 0;

	var copyButton:FlxSprite;
	var pasteButton:FlxSprite;

	var colorGradient:FlxSprite;
	var colorGradientSelector:FlxSprite;
	var colorPalette:FlxSprite;
	var colorWheel:FlxSprite;
	var colorWheelSelector:FlxSprite;

	var alphabetR:Alphabet;
	var alphabetG:Alphabet;
	var alphabetB:Alphabet;
	var alphabetHex:Alphabet;

	var modeBG:FlxSprite;
	var notesBG:FlxSprite;
	var colorBG:FlxSprite;

	var tipTxt:FlxText;

	// controller support
	var controllerPointer:FlxSprite;
	var usingController:Bool = false;

	override function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Editing Note Colors", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('sketch2'));
		bg.color = 0xFFea71fd;
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		add(grid);

		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});

		modeBG = new FlxSprite();
		modeBG.visible = false;
		modeBG.alpha = 0.4;
		add(modeBG);

		notesBG = new FlxSprite();
		notesBG.visible = false;
		notesBG.alpha = 0.4;
		add(notesBG);

		modeNotes = new FlxTypedGroup<FlxSprite>();
		add(modeNotes);

		myNotes = new FlxTypedGroup<StrumNote>();
		add(myNotes);

		final colorBGWidth:Float = FlxG.width * 0.45;
		final maxWidth:Float = 580;
		final finalColorBGWidth:Float = FlxMath.bound(colorBGWidth, 0, maxWidth);

		colorBG = new FlxSprite().makeGraphic(Std.int(finalColorBGWidth), FlxG.height, FlxColor.BLACK);
		colorBG.x = FlxG.width * #if mobile 0.88 #else 0.95 #end - colorBG.width;
		colorBG.alpha = 0.25;
		add(colorBG);

		final wheelBGWidth:Float = colorBG.width * 0.9;
		final wheelBGHeight:Float = wheelBGWidth * 1.15;
		var colorWheelBG:FlxSprite = new FlxSprite(0, 160).makeGraphic(Std.int(wheelBGWidth), Std.int(wheelBGHeight), FlxColor.BLACK);
		colorWheelBG.alpha = 0.25;
		colorWheelBG.x = colorBG.x + (colorBG.width - colorWheelBG.width) / 2;
		add(colorWheelBG);

		copyButton = new FlxSprite(0, 50).loadGraphic(Paths.image('noteColorMenu/copy'));
		copyButton.x = colorWheelBG.x + colorWheelBG.width * 0.05;
		copyButton.alpha = 0.6;
		add(copyButton);

		pasteButton = new FlxSprite(0, 50).loadGraphic(Paths.image('noteColorMenu/paste'));
		pasteButton.x = colorWheelBG.x + colorWheelBG.width * 0.95 - pasteButton.width;
		pasteButton.alpha = 0.6;
		add(pasteButton);

		var colorOptionsCenter:Float = colorWheelBG.width * 0.24;
		var borderSizeIdk:Float = 25;

		var distanceFromStart:Float = (colorWheelBG.x + borderSizeIdk) - (colorWheelBG.x + colorOptionsCenter);

		colorGradient = FlxGradient.createGradientFlxSprite(60, 360, [FlxColor.WHITE, FlxColor.BLACK]);
		colorGradient.y = 200;

		colorGradientSelector = new FlxSprite(0, 200).makeGraphic(80, 10, FlxColor.WHITE);

		colorPalette = new FlxSprite().loadGraphic(Paths.image('noteColorMenu/palette', false));
		colorPalette.setGraphicSize(colorWheelBG.width * 0.7);
		colorPalette.updateHitbox();
		colorPalette.x = colorWheelBG.x + (colorWheelBG.width - colorPalette.width) / 2;
		colorPalette.antialiasing = false;

		var distanceFromWidth:Float = (colorWheelBG.width - borderSizeIdk) - colorOptionsCenter;
		colorWheel = new FlxSprite(0, 200).loadGraphic(Paths.image('noteColorMenu/colorWheel'));
		colorWheel.setGraphicSize(distanceFromWidth);
		colorWheel.updateHitbox();
		colorWheel.x = colorWheelBG.x + colorOptionsCenter;

		colorGradient.setGraphicSize(distanceFromStart, colorWheel.height);
		colorGradient.updateHitbox();
		colorGradient.x = colorWheelBG.x + colorOptionsCenter - colorGradient.width - borderSizeIdk;
		colorGradientSelector.x = colorGradient.x + (colorGradient.width - colorGradientSelector.width) / 2;
		colorPalette.y = colorGradient.y + colorGradient.height + borderSizeIdk;

		add(colorGradient);
		add(colorGradientSelector);
		add(colorPalette);
		add(colorWheel);

		colorWheelSelector = new FlxShapeCircle(0, 0, 8, {thickness: 0}, FlxColor.WHITE);
		colorWheelSelector.offset.set(8, 8);
		colorWheelSelector.alpha = 0.6;
		add(colorWheelSelector);

		var alphabetCenterLeftBorder:Float = copyButton.x + copyButton.width;
		var alphabetCenter = alphabetCenterLeftBorder + (pasteButton.x - alphabetCenterLeftBorder) / 2 - 16;
		var alphabetY = 90;
		alphabetR = makeColorAlphabet(alphabetCenter - 100, alphabetY);
		add(alphabetR);
		alphabetG = makeColorAlphabet(alphabetCenter, alphabetY);
		add(alphabetG);
		alphabetB = makeColorAlphabet(alphabetCenter + 100, alphabetY);
		add(alphabetB);
		alphabetHex = makeColorAlphabet(alphabetCenter - 10, alphabetY - 55);
		add(alphabetHex);
		hexTypeLine = new FlxSprite(0, 20).makeGraphic(5, 62, FlxColor.WHITE);
		hexTypeLine.visible = false;
		add(hexTypeLine);

		spawnNotes();
		updateNotes(true);
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);

		var tipX = 20;
		var tipY = 840;
		var tip:FlxText = new FlxText(tipX, tipY, 0, "Press RESET to Reset the selected Note Part.", 16);
		tip.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tip.borderSize = 2;
		add(tip);

		tipTxt = new FlxText(tipX, tipY + 24, 0, '', 16);
		tipTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipTxt.borderSize = 2;
		add(tipTxt);

		updateTip();

		#if mobile
		var backButton:BackButton = new BackButton(0, 0, FlxColor.WHITE, true);
		backButton.x = FlxG.width - backButton.width - 60;
		backButton.y = FlxG.height - backButton.height - 28;
		backButton.onConfirmEnd.add(() -> close());
		add(backButton);
		#end

		controllerPointer = new FlxShapeCircle(0, 0, 20, {thickness: 0}, FlxColor.WHITE);
		controllerPointer.offset.set(20, 20);
		controllerPointer.screenCenter();
		controllerPointer.alpha = 0.6;
		add(controllerPointer);

		super.create();

		PointerUtil.visible = !controls.controllerMode;

		#if !mobile
		usingController = controls.controllerMode;
		#end

		controllerPointer.visible = usingController;

		updateColors();
	}

	function makeColorAlphabet(x:Float = 0, y:Float = 0):Alphabet
	{
		var text:Alphabet = new Alphabet(x, y, '', true);
		text.alignment = CENTERED;
		text.setScale(0.6);
		add(text);
		return text;
	}

	function updateTip()
	{
		tipTxt.text = 'Hold ' + (!usingController ? 'Shift' : 'Left Shoulder Button') + ' + Press RESET key to fully reset the selected Note.';
	}

	var _storedColor:FlxColor;
	var changingNote:Bool = false;
	var holdingOnObj:FlxSprite;

	var allowedTypeKeys:Map<FlxKey, String> = [
		ZERO => '0', ONE => '1', TWO => '2', THREE => '3', FOUR => '4', FIVE => '5', SIX => '6', SEVEN => '7', EIGHT => '8', NINE => '9',
		NUMPADZERO => '0', NUMPADONE => '1', NUMPADTWO => '2', NUMPADTHREE => '3', NUMPADFOUR => '4', NUMPADFIVE => '5', NUMPADSIX => '6',
		NUMPADSEVEN => '7', NUMPADEIGHT => '8', NUMPADNINE => '9', A => 'A', B => 'B', C => 'C', D => 'D', E => 'E', F => 'F'
	];

	override function update(elapsed:Float)
	{
		#if mobile
		#if android
		if (FlxG.android.justReleased.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			close();
			return;
		}
		#end
		#end

		if (controls.BACK)
		{
			PointerUtil.visible = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			close();
			return;
		}

		if (FlxG.gamepads.anyJustPressed(ANY))
			usingController = true;
		else if (PointerUtil.justMoved)
			usingController = false;

		/*
		var changedToController:Bool = false;
		if (controls.controllerMode != usingController)
		{
			//trace('changed controller mode');
			PointerUtil.visible = !controls.controllerMode;
			controllerPointer.visible = controls.controllerMode;

			// changed to controller mid state
			if (usingController)
			{
				controllerPointer.x = FlxG.mouse.x;
				controllerPointer.y = FlxG.mouse.y;
				changedToController = true;
			}
			usingController = controls.controllerMode;
			updateTip();
		}
		*/

		// controller things
		var analogX:Float = 0;
		var analogY:Float = 0;
		var analogMoved:Bool = false;
		if (usingController && FlxG.gamepads.anyInput())
		{
			for (gamepad in FlxG.gamepads.getActiveGamepads())
			{
				analogX = gamepad.getXAxis(LEFT_ANALOG_STICK);
				analogY = gamepad.getYAxis(LEFT_ANALOG_STICK);
				analogMoved = (analogX != 0 || analogY != 0);
				if(analogMoved) break;
			}
			controllerPointer.x = Math.max(0, Math.min(FlxG.width, controllerPointer.x + analogX * 1000 * elapsed));
			controllerPointer.y = Math.max(0, Math.min(FlxG.height, controllerPointer.y + analogY * 1000 * elapsed));
		}

		var controllerPressed:Bool = (usingController && controls.ACCEPT);

		if (hexTypeNum > -1)
		{
			var keyPressed:FlxKey = cast (FlxG.keys.firstJustPressed(), FlxKey);
			hexTypeVisibleTimer += elapsed;
			var changed:Bool = false;
			if (changed = FlxG.keys.justPressed.LEFT)
				hexTypeNum--;
			else if (changed = FlxG.keys.justPressed.RIGHT)
				hexTypeNum++;
			else if (allowedTypeKeys.exists(keyPressed))
			{
				//trace('keyPressed: $keyPressed, lil str: ' + allowedTypeKeys.get(keyPressed));
				var curColor:String = alphabetHex.text;
				var newColor:String = curColor.substring(0, hexTypeNum) + allowedTypeKeys.get(keyPressed) + curColor.substring(hexTypeNum + 1);

				var colorHex:FlxColor = FlxColor.fromString('#' + newColor);
				setShaderColor(colorHex);
				_storedColor = getShaderColor();
				updateColors();
				
				// move you to next letter
				hexTypeNum++;
				changed = true;
			}
			else if (FlxG.keys.justPressed.ENTER)
				hexTypeNum = -1;
			
			var end:Bool = false;
			if (changed)
			{
				if (hexTypeNum > 5) //Typed last letter
				{
					hexTypeNum = -1;
					end = true;
					hexTypeLine.visible = false;
				}
				else
				{
					if (hexTypeNum < 0) hexTypeNum = 0;
					else if (hexTypeNum > 5) hexTypeNum = 5;
					centerHexTypeLine();
					hexTypeLine.visible = true;
				}
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
			}
			if (!end) hexTypeLine.visible = Math.floor(hexTypeVisibleTimer * 2) % 2 == 0;
		}
		else
		{
			var add:Int = 0;
			if (analogX == 0 && !usingController)
			{
				if (controls.UI_LEFT_P) add = -1;
				else if (controls.UI_RIGHT_P) add = 1;
			}

			if (analogY == 0 && !usingController && (controls.UI_UP_P || controls.UI_DOWN_P))
			{
				onModeColumn = !onModeColumn;
				modeBG.visible = onModeColumn;
				notesBG.visible = !onModeColumn;
			}
	
			if (add != 0)
			{
				if (onModeColumn)
					changeSelectionMode(add);
				else
					changeSelectionNote(add);
			}
			hexTypeLine.visible = false;
		}

		// Copy/Paste buttons
		var generalMoved:Bool = (PointerUtil.justMoved || analogMoved);
		var generalPressed:Bool = (PointerUtil.justPressed || controllerPressed);
		if (generalMoved)
		{
			copyButton.alpha = 0.6;
			pasteButton.alpha = 0.6;
		}

		if (pointerOverlaps(copyButton))
		{
			copyButton.alpha = 1;
			if (generalPressed)
			{
				Clipboard.text = getShaderColor().toHexString(false, false);
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
				// trace('copied: ' + Clipboard.text);
			}
			hexTypeNum = -1;
		}
		else if (pointerOverlaps(pasteButton))
		{
			pasteButton.alpha = 1;
			if (generalPressed)
			{
				var formattedText = Clipboard.text.trim().toUpperCase().replace('#', '').replace('0x', '');
				var newColor:Null<FlxColor> = FlxColor.fromString('#' + formattedText);
				//trace('#${Clipboard.text.trim().toUpperCase()}');
				if (newColor != null && formattedText.length == 6)
				{
					setShaderColor(newColor);
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
					_storedColor = getShaderColor();
					updateColors();
				}
				else //errored
					FlxG.sound.play(Paths.sound('cancelMenu'), 0.6);
			}
			hexTypeNum = -1;
		}

		// Click
		if (generalPressed)
		{
			hexTypeNum = -1;
			if (pointerOverlaps(modeNotes))
			{
				modeNotes.forEachAlive(function(note:FlxSprite) {
					if (curSelectedMode != note.ID && pointerOverlaps(note))
					{
						modeBG.visible = notesBG.visible = false;
						curSelectedMode = note.ID;
						onModeColumn = true;
						updateNotes();
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
					}
				});
			}
			else if (pointerOverlaps(myNotes))
			{
				myNotes.forEachAlive(function(note:StrumNote) {
					if (curSelectedNote != note.ID && pointerOverlaps(note))
					{
						modeBG.visible = notesBG.visible = false;
						curSelectedNote = note.ID;
						onModeColumn = false;
						bigNote.rgbShader.parent = Note.globalRgbShaders[note.ID];
						bigNote.shader = Note.globalRgbShaders[note.ID].shader;
						updateNotes();
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
					}
				});
			}
			else if (pointerOverlaps(colorWheel))
			{
				_storedColor = getShaderColor();
				holdingOnObj = colorWheel;
			}
			else if (pointerOverlaps(colorGradient))
			{
				_storedColor = getShaderColor();
				holdingOnObj = colorGradient;
			}
			else if (pointerOverlaps(colorPalette))
			{
				setShaderColor(colorPalette.pixels.getPixel32(
					Std.int((pointerX() - colorPalette.x) / colorPalette.scale.x), 
					Std.int((pointerY() - colorPalette.y) / colorPalette.scale.y)));
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
				updateColors();
			}
			else if (pointerY() >= hexTypeLine.y && pointerY() < hexTypeLine.y + hexTypeLine.height && Math.abs(pointerX() - 1000) <= 84)
			{
				hexTypeNum = 0;
				for (letter in alphabetHex.letters)
				{
					if (letter.x - letter.offset.x + letter.width <= pointerX())
						hexTypeNum++;
					else
						break;
				}
				if (hexTypeNum > 5) hexTypeNum = 5;
				hexTypeLine.visible = true;
				centerHexTypeLine();
			}
			else
				holdingOnObj = null;
		}
		// holding
		if (holdingOnObj != null)
		{
			if (PointerUtil.justReleased || (usingController && controls.justReleased('accept')))
			{
				holdingOnObj = null;
				_storedColor = getShaderColor();
				updateColors();
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
			}
			else if (generalMoved || generalPressed)
			{
				if (holdingOnObj == colorGradient)
				{
					var newBrightness = 1 - FlxMath.bound((pointerY() - colorGradient.y) / colorGradient.height, 0, 1);
					_storedColor.alpha = 1;
					if (_storedColor.brightness == 0) //prevent bug
						setShaderColor(FlxColor.fromRGBFloat(newBrightness, newBrightness, newBrightness));
					else
						setShaderColor(FlxColor.fromHSB(_storedColor.hue, _storedColor.saturation, newBrightness));
					updateColors(_storedColor);
				}
				else if (holdingOnObj == colorWheel)
				{
					var center:FlxPoint = new FlxPoint(colorWheel.x + colorWheel.width/2, colorWheel.y + colorWheel.height/2);
					var mouse:FlxPoint = pointerFlxPoint();
					var hue:Float = FlxMath.wrap(FlxMath.wrap(Std.int(mouse.degreesTo(center)), 0, 360) - 90, 0, 360);
					var sat:Float = FlxMath.bound(mouse.dist(center) / colorWheel.width * 2, 0, 1);
					//trace('$hue, $sat');
					if(sat != 0) setShaderColor(FlxColor.fromHSB(hue, sat, _storedColor.brightness));
					else setShaderColor(FlxColor.fromRGBFloat(_storedColor.brightness, _storedColor.brightness, _storedColor.brightness));
					updateColors();
				}
			}
		}
		else if (controls.RESET && hexTypeNum < 0)
		{
			if (#if !mobile FlxG.keys.pressed.SHIFT || #end FlxG.gamepads.anyJustPressed(LEFT_SHOULDER))
			{
				for (i in 0...2)
				{
					var strumRGB:RGBShaderReference = myNotes.members[curSelectedNote].rgbShader;
					var color:FlxColor = !onPixel ? ClientPrefs.defaultData.arrowRGB[curSelectedNote][i] : ClientPrefs.defaultData.arrowRGBPixel[curSelectedNote][i];
					switch(i)
					{
						case 0:
							getShader().r = strumRGB.r = color;
						case 1:
						 	getShader().b = strumRGB.b = color;
						case 2:
							getShader().g = strumRGB.g = color;
					}
					dataArray[curSelectedNote][i] = color;
				}
			}
			setShaderColor(!onPixel ? ClientPrefs.defaultData.arrowRGB[curSelectedNote][curSelectedMode] : ClientPrefs.defaultData.arrowRGBPixel[curSelectedNote][curSelectedMode]);
			FlxG.sound.play(Paths.sound('cancelMenu'), 0.6);
			updateColors();
		}

		super.update(elapsed);
	}

	function pointerOverlaps(obj:Dynamic)
	{
		if (!usingController) return PointerUtil.overlaps(obj);
		return FlxG.overlap(controllerPointer, obj);
	}

	function pointerX():Float
	{
		if (!usingController) return PointerUtil.getPosition()?.x ?? 0;
		return controllerPointer.x;
	}

	function pointerY():Float
	{
		if (!usingController) return PointerUtil.getPosition()?.y ?? 0;
		return controllerPointer.y;
	}

	function pointerFlxPoint():FlxPoint
	{
		if (!usingController) return PointerUtil.getPosition();
		return controllerPointer.getPosition();
	}

	function centerHexTypeLine()
	{
		//trace(hexTypeNum);
		if(hexTypeNum > 0)
		{
			var letter = alphabetHex.letters[hexTypeNum-1];
			hexTypeLine.x = letter.x - letter.offset.x + letter.width;
		}
		else
		{
			var letter = alphabetHex.letters[0];
			hexTypeLine.x = letter.x - letter.offset.x;
		}
		hexTypeLine.x += hexTypeLine.width;
		hexTypeVisibleTimer = 0;
	}

	function changeSelectionMode(change:Int = 0)
	{
		curSelectedMode = FlxMath.wrap(curSelectedMode + change, 0, 1);

		modeBG.visible = true;
		notesBG.visible = false;
		updateNotes();
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function changeSelectionNote(change:Int = 0)
	{
		curSelectedNote = FlxMath.wrap(curSelectedNote + change, 0, dataArray.length - 1);

		modeBG.visible = false;
		notesBG.visible = true;
		bigNote.rgbShader.parent = Note.globalRgbShaders[curSelectedNote];
		bigNote.shader = Note.globalRgbShaders[curSelectedNote].shader;
		updateNotes();
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	// notes sprites functions
	var modeNotes:FlxTypedGroup<FlxSprite>;
	var myNotes:FlxTypedGroup<StrumNote>;
	var bigNote:Note;
	public function spawnNotes()
	{
		dataArray = !onPixel ? ClientPrefs.data.arrowRGB : ClientPrefs.data.arrowRGBPixel;

		// clear groups
		modeNotes.forEachAlive(function(note:FlxSprite) {
			note.destroy();
		});
		myNotes.forEachAlive(function(note:StrumNote) {
			note.destroy();
		});
		modeNotes.clear();
		myNotes.clear();

		if (bigNote != null)
		{
			remove(bigNote);
			bigNote.destroy();
		}

		Note.globalRgbShaders = [];

		for (i in 0...dataArray.length)
			Note.initializeGlobalRGBShader(i);

		bigNote = new Note(0, 0, false, true);
		bigNote.setGraphicSize(250);
		bigNote.updateHitbox();
		bigNote.x = (colorBG.x - bigNote.width) / 2;
		bigNote.y = FlxG.height / 2 - bigNote.height / 4;
		bigNote.rgbShader.parent = Note.globalRgbShaders[curSelectedNote];
		bigNote.shader = Note.globalRgbShaders[curSelectedNote].shader;

		var res:Int = !onPixel ? 160 : 17;
		var notesCenter:Float = bigNote.x + bigNote.width / 2;
		
		var mainSeparator:Float = 480 / dataArray.length;
		var mainPosX:Float = notesCenter - (mainSeparator * dataArray.length) / 2;
		var mainPosY:Float = bigNote.y - 120;

		var modeSeparator:Float = 100;
		var modePosX:Float = notesCenter - (modeSeparator * 2) / 2;
		var modePosY:Float = mainPosY - 120;

		for (i in 0...2)
		{
			var newNote:FlxSprite = new FlxSprite(modePosX + (modeSeparator * i), modePosY).loadGraphic(Paths.image('noteColorMenu/' + (!onPixel ? 'note' : 'notePixel')), true, res, res);
			newNote.antialiasing = ClientPrefs.data.antialiasing;
			newNote.setGraphicSize(85);
			newNote.updateHitbox();
			newNote.animation.add('anim', [i], 24, true);
			newNote.animation.play('anim', true);
			newNote.ID = i;
			if(onPixel) newNote.antialiasing = false;
			modeNotes.add(newNote);
		}

		var modeBGWidth:Float = modeSeparator * 2;
		modeBG.makeGraphic(Std.int(modeBGWidth + 10), Std.int(modeNotes.members[0].height + 10), FlxColor.BLACK);
		modeBG.x = notesCenter - modeBGWidth / 2 - 10;
		modeBG.y = modePosY - (modeNotes.members[0].height - modeBG.height) / 2 - 10;

		for (i in 0...dataArray.length)
		{
			var newNote:StrumNote = new StrumNote(mainPosX + (mainSeparator * i), mainPosY, i, 0);
			newNote.useRGBShader = true;
			newNote.setGraphicSize(102);
			newNote.updateHitbox();
			newNote.ID = i;
			newNote.scrollFactor.set(1, 1);
			myNotes.add(newNote);
		}

		var notesBGWidth:Float = mainSeparator * dataArray.length;
		notesBG.makeGraphic(Std.int(notesBGWidth + 14), Std.int(myNotes.members[0].height + 14), FlxColor.BLACK);
		notesBG.x = notesCenter - notesBGWidth / 2 - 14;
		notesBG.y = mainPosY - (myNotes.members[0].height - notesBG.height) / 2 - 14;

		for (i in 0...Note.colArray.length)
		{
			if (!onPixel)
				bigNote.animation.addByPrefix('note$i', Note.colArray[i] + '0', 24, true);
			else
				bigNote.animation.add('note$i', [i + 4], 24, true);
		}

		insert(members.indexOf(myNotes) + 1, bigNote);
		_storedColor = getShaderColor();
	}

	function updateNotes(?instant:Bool = false)
	{
		for (note in modeNotes)
			note.alpha = (curSelectedMode == note.ID) ? 1 : 0.6;

		for (note in myNotes)
		{
			var newAnim:String = curSelectedNote == note.ID ? 'confirm' : 'pressed';
			note.alpha = (curSelectedNote == note.ID) ? 1 : 0.6;
			if(note.animation.curAnim == null || note.animation.curAnim.name != newAnim) note.playAnim(newAnim, true);
			if(instant) note.animation.curAnim.finish();
		}
		bigNote.animation.play('note$curSelectedNote', true);
		updateColors();
	}

	function updateColors(specific:Null<FlxColor> = null)
	{
		var color:FlxColor = getShaderColor();
		var wheelColor:FlxColor = specific == null ? getShaderColor() : specific;
		alphabetR.text = Std.string(color.red);
		alphabetG.text = Std.string(color.green);
		alphabetB.text = Std.string(color.blue);
		alphabetHex.text = color.toHexString(false, false);

		for (letter in alphabetHex.letters)
			letter.color = color;

		colorWheel.color = FlxColor.fromHSB(0, 0, color.brightness);
		colorWheelSelector.setPosition(colorWheel.x + colorWheel.width/2, colorWheel.y + colorWheel.height / 2);

		if (wheelColor.brightness != 0)
		{
			var hueWrap:Float = wheelColor.hue * Math.PI / 180;
			colorWheelSelector.x += (Math.sin(hueWrap) * colorWheel.width/2 * wheelColor.saturation);
			colorWheelSelector.y -= Math.cos(hueWrap) * colorWheel.height/2 * wheelColor.saturation;
		}
		colorGradientSelector.y = colorGradient.y + colorGradient.height * (1 - color.brightness);

		var strumRGB:RGBShaderReference = myNotes.members[curSelectedNote].rgbShader;
		switch(curSelectedMode)
		{
			case 0: getShader().r = strumRGB.r = color;
			case 1: getShader().b = strumRGB.b = color;
			case 2: getShader().g = strumRGB.g = color;
		}
	}

	function setShaderColor(value:FlxColor) dataArray[curSelectedNote][curSelectedMode] = value;
	function getShaderColor() return dataArray[curSelectedNote][curSelectedMode];
	function getShader() return Note.globalRgbShaders[curSelectedNote];
}
