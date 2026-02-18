function onCreatePost()
	makeAnimatedLuaSprite("cheese", "bg/polus/Mrcheese", -680, 500)
	addAnimationByPrefix("cheese", "idle", "MrcheeseLook", 8, true)
	addAnimationByIndices("cheese", "walk", "MrcheeseWalk", { 1, 2, 3, 2 }, 8, true)
	playAnim("cheese", "idle")
	scaleObject("cheese", 2.6, 2.6)
	setProperty("cheese.visible", false)
	addLuaSprite("cheese")

	makeAnimatedLuaSprite("rose", "bg/polus/Rose", -940, 550)
	addAnimationByPrefix("rose", "idle", "RoseLook", 8, true)
	addAnimationByIndices("rose", "walk", "RoseRun", { 1, 2, 3, 2 }, 8, true)
	playAnim("rose", "idle")
	scaleObject("rose", 3, 3)
	setProperty("rose.visible", false)
	addLuaSprite("rose")

	makeAnimatedLuaSprite("cyanDead", "bg/polus/Cyanbody", -1180, 700)
	addAnimationByPrefix("cyanDead", "idle", "Cyanbody", 8, true)
	playAnim("cyanDead", "idle")
	scaleObject("cyanDead", 3, 3)
	setProperty("cyanDead.visible", false)
	addLuaSprite("cyanDead")

	makeAnimatedLuaSprite("cyanGhost", "bg/polus/Cyanghost", -1180, 300)
	addAnimationByPrefix("cyanGhost", "idle", "Cyanghost", 8, true)
	playAnim("cyanGhost", "idle")
	scaleObject("cyanGhost", 3, 3)
	setProperty("cyanGhost.visible", false)
	setProperty("cyanGhost.alpha", 0.7)
	addLuaSprite("cyanGhost")

	makeAnimatedLuaSprite("green", "bg/polus/Greenbg", 800, 420)
	addAnimationByPrefix("green", "idle", "GreenLook", 8, true)
	addAnimationByPrefix("green", "knife", "GreenKnife", 8, true)
	addAnimationByIndices("green", "walk", "GreenRun", { 1, 2, 3, 2 }, 8, true)
	playAnim("green", "idle")
	scaleObject("green", 2.4, 2.4)
	setProperty("green.visible", false)
	addLuaSprite("green")

	makeAnimatedLuaSprite("coral", "bg/polus/Coral", 1080, 480)
	addAnimationByPrefix("coral", "idle", "CoralLook", 8, true)
	addAnimationByIndices("coral", "walk", "CoralRun", { 1, 2, 3, 2 }, 8, true)
	playAnim("coral", "idle")
	scaleObject("coral", 2.4, 2.4)
	setProperty("coral.visible", false)
	addLuaSprite("coral")

	makeAnimatedLuaSprite("pink", "bg/polus/Pink", 1140, 720)
	addAnimationByPrefix("pink", "idle", "PinkSleep", 8, true)
	addAnimationByPrefix("pink", "crawl", "PinkCrawl", 8, true)
	playAnim("pink", "idle")
	scaleObject("pink", 2.4, 2.4)
	setProperty("pink.visible", false)
	addLuaSprite("pink")

	makeAnimatedLuaSprite("poop", "bg/polus/Poopyfarts", -240, 380)
	addAnimationByIndices("poop", "megaphone", "Poopymegaphone", { 2, 1, 2 }, 8, false)
	addAnimationByIndices("poop", "walk", "Poopyrun", { 1, 2, 3, 2 }, 10, true)
	playAnim("poop", "walk")
	scaleObject("poop", 2.3, 2.3)
	setProperty("poop.visible", false)
	addLuaSprite("poop", true)

	makeAnimatedLuaSprite("brown", "bg/polus/Brown", -1740, 480)
	addAnimationByPrefix("brown", "idle", "brown", 8, true)
	playAnim("brown", "idle")
	scaleObject("brown", 3.1, 3.1)
	setScrollFactor("brown", 1.4, 1.4)
	setProperty("brown.visible", false)
	setProperty("brown.alpha", 0.7)
	addLuaSprite("brown", true)

	makeAnimatedLuaSprite("detective", "bg/polus/Detective", 1000, 370)
	addAnimationByPrefix("detective", "idle", "detective", 8, true)
	playAnim("detective", "idle")
	scaleObject("detective", 3.1, 3.1)
	setScrollFactor("detective", 1.4, 1.4)
	setProperty("detective.visible", false)
	setProperty("detective.alpha", 0.7)
	addLuaSprite("detective", true)

	makeAnimatedLuaSprite("detectiveAmused", "bg/polus/Detectiveamused", 840, 460)
	addAnimationByPrefix("detectiveAmused", "idle", "Detectiveamused", 8, true)
	playAnim("detectiveAmused", "idle")
	scaleObject("detectiveAmused", 3.1, 3.1)
	setScrollFactor("detectiveAmused", 1.4, 1.4)
	setProperty("detectiveAmused.visible", false)
	setProperty("detectiveAmused.alpha", 0.7)
	addLuaSprite("detectiveAmused", true)

	makeLuaSprite("comicBG", nil, -800, -500)
	makeGraphic("comicBG", screenWidth * 3, screenHeight * 3, "000000")
	setProperty("comicBG.alpha", 0)
	addLuaSprite("comicBG")

	makeAnimatedLuaSprite("comicBF", "bg/polus/comicbf", 500, 140)
	addAnimationByPrefix("comicBF", "idle", "ComicBf", 6, true)
	playAnim("comicBF", "idle")
	setObjectCamera("comicBF", "hud")
	setProperty("comicBF.visible", false)
	addLuaSprite("comicBF")

	makeAnimatedLuaSprite("comicRed", "bg/polus/comicred", 0, 164)
	addAnimationByPrefix("comicRed", "idle", "ComicRed", 6, true)
	playAnim("comicRed", "idle")
	setObjectCamera("comicRed", "hud")
	setProperty("comicRed.visible", false)
	addLuaSprite("comicRed")

	makeAnimatedLuaSprite("comicGF", "bg/polus/comicgf", 0, 0)
	addAnimationByPrefix("comicGF", "idle", "ComicGf", 6, true)
	playAnim("comicGF", "idle")
	setScrollFactor("comicGF", 0, 0)
	setObjectCamera("comicGF", "hud")
	screenCenter("comicGF")
	setProperty("comicGF.visible", false)
	addLuaSprite("comicGF")

	makeLuaSprite("comicDetectBG", nil, 0, 0)
	makeGraphic("comicDetectBG", screenWidth, screenHeight, "FFFFFF")
	setObjectCamera("comicDetectBG", "hud")
	setProperty("comicDetectBG.visible", false)
	addLuaSprite("comicDetectBG")

	makeAnimatedLuaSprite("comicDetective", "bg/polus/detectivecomic", 0, 0)
	addAnimationByPrefix("comicDetective", "idle", "detectiveboil", 6, true)
	addAnimationByPrefix("comicDetective", "bump", "detectivebump", 9, false)
	playAnim("comicDetective", "idle")
	setScrollFactor("comicDetective", 0, 0)
	setObjectCamera("comicDetective", "hud")
	setProperty("comicDetective.y", screenHeight - getProperty("comicDetective.height"))
	setProperty("comicDetective.visible", false)
	addLuaSprite("comicDetective")

	makeAnimatedLuaSprite("comicCoral", "bg/polus/greencoralcomic", 0, 0)
	addAnimationByPrefix("comicCoral", "idle", "greencoralcomic", 6, true)
	playAnim("comicCoral", "idle")
	setScrollFactor("comicCoral", 0, 0)
	setObjectCamera("comicCoral", "hud")
	setProperty("comicCoral.x", screenWidth - getProperty("comicCoral.width"))
	setProperty("comicCoral.visible", false)
	addLuaSprite("comicCoral")

	makeAnimatedLuaSprite("comicBrown", "bg/polus/browncomic", 0, 0)
	addAnimationByPrefix("comicBrown", "idle", "browncomic", 6, true)
	playAnim("comicBrown", "idle")
	setScrollFactor("comicBrown", 0, 0)
	setObjectCamera("comicBrown", "hud")
	setProperty("comicBrown.visible", false)
	addLuaSprite("comicBrown")
