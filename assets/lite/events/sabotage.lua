function onCreate()
	makeLuaSprite('flash', '', 0, 0);
	makeGraphic('flash', screenWidth, screenHeight, 'fd7f7f')
	setObjectCamera('flash', 'camHUD')
	addLuaSprite('flash');
	setProperty('flash.alpha', 0.00001)
end

function onEvent(n,v1,v2)
	if n == 'sabotage' then
		setProperty('flash.alpha', 0.4)
		doTweenAlpha('flTw', 'flash', 0.00001, v1, 'linear')
	end
end