package options;

#if mobile
import backend.InputFormatter;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepad.FlxGamepadModel;
import flixel.input.gamepad.FlxGamepad;

import objects.AttachedSprite;
import objects.BackButton;

class MobileControlsSubState extends MusicBeatSubstate
{
    var curSelected:Int = 0;
    var curSelectedFloat:Float = 0;
    var curAlt:Bool = false;

	final bindBoxesWidth:Int = 320;

	var bindsOptions:Array<Array<String>> = [
		['NOTES'],
		['Left', 'note_left', 'Note Left'],
		['Down', 'note_down', 'Note Down'],
		['Up', 'note_up', 'Note Up'],
		['Right', 'note_right', 'Note Right'],
		[],
		['UI'],
		['Left', 'ui_left', 'UI Left'],
		['Down', 'ui_down', 'UI Down'],
		['Up', 'ui_up', 'UI Up'],
		['Right', 'ui_right', 'UI Right'],
		[],
		['Reset', 'reset', 'Reset'],
		['Accept', 'accept', 'Accept'],
		['Back', 'back', 'Back'],
		['Pause', 'pause', 'Pause'],
	];
	final defaultKey:String = 'Reset to Default Keys';
    var curOptions:Array<Int> = [];

    var mobileOptions:Array<String> = [
        'Double Thumbs',
        'Four Lanes'
    ];

    var bg:FlxSprite;

	var grpDisplay:FlxTypedGroup<Alphabet>;
	var grpBGs:FlxTypedGroup<AttachedSprite>;
	var grpOptions:FlxTypedGroup<Alphabet>;
	var grpBinds:FlxTypedGroup<Alphabet>;
	var selectorThing:AttachedSprite;

    var mobileCtrlText:Alphabet;
    var leftArrow:Alphabet;
    var rightArrow:Alphabet;

	var gamepadColor:FlxColor = 0xFFFD7194;
	var mobileColor:FlxColor = 0xFF71FD94;
    var onTouchMode:Bool = true;

    var controllerSpr:FlxSprite;

    override function create()
    {
		bindsOptions.push([]);
		bindsOptions.push([]);
		bindsOptions.push([defaultKey]);

        bg = new FlxSprite().loadGraphic(Paths.image('sketch2'));
		bg.color = mobileColor;
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.screenCenter();
        add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

		grpDisplay = new FlxTypedGroup<Alphabet>();
		add(grpDisplay);
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);
		grpBGs = new FlxTypedGroup<AttachedSprite>();
		add(grpBGs);

		selectorThing = new AttachedSprite();
		selectorThing.makeGraphic(bindBoxesWidth, 78, FlxColor.WHITE);
		selectorThing.copyAlpha = false;
		selectorThing.alpha = 0.75;
		selectorThing.visible = false;
		add(selectorThing);

		grpBinds = new FlxTypedGroup<Alphabet>();
		add(grpBinds);

		mobileCtrlText = new Alphabet(0, 60, '');
		mobileCtrlText.alignment = CENTERED;
		mobileCtrlText.screenCenter(X);
		add(mobileCtrlText);

		leftArrow = new Alphabet(0, 0, '<');
		leftArrow.x = mobileCtrlText.x - leftArrow.width - 20;
		leftArrow.y = mobileCtrlText.y;
		add(leftArrow);

		rightArrow = new Alphabet(0, 0, '>');
		rightArrow.x = mobileCtrlText.x + mobileCtrlText.width + 20;
		rightArrow.y = mobileCtrlText.y;
		add(rightArrow);

		controllerSpr = new FlxSprite(50, 40).loadGraphic(Paths.image("controllertype"), true, 82, 70);
		controllerSpr.antialiasing = ClientPrefs.data.antialiasing;
		controllerSpr.animation.add('gamepad', [1], 1, false);
		controllerSpr.animation.add('touch', [2], 1, false);
		controllerSpr.animation.play('touch');
		add(controllerSpr);

