function onCreate()
	makeLuaSprite("backgroundOfficeBroken", "bg/office/officeBroken", -1250, -1050)
	scaleObject("backgroundOfficeBroken", 1.8, 1.8)
	setProperty("backgroundOfficeBroken.antialiasing", false)
	setProperty("backgroundOfficeBroken.visible", false)
	addLuaSprite("backgroundOfficeBroken")
end

local events = {
	{
		step = 2032,
		func = function()
			setProperty('defaultCamZoom', 0.82)
			setProperty('opponentCameraOffset[0]', -75)
			setProperty('opponentCameraOffset[1]', -40)
		end,
		executed = false
	},
	{
		step = 2056,
		func = function()
			playAnim("dad", "jump-prep")
			setProperty("dad.stunned", true)
		end,
		executed = false
	},
	{
		step = 2067,
		func = function()
			playAnim("dad", "jump")
		end,
		executed = false
	},
	{
		step = 2080,
		func = function()
			cameraShake('camGame', 0.02, 1.6)
			cameraShake('camHUD', 0.01, 1.6)
			setProperty('dad.visible', false)
			setProperty('backgroundOffice.visible', false)
			setProperty('backgroundOfficeBroken.visible', true)
			setProperty('defaultCamZoom', 0.75)
			setProperty('cameraSpeed', 6)
			setProperty('opponentCameraOffset[0]', -200)
			setProperty('opponentCameraOffset[1]', -200)
		end,
		executed = false
	}
}

function onStepHit()
	for _, eventData in ipairs(events) do
		if curStep >= eventData.step and not eventData.executed then
			if eventData.func then
				eventData.func()
			end

			eventData.executed = true
		end
	end
end
