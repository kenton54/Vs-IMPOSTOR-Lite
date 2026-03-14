package states;

import flixel.FlxSubState;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import flixel.util.FlxGradient;
import flixel.addons.display.FlxBackdrop;

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
		var stars:FlxBackdrop = new FlxBackdrop();
		stars.loadGraphic(Paths.image("bg/polus/stars"));
		stars.velocity.x = 8;
		stars.scale.set(1, 1);
		stars.updateHitbox();
		add(stars);

		disclaimerTxtTitle = new FlxText(0, 0, 0, "disclaimer:", 32);
		disclaimerTxtTitle.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		disclaimerTxtTitle.text = disclaimerTxtTitle.text.toUpperCase();

		disclaimerTxt = new FlxText(0, disclaimerTxtTitle.y + disclaimerTxtTitle.height + 10, 0, "", 20);
		disclaimerTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		disclaimerTxt.text = 
		"\nWE ARE #NOT# AFFILIATED WITH OR APART OF THE ORIGINAL *LITE FUNKIN' TEAM*."
		+ "\nThis mod is completely $separate from Lite Funkin'$ and is merely a $passionate project$ inspired by the mod,"
		+ "\nas well as #Vs. Impostor V4#."
		+ "\n\nThe original mod's credits is listed in the *CREDITS section* in the main menu.";

		disclaimerTxtEnter = new FlxText(0, disclaimerTxt.y + disclaimerTxt.height + 25, 0, "> Okay, damn, let me play <", 20);
		disclaimerTxtEnter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);

		// FlxG.camera.bgColor = 0xFF030317;
		persistentUpdate = persistentDraw = true;
		FlxG.mouse.visible = true;
		Lib.application.window.resizable = false;

		#if DISCORD_ALLOWED
        DiscordClient.changePresence("Warning Screen", null);
        #end

		disclaimerTxt.applyMarkup(disclaimerTxt.text,
			[
				new FlxTextFormatMarkerPair(new FlxTextFormat(0xe77279), "#"),
				new FlxTextFormatMarkerPair(new FlxTextFormat(0xa8ffd0), "*"),
				new FlxTextFormatMarkerPair(new FlxTextFormat(0xe4eb6a), "$")
			]
		);

		for(txt in [disclaimerTxtTitle, disclaimerTxt, disclaimerTxtEnter]) {
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
		FlxTween.tween(FlxG.camera.scroll, {y: 0}, 0.8, {ease: FlxEase.quadInOut, startDelay: 0.8, onComplete: function(_) {
			actuallyAllowed = true;
		}});

		super.create();
	}

	override function update(elapsed:Float)
	{
		whiteTransitionTail.x = whiteTransition.x;
		whiteTransitionTail.y = whiteTransition.y + whiteTransition.height;

		if (actuallyAllowed)
		{
			if ((FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed #if mobile || FlxG.touches.getFirst() != null && FlxG.touches.getFirst().justPressed #end) && !leftState)
			{
            	FlxTransitionableState.skipNextTransOut = true;
            	FlxTransitionableState.skipNextTransIn = true;
				leftState = true;
				FlxG.mouse.visible = false;
				ClientPrefs.saveSettings();
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxFlicker.flicker(disclaimerTxtEnter, 1.4, 0.1, false, true, function(_) {
					new FlxTimer().start(1.4, function (_) {
						Lib.application.window.resizable = true;
						FlxG.switchState(() -> new TitleState());
					});
				});

				new FlxTimer().start(0.6, function(_) {
					FlxTween.cancelTweensOf(FlxG.camera);
					FlxTween.tween(FlxG.camera, {"scroll.y": FlxG.height*2}, 1, {ease: FlxEase.smootherStepIn});
				});

				FlxG.save.data.seenWarning = true;
			}
		}
		super.update(elapsed);
	}
}