package objects;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';
	public var isAnimatedIcon(default, null):Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false, ?allowGPU:Bool = true)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char, allowGPU);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	private var iconOffsets:Array<Float> = [0, 0];

	public function changeIcon(char:String, ?allowGPU:Bool = true)
	{
		if (this.char != char)
		{
			var name:String = 'icons/' + char;
			if (!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if (!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/face'; //Prevents crash from missing icon

			if (Paths.fileExists('images/' + name + '.xml', TEXT))
			{
				isAnimatedIcon = true;
				frames = Paths.getSparrowAtlas(name);
				animation.addByPrefix('normal', 'normal', 6, true, isPlayer);
				animation.addByPrefix('losing', 'lose', 6, true, isPlayer);
				animation.addByPrefix('winning', 'win', 6, true, isPlayer);
				animation.play('normal');
			}
			else
			{
				isAnimatedIcon = false;
				var graphic = Paths.image(name, allowGPU);
				loadGraphic(graphic, true, Math.floor(graphic.width / 2), Math.floor(graphic.height));
	
				animation.add(char, [0, 1], 0, false, isPlayer);
				animation.play(char);
			}

			var additionalOffset:FlxPoint = FlxPoint.get();

			switch (char)
			{
				case "red": additionalOffset.set(10, 0);
				case "redM": additionalOffset.set(10, 0);
				case "idk": additionalOffset.set(8, 0);
				case "dave": additionalOffset.set(-30, -21);
				case "black": additionalOffset.set(4, 0);
			}

			iconOffsets[0] = ((width - 150) / 2) - additionalOffset.x;
			iconOffsets[1] = ((height - 150) / 2) - additionalOffset.y;
			updateHitbox();

			this.char = char;

			antialiasing = char.endsWith('-pixel') ? false : ClientPrefs.data.antialiasing;
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String
		return char;
}
