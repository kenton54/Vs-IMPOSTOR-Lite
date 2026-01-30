package states;

import flixel.util.typeLimit.OneOfTwo;
import objects.AttachedSprite;
import objects.MenuItem;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = 0;

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

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1100, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER /*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		// descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		var socialCheck:FlxText = new FlxText(0, FlxG.height - 24, 0, "Press ACCEPT to move to social media!", 12);
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
				creditPortrait.x = creditPortrait.width * i;
				creditPortrait.targetX = i;
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

		super.create();

		changeSelection();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (controls.UI_RIGHT)
			rightArrow.color = FlxColor.GRAY;
		else
			rightArrow.color = FlxColor.WHITE;

		if (controls.UI_LEFT)
			leftArrow.color = FlxColor.GRAY;
		else
			leftArrow.color = FlxColor.WHITE;

		if(!quitting)
		{
			if(creditsList.length > 1)
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

				if(rightP || leftP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (leftP ? -shiftMult : shiftMult));
					}
				}
			}

			if (controls.ACCEPT && Std.isOfType(grpOptions.members[curSelected], MenuItem) && curCredits[3] == null && curCredits[3] != "")
				CoolUtil.browserLoad(curCredits[3]);

			if (controls.BACK)
			{
				if(colorTween != null) colorTween.cancel();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new SelectCreditsState());
				quitting = true;
			}
		}

		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	public function changeSelection(change:Int = 0, manualText:String = "")
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, creditsList.length - 1);

		if (unselectableCheck(curSelected))
		{
			changeSelection(change, manualText);
			return;
		}

		if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		description = manualText != "" ? manualText : curCredits[2];
		var newColor:FlxColor = CoolUtil.colorFromString(curCredits[4] ?? "FFFFFF");
		color = newColor;

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

class CreditsList extends FlxTypedSpriteGroup<FlxSprite>
{
	public var currentPerson:Int = 0;

	public var targetX:Float = 0;

	public var parent:CreditsState;

	public var blackBox:FlxSprite;

	public var peopleGrp:FlxTypedSpriteGroup<Alphabet>;

	public var groupList:Array<Array<String>> = [];

	public var allowSelection:Bool = false;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		blackBox = new FlxSprite();
		blackBox.makeGraphic(1, 1, FlxColor.BLACK);
		blackBox.alpha = 0.6;
		add(blackBox);

		peopleGrp = new FlxTypedSpriteGroup<Alphabet>();
		add(peopleGrp);

		// peopleGrp.y += 25;

		updateBox();
	}

	public function addCredit(name:String, description:String, url:String)
	{
		var nameSpr:Alphabet = new Alphabet(0, 0, name, true);
		nameSpr.distancePerItem.x = 0;
		nameSpr.targetY = groupList.length;
		nameSpr.ID = groupList.length;
		nameSpr.setScale(0.75, 0.75);
		nameSpr.screenCenter(X);
		nameSpr.y = 90 * groupList.length;
		peopleGrp.add(nameSpr);
		groupList.push([name, description, url]);

		/*
		for (i => nameSpr in peopleGrp.members)
		{
			nameSpr.y = blackBox.y + (90 * (i - (groupList.length / 2))) - 55;
		}
		*/

		updateBox();
		changePerson();
	}

	function updateBox()
	{
		blackBox.setGraphicSize(peopleGrp.width + 100, peopleGrp.height + 100);
		blackBox.updateHitbox();
		blackBox.screenCenter();
		blackBox.y -= 50;
		peopleGrp.y = blackBox.y + 50;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		x = FlxMath.lerp(targetX * FlxG.width, x, Math.exp(-elapsed * 10.2));

		if (allowSelection && groupList.length > 0)
		{
			if (Controls.instance.UI_UP_P) changePerson(-1);
			if (Controls.instance.UI_DOWN_P) changePerson(1);

			if (Controls.instance.ACCEPT)
				if (groupList[currentPerson][2] != "" && groupList[currentPerson][2] != null) CoolUtil.browserLoad(groupList[currentPerson][2]);
		}
	}

	public function changePerson(change:Int = 0)
	{
		if (!allowSelection) return;

		if(change != 0) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		currentPerson = FlxMath.wrap(currentPerson + change, 0, peopleGrp.length - 1);

		for(i => person in peopleGrp.members) {
			person.targetY = i - currentPerson;

			if(person.ID == currentPerson) person.alpha = 1; 
			else person.alpha = 0.5;
		}

		if (parent != null)
			parent.description = groupList[currentPerson][1];
	}
}