package backend;

import flixel.addons.display.shapes.FlxShapeCircle;

class CustomFadeTransition extends MusicBeatSubstate
{
	public static var instance(default, null):CustomFadeTransition;

	public static var finishCallback:Void->Void;

	var isTransIn:Bool = false;
	var duration:Float;

	static var whiteCircle:FlxSprite;
	static var bf:FlxSprite;

	public var camTrans:FlxCamera;

	public function new(duration:Float, isTransIn:Bool)
	{
		this.duration = duration;
		this.isTransIn = isTransIn;
		super();
	}

	override function create()
	{
		instance = this;

		camTrans = new FlxCamera();
		camTrans.bgColor.alpha = 0;
		FlxG.cameras.add(camTrans, false);

		cameras = [camTrans];

		whiteCircle = new FlxSprite().loadGraphic(Paths.image('switchState'));
		whiteCircle.antialiasing = false;
		whiteCircle.screenCenter();
		add(whiteCircle);

		bf = new FlxSprite();
		bf.frames = Paths.getSparrowAtlas('runbfrun');
		bf.animation.addByPrefix('run', "run", 24, false);
		bf.animation.addByPrefix('stop', "stop", 24, false);
		bf.animation.addByPrefix('loopedStop', "loop-stop", 24, true);
		bf.animation.play('run');
		bf.antialiasing = false;
		bf.screenCenter(Y);
		bf.x -= bf.width;
		bf.scale.set(1.5, 1.5);
		add(bf);

		if (!isTransIn)
		{
			bf.x -= bf.width;
			whiteCircle.scale.set(0, 0);
		}
		else
		{
			bf.x = (FlxG.width / 2) - (bf.width / 2);
			whiteCircle.scale.set(7, 7);
		}

		if (!isTransIn)
		{
			FlxTween.tween(bf, {x: (FlxG.width - bf.width) / 2}, duration, {ease: FlxEase.quadOut});
			FlxTween.tween(whiteCircle.scale, {x: 7, y: 7}, duration, {ease: FlxEase.quadOut, onComplete: _ ->
				{
					if (finishCallback != null) finishCallback();
					finishCallback = null;
				}
			});
		}
		else
		{
			FlxTween.tween(bf, {x: FlxG.width}, duration, {ease: FlxEase.quadIn});
			FlxTween.tween(whiteCircle.scale, {x: 0.001, y: 0.001}, duration, {ease: FlxEase.quadIn, onComplete: _ -> close()});
		}

		super.create();
	}

	override function destroy()
	{
		super.destroy();

		instance = null;
	}
}