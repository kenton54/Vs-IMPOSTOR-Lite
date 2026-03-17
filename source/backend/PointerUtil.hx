package backend;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.input.touch.FlxTouch;
import flixel.input.mouse.FlxMouse;

class PointerUtil
{
    public static var justPressed(get, never):Bool;

	public static var pressed(get, never):Bool;

	public static var justReleased(get, never):Bool;

	public static var released(get, never):Bool;

    public static var justMoved(get, never):Bool;

    public static var visible(get, set):Bool;

    public static var pointer(get, never):#if mobile FlxTouch #else FlxMouse #end;

	public static function overlaps(object:FlxBasic, ?camera:FlxCamera):Bool
    {
		if (pointer == null || object == null) return false;

		return pointer.overlaps(object, camera);
    }

    public static function overlapsComplex(object:FlxObject, ?camera:FlxCamera):Bool
    {
		if (pointer == null || object == null) return false;

        if (camera == null) camera = object.camera;

		return object.overlapsPoint(pointer.getWorldPosition(camera), true, camera);
    }

	static inline function get_justPressed():Bool
		return pointer != null && pointer.justPressed;

	static inline function get_pressed():Bool
		return pointer != null && pointer.pressed;

	static inline function get_justReleased():Bool
		return pointer != null && pointer.justReleased;

	static inline function get_released():Bool
		return pointer != null && pointer.released;

	static inline function get_justMoved():Bool
		return pointer != null && pointer.justMoved;

	static inline function get_visible():Bool
    {
        #if mobile
        return false;
        #else
        return pointer.visible;
        #end
    }

	static inline function set_visible(value:Bool):Bool
	{
		#if mobile
		return false;
		#else
		return pointer.visible = value;
		#end
	}

    #if mobile
	static function get_pointer():FlxTouch
    {
        for (touch in FlxG.touches.list)
            if (touch != null)
                return touch;

        return FlxG.touches.getFirst();
    }
    #else
	static inline function get_pointer():FlxMouse
        return FlxG.mouse;
    #end
}