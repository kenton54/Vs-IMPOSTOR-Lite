package states;

import backend.Highscore;
import backend.Song;
import backend.WeekData;

import flixel.effects.FlxFlicker;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;

import objects.MenuItem;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

#if mobile
import objects.BackButton;
#end

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';

	var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;

	static var curWeek:Int = 0;

	var curWeekFloat:Float = 0;

	var txtTracklist:FlxText;

	var grpWeekOptions:FlxTypedGroup<MenuItem>;
	var grpLocks:FlxTypedGroup<FlxSprite>;

	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var loadedWeeks:Array<WeekData> = [];

	override function create()
	{
		persistentUpdate = true;

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if (curWeek >= WeekData.weeksList.length)
			curWeek = 0;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat(Paths.font("vcr"), 32, FlxColor.BLACK);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat(Paths.font("vcr"), 32, FlxColor.BLACK, RIGHT);
		txtWeekTitle.alpha = 1;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('storymode/bg'));
		bg.antialiasing = false;
		bg.screenCenter();
		add(bg);

		grpWeekOptions = new FlxTypedGroup<MenuItem>();
		add(grpWeekOptions);
		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Looking at the story menu", null);
		#end

		var weeksList:Array<WeekData> = [for (i in 0...WeekData.weeksList.length) WeekData.weeksLoaded.get(WeekData.weeksList[i])];
		weeksList.push(new WeekData({
			songs: [["", "", [255, 255, 255], ""]],
			storyName: "coming soon...",
			weekName: "Coming Soon",
			weekBefore: "week1",
			weekCharacters: [],
			weekBackground: "",
			freeplayColor: [255, 255, 255],
			startUnlocked: false,
			hiddenUntilUnlocked: false,
			hideStoryMode: false,
			hideFreeplay: true,
			difficulties: ""
		}, "soon"));

		var num:Int = 0;
		for (i in 0...weeksList.length)
		{
			var weekFile:WeekData = weeksList[i];
			if (!weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				var weekThing:MenuItem = new MenuItem();
				weekThing.loadGraphic(Paths.image('storymode/weeks/' + weekFile.fileName));
				weekThing.centerInScreen = true;
				weekThing.setGraphicSize(0, FlxG.height);
				weekThing.updateHitbox();
				weekThing.x = weekThing.width / 2 + FlxG.width * num;
				weekThing.targetX = num;
				grpWeekOptions.add(weekThing);

				/*
					// Needs an offset thingie
					if (isLocked)
					{
						var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
						lock.antialiasing = ClientPrefs.data.antialiasing;
						lock.loadGraphic(ui_tex);
						lock.animation.addByPrefix('lock', 'lock');
						lock.animation.play('lock');
						lock.ID = i;
						grpLocks.add(lock);
					}
				 */
				num++;
			}
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);

		leftArrow = new FlxSprite(20, 0);
		leftArrow.antialiasing = ClientPrefs.data.antialiasing;
		leftArrow.loadGraphic(Paths.image('arrowButton'));
		leftArrow.color = FlxColor.WHITE;
		leftArrow.screenCenter(Y);

		Difficulty.resetList();
		if (lastDifficultyName == '')
		{
			lastDifficultyName = Difficulty.getDefault();
		}
		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		rightArrow = new FlxSprite();
		rightArrow.antialiasing = ClientPrefs.data.antialiasing;
		rightArrow.loadGraphic(Paths.image('arrowButton'));
		rightArrow.color = FlxColor.WHITE;
		rightArrow.screenCenter(Y);
		rightArrow.x = FlxG.width - rightArrow.width - 20;
		rightArrow.flipX = true;

		var tracksSprite:FlxSprite = new FlxSprite(10, 60).loadGraphic(Paths.image('storymode/tracks'));
		tracksSprite.antialiasing = ClientPrefs.data.antialiasing;
		add(tracksSprite);

		txtTracklist = new FlxText(10, tracksSprite.y + 50, 0, "", 32);
		txtTracklist.alignment = LEFT;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		var leText:String = "\nCTRL / Gameplay options\nRESET / Resets score and accuracy";
		var size:Int = 16;
		var bottomText:FlxText = new FlxText(10, 0, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("vcr"), size, FlxColor.BLACK, LEFT);
		bottomText.scrollFactor.set();
		bottomText.y = (FlxG.height - 26) - bottomText.height + 20;
		add(bottomText);

		add(leftArrow);
		add(rightArrow);

		#if mobile
		var backButton:BackButton = new BackButton();
		backButton.x = FlxG.width - backButton.width - 60;
		backButton.y = FlxG.height - backButton.height - 28;
		backButton.onConfirmStart.add(() -> movedBack = true);
		backButton.onConfirmEnd.add(() -> FlxG.switchState(() -> new MainMenuState()));
		add(backButton);
		#end

		super.create();
		changeWeek();
	}

	override function closeSubState()
	{
		changeWeek();
		super.closeSubState();

		persistentUpdate = true;
	}

	#if mobile
	var swiping:Bool = false;
	var moveLength:Float = 0;
	#end
	var usingControls:Bool = true;

	override function update(elapsed:Float)
	{
		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 30)));
		if (Math.abs(intendedScore - lerpScore) < 10)
			lerpScore = intendedScore;

		scoreText.text = "WEEK SCORE: " + lerpScore;

		if (FlxG.keys.justPressed.ANY || FlxG.gamepads.anyInput())
			usingControls = true;

		#if mobile
		if (PointerUtil.justPressed || PointerUtil.justMoved)
			usingControls = false;

		var overlapLeft:Bool = false;
		var overlapRight:Bool = false;
		if (!selectedWeek && !movedBack)
		{
			if (PointerUtil.overlaps(leftArrow) && !swiping)
			{
				overlapLeft = true;
				leftArrow.color = PointerUtil.pressed ? FlxColor.GRAY : FlxColor.WHITE;

				if (PointerUtil.justPressed)
					changeWeek(-1);
			}

			if (PointerUtil.overlaps(rightArrow) && !swiping)
			{
				overlapRight = true;
				rightArrow.color = PointerUtil.pressed ? FlxColor.GRAY : FlxColor.WHITE;

				if (PointerUtil.justPressed)
					changeWeek(1);
			}

			if (PointerUtil.justPressed && !(overlapLeft || overlapRight))
				swiping = true;
		}

		final fpsMult:Float = FlxG.updateFramerate / 60;
		if (PointerUtil.pressed && swiping)
		{
			final delta:Float = PointerUtil.pointer.deltaViewX * fpsMult;

			if (Math.isFinite(delta) && Math.abs(delta) >= 2)
			{
				var dpiScale:Float = FlxG.stage.window.display.dpi / 160;
				dpiScale = FlxMath.bound(dpiScale, 0.5, #if android 1 #else 2 #end);

				var _moveLength:Float = delta / FlxG.updateFramerate / dpiScale / 2;
				moveLength += Math.abs(_moveLength);
				curWeekFloat -= _moveLength;

				updateScroll();
			}
		}
		else if (moveLength > 0)
		{
			moveLength = 0;
			changeWeek();
		}

		curWeekFloat = FlxMath.bound(curWeekFloat, 0, loadedWeeks.length - 1);
		curWeek = Math.round(curWeekFloat);

		if (PointerUtil.overlaps(grpWeekOptions.members[curWeek])
			&& !(overlapLeft || overlapRight)
			&& !swiping
			&& !SwipeUtil.justSwipedAny
			&& PointerUtil.justReleased)
			selectWeek();

		if (PointerUtil.justReleased)
			swiping = false;

		#if android
		if (FlxG.android.justReleased.BACK)
		{
			movedBack = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(() -> new MainMenuState());
			return;
		}
		#end
		#end

		if ((!movedBack || !selectedWeek) && usingControls)
		{
			var rightP = controls.UI_RIGHT_P;
			var leftP = controls.UI_LEFT_P;

			if (leftP)
				changeWeek(-1);

			if (rightP)
				changeWeek(1);

			if (FlxG.mouse.wheel != 0)
				changeWeek(-FlxG.mouse.wheel);

			rightArrow.color = controls.UI_RIGHT ? FlxColor.GRAY : FlxColor.WHITE;
			leftArrow.color = controls.UI_LEFT ? FlxColor.GRAY : FlxColor.WHITE;

			if (FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if (controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				// FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			movedBack = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(() -> new MainMenuState());
		}

		super.update(elapsed);

		/*
			grpLocks.forEach(function(lock:FlxSprite)
			{
				lock.y = grpWeekOptions.members[lock.ID].y;
				lock.visible = (lock.y > FlxG.height / 2);
			});
		 */
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (loadedWeeks[curWeek].fileName != 'soon' && !weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length)
			{
				songArray.push(leWeek[i][0]);
			}

			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				stopspamming = true;
			}

			FlxFlicker.flicker(grpWeekOptions.members[curWeek], 1, 0.06, true, false, function(flick:FlxFlicker)
			{
				// Nevermind that's stupid lmao
				try
				{
					PlayState.storyPlaylist = songArray;
					PlayState.isStoryMode = true;
					selectedWeek = true;

					var diffic = Difficulty.getFilePath(curDifficulty);
					if (diffic == null)
						diffic = '';

					PlayState.storyDifficulty = curDifficulty;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
					PlayState.campaignScore = 0;
					PlayState.campaignMisses = 0;
				}
				catch (e:Dynamic)
				{
					trace('ERROR! $e');
					return;
				}

				LoadingState.loadState(() -> new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
		}
		else
			FlxG.sound.play(Paths.sound('cancelMenu'));
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek = FlxMath.wrap(curWeek + change, 0, loadedWeeks.length - 1);

		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		var bullShit:Int = 0;
		for (item in grpWeekOptions.members)
		{
			item.targetX = bullShit - curWeek;
			bullShit++;
		}
		PlayState.storyWeek = curWeek;

		if (loadedWeeks[curWeek].fileName == 'soon')
		{
			intendedScore = 0;
			updateText();
			return;
		}

		Difficulty.loadFromWeek();
		if (Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		var newPos:Int = Difficulty.list.indexOf(lastDifficultyName);
		// trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if (newPos > -1)
		{
			curDifficulty = newPos;
		}

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end

		updateText();
	}

	function updateScroll()
	{
		var lastWeek:Int = curWeek;
		curWeek = CoolUtil.boundInt(Math.round(curWeekFloat), 0, loadedWeeks.length - 1);

		if (curWeek != lastWeek)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));

			var leWeek:WeekData = loadedWeeks[curWeek];
			WeekData.setDirectoryFromWeek(leWeek);

			var leName:String = leWeek.storyName;
			txtWeekTitle.text = leName.toUpperCase();
			txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

			PlayState.storyWeek = curWeek;

			if (loadedWeeks[curWeek].fileName == 'soon')
			{
				intendedScore = 0;
				updateText();
				return;
			}

			Difficulty.loadFromWeek();
			if (Difficulty.list.contains(Difficulty.getDefault()))
				curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
			else
				curDifficulty = 0;

			var newPos:Int = Difficulty.list.indexOf(lastDifficultyName);
			// trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
			if (newPos > -1)
			{
				curDifficulty = newPos;
			}

			#if !switch
			intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
			#end

			updateText();
		}

		var bullShit:Int = 0;
		for (item in grpWeekOptions.members)
		{
			item.targetX = bullShit - curWeekFloat;
			bullShit++;
		}
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length)
		{
			stringThing.push(leWeek.songs[i][0]);
		}

		// This capitalization part looks rlly ugly but im still proud i made it to work :) -polo

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += CoolUtil.capitalize(stringThing[i]) + '\n';
		}

		var txtTracklistAll:Array<String> = txtTracklist.text.split('\n');
		for (i => txt in txtTracklistAll)
		{
			txt = txt.replace('-', ' ');
			txt = txt.replace('_', ' ');
			if (txt.contains(' '))
			{
				var nameStrings:Array<String> = txt.split(' ');
				var txtResult:String = '';

				for (str in nameStrings)
				{
					var str2:String = CoolUtil.capitalize(str);
					txtResult += str2 + ' ';
				}
				txtTracklistAll[i] = txtResult;
			}
		}

		txtTracklist.text = '';
		for (txt in txtTracklistAll)
			txtTracklist.text += txt + '\n';

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}
}
