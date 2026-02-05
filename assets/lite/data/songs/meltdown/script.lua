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

	makeAnimatedLuaSprite("green", "bg/polus/Greenbg", 800, 420)
	addAnimationByPrefix("green", "idle", "GreenLook", 8, true)
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
	addAnimationByIndices("poop", "megaphone", "Poopyfartsmegaphone", { 2, 1, 2 }, 8, false)
	addAnimationByIndices("poop", "walk", "Poopyfartswalk", { 1, 2, 3, 2 }, 10, true)
	playAnim("poop", "walk")
	scaleObject("poop", 3.2, 3.2)
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
		step = 784,
		event = function()
			setProperty("detective.visible", false)
			setProperty("detectiveAmused.visible", true)
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

	if tag == "poopEntrance" then
		playAnim("poop", "megaphone")
	end
end
