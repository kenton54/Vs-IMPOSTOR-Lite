package states;

import backend.Highscore;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;
import lime.app.Application;

class InitState extends FlxState
{
    override function create()
    {
        super.create();

		if (TitleState.isSteginiteBuildLol)
			Application.current.window.title = Application.current.meta["title"] + " - The Steginite Build";

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;

		#if android
		FlxG.android.preventDefaultKeys = [flixel.input.android.FlxAndroidKey.BACK];
		#end

		if (FlxG.save.data != null && FlxG.save.data.fullscreen)
			FlxG.fullscreen = FlxG.save.data.fullscreen;

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.save.bind('funkin', CoolUtil.getSavePath());
		ClientPrefs.loadPrefs();
		Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

		Assets.init();

		FlxTransitionableState.skipNextTransOut = true;
		if (!FlxG.save.data.seenWarning)
			FlxG.switchState(() -> new WarningState());
        else
			FlxG.switchState(() -> new TitleState());
    }
}