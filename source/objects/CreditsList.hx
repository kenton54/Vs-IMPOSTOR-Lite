package objects;

import states.CreditsState;

class CreditsList extends FlxTypedSpriteGroup<FlxSprite>
{
	public var currentPerson:Int = 0;

	public var targetX:Float = 0;

	public var blackBox:FlxSprite;

	public var peopleGrp:FlxTypedSpriteGroup<Alphabet>;

	public var groupList:Array<Array<String>> = [];

	public var allowSelection:Bool = false;

    @:allow(states.CreditsState)
	var parent:CreditsState;

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
			if (Controls.instance.UI_UP_P)
				changePerson(-1);
			if (Controls.instance.UI_DOWN_P)
				changePerson(1);

			if (Controls.instance.ACCEPT)
				if (groupList[currentPerson][2] != "" && groupList[currentPerson][2] != null)
					CoolUtil.browserLoad(groupList[currentPerson][2]);
		}
	}

	public function changePerson(change:Int = 0)
	{
		if (!allowSelection) return;

		if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		currentPerson = FlxMath.wrap(currentPerson + change, 0, peopleGrp.length - 1);

		for (i => person in peopleGrp.members)
		{
			person.targetY = i - currentPerson;

			if (person.ID == currentPerson)
				person.alpha = 1;
			else
				person.alpha = 0.5;
		}

		if (parent != null)
			parent.description = groupList[currentPerson][1];
	}
}