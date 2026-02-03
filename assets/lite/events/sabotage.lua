function onCreate()
	makeLuaSprite('flash', '', 0, 0);
	makeGraphic('flash', 1400, 1000, 'fd7f7f')
	addLuaSprite('flash', true);
	setProperty('flash.alpha', 0.00001)
	setObjectCamera('flash', 'camHUD');
end

function onEvent(n,v1,v2)
	if n == 'sabotage' then
		setProperty('flash.alpha', 0.4)
		doTweenAlpha('flTw', 'flash', 0.00001, v1, 'linear')
	end
end