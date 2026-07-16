package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.util.FlxGradient;

class WarningState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var actuallyAllowed:Bool = false;

	var txtsSpr:FlxSpriteGroup = new FlxSpriteGroup();

	var disclaimerTxtTitle:FlxText;
	var disclaimerTxt:FlxText;
	var disclaimerTxtEnter:FlxText;

	var whiteTransition:FlxSprite;
	var whiteTransitionTail:FlxSprite;

	override function create()
	{
		if (leftState)
		{
			FlxG.switchState(() -> new TitleState());
			return;
		}

		var stars:FlxBackdrop = new FlxBackdrop();
		stars.loadGraphic(Paths.image("bg/polus/stars"));
		stars.velocity.x = 8;
		stars.scale.set(1, 1);
		stars.updateHitbox();
		add(stars);

		disclaimerTxtTitle = new FlxText(0, 0, 0, "disclaimer:", 32);
		disclaimerTxtTitle.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, CENTER);
		disclaimerTxtTitle.text = disclaimerTxtTitle.text.toUpperCase();

		disclaimerTxt = new FlxText(0, disclaimerTxtTitle.y + disclaimerTxtTitle.height + 10, 0, "", 20);
		disclaimerTxt.setFormat(Paths.font("vcr"), 20, FlxColor.WHITE, CENTER);
		disclaimerTxt.text = "\nWE ARE #NOT# AFFILIATED WITH OR APART OF THE ORIGINAL *LITE FUNKIN' TEAM*."
			+ "\nThis mod is completely $separate from Lite Funkin'$ and is merely a $passionate project$ inspired by the mod,"
			+ "\nas well as #Vs. Impostor V4#."
			+ "\n\nThe original mod's credits is listed in the *CREDITS section* in the main menu.";

		disclaimerTxtEnter = new FlxText(0, disclaimerTxt.y + disclaimerTxt.height + 25, 0, "> Okay, damn, let me play <", 20);
		disclaimerTxtEnter.setFormat(Paths.font("vcr"), 20, FlxColor.WHITE, CENTER);

		// FlxG.camera.bgColor = 0xFF030317;
		persistentUpdate = true;
		FlxG.stage.color = stageColor;

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Warning Screen", null);
		#end

		disclaimerTxt.applyMarkup(disclaimerTxt.text, [
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xe77279), "#"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xa8ffd0), "*"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xe4eb6a), "$")
		]);

		for (txt in [disclaimerTxtTitle, disclaimerTxt, disclaimerTxtEnter])
		{
			txtsSpr.add(txt);
			txt.screenCenter(X);
			txt.scrollFactor.y = 1.25;
		}
		add(txtsSpr);
		txtsSpr.screenCenter(Y);

		whiteTransition = FlxGradient.createGradientFlxSprite(1, FlxG.height, [0x0, FlxColor.WHITE]);
		whiteTransition.scale.x = FlxG.width;
		whiteTransition.updateHitbox();
		whiteTransition.screenCenter(X);
		whiteTransition.y = FlxG.height;
		add(whiteTransition);

		whiteTransitionTail = new FlxSprite(0, whiteTransition.y + whiteTransition.height).makeGraphic(1, 1, FlxColor.WHITE);
		whiteTransitionTail.scale.set(FlxG.width, FlxG.height + 400);
		whiteTransitionTail.updateHitbox();
		add(whiteTransitionTail);

		FlxTween.cancelTweensOf(FlxG.camera);
		FlxG.camera.scroll.y = -FlxG.height;
		FlxTween.tween(FlxG.camera.scroll, {y: 0}, 0.8, {
			ease: FlxEase.quadInOut,
			startDelay: 0.8,
			onComplete: function(_)
			{
				actuallyAllowed = true;
			}
		});

		super.create();
	}

	var stageColor:FlxColor = 0x2A2140;
	var targetColor:FlxColor = 0x2A2140;

	override function update(elapsed:Float)
	{
		whiteTransitionTail.x = whiteTransition.x;
		whiteTransitionTail.y = whiteTransition.y + whiteTransition.height;

		if (actuallyAllowed)
		{
			if (PointerUtil.justPressed || FlxG.keys.justPressed.ENTER)
			{
				leftState = true;
				actuallyAllowed = false;

				targetColor = 0xFFFFFF;

				FlxTransitionableState.skipNextTransOut = true;
				FlxTransitionableState.skipNextTransIn = true;

				ClientPrefs.saveSettings();
				FlxG.sound.play(Paths.sound('confirmMenu'));

				FlxFlicker.flicker(disclaimerTxtEnter, 1.4, 0.1, false, true, function(_)
				{
					new FlxTimer().start(1.4, _ -> FlxG.switchState(() -> new TitleState()));
				});

				new FlxTimer().start(0.6, function(_)
				{
					FlxTween.cancelTweensOf(FlxG.camera);
					FlxTween.tween(FlxG.camera, {"scroll.y": FlxG.height * 2}, 1, {ease: FlxEase.smootherStepIn});
				});

				FlxG.save.data.seenWarning = true;
			}
		}

		stageColor = FlxColor.interpolate(stageColor, targetColor, 0.05);
		FlxG.stage.color = stageColor.rgb;

		super.update(elapsed);
	}

	override function destroy()
	{
		super.destroy();
		FlxG.stage.color = 0xFFFFFF;
	}
}
