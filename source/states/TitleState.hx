package states;

import backend.WeekData;
import backend.Highscore;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import states.MainMenuState;
import flixel.addons.transition.FlxTransitionableState;

class TitleState extends MusicBeatState
{
	static var seenIntro:Bool = false;
	static var passedWarning:Bool = false;
	var curWacky:Array<String> = [];
	
	var whiteFront:FlxSprite;
	var textsGrp:FlxTypedSpriteGroup<Alphabet>;

	var logo:FlxSprite;
	var titleStuff:FlxTypedGroup<FlxSprite>;

	override function create():Void
	{
		Paths.clearStoredMemory();
		FlxG.mouse.visible = false;
        if(!seenIntro) FlxTransitionableState.skipNextTransOut = true;

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];
		FlxG.camera.bgColor = 0xFFFFFF;

		curWacky = FlxG.random.getObject(getIntroTextShit());

		FlxG.save.bind('funkin', CoolUtil.getSavePath());
		ClientPrefs.loadPrefs();
		Highscore.load();

		if(FlxG.save.data != null && FlxG.save.data.fullscreen) FlxG.fullscreen = FlxG.save.data.fullscreen;
		persistentUpdate = true;
		persistentDraw = true;

		if (FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(2, 0, 1);
		}
		Conductor.bpm = 109;

		if (FlxG.save.data.weekCompleted != null)
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

		if(FlxG.save.data.flashing == null && !WarningState.leftState) {
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;
            new FlxTimer().start(1, function(_) {
				FlxG.switchState(() -> new WarningState());
			});
			passedWarning = true;
			allow = false;
            return;
        }

		titleStuff = new FlxTypedGroup<FlxSprite>();
		titleStuff.visible = false;
		add(titleStuff);

		var red:FlxSprite = new FlxSprite().loadGraphic(Paths.image('title/red'));
		red.antialiasing = false;
		red.x = 75;
		red.y = FlxG.height - red.height - 125;
		titleStuff.add(red);

		var enter:FlxSprite = new FlxSprite().loadGraphic(Paths.image('title/press'));
		enter.antialiasing = false;
		enter.screenCenter();
		enter.y += 325;
		titleStuff.add(enter);

		logo = new FlxSprite(0, 35).loadGraphic(Paths.image('title/logo'));
		logo.x = FlxG.width - logo.width - 80;
		logo.antialiasing = false;
		titleStuff.add(logo);

		whiteFront = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		whiteFront.scrollFactor.set(0, 0);
		whiteFront.visible = !seenIntro;
		add(whiteFront);

		textsGrp = new FlxTypedSpriteGroup();
		add(textsGrp);
		
		allow = false;
		new FlxTimer().start((seenIntro ? 0.5 : 0.01), function(_)
		{
			allow = true;
			if(passedWarning) {
				FlxTween.cancelTweensOf(FlxG.camera);
				FlxG.camera.scroll.y = -FlxG.height;
				FlxTween.tween(FlxG.camera, {"scroll.y": 0}, 1.25, {ease: FlxEase.smootherStepOut});
			}

			titleStuff.visible = true;
		
			if(!seenIntro) seenIntro = true;
			else finishIntro();
		});

		super.create();
		Paths.clearUnusedMemory();
	}

	function getIntroTextShit():Array<Array<String>>
	{
		#if MODS_ALLOWED
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introTexts.txt', Paths.getLitePath());
		#else
		var fullText:String = Assets.getText(Paths.txt('introTexts'));
		var firstArray:Array<String> = fullText.split('\n');
		#end
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var selected:Bool = false;
	var allow:Bool = false;
	override function update(elapsed:Float)
	{
		if(!allow) return;

		if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

		var mult:Float = FlxMath.lerp(1, logo.scale.x, Math.exp(-elapsed * 9 * 1));
		logo.scale.set(mult, mult);

		if(!selected) {
			if(FlxG.keys.justPressed.ENTER && skippedIntro)
			{
				selected = true;
				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
				for(item in titleStuff.members) 
					FlxTween.tween(item, {y: item.y + 1000}, 1.25, {ease: FlxEase.smootherStepIn, startDelay: 0.06});

				new FlxTimer().start(1.3, function(_) {
					FlxG.switchState(() -> new MainMenuState());
				});
			} else if(FlxG.keys.justPressed.ENTER && !skippedIntro) {
				finishIntro();
				return; // just making sure
			}
		}

		super.update(elapsed);
	}

	private var correctBeat:Int = 0;
	override function beatHit()
	{
		super.beatHit();
		if(!allow) return;
		
		logo.scale.set(1.075, 1.075);

		if(!selected)
		{
			correctBeat++;
			switch(correctBeat)
			{
				case 1:
					makeIntroText('Original by IMPOSTORM');
				case 3:
					makeIntroText('And');
					makeIntroText('The Funkin\' Crew');
				case 4:
					removeIntroTexts();
				case 5:
					makeIntroText('And inspired by', -40);
				case 7:
					makeIntroText('This mod here', -40);
					// ngSpr.visible = true;
				case 8:
					removeIntroTexts();
					// ngSpr.visible = false;
				case 9:
					makeIntroArrText([curWacky[0]]);
				case 11:
					makeIntroText(curWacky[1]);
				case 12:
					removeIntroTexts();
				case 13:
					makeIntroText('Vs.');
				case 14:
					var txtAlph = makeIntroText('Impostor');
					for(txt in txtAlph.letters) txt.setColorTransform(1, 1, 1, 1, 231, 114, 121);
				case 15:
					var txtAlph = makeIntroText('Lite');
					var colors:Array<Array<Int>> = [
						[243, 219, 255],
						[218, 245, 255],
						[219, 254, 255],
						[255, 219, 231]
					];

					for(i => txt in txtAlph.letters)
						txt.setColorTransform(1, 1, 1, 1, colors[i][0] - 25, colors[i][1] - 25, colors[i][2] - 25);
				case 16:
					finishIntro();
			}
		}
	}

	function makeIntroArrText(hand:Array<String>, ?offsetY:Float = 0)
	{
		for (i in 0...hand.length)
		{
			var text:Alphabet = new Alphabet(0, 0, hand[i], false);
			text.screenCenter(X);
			text.y = (260 + (i * 70)) + offsetY;
			textsGrp.add(text);
		}
	}	

	function makeIntroText(hand:String, ?offsetY:Float = 0)
	{
		var text:Alphabet = new Alphabet(0, 0, hand, false);
		text.screenCenter(X);
		text.y = 260 + (textsGrp.length * 70)  + offsetY;
		textsGrp.add(text);

		return text;
	}	

	function removeIntroTexts()
	{
		while (textsGrp.members.length > 0)
		{
			textsGrp.remove(textsGrp.members[0], true);
		}
	}

	var skippedIntro:Bool = false;
	function finishIntro()
	{
		if(skippedIntro) return;
		if(!skippedIntro) skippedIntro = true;

		FlxG.camera.flash(FlxColor.WHITE, 1.6);
		FlxTween.cancelTweensOf(FlxG.camera);
		FlxG.camera.scroll.y = -FlxG.height;
		FlxTween.tween(FlxG.camera, {"scroll.y": 0}, 1.25, {ease: FlxEase.smootherStepOut});

		whiteFront.visible = false;
		removeIntroTexts();
		remove(textsGrp);
	}
}