package backend;

import flixel.input.FlxSwipe;

class SwipeUtil
{
    public static var swipeLeft(get, never):Bool;

	public static var swipeRight(get, never):Bool;

	public static var swipeUp(get, never):Bool;

	public static var swipeDown(get, never):Bool;

    public static var swipeAny(get, never):Bool;

	public static var justSwipedLeft(get, never):Bool;

	public static var justSwipedRight(get, never):Bool;

	public static var justSwipedUp(get, never):Bool;

	public static var justSwipedDown(get, never):Bool;

	public static var justSwipedAny(get, never):Bool;

	public static var flickLeft(get, never):Bool;

	public static var flickRight(get, never):Bool;

	public static var flickUp(get, never):Bool;

	public static var flickDown(get, never):Bool;

	public static var flickAny(get, never):Bool;

    public static inline function resetVelocity()
    {
        FlxG.touches.flickManager.destroy();
		FlxG.mouse.flickManager.destroy();
    }

    static inline function get_swipeLeft():Bool
    {
        #if mobile
		return PointerUtil.pointer?.justMovedLeft ?? false;
        #else
		return FlxG.mouse.justMovedLeft && PointerUtil.pressed;
        #end
    }

	static inline function get_swipeRight():Bool
	{
		#if mobile
		return PointerUtil.pointer?.justMovedRight ?? false;
		#else
		return FlxG.mouse.justMovedRight && PointerUtil.pressed;
		#end
	}

	static inline function get_swipeUp():Bool
	{
		#if mobile
		return PointerUtil.pointer?.justMovedUp ?? false;
		#else
		return FlxG.mouse.justMovedUp && PointerUtil.pressed;
		#end
	}

	static inline function get_swipeDown():Bool
	{
		#if mobile
		return PointerUtil.pointer?.justMovedDown ?? false;
		#else
		return FlxG.mouse.justMovedDown && PointerUtil.pressed;
		#end
	}

	static inline function get_swipeAny():Bool
		return swipeLeft || swipeRight || swipeUp || swipeDown;

    static function get_justSwipedLeft():Bool
    {
		final swipe:FlxSwipe = (FlxG.swipes.length > 0) ? FlxG.swipes[0] : null;
		return swipe?.degrees > 135 || swipe?.degrees < -135 && swipe?.distance > 20;
    }

	static function get_justSwipedRight():Bool
	{
		final swipe:FlxSwipe = (FlxG.swipes.length > 0) ? FlxG.swipes[0] : null;
		return swipe?.degrees > -45 && swipe?.degrees < 45 && swipe?.distance > 20;
	}

	static function get_justSwipedUp():Bool
	{
		final swipe:FlxSwipe = (FlxG.swipes.length > 0) ? FlxG.swipes[0] : null;
		return swipe?.degrees > 45 && swipe?.degrees < 135 && swipe?.distance > 20;
	}

	static function get_justSwipedDown():Bool
	{
		final swipe:FlxSwipe = (FlxG.swipes.length > 0) ? FlxG.swipes[0] : null;
		return swipe?.degrees > -135 && swipe?.degrees < -45 && swipe?.distance > 20;
	}

	static inline function get_justSwipedAny():Bool
		return justSwipedLeft || justSwipedRight || justSwipedUp || justSwipedDown;

	static inline function get_flickLeft():Bool
	{
		#if mobile
		return FlxG.touches.flickManager.flickLeft;
		#else
		return FlxG.mouse.flickManager.flickLeft;
		#end
	}

	static inline function get_flickRight():Bool
	{
		#if mobile
		return FlxG.touches.flickManager.flickRight;
		#else
		return FlxG.mouse.flickManager.flickRight;
		#end
	}

	static inline function get_flickUp():Bool
	{
		#if mobile
		return FlxG.touches.flickManager.flickUp;
		#else
		return FlxG.mouse.flickManager.flickUp;
		#end
	}

	static inline function get_flickDown():Bool
	{
		#if mobile
		return FlxG.touches.flickManager.flickDown;
		#else
		return FlxG.mouse.flickManager.flickDown;
		#end
	}

	static inline function get_flickAny():Bool
		return flickLeft || flickRight || flickUp || flickDown;
}