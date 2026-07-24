package states;

class TitleState extends MusicBeatState
{
	/**
	 * The joke being that a specific build was sent exclusively to steginite for the Sussin' Direct lol
	 */
	public static final isSteginiteBuildLol:Bool = false;

	static var seenIntro:Bool = false;
	static var passedWarning:Bool = false;

	var curWacky:Array<String> = [];

	var whiteFront:FlxSprite;
	var textsGrp:FlxTypedSpriteGroup<Alphabet>;

	var logo:FlxSprite;
	var logoTTSpr:FlxSprite;
	var titleStuff:FlxTypedGroup<FlxSprite>;

	override function create()
	{
		PointerUtil.visible = false;

		curWacky = FlxG.random.getObject(getIntroTextShit());

		persistentUpdate = true;

		if (FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(2, 0, 1);
		}
		Conductor.bpm = 109;

		titleStuff = new FlxTypedGroup<FlxSprite>();
		titleStuff.visible = false;
		add(titleStuff);

		var red:FlxSprite = new FlxSprite().loadGraphic(Paths.image('title/red'));
		red.antialiasing = false;
		red.x = 75;
		red.y = FlxG.height - red.height - #if mobile 100 #else 125 #end;
		titleStuff.add(red);

		var enter:FlxSprite = new FlxSprite().loadGraphic(#if mobile Paths.image('title/touch') #else Paths.image('title/press') #end);
		enter.antialiasing = false;
		enter.screenCenter(X);
		enter.y = (FlxG.height * 0.95) - enter.height;
		titleStuff.add(enter);

		logo = new FlxSprite(0, 50).loadGraphic(Paths.image('logo'));
		logo.x = FlxG.width - logo.width - 35;
		logo.antialiasing = false;
		titleStuff.add(logo);

		whiteFront = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		whiteFront.scrollFactor.set(0, 0);
		whiteFront.visible = !seenIntro;
		add(whiteFront);

		textsGrp = new FlxTypedSpriteGroup();
		add(textsGrp);

		logoTTSpr = new FlxSprite().loadGraphic(Paths.image('logo'));
		logoTTSpr.antialiasing = false;
		logoTTSpr.setGraphicSize(Std.int(500));
		logoTTSpr.updateHitbox();
		logoTTSpr.screenCenter(X);
		logoTTSpr.y = FlxG.height - logoTTSpr.height - 120;
		logoTTSpr.visible = false;
		add(logoTTSpr);

		allow = false;
		new FlxTimer().start((seenIntro ? 0.5 : 0.01), _ ->
		{
			allow = true;

			titleStuff.visible = true;

			if (seenIntro)
			{
				finishIntro();
				// FlxTween.cancelTweensOf(FlxG.camera);
				// FlxG.camera.scroll.y = 0;
			}
		});

		super.create();
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introTexts.txt', Paths.getLitePath());
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
		if (!allow)
			return;

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var pressedEnter:Bool = (PointerUtil.justReleased && !SwipeUtil.justSwipedAny) || FlxG.keys.justPressed.ENTER;

		var mult:Float = FlxMath.lerp(0.85, logo.scale.x, Math.exp(-elapsed * 9 * 1));
		logo.scale.set(mult, mult);

		if (!selected && pressedEnter)
		{
			if (skippedIntro)
			{
				selected = true;
				FlxG.camera.stopFlash();
				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
				for (item in titleStuff.members)
					FlxTween.tween(item, {y: item.y + 1000}, 1.25, {ease: FlxEase.smootherStepIn, startDelay: 0.06});

				new FlxTimer().start(1.3, function(_)
				{
					FlxG.switchState(() -> new MainMenuState());
				});
			}
			else
				finishIntro();
		}

		super.update(elapsed);

		#if android
		if (FlxG.android.justReleased.BACK)
			openfl.Lib.application.window.close();
		#end
	}

	private var correctBeat:Int = 0;

	override function beatHit()
	{
		super.beatHit();
		if (!allow)
			return;

		logo.scale.set(0.9, 0.9);

		if (!selected && !seenIntro)
		{
			correctBeat++;
			switch (correctBeat)
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
					logoTTSpr.visible = true;
				case 8:
					removeIntroTexts();
					logoTTSpr.visible = false;
				case 9:
					makeIntroText(curWacky[0]);
				case 11:
					// kenton... hear me out...
					if (curWacky[1] != null)
						makeIntroText(curWacky[1]);
					if (curWacky[2] != null)
						makeIntroText(curWacky[2]);
					if (curWacky[3] != null)
						makeIntroText(curWacky[3]);
				case 12:
					removeIntroTexts();
				case 13:
					makeIntroText('Vs.');
				case 14:
					var txtAlph = makeIntroText('Impostor');
					for (txt in txtAlph.letters)
						txt.setColorTransform(1, 1, 1, 1, 231, 114, 121);
				case 15:
					var txtAlph = makeIntroText('Lite');
					var colors:Array<Array<Int>> = [
						[243, 219, 255],
						[218, 245, 255],
						[219, 254, 255],
						[255, 219, 231]
					];

					for (i => txt in txtAlph.letters)
						txt.setColorTransform(1, 1, 1, 1, colors[i][0] - 25, colors[i][1] - 25, colors[i][2] - 25);
				case 16:
					finishIntro();
			}
		}
	}

	var textPos:Float = #if mobile 180 #else 260 #end;

	function makeIntroArrText(hand:Array<String>, ?offsetY:Float = 0)
	{
		for (i in 0...hand.length)
		{
			var text:Alphabet = new Alphabet(0, 0, hand[i], false);
			text.screenCenter(X);
			text.y = textPos + (i * 70) + offsetY;
			textsGrp.add(text);
		}
	}

	function makeIntroText(hand:String = '', ?offsetY:Float = 0)
	{
		var text:Alphabet = new Alphabet(0, 0, hand, false);
		text.screenCenter(X);
		text.y = textPos + (textsGrp.length * 70) + offsetY;
		textsGrp.add(text);

		return text;
	}

	function removeIntroTexts()
	{
		while (textsGrp.members.length > 0)
		{
			textsGrp.members[0].destroy();
			textsGrp.remove(textsGrp.members[0], true);
		}
	}

	var skippedIntro:Bool = false;

	function finishIntro()
	{
		if (!seenIntro)
			seenIntro = true;

		if (skippedIntro)
			return;
		if (!skippedIntro)
			skippedIntro = true;

		logoTTSpr.destroy();
		remove(logoTTSpr);

		FlxG.camera.flash(FlxColor.WHITE, 1.6);
		FlxTween.cancelTweensOf(FlxG.camera);
		FlxG.camera.scroll.y = -FlxG.height;
		FlxTween.tween(FlxG.camera, {"scroll.y": 0}, 1.25, {ease: FlxEase.smootherStepOut});

		whiteFront.visible = false;
		removeIntroTexts();
		remove(textsGrp);
	}
}
