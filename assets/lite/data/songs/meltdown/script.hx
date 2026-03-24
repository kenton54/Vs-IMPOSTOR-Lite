import flixel.util.FlxSort;

var mrCheese:FlxSprite;
var rose:FlxSprite;
var cyanDead:FlxSprite;
var cyanGhost:FlxSprite;
var green:FlxSprite;
var coral:FlxSprite;
var pink:FlxSprite;
var poopyfarts:FlxSprite;

var brownFront:FlxSprite;
var detective:FlxSprite;

var comicBG:FlxSprite;
var comicGF:FlxSprite;
var comicBF:FlxSprite;
var comicRed:FlxSprite;
var comicBrown:FlxSprite;
var comicDuo:FlxSprite;
var comicDetectiveBG:FlxSprite;
var comicDetective:FlxSprite;

var reportThing:FlxSprite;
var reportText:FlxSprite;
var reportBodies:FlxSprite;

var events:Array<Dynamic> = [
	{
		step: 144,
		func: function()
		{
			cyanDead.visible = true;
		}
	},
	{
		step: 152,
		func: function()
		{
			mrCheese.visible = true;

			var cheesePos:Float = mrCheese.x;
			mrCheese.x = cheesePos - 800;
			mrCheese.animation.play("walk");
			FlxTween.tween(mrCheese, {x: cheesePos}, 3.5, {onComplete: _ -> mrCheese.animation.play("idle")});
		}
	},
	{
		step: 160,
		func: function()
		{
			cyanGhost.visible = true;
			cyanGhost.alpha = 0;
			FlxTween.tween(cyanGhost, {alpha: 0.7}, 1);
		}
	},
	{
		step: 176,
		func: function()
		{
			detective.visible = green.visible = true;

			var greenPos:Float = green.x;
			green.x = greenPos + 400;
			green.animation.play("walk");
			FlxTween.tween(green, {x: greenPos}, 2, {onComplete: _ -> green.animation.play("idle")});
		}
	},
	{
		step: 204,
		func: function()
		{
			rose.visible = true;

			var rosePos:Float = rose.x;
			rose.x = rosePos - 700;
			rose.animation.play("walk");
			FlxTween.tween(rose, {x: rosePos}, 3, {onComplete: _ -> rose.animation.play("idle")});
		}
	},
	{
		step: 246,
		func: function()
		{
			pink.visible = true;

			var pinkPos:Float = pink.x;
			pink.x = pinkPos + 300;
			pink.animation.play("walk");
			FlxTween.tween(pink, {x: pinkPos}, 3, {onComplete: _ -> pink.animation.play("idle")});
		}
	},
	{
		step: 248,
		func: function()
		{
			coral.visible = true;

			var coralPos:Float = coral.x;
			coral.x = coralPos + 300;
			coral.animation.play("walk");
			FlxTween.tween(coral, {x: coralPos}, 2, {onComplete: _ -> coral.animation.play("idle")});
		}
	},
	{
		step: 368,
		func: function()
		{
			brownFront.visible = true;
		}
	},
	{
		step: 746,
		func: function()
		{
			dad.animation.play("stare");
			dad.skipDance = true;
		}
	},
	{
		step: 748,
		func: function()
		{
			var healthAlpha:Float = ClientPrefs.data.healthBarAlpha * 0.67;
			game.healthBar.alpha = game.iconP1.alpha = game.iconP2.alpha = healthAlpha;

			comicBG.visible = true;
			comicBG.alpha = 0.1;
		}
	},
	{
		step: 750,
		func: function()
		{
			var healthAlpha:Float = ClientPrefs.data.healthBarAlpha * 0.34;
			game.healthBar.alpha = game.iconP1.alpha = game.iconP2.alpha = healthAlpha;
			comicBG.alpha = 0.2;
		}
	},
	{
		step: 752,
		func: function()
		{
			game.healthBar.alpha = game.iconP1.alpha = game.iconP2.alpha = 0;
			comicBG.alpha = 0.35;

			comicGF.visible = comicBF.visible = true;
			comicBF.x = FlxG.width;
			FlxTween.tween(comicBF, {x: 0}, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.expoOut});
		}
	},
	{
		step: 760,
		func: function()
		{
			comicBG.alpha = 0.6;

			comicRed.visible = true;
			comicRed.x = -FlxG.width;
			FlxTween.tween(comicRed, {x: 0}, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.expoOut});
		}
	},
	{
		step: 768,
		func: function()
		{
			comicBrown.visible = true;
		}
	},
	{
		step: 771,
		func: function()
		{
			comicDuo.visible = true;
		}
	},
	{
		step: 774,
		func: function()
		{
			comicDetectiveBG.visible = comicDetective.visible = true;
		}
	},
	{
		step: 778,
		func: function()
		{
			comicDetective.animation.play("bump");
		}
	},
	{
		step: 784,
		func: function()
		{
			game.healthBar.alpha = game.iconP1.alpha = game.iconP2.alpha = ClientPrefs.data.healthBarAlpha;

			green.animation.play("knife");
			dad.skipDance = false;

			comicBG.visible = comicGF.visible = comicBrown.visible = comicDuo.visible = comicDetectiveBG.visible = comicDetective.visible = false;

			detective.animation.play("amused");
			detective.offset.x += 100;

			var tweenDuration:Float = (Conductor.stepCrochet / 1000) * 16;
			FlxTween.tween(comicBF, {x: FlxG.width}, tweenDuration, {ease: FlxEase.expoOut});
			FlxTween.tween(comicRed, {x: -FlxG.width}, tweenDuration, {ease: FlxEase.expoOut, onComplete: _ ->
				{
					comicBF.visible = false;
					comicRed.visible = false;
				}
			});
		}
	},
	{
		step: 1118,
		func: function()
		{
			FlxTween.tween(brownFront, {x: brownFront.x - FlxG.width / 2}, 0.6, {ease: FlxEase.quartIn});
		}
	},
	{
		step: 1164,
		func: function()
		{
			poopyfarts.visible = true;

			var poopPos:Float = poopyfarts.x;
			poopyfarts.x = poopPos + FlxG.width;
			poopyfarts.animation.play("run");
			FlxTween.tween(poopyfarts, {x: poopPos}, (Conductor.stepCrochet / 1000) * 4, {onComplete: _ -> poopyfarts.animation.play("megaphone")});
		}
	},
	{
		step: 1168,
		func: function()
		{
			reportThing.visible = true;

			var scale:Float = FlxG.width / reportThing.frameWidth;

			reportThing.scale.x = scale * 2;
			reportThing.scale.y = scale * 0.4;
			reportThing.angle = -25;

			var tweenDuration:Float = 0.8;

			for (spr in [game.healthBar, game.iconP1, game.iconP2, game.scoreTxt, game.timeBar, game.timeTxt])
				FlxTween.tween(spr, {alpha: 0}, tweenDuration);

			for (strum in game.opponentStrums.members)
				FlxTween.tween(strum, {alpha: 0}, tweenDuration);

			for (i in 0...game.playerStrums.members.length)
			{
				if (i == 1) continue;
				var strum = game.playerStrums.members[i];
				FlxTween.tween(strum, {alpha: 0}, tweenDuration);
			}
		}
	},
	{
		step: 1169,
		func: function()
		{
			var scale:Float = FlxG.width / reportThing.frameWidth;

			reportThing.scale.x = scale * 1.5;
			reportThing.scale.y = scale * 0.65;
			reportThing.angle = 12;
		}
	},
	{
		step: 1170,
		func: function()
		{
			reportThing.setGraphicSize(FlxG.width);
			reportThing.angle = 0;

			reportText.visible = reportBodies.visible = true;
		}
	},
	{
		step: 1192,
		func: function()
		{
			FlxTween.tween(game.playerStrums.members[1], {alpha: 0}, 0.8);
		}
	},
];

