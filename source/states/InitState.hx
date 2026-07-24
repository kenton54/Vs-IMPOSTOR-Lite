package states;

import backend.Highscore;
import backend.Macros;
import backend.Song;
import backend.WeekData;

import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;

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

		FlxG.save.bind('funkin', CoolUtil.getSavePath());
		ClientPrefs.loadPrefs();
		Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

		Assets.init();

		FlxTransitionableState.skipNextTransOut = true;

		#if SONG
		startSong(Macros.getDefine('SONG'));
		#elseif WEEK
		startWeek(Macros.getDefine('WEEK'));
		#else
		startGame();
		#end
	}

	function startSong(song:String)
	{
		WeekData.reloadWeekFiles();

		var songFormat:String = Paths.formatToSongPath(song);
		var song:String = Highscore.formatSong(songFormat, 1);

		PlayState.SONG = Song.loadFromJson(song, songFormat);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 1;

		LoadingState.loadState(() -> new PlayState(), true);
	}

	function startWeek(week:String)
	{
		WeekData.reloadWeekFiles(true);

		var songData:Array<Dynamic> = WeekData.weeksLoaded.get(week).songs;
		var storyPlaylist:Array<String> = [for (song in songData) song[0]];
		var firstFormatSong:String = Paths.formatToSongPath(storyPlaylist[0]);

		PlayState.storyPlaylist = storyPlaylist;
		PlayState.SONG = Song.loadFromJson(Highscore.formatSong(firstFormatSong, 1), firstFormatSong);
		PlayState.isStoryMode = true;
		PlayState.storyDifficulty = 1;

		LoadingState.loadState(() -> new PlayState(), true);
	}

	function startGame()
	{
		if (!FlxG.save.data.seenWarning)
			FlxG.switchState(() -> new WarningState());
		else
			FlxG.switchState(() -> new TitleState());
	}
}