end

local events = {
	{
		step = 144,
		event = function()
			setProperty("cyanDead.visible", true)
		end,
		executed = false
	},
	{
		step = 160,
		event = function()
			setProperty("cyanGhost.visible", true)
			setProperty("cyanGhost.alpha", 0)
			doTweenAlpha("cyanGhostAppear", "cyanGhost", 0.7, 1)
		end,
		executed = false
	},
	{
		step = 176,
		event = function()
			setProperty("detective.visible", true)
		end,
		executed = false
	},
	{
		step = 152,
		event = function()
			setProperty("cheese.visible", true)

			local position = getProperty("cheese.x")
			setProperty("cheese.x", position - 800)
			doTweenX("cheeseMove", "cheese", position, 3.5)
			playAnim("cheese", "walk")
		end,
		executed = false
	},
	{
		step = 176,
		event = function()
			setProperty("green.visible", true)

			local position = getProperty("green.x")
			setProperty("green.x", position + 400)
			doTweenX("greenMove", "green", position, 2)
			playAnim("green", "walk")
		end,
		executed = false
	},
	{
		step = 204,
		event = function()
			setProperty("rose.visible", true)

			local position = getProperty("rose.x")
			setProperty("rose.x", position - 700)
			doTweenX("roseMove", "rose", position, 3)
			playAnim("rose", "walk")
		end,
		executed = false
	},
	{
		step = 246,
		event = function()
			setProperty("pink.visible", true)

			local position = getProperty("pink.x")
			setProperty("pink.x", position + 300)
			doTweenX("pinkMove", "pink", position, 3)
			playAnim("pink", "crawl")
		end,
		executed = false
	},
	{
		step = 248,
		event = function()
			setProperty("coral.visible", true)

			local position = getProperty("coral.x")
			setProperty("coral.x", position + 300)
			doTweenX("coralMove", "coral", position, 2)
			playAnim("coral", "walk")
		end,
		executed = false
	},
	{
		step = 368,
		event = function()
			setProperty("brown.visible", true)
		end,
		executed = false
	},
	{
		step = 746,
		event = function()
			playAnim("dad", "stare")
			setProperty("dad.skipDance", true)
		end,
		executed = false
	},
	{
		step = 748,
		event = function()
			setProperty("healthBar.alpha", 0.67)
			setProperty("iconP1.alpha", 0.67)
			setProperty("iconP2.alpha", 0.67)

			setProperty("comicBG.alpha", 0.1)
		end,
		executed = false
	},
	{
		step = 750,
		event = function()
			setProperty("healthBar.alpha", 0.34)
			setProperty("iconP1.alpha", 0.34)
			setProperty("iconP2.alpha", 0.34)

			setProperty("comicBG.alpha", 0.2)
		end,
		executed = false
	},
	{
		step = 752,
		event = function()
			setProperty("healthBar.alpha", 0)
			setProperty("iconP1.alpha", 0)
			setProperty("iconP2.alpha", 0)

			setProperty("comicBF.visible", true)
			setProperty("comicGF.visible", true)

			setProperty("comicBG.alpha", 0.35)

			local position = getProperty("comicBF.x")
			setProperty("comicBF.x", position + getProperty("comicBF.width"))
			doTweenX("bfComicAppear", "comicBF", position, (stepCrochet / 1000) * 4, "expoOut")
		end,
		executed = false
	},
	{
		step = 760,
		event = function()
			setProperty("comicRed.visible", true)

			setProperty("comicBG.alpha", 0.6)

			local position = getProperty("comicRed.x")
			setProperty("comicRed.x", position - getProperty("comicRed.width"))
			doTweenX("redComicAppear", "comicRed", position, (stepCrochet / 1000) * 4, "expoOut")
		end,
		executed = false
	},
	{
		step = 768,
		event = function()
			setProperty("comicBrown.visible", true)
		end,
		executed = false
	},
	{
		step = 771,
		event = function()
			setProperty("comicCoral.visible", true)
		end,
		executed = false
	},
	{
		step = 774,
		event = function()
			setProperty("comicDetectBG.visible", true)
			setProperty("comicDetective.visible", true)
		end,
		executed = false
	},
	{
		step = 778,
		event = function()
			playAnim("comicDetective", "bump")
		end,
		executed = false
	},
	{
		step = 784,
		event = function()
			playAnim("green", "knife")

			setProperty("detective.visible", false)
			setProperty("detectiveAmused.visible", true)

			setProperty("comicBG.visible", false)
			setProperty("comicGF.visible", false)
			setProperty("comicRed.visible", false)
			setProperty("comicBrown.visible", false)
			setProperty("comicCoral.visible", false)
			setProperty("comicDetectBG.visible", false)
			setProperty("comicDetective.visible", false)

			setProperty("healthBar.alpha", 1)
			setProperty("iconP1.alpha", 1)
			setProperty("iconP2.alpha", 1)

			setProperty("dad.skipDance", false)

			doTweenX("bfComicDissapear", "comicBF", getProperty("comicBF.x") + getProperty("comicBF.width"),
				(stepCrochet / 1000) * 4, "expoOut")
			doTweenX("redComicDissapear", "comicRed", getProperty("comicRed.x") - getProperty("comicRed.width"),
				(stepCrochet / 1000) * 4, "expoOut")
		end,
		executed = false
	},
	{
		step = 1128,
		event = function()
			doTweenX("brownYeet", "brown", getProperty("brown.x") - 500, 0.5, "quadIn")
		end,
		executed = false
	},
	{
		step = 1160,
		event = function()
			setProperty("poop.visible", true)

			local position = getProperty("poop.x")
			setProperty("poop.x", position + 1400)
			doTweenX("poopEntrance", "poop", position, (stepCrochet / 1000) * 6)
		end,
		executed = false
	},
	{
		step = 1168,
		event = nil,
		executed = false
	},
}

function onStepHit()
	for i, eventData in ipairs(events) do
		if curStep >= eventData.step and not eventData.executed then
			if eventData.event then
				eventData.event()
			end
			eventData.executed = true
		end
	end
end

function onTweenCompleted(tag)
	if tag == "cheeseMove" then
		playAnim("cheese", "idle")
	end
	if tag == "greenMove" then
		playAnim("green", "idle")
	end
	if tag == "roseMove" then
		playAnim("rose", "idle")
	end
	if tag == "pinkMove" then
		playAnim("pink", "idle")
	end
	if tag == "coralMove" then
		playAnim("coral", "idle")
	end

	if tag == "redComicDissapear" then
		setProperty("comicRed.visible", false)
	end
	if tag == "bfComicDissapear" then
		setProperty("comicBF.visible", false)
	end

	if tag == "poopEntrance" then
		playAnim("poop", "megaphone")
	end
end
