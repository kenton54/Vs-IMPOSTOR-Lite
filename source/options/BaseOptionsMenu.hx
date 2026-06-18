package options;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

import objects.AttachedSprite;
import objects.CheckboxThingie;
import objects.AttachedText;
import options.Option;
import backend.InputFormatter;

#if mobile
import objects.BackButton;
#end

class BaseOptionsMenu extends MusicBeatSubstate
{
	var curOption(get, never):Option;
	var curSelected:Int = 0;
	var curSelectedFloat:Float = 0;
	var optionsArray:Array<Option> = [];

	var bg:FlxSprite;

	var grpOptions:FlxTypedGroup<Alphabet>;
	var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
	var grpTexts:FlxTypedGroup<AttachedText>;

	var descBox:AttachedSprite;
	var descText:FlxText;

	public var title:String;
	public var rpcTitle:String;

	public function new(title:String = 'Options', ?rpcTitle:String = 'Looking at the options menu')
	{
		super();

		this.title = title;
		this.rpcTitle = rpcTitle;

		#if DISCORD_ALLOWED
		DiscordClient.changePresence(rpcTitle, null);
		#end
	}

	public function addOption(option:Option)
	{
		optionsArray.push(option);
		return option;
	}

	override function create()
	{
		bg = new FlxSprite().loadGraphic(Paths.image('sketch2'));
		bg.color = 0xFFea71fd;
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		// avoids lagspikes while scrolling through menus!
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		add(checkboxGroup);

		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		var titleText:Alphabet = new Alphabet(75, 45, title, true);
		titleText.setScale(0.6);
		titleText.alpha = 0.4;
		add(titleText);

		descText = new FlxText(50, 600, 1100, "", 32);
		descText.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		descText.screenCenter(X);
		descBox.sprTracker = descText;
		add(descText);

		for (i in 0...optionsArray.length)
		{
			var optionText:Alphabet = new Alphabet(280, #if mobile 240 #else 360 #end, optionsArray[i].name, false);
			optionText.isMenuItem = true;
			/*optionText.forceX = 300;
				optionText.yMult = 90; */
			optionText.targetY = i;
			grpOptions.add(optionText);

			if (optionsArray[i].type == Boolean)
			{
				var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, Std.string(optionsArray[i].getValue()) == 'true');
				checkbox.sprTracker = optionText;
				checkbox.ID = i;
				checkboxGroup.add(checkbox);
			}
			else
			{
				optionText.x -= 80;
				optionText.startPosition.x -= 80;
				// optionText.xAdd -= 80;
				var valueText:AttachedText = new AttachedText('' + optionsArray[i].getValue(), optionText.width + 60);
				valueText.sprTracker = optionText;
				valueText.copyAlpha = true;
				valueText.ID = i;
				grpTexts.add(valueText);
				optionsArray[i].child = valueText;
			}
			// optionText.snapToPosition(); //Don't ignore me when i ask for not making a fucking pull request to uncomment this line ok
			updateTextFrom(optionsArray[i]);
		}

		#if mobile
		var backButton:BackButton = new BackButton(0, 0, FlxColor.WHITE, true);
		backButton.x = FlxG.width - backButton.width - 60;
		backButton.y = FlxG.height - backButton.height - 28;
		backButton.onConfirmEnd.add(() -> close());
		add(backButton);
		#end

		super.create();

		changeSelection();
		reloadCheckboxes();
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	var holdValue:Float = 0;
	#if mobile
	var swiping:Bool = false;
	var moveLength:Float = 0;
	var touchingOption:Bool = false;
	#end
	override function update(elapsed:Float)
	{
		#if mobile
		final overlapsAnyOption:Bool = overlapsAnything();

		if (PointerUtil.justPressed)
		{
			if (overlapsAnyOption)
				touchingOption = true;
			else
				swiping = true;
		}

		final fpsMult:Float = FlxG.updateFramerate / 60;
		if (PointerUtil.pressed)
		{
			if (touchingOption)
			{}
			else if (swiping)
			{
				final delta:Float = PointerUtil.pointer.deltaViewY * fpsMult;

				if (Math.isFinite(delta) && Math.abs(delta) >= 2)
				{
					var dpiScale:Float = FlxG.stage.window.display.dpi / 160;
					dpiScale = FlxMath.bound(dpiScale, 0.5, #if android 1 #else 2 #end);

					var _moveLength:Float = delta / FlxG.updateFramerate / dpiScale;
					moveLength += Math.abs(_moveLength);
					curSelectedFloat -= _moveLength;

					updateScroll();
				}
			}
		}
		else if (moveLength > 0)
		{
			moveLength = 0;
			changeSelection();
		}

		if (PointerUtil.justReleased)
		{
			if (touchingOption)
			{
				touchingOption = false;

				if (curOption.type == Boolean)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					curOption.setValue((curOption.getValue() == true) ? false : true);
					curOption.change();
					reloadCheckboxes();
				}
			}
			else if (swiping)
				swiping = false;
		}

		curSelectedFloat = FlxMath.bound(curSelectedFloat, 0, optionsArray.length - 1);
		curSelected = Math.round(curSelectedFloat);

		#if android
		if (FlxG.android.justReleased.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			close();
			return;
		}
		#end
		#end

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			close();
		}

		if (nextAccept <= 0)
		{
			if (curOption.type == Boolean)
			{
				if (controls.ACCEPT)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					curOption.setValue((curOption.getValue() == true) ? false : true);
					curOption.change();
					reloadCheckboxes();
				}
			}
			else
			{
				if (controls.UI_LEFT || controls.UI_RIGHT)
				{
					var pressed = (controls.UI_LEFT_P || controls.UI_RIGHT_P);
					if (holdTime > 0.5 || pressed)
					{
						if (pressed)
						{
							var add:Dynamic = null;
							if (curOption.type != Choice)
								add = controls.UI_LEFT ? -curOption.changeValue : curOption.changeValue;

							switch(curOption.type)
							{
								case Number | Percentage:
									holdValue = curOption.getValue() + add;
									if (holdValue < curOption.minValue) holdValue = curOption.minValue;
									else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;

									switch(curOption.type)
									{
										case Number:
											holdValue = curOption.changeValue < 1 ? FlxMath.roundDecimal(holdValue, curOption.decimals) : Math.round(holdValue);
											curOption.setValue(holdValue);

										case Percentage:
											holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
											curOption.setValue(holdValue);

										default:
									}

								case Choice:
									var num:Int = curOption.curOption; //lol
									if (controls.UI_LEFT_P) --num;
									else num++;

									if(num < 0)
										num = curOption.options.length - 1;
									else if(num >= curOption.options.length)
										num = 0;

									curOption.curOption = num;
									curOption.setValue(curOption.options[num]); //lol
									//trace(curOption.options[num]);

								default:
							}
							updateTextFrom(curOption);
							curOption.change();
							FlxG.sound.play(Paths.sound('scrollMenu'));
						}
						else if (curOption.type != Choice)
						{
							holdValue += curOption.scrollSpeed * elapsed * (controls.UI_LEFT ? -1 : 1);
							if (holdValue < curOption.minValue) holdValue = curOption.minValue;
							else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;

							switch(curOption.type)
							{
								case Number:
									curOption.setValue(curOption.changeValue < 1 ? FlxMath.roundDecimal(holdValue, curOption.decimals) : Math.round(holdValue));

								case Percentage:
									curOption.setValue(FlxMath.roundDecimal(holdValue, curOption.decimals));

								default:
							}
							updateTextFrom(curOption);
							curOption.change();
						}
					}

					if (curOption.type != Choice)
						holdTime += elapsed;
				}
				else if(controls.UI_LEFT_R || controls.UI_RIGHT_R)
				{
					if(holdTime > 0.5) FlxG.sound.play(Paths.sound('scrollMenu'));
					holdTime = 0;
				}
			}

			if (controls.RESET)
			{
				curOption.setValue(curOption.defaultValue);
				if (curOption.type != Boolean)
				{
					if (curOption.type == Choice) curOption.curOption = curOption.options.indexOf(curOption.getValue());
					updateTextFrom(curOption);
				}
				curOption.change();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				reloadCheckboxes();
			}
		}

