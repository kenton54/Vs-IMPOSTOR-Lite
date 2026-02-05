function onCreatePost()
	makeLuaSprite('gun', 'characters/redgun', getProperty('dad.x') - 180, getProperty('dad.y') + 250)
	scaleObject('gun', 2.6, 2.6)
	addLuaSprite('gun', true)
end