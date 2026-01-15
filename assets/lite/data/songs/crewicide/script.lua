function onCreate()
	makeLuaSprite("backgroundOfficeBroken", "bg/office/officeBroken", -1250, -1050);
	scaleObject("backgroundOfficeBroken", 1.8, 1.8);
	setProperty("backgroundOfficeBroken.antialiasing", false);
	setProperty("backgroundOfficeBroken.visible", false);
	addLuaSprite("backgroundOfficeBroken");
end

function onStepHit()
	if curStep == 2032 then
		setProperty('defaultCamZoom', 0.82);
		setProperty('opponentCameraOffset[0]', -75);
		setProperty('opponentCameraOffset[1]', -40);
	elseif curStep == 2080 then
		cameraShake('camGame', 0.02, 1.6);
		cameraShake('camHUD', 0.01, 1.6);
		setProperty('dad.visible', false);
		setProperty('backgroundOffice.visible', false);
		setProperty('backgroundOfficeBroken.visible', true);
		setProperty('defaultCamZoom', 0.75);
		setProperty('cameraSpeed', 6);
		setProperty('opponentCameraOffset[0]', -200);
		setProperty('opponentCameraOffset[1]', -200);
	end
end

function onUpdate(e)
	if getProperty('FlxG.camera.zoom') == 0.75 then --This doesnt work rn, and it sucks, ill fix it later
		setProperty('camZooming', false);
		setProperty('cameraSpeed', 1);
	end
end