		if (nextAccept > 0) {
			nextAccept -= 1;
		}

		super.update(elapsed);
	}

	#if mobile
	function overlapsAnything():Bool
	{
		var overlapsOption:Bool = grpOptions.any(spr -> {
			if (PointerUtil.overlaps(spr))
				return true;
			else
				return false;
		});
		var overlapsValue:Bool = grpTexts.any(spr -> {
			if (PointerUtil.overlaps(spr))
				return true;
			else
				return false;
		});
		var overlapsCheckbox:Bool = checkboxGroup.any(spr -> {
			if (PointerUtil.overlaps(spr))
				return true;
			else
				return false;
		});

		return overlapsOption || overlapsValue || overlapsCheckbox;
	}
	#end

	function updateTextFrom(option:Option)
	{
		var text:String = option.displayFormat;
		var val:Dynamic = option.getValue();
		if (option.type == Percentage) val *= 100;
		var def:Dynamic = option.defaultValue;
		option.text = text.replace('%v', val).replace('%d', def);
	}

	function changeSelection(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, optionsArray.length - 1);
		curSelectedFloat = curSelected;

		descText.text = curOption.description;

		var bullShit:Int = 0;
		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = item.targetY == 0 ? 1 : 0.6;
		}

		for (text in grpTexts)
			text.alpha = text.ID == curSelected ? 1 : 0.6;

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();

		descText.y = FlxG.height - descText.height - 60;

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	#if mobile
	function updateScroll()
	{
		var lastSelected:Int = curSelected;
		curSelected = CoolUtil.boundInt(Math.round(curSelectedFloat), 0, optionsArray.length - 1);

		var bullShit:Int = 0;
		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelectedFloat;
			bullShit++;

			item.alpha = Math.round(item.targetY) == 0 ? 1 : 0.6;
		}

		for (text in grpTexts)
			text.alpha = text.ID == curSelected ? 1 : 0.6;

		if (curSelected != lastSelected)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));

			descText.text = curOption.description;

			descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
			descBox.updateHitbox();

			descText.y = FlxG.height - descText.height - 60;
		}
	}
	#end

	function reloadCheckboxes()
		for (checkbox in checkboxGroup)
			checkbox.daValue = Std.string(optionsArray[checkbox.ID].getValue()) == 'true'; //Do not take off the Std.string() from this, it will break a thing in Mod Settings Menu

	function get_curOption():Option
		return optionsArray[curSelected];
}