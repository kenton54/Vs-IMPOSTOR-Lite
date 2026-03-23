package states;

import flixel.util.typeLimit.OneOfTwo;
import objects.AttachedSprite;
import objects.CreditsList;
import objects.MenuItem;

#if mobile
import objects.BackButton;
#end

class CreditsState extends MusicBeatState
{
	var curSelected:Int = 0;
	var curSelectedFloat:Float = 0;

	public var description(default, set):String;

	public var color(default, set):FlxColor;

	var grpOptions:FlxTypedGroup<OneOfTwo<MenuItem, CreditsList>>;
	var creditsList:Array<Array<Dynamic>> = [];

	var curCredits(get, never):Array<Dynamic>;

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:FlxColor = FlxColor.WHITE;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var offsetThing:Float = -75;

	var teamName:String = "";

	public function new(teamName:String, list:Array<Array<Dynamic>>)
	{
		super();

		this.teamName = teamName;

		for (i in list)
			creditsList.push(i);
	}

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Looking at the credits", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('sketch2'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		grpOptions = new FlxTypedGroup<OneOfTwo<MenuItem, CreditsList>>();
		add(grpOptions);

		leftArrow = new FlxSprite(20, 0);
		leftArrow.antialiasing = false;
		leftArrow.loadGraphic(Paths.image('arrowButton'));
		leftArrow.color = FlxColor.WHITE;
		leftArrow.screenCenter(Y);

		rightArrow = new FlxSprite();
		rightArrow.antialiasing = false;
		rightArrow.loadGraphic(Paths.image('arrowButton'));
		rightArrow.color = FlxColor.WHITE;
		rightArrow.screenCenter(Y);
		rightArrow.x = FlxG.width - rightArrow.width - 20;
		rightArrow.flipX = true;
		add(leftArrow);
		add(rightArrow);

		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(0, FlxG.height + offsetThing - 25, 1100, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER /*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		// descText.borderSize = 2.4;
		descText.screenCenter(X);
		descBox.sprTracker = descText;
		add(descText);

		var socialText:String = #if mobile "Touch the person to open their social media!" #else "Press ACCEPT to open their social media!" #end;
		var socialCheck:FlxText = new FlxText(0, FlxG.height - 24, 0, socialText, 12);
		socialCheck.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		socialCheck.screenCenter(X);
		add(socialCheck);

		/*
		#if MODS_ALLOWED
		for (mod in Mods.parseList().enabled) pushModCreditsToList(mod);
		#end
		*/
	
		for (i => credit in creditsList)
		{
			var isSelectable:Bool = false;

			if (credit[0] == "portrait")
			{
				isSelectable = !unselectableCheck(i);

				var creditPortrait:MenuItem = new MenuItem();
				creditPortrait.loadGraphic(Paths.image('credits/${teamName}/' + credit[1]));
				creditPortrait.centerInScreen = true;
				creditPortrait.setGraphicSize(0, FlxG.height);
				creditPortrait.updateHitbox();
				creditPortrait.x = creditPortrait.width / 2 + FlxG.width * i;
				creditPortrait.targetX = i;
				creditPortrait.screenCenter(Y);
				creditPortrait.antialiasing = ClientPrefs.data.antialiasing;
				grpOptions.add(creditPortrait);
			}
			else if (credit[0] == "list")
			{
				isSelectable = !unselectableCheck(i);

				var optionList:CreditsList = new CreditsList();
				optionList.parent = this;
				optionList.targetX = i;

				var omfg:Array<Array<String>> = credit[1];
				for (person in omfg)
				{
					optionList.addCredit(person[0], person[1], person[2]);
				}

				grpOptions.add(optionList);
			}

			if (isSelectable)
			{
				if (credit[5] != null)
					Mods.currentModDirectory = credit[5];

				Mods.currentModDirectory = '';
			}
		}

		#if mobile
		var backButton:BackButton = new BackButton();
		backButton.x = FlxG.width - backButton.width - 60;
		backButton.y = FlxG.height - backButton.height - 28;
		backButton.onConfirmStart.add(() -> quitting = true);
		backButton.onConfirmEnd.add(() -> FlxG.switchState(() -> new SelectCreditsState()));
		add(backButton);
		#end

		super.create();

		changeSelection(0, "", true);
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	#if mobile
	var swiping:Bool = false;
	var moveLength:Float = 0;
	#end
	override function update(elapsed:Float)
	{
		#if mobile
		var overlapLeft:Bool = false;
		var overlapRight:Bool = false;
		if (!quitting)
		{
			if (PointerUtil.overlaps(leftArrow) && !swiping)
			{
				overlapLeft = true;
				leftArrow.color = PointerUtil.pressed ? FlxColor.GRAY : FlxColor.WHITE;

				if (PointerUtil.justPressed)
					changeSelection(-1);
			}

			if (PointerUtil.overlaps(rightArrow) && !swiping)
			{
				overlapRight = true;
				rightArrow.color = PointerUtil.pressed ? FlxColor.GRAY : FlxColor.WHITE;

				if (PointerUtil.justPressed)
					changeSelection(1);
			}

			if (PointerUtil.justPressed && !(overlapLeft || overlapRight))
				swiping = true;
		}

		final fpsMult:Float = FlxG.updateFramerate / 60;
		if (PointerUtil.pressed && swiping)
		{
			final delta:Float = PointerUtil.pointer.deltaViewX * fpsMult;

			if (Math.isFinite(delta) && Math.abs(delta) >= 2)
			{
				var dpiScale:Float = FlxG.stage.window.display.dpi / 160;
				dpiScale = FlxMath.bound(dpiScale, 0.5, #if android 1 #else 2 #end);

				var _moveLength:Float = delta / FlxG.updateFramerate / dpiScale / 2;
				moveLength += Math.abs(_moveLength);
				curSelectedFloat -= _moveLength;

				updateScroll();
			}
		}
		else if (moveLength > 0)
		{
			moveLength = 0;
			changeSelection();
		}

		curSelectedFloat = FlxMath.bound(curSelectedFloat, 0, creditsList.length - 1);
		curSelected = Math.round(curSelectedFloat);

		if ((overlapLeft || overlapRight) && !(overlapLeft && overlapRight))
		{
			var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
			holdTime += elapsed;
			var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);
			
			if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				changeSelection((checkNewHold - checkLastHold) * (overlapLeft ? -1 : 1));
		}
		else
			holdTime = 0;

		if (PointerUtil.overlaps(grpOptions.members[curSelected]) && !(overlapLeft || overlapRight) && !swiping && !SwipeUtil.justSwipedAny && PointerUtil.justReleased)
			checkSelection();

		if (PointerUtil.justReleased)
			swiping = false;

		#if android
		if (FlxG.android.justReleased.BACK)
		{
			quitting = true;
			FlxG.switchState(() -> new SelectCreditsState());
		}
		#end
		#else
		rightArrow.color = controls.UI_RIGHT ? FlxColor.GRAY : FlxColor.WHITE;
		leftArrow.color = controls.UI_LEFT ? FlxColor.GRAY : FlxColor.WHITE;

		if (!quitting)
		{
			if (creditsList.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var leftP = controls.UI_LEFT_P;
				var rightP = controls.UI_RIGHT_P;

				if (leftP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (rightP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if (rightP || leftP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						changeSelection((checkNewHold - checkLastHold) * (leftP ? -shiftMult : shiftMult));
				}
			}

			if (controls.ACCEPT)
				checkSelection();

			if (controls.BACK)
			{
				if(colorTween != null) colorTween.cancel();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new SelectCreditsState());
				quitting = true;
			}
		}
		#end

		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	public function changeSelection(change:Int = 0, description:String = "", force:Bool = false)
	{
		var lastSelected:Int = curSelected;
		curSelected = FlxMath.wrap(curSelected + change, 0, creditsList.length - 1);
		curSelectedFloat = curSelected;

		if (unselectableCheck(curSelected))
		{
			changeSelection(change, description);
			return;
		}

		if (curSelected != lastSelected || force)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));

			var descTxt:String = description != "" ? description : (curCredits[2] != null ? curCredits[2] : "");
			this.description = descTxt;

			var newColor:FlxColor = CoolUtil.colorFromString(curCredits[4] ?? "FFFFFF");
			color = newColor;
		}

		// can the haxe compiler stfu
		for (i => item in grpOptions.members)
		{
			if (Std.isOfType(item, MenuItem))
				cast(item, MenuItem).targetX = i - curSelected;
			else if (Std.isOfType(item, CreditsList))
			{
				var list:CreditsList = cast(item, CreditsList);
				list.targetX = i - curSelected;

				list.allowSelection = i == curSelected;
				list.changePerson();
			}
		}
	}

