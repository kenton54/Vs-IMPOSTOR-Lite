package backend.native;

#if windows
/**
 * Adds helper functions exclusively for windows.
 * 
 * Code taken from VS IMPOSTOR Pixel, I'm the same guy who coded this so it's fine lol.
 * 
 * \- kenton.
 */
@:buildXml('
<target id="haxe">
    <lib name="dwmapi.lib"/>
</target>
')
@:cppFileCode('
// to prevent windows doing random shit and slowing things down
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#define NOCRYPT
#define NOKANJI
#define NOHELP

#include <windows.h>
#include <dwmapi.h>
')
class Windows
{
	/**
	 * Sets the window to Dark Mode.
	 */
	@:functionCode('
        HWND window = GetActiveWindow();

        int darkMode = enable ? 1 : 0;

        if (DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode)) != S_OK)
            DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode));

        UpdateWindow(window);
    ')
	public static function setWindowDarkMode(enable:Bool) {}
}
#end