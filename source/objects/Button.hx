package objects;

#if mobile
import flixel.FlxObject;
import flixel.input.FlxInput;
import flixel.input.IFlxInput;
import flixel.input.touch.FlxTouch;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;

class Button extends FlxSprite implements IFlxInput
{
	public var onPress:FlxSignal = new FlxSignal();
	public var onRelease:FlxSignal = new FlxSignal();
	public var onUnhover:FlxSignal = new FlxSignal();

	public var justPressed(get, never):Bool;
	public var pressed(get, never):Bool;
	public var justReleased(get, never):Bool;
	public var released(get, never):Bool;

	public var enabled:Bool = true;

	public var deadzones:Array<FlxObject> = [];

	public var curTouch(get, never):Null<FlxTouch>;

	var curInput:IFlxInput;
	var input:FlxInput<Int>;

	var touchID:Int = -1;

	var _isPressed:Bool = false;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		solid = false;
		immovable = true;
		scrollFactor.set();

		input = new FlxInput(0);
	}

	override function destroy()
	{
		super.destroy();

		deadzones = FlxDestroyUtil.destroyArray(deadzones);
		curInput = null;
		input = null;

		touchID = -1;

		onPress.removeAll();
		onRelease.removeAll();
		onUnhover.removeAll();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (visible && enabled)
		{
			final overlapping:Bool = checkOverlap();

			if (curInput != null && curInput.justReleased && overlapping)
				releaseHandler();

			if ((curInput != null && curInput.justReleased) || !overlapping)
				unhoverHandler();
		}

		input.update();
	}

	function checkOverlap():Bool
	{
		for (camera in cameras)
		{
			for (touch in FlxG.touches.list)
			{
				final worldPos:FlxPoint = touch.getWorldPosition(camera, _point);

				for (deadzone in deadzones)
					if (deadzone != null && deadzone.overlapsPoint(worldPos, true, camera))
						return false;

				if (overlapsPoint(worldPos, true, camera))
				{
					touchID = touch.touchPointID;
					updateStatus(touch);
					return true;
				}
			}
		}

		return false;
	}

	function updateStatus(newInput:IFlxInput)
	{
		if (newInput.justPressed)
		{
			curInput = newInput;
			pressHandler();
		}
		else if (!_isPressed)
			if (newInput.pressed)
				pressHandler();
	}

	function pressHandler()
	{
		_isPressed = true;

		input.press();

		onPress.dispatch();
	}

	function releaseHandler()
	{
		_isPressed = false;

		input.release();
		curInput = null;
		touchID = -1;

		onRelease.dispatch();
	}

	function unhoverHandler()
	{
		_isPressed = false;

		input.release();
		touchID = -1;

		onUnhover.dispatch();
	}

	function get_justPressed():Bool
		return input.justPressed;

	function get_pressed():Bool
		return input.pressed;

	function get_justReleased():Bool
		return input.justReleased;

	function get_released():Bool
		return input.released;

	function get_curTouch():Null<FlxTouch>
		return FlxG.touches.getByID(touchID);
}
#end
