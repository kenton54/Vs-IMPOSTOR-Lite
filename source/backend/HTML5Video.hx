package backend;

import openfl.events.NetStatusEvent;
#if html5
import flixel.util.FlxSignal;
import openfl.media.SoundTransform;
import openfl.media.Video;
import openfl.net.NetConnection;
import openfl.net.NetStream;

/**
 * Video playback for HTML5.
 * 
 * This doesn't replace `hxvlc`.
 */
class HTML5Video extends FlxSprite
{
	public var video(default, null):Video;
	public var netStream(default, null):NetStream;

	/**
	 * Compatibility with `hxvlc`.
	 */
	public var bitmap(get, never):HTML5Video;

	/**
	 * Compatibility with `hxvlc`.
	 */
    public var bitmapData(get, never):Video;

	public var onFormatSetup:FlxSignal = new FlxSignal();

	public var onEndReached:FlxSignal = new FlxSignal();

    public function new(x:Float = 0, y:Float = 0)
    {
        super(x, y);

		video = new Video();
		video.x = 0;
		video.y = 0;
		video.alpha = 0;

		var netConnection = new NetConnection();
		netConnection.connect(null);
		netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus);

		netStream = new NetStream(netConnection);
		netStream.client = {onMetaData: onClientMetaData};

		FlxG.sound.onVolumeChange.add(onVolumeChange);
    }

    override function destroy()
    {
        super.destroy();
		netStream.dispose();

		FlxG.sound.onVolumeChange.remove(onVolumeChange);
    }

    public function load(videoPath:String)
    {
		netStream.play(videoPath);
		pause();
    }

	public function play()
	{
		resume();
	}

	public function pause()
	{
		netStream.pause();
	}

	public function resume()
	{
		netStream.resume();
	}

	function onClientMetaData(metaData:Dynamic):Void
	{
		video.attachNetStream(netStream);
		videoReady();
	}

    function videoReady()
    {
        renderVideo();
		onFormatSetup.dispatch();
    }

    function finishVideo()
    {
		onEndReached.dispatch();
    }

	function onNetConnectionStatus(event:NetStatusEvent)
    {
        if (event.info.code == 'NetStream.Play.Complete') finishVideo();
    }

    function onVolumeChange(volume:Float)
    {
		netStream.soundTransform = new SoundTransform(volume);
    }

    override function draw()
    {
		renderVideo();
		super.draw();
    }

    override function updateHitbox()
    {
		renderVideo();
        super.updateHitbox();
    }

	function get_bitmap():HTML5Video
        return this;

    function get_bitmapData():Video
        return video;

    override function get_width():Float
    {
		renderVideo();
		return super.get_width();
    }

	override function get_height():Float
    {
		renderVideo();
		return super.get_height();
    }

    override function set_antialiasing(value:Bool):Bool
		return video.smoothing = super.set_antialiasing(value);

	/**
	 * Renders the video.
	 */
	function renderVideo()
	{
		final daWidth:Int = Math.ceil(video.width);
		final daHeight:Int = Math.ceil(video.height);
        final key:String = FlxG.bitmap.getUniqueKey("video");
		makeGraphic(daWidth, daHeight, FlxColor.TRANSPARENT, false, key);
        frameWidth = video.videoWidth;
		frameHeight = video.videoHeight;

		_matrix.identity();
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

        graphic.bitmap.draw(video, _matrix);

		resetFrame();
	}
}
#end