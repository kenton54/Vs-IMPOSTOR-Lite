package objects;

#if VIDEOS_ALLOWED
import flixel.addons.display.FlxPieDial;

#if hxvlc
import hxvlc.flixel.FlxVideoSprite as VideoHandler;
#elseif html5
import backend.HTML5Video as VideoHandler;
#end

class VideoSprite extends FlxSpriteGroup
{
	public var finishCallback:Void->Void = null;
	public var onSkip:Void->Void = null;

	final _timeToSkip:Float = 1;

	public var speed(get, set):Float;

	public var videoSprite:VideoHandler;
	public var skipSprite:FlxPieDial;
	public var cover:FlxSprite;

	/**
	 * Whether the video can be skipped.
	 */
	public var canSkip(default, set):Bool = false;

	private var videoName:String;

	public var waiting:Bool = false;

	var holdingTime:Float = 0;

	public function new(videoName:String, isWaiting:Bool, canSkip:Bool = false)
	{
		super();

		this.videoName = videoName;
		scrollFactor.set();

		waiting = isWaiting;
		if (!waiting)
		{
			cover = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
			cover.scale.set(FlxG.width + 100, FlxG.height + 100);
			cover.screenCenter();
			cover.scrollFactor.set();
			add(cover);
		}

		// initialize sprites
		videoSprite = new VideoHandler();
		videoSprite.antialiasing = ClientPrefs.data.antialiasing;
		add(videoSprite);
		if (canSkip)
			this.canSkip = true;

		// callbacks
		videoSprite.bitmap.onEndReached.add(finishVideo);

		videoSprite.bitmap.onFormatSetup.add(function()
		{
			final scale:Float = Math.min(FlxG.width / getVideoWidth(), FlxG.height / getVideoHeight());
			videoSprite.setGraphicSize(getVideoWidth() * scale, getVideoHeight() * scale);
			videoSprite.updateHitbox();
			videoSprite.screenCenter();
		});

		// start video and adjust resolution to screen size
		videoSprite.load(videoName);
	}

	var alreadyDestroyed:Bool = false;

	override function destroy()
	{
		if (alreadyDestroyed)
			return;

		if (cover != null)
		{
			remove(cover);
			cover.destroy();
		}

		finishCallback = null;
		onSkip = null;

		if (FlxG.state != null)
		{
			if (FlxG.state.members.contains(this))
				FlxG.state.remove(this);

			if (FlxG.state.subState != null && FlxG.state.subState.members.contains(this))
				FlxG.state.subState.remove(this);
		}
		super.destroy();
		alreadyDestroyed = true;
	}

	function finishVideo()
	{
		if (!alreadyDestroyed)
		{
			if (finishCallback != null)
				finishCallback();

			destroy();
		}
	}

	override function update(elapsed:Float)
	{
		if (canSkip)
		{
			if (Controls.instance.pressed('accept'))
			{
				holdingTime = Math.max(0, Math.min(_timeToSkip, holdingTime + elapsed));
			}
			else if (holdingTime > 0)
			{
				holdingTime = Math.max(0, FlxMath.lerp(holdingTime, -0.1, FlxMath.bound(elapsed * 3, 0, 1)));
			}
			updateSkipAlpha();

			if (holdingTime >= _timeToSkip)
			{
				if (onSkip != null)
					onSkip();
				finishCallback = null;
				videoSprite.bitmap.onEndReached.dispatch();
				trace('Skipped video');
				return;
			}
		}
		super.update(elapsed);
	}

	function set_canSkip(newValue:Bool)
	{
		canSkip = newValue;
		if (canSkip)
		{
			if (skipSprite == null)
			{
				skipSprite = new FlxPieDial(0, 0, 40, FlxColor.WHITE, 40, true, 24);
				skipSprite.replaceColor(FlxColor.BLACK, FlxColor.TRANSPARENT);
				skipSprite.x = FlxG.width - (skipSprite.width + 80);
				skipSprite.y = FlxG.height - (skipSprite.height + 72);
				skipSprite.amount = 0;
				add(skipSprite);
			}
		}
		else if (skipSprite != null)
		{
			remove(skipSprite);
			skipSprite.destroy();
			skipSprite = null;
		}
		return canSkip;
	}

	function updateSkipAlpha()
	{
		if (skipSprite == null)
			return;

		skipSprite.amount = Math.min(1, Math.max(0, (holdingTime / _timeToSkip) * 1.025));
		skipSprite.alpha = FlxMath.remapToRange(skipSprite.amount, 0.025, 1, 0, 1);
	}

	public function getVideoWidth():Int
	{
		#if hxvlc
		return videoSprite.bitmap.bitmapData.width;
		#elseif html5
		return videoSprite.video.videoWidth;
		#else
		return 0;
		#end
	}

	public function getVideoHeight():Int
	{
		#if hxvlc
		return videoSprite.bitmap.bitmapData.height;
		#elseif html5
		return videoSprite.video.videoHeight;
		#else
		return 0;
		#end
	}

	public function play() videoSprite.play();

	public function resume() videoSprite.resume();

	public function pause() videoSprite.pause();

	function get_speed():Float
	{
		#if hxvlc
		return videoSprite.bitmap.rate;
		#elseif html5
		return videoSprite.netStream.speed;
		#else
		return 1.0;
		#end
	}

	function set_speed(value:Float):Float
	{
		#if hxvlc
		return videoSprite.bitmap.rate = value;
		#elseif html5
		return videoSprite.netStream.speed = value;
		#else
		return value;
		#end
	}
}
#end