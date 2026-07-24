package states;

import flixel.effects.FlxFlicker;

#if mobile
import objects.BackButton;
#end

class SelectCreditsState extends MusicBeatState
{
	public static var prevCurCredit:Int = 0;
	public static var curCredit:Int = 0;

	public var logosGrp:FlxTypedGroup<FlxSprite>;

	// ARRAY: [Team Name - Position Add[X/Y] - Scale[X/Y] - Devs]
	public var teamsList:Array<Dynamic> = haxe.Json.parse(Assets.getText(Paths.getLitePath("data/credits.json"))).credits;

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Choosing a team...", null);
		#end

		persistentUpdate = true;

		#if !mobile
		PointerUtil.visible = true;
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('storymode/bg'));
		bg.antialiasing = false;
		bg.screenCenter();
		add(bg);

		var titleTxt = new FlxText(0, 1, FlxG.width, "Select a Team!", 40);
		titleTxt.setFormat(Paths.font("vcr"), 40, FlxColor.BLACK, CENTER);
		add(titleTxt);

		logosGrp = new FlxTypedGroup<FlxSprite>();
		add(logosGrp);

		var funkinLogo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('funkin-logo'));
		funkinLogo.scale.set(teamsList[0][2][0], teamsList[0][2][1]);
		funkinLogo.updateHitbox();
		funkinLogo.screenCenter();
		funkinLogo.x += teamsList[0][1][0];
		funkinLogo.y += teamsList[0][1][1];
		funkinLogo.ID = 0;
		logosGrp.add(funkinLogo);

		var impostorLogo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		impostorLogo.scale.set(teamsList[1][2][0], teamsList[1][2][1]);
		impostorLogo.updateHitbox();
		impostorLogo.screenCenter();
		impostorLogo.x += teamsList[1][1][0];
		impostorLogo.y += teamsList[1][1][1];
		impostorLogo.ID = 1;
		logosGrp.add(impostorLogo);

		#if mobile
		var backButton:BackButton = new BackButton();
		backButton.x = (FlxG.width - backButton.width) / 2;
		backButton.y = FlxG.height - backButton.height - 28;
		backButton.onConfirmStart.add(() -> selected = true);
		backButton.onConfirmEnd.add(() -> FlxG.switchState(() -> new MainMenuState()));
		add(backButton);
		#end

		super.create();
	}

	var selected:Bool = false;

	override function update(elapsed:Float)
	{
		if (!selected)
		{
			if (controls.UI_LEFT_P)
				changeItem(-1);
			if (controls.UI_RIGHT_P)
				changeItem(1);

			if (PointerUtil.justMoved)
				PointerUtil.visible = true;

			logosGrp.forEach(function(spr:FlxSprite)
			{
				#if mobile
				for (touch in FlxG.touches.list)
				{
					if (touch.overlaps(spr))
					{
						prevCurCredit = curCredit;
						curCredit = spr.ID;
						if (prevCurCredit != curCredit)
							FlxG.sound.play(Paths.sound('scrollMenu'));
						if (touch.justReleased)
							enterCredits();
					}
				}
				#else
				if (FlxG.mouse.overlaps(spr) && FlxG.mouse.visible)
				{
					prevCurCredit = curCredit;
					curCredit = spr.ID;
					if (prevCurCredit != curCredit)
						FlxG.sound.play(Paths.sound('scrollMenu'));
					if (FlxG.mouse.justPressed)
						enterCredits();
				}
				#end
			});

			if (controls.ACCEPT)
				enterCredits();

			if (controls.BACK)
			{
				PointerUtil.visible = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new MainMenuState());
				selected = true;
			}
		}

		#if android
		if (FlxG.android.justReleased.BACK)
			FlxG.switchState(() -> new MainMenuState());
		#end

		logosGrp.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == curCredit)
			{
				spr.scale.x = FlxMath.lerp(spr.scale.x, teamsList[curCredit][2][0] + 0.1, FlxMath.bound(elapsed * 12, 0, 1));
				spr.scale.y = FlxMath.lerp(spr.scale.y, teamsList[curCredit][2][1] + 0.1, FlxMath.bound(elapsed * 12, 0, 1));
				spr.alpha = FlxMath.lerp(spr.alpha, 1, FlxMath.bound(elapsed * 10, 0, 1));
			}
			else
			{
				spr.scale.x = FlxMath.lerp(spr.scale.x, teamsList[spr.ID][2][0], FlxMath.bound(elapsed * 12, 0, 1));
				spr.scale.y = FlxMath.lerp(spr.scale.y, teamsList[spr.ID][2][1], FlxMath.bound(elapsed * 12, 0, 1));
				spr.alpha = FlxMath.lerp(spr.alpha, 0.8, FlxMath.bound(elapsed * 10, 0, 1));
			}
		});

		super.update(elapsed);
	}

	function enterCredits()
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		selected = true;

		PointerUtil.visible = false;

		FlxFlicker.flicker(logosGrp.members[curCredit], 1, 0.06, false, false, _ -> FlxG.switchState(() -> new CreditsState(teamsList[curCredit][0], teamsList[curCredit][3])));
	}

	function changeItem(huh:Int = 0)
	{
		prevCurCredit = curCredit;
		curCredit = FlxMath.wrap(curCredit + huh, 0, teamsList.length - 1);

		if (curCredit != prevCurCredit)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		PointerUtil.visible = false;
	}
}