		var controllerTip:Alphabet = new Alphabet(54, 90, 'Touch', false);
		controllerTip.alignment = CENTERED;
		controllerTip.setScale(0.4);
		add(controllerTip);

		createBinding();

		var backButton:BackButton = new BackButton(0, 0, FlxColor.WHITE, true);
		backButton.x = FlxG.width - backButton.width - 60;
		backButton.y = FlxG.height - backButton.height - 28;
		backButton.onConfirmEnd.add(backButtonTrigger);
		add(backButton);

        super.create();
    }

    var lastID:Int = -1;
    function createTexts()
    {
		removeTexts();

        for (i in 0...bindsOptions.length)
        {
			var option:Array<String> = bindsOptions[i];
			var isCentered:Bool = option.length < 2;
			var isDefaultKey:Bool = option[0] == defaultKey;
			var isDisplayKey:Bool = isCentered && !isDefaultKey;

			var text:Alphabet = new Alphabet(240, 300, option[0], !isDisplayKey);
			text.isMenuItem = true;
			text.changeX = false;
			text.distancePerItem.y = 60;
			text.targetY = i;
			lastID = text.ID = i;

			if (isDisplayKey)
				grpDisplay.add(text);
			else {
				grpOptions.add(text);
				curOptions.push(i);
			}

			if (isCentered) {
				text.screenCenter(X);
				text.y -= 55;
				text.startPosition.y -= 55;
			}
			else
				setupBindText(text, option);

			text.snapToPosition();
			text.y += FlxG.height * 2;
        }

		changeBindingsSelection();
    }

    function setupBindText(text:Alphabet, config:Array<String>)
    {
		var gamepadBinds:Array<Null<FlxGamepadInputID>> = ClientPrefs.gamepadBinds.get(config[1]);
		if (gamepadBinds == null)
			gamepadBinds = ClientPrefs.defaultButtons.get(config[1]).copy();

        for (n in 0...2)
        {
			var textX:Float = (text.x + 200) + n * (bindBoxesWidth + 50);

			var key:String = InputFormatter.getGamepadName(gamepadBinds[n] != null ? gamepadBinds[n] : NONE);
			var attach:Alphabet = new Alphabet(textX + 170, 248, key, false);
			attach.isMenuItem = true;
			attach.changeX = false;
			attach.distancePerItem.y = 60;
			attach.targetY = text.targetY;
			attach.ID = Math.floor(grpBinds.length / 2);
			attach.snapToPosition();
			attach.y += FlxG.height * 2;
			grpBinds.add(attach);

			attach.scaleX = Math.min(1, (bindBoxesWidth - 20) / attach.width);

			var black:AttachedSprite = new AttachedSprite();
			black.makeGraphic(bindBoxesWidth, 78, FlxColor.BLACK);
			black.alphaMult = 0.4;
			black.sprTracker = text;
			black.yAdd = -6;
			black.xAdd = textX - 78;
			grpBGs.add(black);
        }
    }

    function removeTexts()
    {
		curOptions = [];
		grpDisplay.forEachAlive(spr -> spr.destroy());
		grpOptions.forEachAlive(spr -> spr.destroy());
		grpBGs.forEachAlive(spr -> spr.destroy());
		grpBinds.forEachAlive(spr -> spr.destroy());
		grpDisplay.clear();
		grpOptions.clear();
		grpBGs.clear();
		grpBinds.clear();
    }

	var binding:Bool = false;
    var swiping:Bool = false;
    var moveLength:Float = 0;
	var holdingBackTimer:Float = 0;
    override function update(elapsed:Float)
    {
		if (onTouchMode)
			updateTouchControls();
        else
			updateGamepadKeybinds(elapsed);

		if ((PointerUtil.overlaps(controllerSpr) && PointerUtil.justReleased) || FlxG.gamepads.anyJustPressed(LEFT_SHOULDER) || FlxG.gamepads.anyJustPressed(RIGHT_SHOULDER)) swapMode();

        super.update(elapsed);
    }

    function updateTouchControls()
    {
		#if android
		if (FlxG.android.justReleased.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			close();
			return;
		}
		#end

		var overlapsLeft:Bool = false;
		var overlapsRight:Bool = false;
		if (PointerUtil.overlaps(leftArrow))
		{
			overlapsLeft = true;

			if (PointerUtil.justPressed)
				changeMobileSelection(-1);
		}

		if (PointerUtil.overlaps(rightArrow))
		{
			overlapsRight = true;

			if (PointerUtil.justPressed)
				changeMobileSelection(1);
		}

		leftArrow.color = PointerUtil.pressed && overlapsLeft ? FlxColor.GRAY : FlxColor.WHITE;
		rightArrow.color = PointerUtil.pressed && overlapsRight ? FlxColor.GRAY : FlxColor.WHITE;

		if (!(overlapsLeft || overlapsRight))
		{}
    }

    function updateGamepadKeybinds(elapsed:Float)
    {
		#if android
		if (FlxG.android.justReleased.BACK)
		{
			if (binding)
				stopBinding();
			else
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				close();
			}
			return;
		}
		#end

		if (PointerUtil.justPressed && !binding)
			swiping = true;

		final fpsMult:Float = FlxG.updateFramerate / 60;
		if (PointerUtil.pressed && swiping)
		{
			final delta:Float = PointerUtil.pointer.deltaViewY * fpsMult;

			if (Math.isFinite(delta) && Math.abs(delta) >= 2)
			{
				var dpiScale:Float = FlxG.stage.window.display.dpi / 160;
				dpiScale = FlxMath.bound(dpiScale, 0.5, #if android 1 #else 2 #end);

				var _moveLength:Float = delta / FlxG.updateFramerate / dpiScale;
				moveLength += Math.abs(_moveLength);
				curSelectedFloat -= _moveLength;

				updateBindingsScroll();
			}
		}

		curSelectedFloat = FlxMath.bound(curSelectedFloat, 0, curOptions.length - 1);
		curSelected = Math.round(curSelectedFloat);

		if (PointerUtil.justReleased)
			swiping = false;

		if (!binding)
		{
			if (FlxG.gamepads.anyJustPressed(B))
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				close();
				return;
			}

			if (FlxG.gamepads.anyJustPressed(LEFT_SHOULDER) || FlxG.gamepads.anyJustPressed(RIGHT_SHOULDER))
				swapMode();

			if (FlxG.gamepads.anyJustPressed(DPAD_UP) || FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_UP))
				changeBindingsSelection(-1);
			else if (FlxG.gamepads.anyJustPressed(DPAD_DOWN) || FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_DOWN))
				changeBindingsSelection(1);

			if (FlxG.gamepads.anyJustPressed(DPAD_LEFT) || FlxG.gamepads.anyJustPressed(DPAD_RIGHT) || FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_LEFT) || FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_RIGHT))
				updateAlt(true);

			if (FlxG.gamepads.anyJustPressed(START) || FlxG.gamepads.anyJustPressed(A))
			{
				if (bindsOptions[curOptions[curSelected]][0] != defaultKey)
				{
					startBinding(bindsOptions[curOptions[curSelected]][2]);
					ClientPrefs.toggleVolumeKeys(false);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				else
				{
					ClientPrefs.resetKeys(true);
					ClientPrefs.reloadVolumeKeys();
					var lastSelected:Int = curSelected;
					createTexts();
					curSelected = lastSelected;
					changeBindingsSelection();
					FlxG.sound.play(Paths.sound('cancelMenu'));
				}
			}
		}
		else
		{
			var altNum:Int = curAlt ? 1 : 0;
			var curOption:Array<Dynamic> = bindsOptions[curOptions[curSelected]];
			if (FlxG.gamepads.anyPressed(B))
			{
				if (holdingBackTimer > 0.5)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					stopBinding();
				}
				else
					holdingBackTimer += elapsed;
			}
			else if (FlxG.gamepads.anyPressed(BACK))
			{
				if (holdingBackTimer > 0.5)
				{
					ClientPrefs.keyBinds.get(curOption[1])[altNum] = NONE;
					ClientPrefs.clearInvalidKeys(curOption[1]);
					updateBind(Math.floor(curSelected * 2) + altNum, InputFormatter.getGamepadName(NONE));
					FlxG.sound.play(Paths.sound('cancelMenu'));
					stopBinding();
				}
				else
					holdingBackTimer += elapsed;
			}
			else
			{
				holdingBackTimer = 0;
				var changed:Bool = false;
				var curButtons:Array<FlxGamepadInputID> = ClientPrefs.gamepadBinds.get(curOption[1]);
				if (FlxG.gamepads.anyJustPressed(ANY) || FlxG.gamepads.anyJustPressed(LEFT_TRIGGER) || FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER))
				{
					var buttonPressed:Null<FlxGamepadInputID> = NONE;

					for (i in 0...FlxG.gamepads.numActiveGamepads)
					{
						var gamepad:FlxGamepad = FlxG.gamepads.getByID(i);
						if (gamepad != null)
						{
							buttonPressed = gamepad.firstJustPressedID();

							if (buttonPressed == null) buttonPressed = NONE;
							if (buttonPressed != NONE) break;
						}
					}

					if (buttonPressed != NONE && !(buttonPressed == BACK || buttonPressed == B))
					{
						curButtons[altNum] = buttonPressed;
						changed = true;
					}
				}

				if (changed)
				{
					if (curButtons[altNum] == curButtons[1 - altNum])
						curButtons[1 - altNum] = FlxGamepadInputID.NONE;
				}

				var bindID:String = curOption[1];
				ClientPrefs.clearInvalidKeys(bindID);

				var saveKey:Array<Null<FlxGamepadInputID>> = ClientPrefs.gamepadBinds.get(bindID);
				for (n in 0...2)
				{
					var key:String = InputFormatter.getGamepadName(saveKey[n] != null ? saveKey[n] : NONE);
					updateBind(Math.floor(curSelected * 2) + n, key);
				}

				FlxG.sound.play(Paths.sound('confirmMenu'));
				stopBinding();
			}
		}
    }

	function backButtonTrigger()
	{
		if (binding)
			stopBinding();
		else
			close();
	}

	function changeMobileSelection(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, 2);
		curSelectedFloat = curSelected;

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function changeBindingsSelection(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, curOptions.length - 1);
		curSelectedFloat = curSelected;

		var num:Int = curOptions[curSelected];
		var addNum:Int = 0;
		if (num < 3) addNum = 3 - num;
		else if (num > lastID - 4) addNum = (lastID - 4) - num;

		grpDisplay.forEachAlive(function(item:Alphabet) {
			item.targetY = item.ID - num - addNum;
		});

		grpOptions.forEachAlive(function(item:Alphabet) {
			item.targetY = item.ID - num - addNum;
			item.alpha = (item.ID - num == 0) ? 1 : 0.6;
		});
		grpBinds.forEachAlive(function(item:Alphabet) {
			var parent:Alphabet = grpOptions.members[item.ID];
			item.targetY = parent.targetY;
			item.alpha = parent.alpha;
		});

		updateAlt();
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function updateBindingsScroll()
	{
		var lastSelected:Int = curSelected;
		curSelected = CoolUtil.boundInt(Math.round(curSelectedFloat), 0, curOptions.length - 1);

		if (curSelected != lastSelected)
		{
			var num:Int = curOptions[curSelected];
			var addNum:Int = 0;
			if (num < 3) addNum = 3 - num;
			else if (num > lastID - 4) addNum = (lastID - 4) - num;
	
			grpDisplay.forEachAlive(function(item:Alphabet) {
				item.targetY = item.ID - num - addNum;
			});
	
			grpOptions.forEachAlive(function(item:Alphabet) {
				item.targetY = item.ID - num - addNum;
				item.alpha = (item.ID - num == 0) ? 1 : 0.6;
			});
			grpBinds.forEachAlive(function(item:Alphabet) {
				var parent:Alphabet = grpOptions.members[item.ID];
				item.targetY = parent.targetY;
				item.alpha = parent.alpha;
			});
	
			updateAlt();
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
	}

	function updateAlt(?doSwap:Bool = false)
	{
		if (doSwap)
		{
			curAlt = !curAlt;
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		selectorThing.sprTracker = grpBGs.members[Math.floor(curSelected * 2) + (curAlt ? 1 : 0)];
		selectorThing.visible = selectorThing.sprTracker != null;
	}

    var colorTween:FlxTween;
    function swapMode()
    {
		onTouchMode = !onTouchMode;

		if (colorTween != null) colorTween.destroy();
		colorTween = FlxTween.color(bg, 0.5, bg.color, onTouchMode ? mobileColor : gamepadColor);

		curSelectedFloat = curSelected = 0;
        curAlt = false;
		controllerSpr.animation.play(onTouchMode ? 'touch' : 'gamepad');

		if (onTouchMode)
        {
			removeTexts();
			selectorThing.sprTracker = null;
			selectorThing.visible = false;
			mobileCtrlText.visible = true;
			leftArrow.visible = true;
			rightArrow.visible = true;
        }
        else
        {
			createTexts();
			selectorThing.visible = true;
			mobileCtrlText.visible = false;
			leftArrow.visible = false;
			rightArrow.visible = false;
        }
    }

	var rebindingBG:FlxSprite;
	var rebindingText:Alphabet;
	var rebindingTip:Alphabet;

	function createBinding()
	{
		rebindingBG = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
		rebindingBG.scale.set(FlxG.width, FlxG.height);
		rebindingBG.updateHitbox();
		rebindingBG.alpha = 0;
		rebindingBG.visible = false;
		add(rebindingBG);

		rebindingText = new Alphabet(FlxG.width / 2, 160, 'Rebinding', false);
		rebindingText.alignment = CENTERED;
		rebindingText.visible = false;
		add(rebindingText);

		rebindingTip = new Alphabet(FlxG.width / 2, 340, 'Hold B or Press the Back Button to Cancel\nHold BACK to Delete');
		rebindingTip.alignment = CENTERED;
		rebindingTip.visible = false;
		add(rebindingTip);
	}

	function startBinding(bind:String)
	{
		binding = true;

		rebindingText.text = 'Rebinding $bind';
		rebindingTip.text = 'Hold ${InputFormatter.getGamepadName(B)} or Press the Back Button to Cancel\nHold ${InputFormatter.getGamepadName(BACK)} to Delete';

		rebindingBG.visible = true;
		rebindingText.visible = true;
		rebindingTip.visible = true;

		rebindingBG.alpha = 0;
		FlxTween.tween(rebindingBG, {alpha: 0.6}, 0.35);

		holdingBackTimer = 0;
	}

	function updateBind(num:Int, text:String)
	{
		var bind:Alphabet = grpBinds.members[num];
		var attach:Alphabet = new Alphabet(350 + (num % 2) * 300, 248, text, false);
		attach.isMenuItem = true;
		attach.changeX = false;
		attach.distancePerItem.y = 60;
		attach.targetY = bind.targetY;
		attach.ID = bind.ID;
		attach.x = bind.x;
		attach.y = bind.y;

		attach.scaleX = Math.min(1, (bindBoxesWidth - 20) / attach.width);
		// attach.text = text;

		grpBinds.remove(bind);
		grpBinds.insert(num, attach);
		bind.destroy();
	}

	function stopBinding()
	{
		binding = false;

		rebindingBG.visible = false;
		rebindingText.visible = false;
		rebindingTip.visible = false;

		rebindingBG.alpha = 0;

		holdingBackTimer = 0;
	}
}
#end