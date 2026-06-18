package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import objects.HealthIcon;
import objects.MusicPlayer;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

import flixel.math.FlxMath;

#if EDITORS_ALLOWED
import states.editors.ChartingState;
#end

#if mobile
import objects.BackButton;
#end

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;

	static var curSelected:Int = 0;
	var curSelectedFloat:Float = 0;
	static var prevCurSelected:Int = 0;
	var lerpSelected:Float = 0;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var ratingText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var grpSongs:FlxTypedGroup<Alphabet>;
	var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:FlxColor;
	var colorTween:FlxTween;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var defaultBottomText:String = "SPACE / Listen song\nCTRL / Gameplay options\nRESET / Resets score and accuracy";
	var bottomText:FlxText;
	var bottomBG:FlxSprite;

	var portrait:FlxSprite;
	static var prevPortrait:Null<String> = null;
	var curPortrait:String = "";

	var player:MusicPlayer;

	#if mobile
	var backButton:BackButton;
	#end

	override function create()
	{
		persistentUpdate = true;

		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Looking at the freeplay menu", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), song[3]);
			}
		}
		Mods.loadTopMod();

		bg = new FlxSprite().loadGraphic(Paths.image('sketch'));
		bg.antialiasing = false;
		add(bg);
		bg.screenCenter();

		for (i in 0...songs.length) Paths.image('portraits/${songs[i].portrait}');

		portrait = new FlxSprite().loadGraphic(Paths.image('portraits/${songs[curSelected].portrait}'));
		portrait.antialiasing = false;

		if (songs[curSelected].portrait == "idk")
		{
			portrait.scale.set(0.7, 0.7);
			portrait.updateHitbox();
		}
		else
		{
			portrait.scale.set(1, 1);
			portrait.updateHitbox();
		}

		portrait.x = FlxG.width - portrait.width + 25;
		portrait.y = FlxG.height - portrait.height;
		add(portrait);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(50, #if mobile 320 #else 400 #end, songs[i].songName, true);
			songText.distancePerItem.x = 0;
			songText.targetY = i;
			songText.scaleX = Math.min(1, (FlxG.width * 0.55) / songText.width);
			songText.snapToPosition();

			grpSongs.add(songText);

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();

		final textsBorders:Float = 6;

		scoreText = new FlxText(0, 5, FlxG.width - textsBorders * 2, "", 32);
		scoreText.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, RIGHT);
		scoreText.screenCenter(X);

		ratingText = new FlxText(0, 10, FlxG.width - textsBorders * 2, "", 26);
		ratingText.setFormat(Paths.font("vcr"), 26, FlxColor.WHITE, RIGHT);
		ratingText.screenCenter(X);

		scoreBG = new FlxSprite(FlxG.width, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.origin.x = scoreBG.frameWidth;
		scoreBG.x -= scoreBG.width;
		scoreBG.alpha = 0;
		add(scoreBG);
		add(scoreText);
		add(ratingText); 

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		if (curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		lerpSelected = curSelected;

		bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0;
		add(bottomBG);

		bottomText = new FlxText(bottomBG.x + 10, 0, FlxG.width, defaultBottomText, 16);
		bottomText.setFormat(Paths.font("vcr"), 16, FlxColor.WHITE, LEFT);
		bottomText.scrollFactor.set();
		bottomText.y = bottomBG.y - bottomText.height + 20;
		#if !mobile
		add(bottomText);
		#end

		player = new MusicPlayer(this);
		add(player);

		#if mobile
		backButton = new BackButton(0, 28);
		backButton.x = FlxG.width - backButton.width - 60;
		//backButton.onConfirmStart.add(() -> movedBack = true);
		backButton.onConfirmEnd.add(goBack.bind(false));
		add(backButton);
		#end
		
		changeSelection();
		snapSongsPosition();
		updateSongs();
		super.create();
	}

	override function closeSubState()
	{
		changeSelection(0, false);
		super.closeSubState();

		persistentUpdate = true;
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, portrait:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color, portrait));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	public static var vocals:FlxSound = null;
	var movedBack:Bool = false;
	var instPlaying:Int = -1;
	var holdTime:Float = 0;
	#if mobile
	var swiping:Bool = false;
	var moveLength:Float = 0;
	#end
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * elapsed;

		portraitHolder += 0.01;

		#if mobile
		#if android
		if (FlxG.android.justReleased.BACK)
		{
			goBack();
			return;
		}
		#end

		var overlappingCurrent:Bool = overlapsCurOption();

		if (PointerUtil.justPressed && !overlappingCurrent)
			swiping = true;

		final fpsMult:Float = FlxG.updateFramerate / 60;
		if (PointerUtil.pressed && swiping)
		{
			final delta:Float = PointerUtil.pointer.deltaViewY * fpsMult;

			if (Math.isFinite(delta) && Math.abs(delta) >= 2)
			{
				var dpiScale:Float = FlxG.stage.window.display.dpi / 160;
				dpiScale = FlxMath.bound(dpiScale, 0.5, #if android 1 #else 2 #end);

				var _moveLength:Float = delta / FlxG.updateFramerate / dpiScale;
				moveLength += Math.abs(_moveLength);
				curSelectedFloat -= _moveLength;

				updateScroll();
			}
		}
		else if (moveLength > 0)
		{
			moveLength = 0;
			changeSelection();
		}

		curSelectedFloat = FlxMath.bound(curSelectedFloat, 0, songs.length - 1);
		curSelected = Math.round(curSelectedFloat);

		if (PointerUtil.justReleased)
		{
			if (overlappingCurrent && !swiping)
				chooseSong();
			else
				swiping = false;
		}
		#end

		var shiftMult:Int = FlxG.keys.pressed.SHIFT ? 3 : 1;

		if (!player.playingMusic)
		{	
			if (songs.length > 1)
			{
				if (FlxG.keys.justPressed.HOME)
				{
					curSelected = 0;
					changeSelection();
					holdTime = 0;
				}
				else if (FlxG.keys.justPressed.END)
				{
					curSelected = songs.length - 1;
					changeSelection();
					holdTime = 0;	
				}
				if (controls.UI_UP_P)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (controls.UI_DOWN_P)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if (controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
				}

				if (FlxG.mouse.wheel != 0)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
					changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				}
			}

			lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
			lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));
	
			if (Math.abs(lerpScore - intendedScore) <= 10)
				lerpScore = intendedScore;
			if (Math.abs(lerpRating - intendedRating) <= 0.01)
				lerpRating = intendedRating;

			var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
			if (ratingSplit.length < 2) //No decimals, add an empty space
				ratingSplit.push('');

			while(ratingSplit[1].length < 2) //Less than 2 decimals in it, add decimals then
				ratingSplit[1] += '0';

			scoreText.text = '' + Std.string(lerpScore).lpad('0', 8);
			ratingText.text = '\n' + ratingSplit.join('.') + '%';
			updateScoreTexts();

			if (portraitHolder > 0.2 && !isPortraitOn && portrait.x >= FlxG.width)
			{
				isPortraitOn = true;
				FlxTween.cancelTweensOf(portrait);
				portrait.loadGraphic(Paths.image('portraits/${songs[curSelected].portrait}'));

				if (songs[curSelected].portrait == "idk")
				{
					portrait.scale.set(0.7, 0.7);
					portrait.updateHitbox();
				}
				else
				{
					portrait.scale.set(1, 1);
					portrait.updateHitbox();
				}

				portrait.y = FlxG.height - portrait.height;
				FlxTween.tween(portrait, {x: FlxG.width - portrait.width + 25, alpha: 1}, 0.55, {ease: FlxEase.quartOut});
			}
		}

		if (controls.BACK)
			goBack();

		if (FlxG.keys.justPressed.CONTROL && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if (FlxG.keys.justPressed.SPACE)
		{
			if (instPlaying != curSelected && !player.playingMusic)
			{
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;

				Mods.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), 1);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());

				if (PlayState.SONG.needsVoices)
				{
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
					FlxG.sound.list.add(vocals);
					//vocals.persist = true;
					vocals.looped = true;
				}
				else if (vocals != null)
				{
					vocals.stop();
					vocals.destroy();
					vocals = null;
				}

				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.8);
				if (vocals != null) //Sync vocals to Inst
				{
					vocals.play();
					vocals.volume = 0.8;
				}
				instPlaying = curSelected;

				player.playingMusic = true;
				player.curTime = 0;
				player.switchPlayMusic();
			}
			else if (instPlaying == curSelected && player.playingMusic)
			{
				player.pauseOrResume(player.paused);
			}
		}
		else if (controls.ACCEPT && !player.playingMusic)
		{
			chooseSong();
		}
		#if EDITORS_ALLOWED
		else if (controls.justPressed("debug_1") && !player.playingMusic)
		{
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, 1);

			try
			{
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 1;

				trace("LOADING SONG CHART: [" + poop + "]");

				if (colorTween != null)
				{
					colorTween.cancel();
				}
			}
			catch (e:Dynamic)
			{
				trace('ERROR! $e');

				var errorStr:String = e.toString();
				if (errorStr.startsWith('[file_contents,assets/data/'))
					errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length - 1); // Missing chart
				missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
				missingText.screenCenter(Y);
				missingText.visible = true;
				missingTextBG.visible = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				return;
			}

			LoadingState.loadState(() -> new ChartingState());

			FlxG.sound.music.stop();
			destroyFreeplayVocals();
		}
		#end
		else if (controls.RESET && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, 1, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		updateSongs(elapsed);
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals()
	{
		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}

		vocals = null;
	}

	function overlapsCurOption():Bool
		return PointerUtil.overlaps(grpSongs.members[curSelected]) || PointerUtil.overlaps(iconArray[curSelected]);

	var portraitHolder:Float = 0;
	var isPortraitOn:Bool = true;
	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (player.playingMusic) return;

		if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'));

		prevCurSelected = curSelected;
		prevPortrait = songs[curSelected].portrait;
		var lastList:Array<String> = Difficulty.list;

		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length - 1);
		curSelectedFloat = curSelected;
		curPortrait = songs[curSelected].portrait;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, 1);
		intendedRating = Highscore.getRating(songs[curSelected].songName, 1);
		#end

		var newColor:Int = songs[curSelected].color;
		if (newColor != intendedColor)
		{
			if (colorTween != null) colorTween.cancel();
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {onComplete: _ -> colorTween = null});
		}

		updateSongsPosition();

		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();

		if (curPortrait != prevPortrait) portraitHolder = 0;
		if (curPortrait != prevPortrait && isPortraitOn)
		{
            FlxTween.cancelTweensOf(portrait);
			isPortraitOn = false;
            FlxTween.tween(portrait, {x: FlxG.width + 25, alpha: 0}, 0.225);
		}
	}

	function updateScroll()
	{
		if (player.playingMusic) return;

		var lastSelected:Int = curSelected;
		curSelected = CoolUtil.boundInt(Math.round(curSelectedFloat), 0, songs.length - 1);

		if (curSelected != lastSelected)
		{
			prevPortrait = songs[lastSelected].portrait;
			curPortrait = songs[curSelected].portrait;

			FlxG.sound.play(Paths.sound('scrollMenu'));

			#if !switch
			intendedScore = Highscore.getScore(songs[curSelected].songName, 1);
			intendedRating = Highscore.getRating(songs[curSelected].songName, 1);
			#end

			var newColor:Int = songs[curSelected].color;
			if (newColor != intendedColor)
			{
				if (colorTween != null) colorTween.cancel();
				intendedColor = newColor;
				colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {onComplete: _ -> colorTween = null});
			}

			var bullShit:Int = 0;
			for (item in grpSongs.members)
			{
				item.targetY = bullShit - curSelectedFloat;
				final isSelected:Bool = Math.round(item.targetY) == 0;

				if (isSelected)
				{
					item.alpha = 1;
					iconArray[bullShit].alpha = 1;
				}
				else
				{
					item.alpha = 0.6;
					iconArray[bullShit].alpha = 0.6;
				}

				bullShit++;
			}

			Mods.currentModDirectory = songs[curSelected].folder;
			PlayState.storyWeek = songs[curSelected].week;
			Difficulty.loadFromWeek();

			if (curPortrait != prevPortrait) portraitHolder = 0;
			if (curPortrait != prevPortrait && isPortraitOn)
			{
				FlxTween.cancelTweensOf(portrait);
				isPortraitOn = false;
				FlxTween.tween(portrait, {x: FlxG.width + 25, alpha: 0}, 0.225);
			}
		}
	}

	function updateSongsPosition()
	{
		var bullShit:Int = 0;
		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			final isSelected:Bool = item.targetY == 0;

			if (isSelected)
			{
				item.alpha = 1;
				iconArray[bullShit].alpha = 1;
			}
			else
			{
				item.alpha = 0.6;
				iconArray[bullShit].alpha = 0.6;
			}

			bullShit++;
		}
	}

	function snapSongsPosition()
	{
		for (item in grpSongs.members)
			item.snapToPosition();
	}

	function updateSongs(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(curSelected, lerpSelected, Math.exp(-elapsed * 9.6));

		for (item in grpSongs.members)
		{
			item.visible = item.active = true;
			item.x = FlxMath.lerp(item.x, (Math.abs(item.targetY * 80) * -1) + 70, FlxMath.bound(elapsed * 10, 0, 1));
			item.y = FlxMath.lerp((item.targetY * 1.3 * item.distancePerItem.y) + item.startPosition.y, item.y, Math.exp(-elapsed * 9.6));
		}
	}

	function updateScoreTexts()
	{
		scoreBG.scale.x = scoreText.textField.textWidth + 6;
	}

	function chooseSong()
	{
		var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
		var poop:String = Highscore.formatSong(songLowercase, 1);

		try
		{
			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 1;

			trace("PLAYING SONG: [" + poop + "]");
			trace('PLAYING SONG FROM WEEK: [' + WeekData.getWeekFileName() + ']');

			if (colorTween != null)
			{
				colorTween.cancel();
			}
		}
		catch (e:Dynamic)
		{
			trace('ERROR! $e');

			var errorStr:String = e.toString();
			if (errorStr.startsWith('[file_contents,assets/data/'))
				errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length - 1); // Missing chart
			missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
			missingText.screenCenter(Y);
			missingText.visible = true;
			missingTextBG.visible = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		}

		LoadingState.loadState(() -> new PlayState(), true);

		FlxG.sound.music.stop();
		destroyFreeplayVocals();

		#if (MODS_ALLOWED && DISCORD_ALLOWED)
		DiscordClient.loadModRPC();
		#end
	}

	function goBack(playCancelSound:Bool = true)
	{
		if (player.playingMusic)
		{
			FlxG.sound.music.destroy();
			destroyFreeplayVocals();
			instPlaying = -1;

			player.playingMusic = false;
			player.switchPlayMusic();

			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
		}
		else
		{
			movedBack = true;

			if (colorTween != null) colorTween.cancel();
			if (playCancelSound) FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(() -> new MainMenuState());
		}
	}

	override function destroy():Void
	{
		super.destroy();

		if ((FlxG.sound.music == null || !FlxG.sound.music.playing) && movedBack)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;
	public var portrait:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int, portrait:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
		this.portrait = portrait;
	}
}