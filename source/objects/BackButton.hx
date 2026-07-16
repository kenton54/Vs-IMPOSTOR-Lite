package objects;

#if mobile
import flixel.util.FlxSignal;

class BackButton extends Button
{
	public var onConfirmStart:FlxSignal = new FlxSignal();
	public var onConfirmEnd:FlxSignal = new FlxSignal();

	var instant:Bool;

	var _confirming:Bool = false;

	public function new(x:Float = 0, y:Float = 0, color:FlxColor = FlxColor.WHITE, instant:Bool = false)
	{
		super(x, y);

		this.instant = instant;

		frames = Paths.getSparrowAtlas("backButton");
		animation.addByIndices("idle", "back button", [0, 1, 2, 3], "", 8, true);
		animation.addByIndices("hold", "back button", [4], "", 1, false);
		animation.addByIndices("confirm", "back button", [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], "", 24, false);
		animation.play("idle");
		antialiasing = false;

		this.color = color;

		scale.set(0.7, 0.7);
		updateHitbox();

		onPress.add(playHold);
		onRelease.add(playConfirm);
		onUnhover.add(playIdle);
		animation.onFinish.add(animEnd);
	}

	override function destroy()
	{
		super.destroy();

		onConfirmStart.removeAll();
		onConfirmEnd.removeAll();
	}

	function playIdle()
	{
		if (!enabled || _confirming)
			return;

		animation.play('idle');
	}

	function playHold()
	{
		if (!enabled || _confirming)
			return;

		animation.play('hold');
	}

	function playConfirm()
	{
		if (!enabled || _confirming)
			return;

		_confirming = true;
		enabled = false;
		FlxG.sound.play(Paths.sound('cancelMenu'));
		onConfirmStart.dispatch();

		if (instant)
		{
			_confirming = false;
			onConfirmEnd.dispatch();
			return;
		}

		animation.play('confirm');
	}

	function animEnd(anim:String)
	{
		if (anim == 'confirm')
		{
			_confirming = false;
			onConfirmEnd.dispatch();

			animation.play('idle');
		}
	}
}
#end
