package states;

import openfl.utils.Assets;
import flixel.effects.FlxFlicker;

class SelectCreditsState extends MusicBeatState
{
    public static var prevCurCredit:Int = 0;
    public static var curCredit:Int = 0;

    public var logosGrp:FlxTypedGroup<FlxSprite>;

    // ARRAY: [Team Name - Position Add[X/Y] - Scale[X/Y] - Devs]
    public var teamsList:Array<Dynamic> = tjson.TJSON.parse(Assets.getText(Paths.getLitePath("data/credits.json"))).credits;

    override function create()
    {
        #if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Choosing a team...", null);
		#end

		persistentUpdate = persistentDraw = true;
        FlxG.mouse.visible = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('storymode/bg'));
		bg.antialiasing = false;
        bg.screenCenter();
		add(bg);

        var titleTxt = new FlxText(0, 1, FlxG.width, "Select a Team!", 40);
		titleTxt.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.BLACK, CENTER);
		add(titleTxt);

        logosGrp = new FlxTypedGroup<FlxSprite>();
		add(logosGrp);

        for(i in 0...teamsList.length)
        {
            var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('credits/${teamsList[i][0]}'));
            logo.antialiasing = false;
            logo.scale.set(teamsList[i][2][0], teamsList[i][2][1]);
            logo.updateHitbox();
            logo.screenCenter();
            logo.x += teamsList[i][1][0];
            logo.y += teamsList[i][1][1];
            logo.ID = i;
            logosGrp.add(logo);
        }

        super.create();
    }

    var selected:Bool = false;
    override function update(elapsed:Float)
    {
        if(!selected)
        {
            if(controls.UI_LEFT_P)
				changeItem(-1);
			if(controls.UI_RIGHT_P)
				changeItem(1);

            if(FlxG.mouse.justMoved) {
                FlxG.mouse.visible = true;
            }

            logosGrp.forEach(function(spr:FlxSprite) {
                if(FlxG.mouse.overlaps(spr) && FlxG.mouse.visible)
                {
                    prevCurCredit = curCredit;
                    curCredit = spr.ID;
                    if(prevCurCredit != curCredit) FlxG.sound.play(Paths.sound('scrollMenu'));
                    if(FlxG.mouse.justPressed) enterCredits();
                }
            });

            logosGrp.forEach(function(spr:FlxSprite) 
            {
                if(spr.ID == curCredit) {
                    spr.scale.x = FlxMath.lerp(spr.scale.x, teamsList[curCredit][2][0] + 0.1, FlxMath.bound(elapsed * 12, 0, 1));
                    spr.scale.y = FlxMath.lerp(spr.scale.y, teamsList[curCredit][2][1] + 0.1, FlxMath.bound(elapsed * 12, 0, 1));
                    spr.alpha = FlxMath.lerp(spr.alpha, 1, FlxMath.bound(elapsed * 10, 0, 1));
                }
                else {
                    spr.scale.x = FlxMath.lerp(spr.scale.x, teamsList[spr.ID][2][0], FlxMath.bound(elapsed * 12, 0, 1));
                    spr.scale.y = FlxMath.lerp(spr.scale.y, teamsList[spr.ID][2][1], FlxMath.bound(elapsed * 12, 0, 1));
                    spr.alpha = FlxMath.lerp(spr.alpha, 0.8, FlxMath.bound(elapsed * 10, 0, 1));
                }
            });

            if (controls.ACCEPT)
                enterCredits();
            
            if (controls.BACK || FlxG.mouse.justPressedRight)
            {
                FlxG.mouse.visible = false;
                FlxG.sound.play(Paths.sound('cancelMenu'));
                FlxG.switchState(() -> new MainMenuState());
                selected = true;
            }
        }

        super.update(elapsed);
    }    

    function enterCredits()
    {
        FlxG.sound.play(Paths.sound('confirmMenu'));
        selected = true;
        FlxG.mouse.visible = false;
        FlxFlicker.flicker(logosGrp.members[curCredit], 1, 0.06, false, false, _ -> FlxG.switchState(() -> new CreditsState(teamsList[curCredit][0], teamsList[curCredit][3])));
    }

    function changeItem(huh:Int = 0)
    {
        if(huh != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
        prevCurCredit = curCredit;
        curCredit += huh;
        if (curCredit >= teamsList.length) curCredit = 0;
        if (curCredit < 0) curCredit = teamsList.length - 1;

        FlxG.mouse.visible = false;
    }
}