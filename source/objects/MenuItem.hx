package objects;

class MenuItem extends FlxSprite
{
	public var targetX:Float = 0;
	public var centerInScreen:Bool = false;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		antialiasing = ClientPrefs.data.antialiasing;
	}

	public var isFlashing(default, set):Bool = false;
	private var _flashingElapsed:Float = 0;
	final _flashColor:Int = 0xFF33FFFF;
	final flashes_ps:Int = 6;

	public function set_isFlashing(value:Bool = true):Bool
	{
		isFlashing = value;
		_flashingElapsed = 0;
		color = (isFlashing) ? _flashColor : FlxColor.WHITE;
		return isFlashing;
	}

	var lerpX:Float = 0;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (centerInScreen)
		{
			var center:Float = (FlxG.width - width) / 2;
			var intendedX:Float = targetX * FlxG.width;
			lerpX = FlxMath.lerp(intendedX, lerpX, Math.exp(-elapsed * 10.2));
			x = lerpX + center;
		}
		else
		{
			var intendedX:Float = targetX * FlxG.width;
			lerpX = FlxMath.lerp(intendedX, lerpX, Math.exp(-elapsed * 10.2));
			x = lerpX;
		}

		if (isFlashing)
		{
			_flashingElapsed += elapsed;
			color = (Math.floor(_flashingElapsed * FlxG.updateFramerate * flashes_ps) % 2 == 0) ? _flashColor : FlxColor.WHITE;
		}
	}
}
