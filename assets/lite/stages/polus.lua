function onCreatePost()
    	if isSongSM then
    		runHaxeCode([[
			import flixel.addons.display.FlxBackdrop;
			var spaceInf:FlxBackdrop = new FlxBackdrop(Paths.image("bg/polus/stars"));
			spaceInf.setPosition(-1460, -1200);
			spaceInf.scale.set(2.2, 2.2);
			// spaceInf.scrollFactor.set(0.8, 0.8);
			addBehindGF(spaceInf);
    		]]);
    	end

    	makeLuaSprite("pbg", "bg/polus/background", -1460, -1200)
    	scaleObject("pbg", 2.2, 2.2)
    	setProperty("pbg.antialiasing", false)
    	addLuaSprite("pbg")

    	makeLuaSprite("moon", "bg/polus/moon", -1750, -2500)
    	scaleObject("moon", 2.2, 2.2)
    	setProperty("moon.antialiasing", false)
    	addLuaSprite("moon")
end