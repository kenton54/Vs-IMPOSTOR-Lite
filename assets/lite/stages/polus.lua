function onCreatePost()
	runHaxeCode([[
		import flixel.addons.display.FlxBackdrop;

		var spaceInf:FlxBackdrop = new FlxBackdrop(Paths.image("bg/polus/stars"));
		spaceInf.setPosition(-1460, -1200);
		spaceInf.scale.set(2.2, 2.2);
		game.addBehindGF(spaceInf);
	]])

	makeLuaSprite("pbg", "bg/polus/background", -1460, -1200)
	scaleObject("pbg", 2.2, 2.2)
	setProperty("pbg.antialiasing", false)
	addLuaSprite("pbg")

	makeLuaSprite("moon", "bg/polus/moon", -1750, -2500)
	scaleObject("moon", 2.2, 2.2)
	setProperty("moon.antialiasing", false)
	addLuaSprite("moon")

	runHaxeCode([[
		using StringTools;

		var bgSpr:FlxSprite = game.getLuaObject('pbg');

		var snowEmitter:SnowEmitter = new SnowEmitter(bgSpr.x + 100, bgSpr.y + 450, 325, bgSpr.width);
		snowEmitter.snowScrollFactor.x = {x: 1, y: 1.5};
		snowEmitter.snowScrollFactor.y = {x: 1, y: 1.5};
		snowEmitter.updateScrollFactor();
		snowEmitter.snowEmitterAlpha = 1;
		add(snowEmitter);

		if(PlayState.SONG.song == 'sussus-moongus')
			snowEmitter.snowEmitterAlpha = 0;

		snowEmitter.startSnowEmitter(0.06);
			
		game.variables.set('snowEmitter', snowEmitter);
	]])
end

function onStepHit()
	if curStep == 84 then
		runHaxeCode([[
			var snowEmit:SnowEmitter = game.variables.get('snowEmitter');
			snowEmit.tweenSnowEmitterAlpha(1, 1.2, 0.4);
		]])
	end
end