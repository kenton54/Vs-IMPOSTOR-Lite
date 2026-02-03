function onCreatePost()
	makeLuaSprite('gun', 'gun', 0, 0);
	scaleObject('gun', 1.6, 1.6);
	addLuaSprite('gun', true);
	setProperty('gun.x', getProperty('dad.x') - 650);
	setProperty('gun.y', getProperty('dad.y') + 1025);
end