function onCreate()
{
	mrCheese = new FlxSprite(-700, 500);
	mrCheese.frames = Paths.getSparrowAtlas("bg/polus/Mrcheese");
	mrCheese.animation.addByPrefix("idle", "MrcheeseLook", 8, true);
	mrCheese.animation.addByIndices("walk", "MrcheeseWalk", [1, 2, 3, 2], "", 8, true);
	mrCheese.animation.play("idle");
	mrCheese.scale.set(2.6, 2.6);
	mrCheese.updateHitbox();
	game.addBehindDad(mrCheese);

	rose = new FlxSprite(-960, 550);
	rose.frames = Paths.getSparrowAtlas("bg/polus/Rose");
	rose.animation.addByPrefix("idle", "RoseLook", 8, true);
	rose.animation.addByIndices("walk", "RoseRun", [1, 2, 3, 2], "", 8, true);
	rose.animation.play("idle");
	rose.scale.set(3, 3);
	rose.updateHitbox();
	game.addBehindDad(rose);

	cyanDead = new FlxSprite(-1180, 700);
	cyanDead.frames = Paths.getSparrowAtlas("bg/polus/Cyanbody");
	cyanDead.animation.addByPrefix("idle", "Cyanbody", 8, true);
	cyanDead.animation.play("idle");
	cyanDead.scale.set(3, 3);
	cyanDead.updateHitbox();
	game.addBehindDad(cyanDead);

	cyanGhost = new FlxSprite(-1180, 300);
	cyanGhost.frames = Paths.getSparrowAtlas("bg/polus/Cyanghost");
	cyanGhost.animation.addByPrefix("idle", "bandanacyan", 8, true);
	cyanGhost.animation.play("idle");
	cyanGhost.scale.set(3, 3);
	cyanGhost.updateHitbox();
	cyanGhost.alpha = 0.7;
	game.addBehindDad(cyanGhost);

	green = new FlxSprite(880, 420);
	green.frames = Paths.getSparrowAtlas("bg/polus/Greenbg");
	green.animation.addByPrefix("idle", "GreenLook", 8, true);
	green.animation.addByPrefix("knife", "GreenKnife", 8, true);
	green.animation.addByIndices("walk", "GreenRun", [1, 2, 3, 2], "", 8, true);
	green.animation.play("idle");
	green.scale.set(2.4, 2.4);
	green.updateHitbox();
	game.addBehindDad(green);

	coral = new FlxSprite(1140, 480);
	coral.frames = Paths.getSparrowAtlas("bg/polus/Coral");
	coral.animation.addByPrefix("idle", "CoralLook", 8, true);
	coral.animation.addByIndices("walk", "CoralRun", [1, 2, 3, 2], "", 8, true);
	coral.animation.play("idle");
	coral.scale.set(2.4, 2.4);
	coral.updateHitbox();
	game.addBehindDad(coral);

	pink = new FlxSprite(1260, 700);
	pink.frames = Paths.getSparrowAtlas("bg/polus/Pink");
	pink.animation.addByPrefix("idle", "PinkSleep", 8, true);
	pink.animation.addByPrefix("walk", "PinkCrawl", 10, true);
	pink.animation.play("idle");
	pink.scale.set(2.4, 2.4);
	pink.updateHitbox();
	game.addBehindDad(pink);

	poopyfarts = new FlxSprite(-260, 380);
	poopyfarts.frames = Paths.getSparrowAtlas("bg/polus/Poopyfarts");
	poopyfarts.animation.addByIndices("megaphone", "Poopymegaphone", [2, 1, 2], "", 8, false);
	poopyfarts.animation.addByIndices("run", "Poopyrun", [1, 2, 3, 2], "", 10, true);
	poopyfarts.animation.play("run");
	poopyfarts.scale.set(2.3, 2.3);
	poopyfarts.updateHitbox();
	add(poopyfarts);

	brownFront = new FlxSprite(-1900, 488);
	brownFront.frames = Paths.getSparrowAtlas("bg/polus/Brown");
	brownFront.animation.addByPrefix("idle", "brown", 8, true);
	brownFront.animation.play("idle");
	brownFront.scale.set(3.1, 3.1);
	brownFront.updateHitbox();
	brownFront.scrollFactor.set(1.4, 1.4);
	brownFront.alpha = 0.7;
	add(brownFront);

	detective = new FlxSprite(1080, 370);
	detective.frames = Paths.getMultiAtlas(["bg/polus/Detective", "bg/polus/Detectiveamused"]);
	detective.animation.addByPrefix("normal", "detective", 8, true);
	detective.animation.addByPrefix("amused", "Detectiveamused", 8, true);
	detective.animation.play("normal");
	detective.scale.set(3.1, 3.1);
	detective.updateHitbox();
	detective.scrollFactor.set(1.4, 1.4);
	detective.alpha = 0.7;
	add(detective);

	comicBG = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
	comicBG.scale.set(FlxG.width * 3, FlxG.height * 3);
	comicBG.updateHitbox();
	comicBG.screenCenter();
	insert(game.members.indexOf(game.gfGroup) + 1, comicBG);

	comicGF = new FlxSprite();
	comicGF.frames = Paths.getSparrowAtlas("bg/polus/comicgf");
	comicGF.animation.addByPrefix("idle", "ComicGf", 6, true);
	comicGF.animation.play("idle");
	comicGF.setGraphicSize(0, FlxG.height);
	comicGF.updateHitbox();
	comicGF.screenCenter();
	comicGF.cameras = [game.camHUD];

	comicBF = new FlxSprite();
	comicBF.frames = Paths.getSparrowAtlas("bg/polus/comicbf");
	comicBF.animation.addByPrefix("idle", "ComicBf", 6, true);
	comicBF.animation.play("idle");
	comicBF.setGraphicSize(0, FlxG.height);
	comicBF.updateHitbox();
	comicBF.screenCenter();
	comicBF.cameras = [game.camHUD];

	comicRed = new FlxSprite();
	comicRed.frames = Paths.getSparrowAtlas("bg/polus/comicred");
	comicRed.animation.addByPrefix("idle", "ComicRed", 6, true);
	comicRed.animation.play("idle");
	comicRed.setGraphicSize(0, FlxG.height);
	comicRed.updateHitbox();
	comicRed.screenCenter();
	comicRed.cameras = [game.camHUD];

	game.addBehindDad(comicRed);
	game.addBehindDad(comicBF);
	game.addBehindDad(comicGF);

	comicBrown = new FlxSprite();
	comicBrown.frames = Paths.getSparrowAtlas("bg/polus/browncomic");
	comicBrown.animation.addByPrefix("idle", "browncomic", 6, true);
	comicBrown.animation.play("idle");
	comicBrown.setGraphicSize(0, FlxG.height);
	comicBrown.updateHitbox();
	comicBrown.screenCenter();
	comicBrown.cameras = [game.camHUD];

	comicDuo = new FlxSprite();
	comicDuo.frames = Paths.getSparrowAtlas("bg/polus/greencoralcomic");
	comicDuo.animation.addByPrefix("idle", "greencoralcomic", 6, true);
	comicDuo.animation.play("idle");
	comicDuo.setGraphicSize(0, FlxG.height);
	comicDuo.updateHitbox();
	comicDuo.screenCenter();
	comicDuo.cameras = [game.camHUD];

	/*
	var ratioWidth:Float = 1200 / FlxG.width;
	var ratioHeight:Float = 900 / FlxG.height;
	var ratioScale:Float = ratioHeight / ratioWidth;
	*/

	comicDetectiveBG = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
	comicDetectiveBG.setGraphicSize(FlxG.width, FlxG.height);
	comicDetectiveBG.updateHitbox();
	comicDetectiveBG.screenCenter();
	comicDetectiveBG.cameras = [game.camHUD];

	comicDetective = new FlxSprite();
	comicDetective.frames = Paths.getSparrowAtlas("bg/polus/detectivecomic");
	comicDetective.animation.addByPrefix("idle", "detectiveboil", 6, true);
	comicDetective.animation.addByPrefix("bump", "detectivebump", 9, false);
	comicDetective.animation.play("idle");
	comicDetective.setGraphicSize(0, FlxG.height);
	comicDetective.updateHitbox();
	comicDetective.y = FlxG.height - comicDetective.height;
	comicDetective.cameras = [game.camHUD];

	game.addBehindDad(comicDetectiveBG);
	game.addBehindDad(comicDetective);
	game.addBehindDad(comicDuo);
	game.addBehindDad(comicBrown);

	reportThing = new FlxSprite().loadGraphic(Paths.image("bg/polus/reportedthing"));

	var reportScale:Float = FlxG.width / reportThing.frameWidth;

	reportThing.scale.set(reportScale, reportScale);
	reportThing.updateHitbox();
	reportThing.screenCenter();
	reportThing.cameras = [game.camHUD];
	game.addBehindDad(reportThing);

	reportText = new FlxSprite().loadGraphic(Paths.image("bg/polus/deadbodyreported"));
	reportText.scale.set(reportScale, reportScale);
	reportText.updateHitbox();
	reportText.screenCenter(0x01);
	reportText.y = reportThing.y + (reportThing.height * 0.6) - reportText.height / 2;
	reportText.cameras = [game.camHUD];
	game.addBehindDad(reportText);

	reportBodies = new FlxSprite().loadGraphic(Paths.image("bg/polus/rip"));
	reportBodies.scale.set(reportScale, reportScale);
	reportBodies.updateHitbox();
	reportBodies.screenCenter(0x01);
	reportBodies.x += 60;
	reportBodies.y = reportThing.y + (reportThing.height * 0.2) - reportBodies.height / 2;
	reportBodies.cameras = [game.camHUD];
	game.addBehindDad(reportBodies);

	for (spr in [mrCheese, rose, cyanDead, cyanGhost, green, coral, pink, poopyfarts, brownFront, detective, comicBG, comicGF, comicBF, comicRed, comicBrown, comicDuo, comicDetectiveBG, comicDetective, reportThing, reportText, reportBodies])
    {
        spr.visible = false;
        spr.antialiasing = ClientPrefs.data.antialiasing;
    }

	events.sort((a, b) -> FlxSort.byValues(1, a.step, b.step));
}

function onCreatePost()
{
	boyfriend.alpha = 0;
	FlxTween.tween(boyfriend, {alpha: 0.7}, 1, {startDelay: 1});
}

function onStepHit()
{
	if (events.length > 0 && curStep >= events[events.length - 1].step)
	{
		var data:Dynamic = events.pop();

		if (data.func != null)
			data.func();
	}
}