	#if mobile
	function updateScroll()
	{
		var lastSelected:Int = curSelected;
		curSelected = CoolUtil.boundInt(Math.round(curSelectedFloat), 0, creditsList.length - 1);

		if (curSelected != lastSelected)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));

			var descTxt:String = curCredits != null && curCredits[2] != null ? curCredits[2] : "";
			description = descTxt;

			var newColor:FlxColor = CoolUtil.colorFromString(curCredits != null ? (curCredits[4] ?? "FFFFFF") : "FFFFFF");
			color = newColor;
		}

		for (i => item in grpOptions.members)
		{
			if (Std.isOfType(item, MenuItem))
				cast(item, MenuItem).targetX = i - curSelectedFloat;
			else if (Std.isOfType(item, CreditsList))
			{
				var list:CreditsList = cast(item, CreditsList);
				list.targetX = i - curSelectedFloat;

				list.allowSelection = i == curSelected;
				list.changePerson();
			}
		}
	}
	#end

	function checkSelection()
	{
		if (curCredits[1] == "sparkly")
		{
			var sixSeven:FlxSound = FlxG.sound.load(Paths.sound("67"), 1, false, null, true);
			sixSeven.persist = true;
			sixSeven.play();
		}

		if (Std.isOfType(grpOptions.members[curSelected], MenuItem) && curCredits[3] != null && curCredits[3] != "")
			CoolUtil.browserLoad(curCredits[3]);
	}

	#if MODS_ALLOWED
	function pushModCreditsToList(folder:String)
	{
		var creditsFile:String = null;
		if(folder != null && folder.trim().length > 0) creditsFile = Paths.mods(folder + '/data/credits.txt');
		else creditsFile = Paths.mods('data/credits.txt');

		if (FileSystem.exists(creditsFile))
		{
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for(i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if(arr.length >= 5) arr.push(folder);
				creditsList.push(arr);
			}
			creditsList.push(['']);
		}
	}
	#end

	private function unselectableCheck(num:Int):Bool {
		return creditsList[num].length <= 1;
	}

	function set_description(value:String):String
	{
		description = value;

		var isEmpty = value == "";
		descText.visible = !isEmpty;
		descBox.visible = !isEmpty;
		descText.text = value;

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();

		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if (moveTween != null) moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y: descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		return value;
	}

	function set_color(color:FlxColor):FlxColor
	{
		if (color != intendedColor)
		{
			if (colorTween != null)
			{
				colorTween.cancel();
			}
			intendedColor = color;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
			});
		}

		return color;
	}

	function get_curCredits():Array<Dynamic>
	{
		return creditsList[curSelected];
	}
}