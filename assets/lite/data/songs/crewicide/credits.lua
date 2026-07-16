local songTitle = "Crewicide"
local artist = "SliceOfBred"
local charter = "Kenton"
local iconColor = "6C5CE7"
local skipped = false
local shown = false

function onSongStart()
	if shown then return end
	shown = true

	makeGraphic('creditsBG', 420, 130, '#000000')
	addLuaSprite('creditsBG', true)
	setObjectCamera('creditsBG', 'camHUD')
	setProperty('creditsBG.x', 40)
	setProperty('creditsBG.y', 20)
	setProperty('creditsBG.alpha', 0)

	makeGraphic('creditsAccent', 420, 6, '#' .. iconColor)
	addLuaSprite('creditsAccent', true)
	setObjectCamera('creditsAccent', 'camHUD')
	setProperty('creditsAccent.x', 40)
	setProperty('creditsAccent.y', 20)
	setProperty('creditsAccent.alpha', 0)

	makeLuaText('creditsTitle', songTitle, 380, 56, 34)
	setTextSize('creditsTitle', 28)
	setTextColor('creditsTitle', '#' .. iconColor)
	setTextBorder('creditsTitle', 2, '#000000')
	addLuaText('creditsTitle')
	setObjectCamera('creditsTitle', 'camHUD')
	setProperty('creditsTitle.alpha', 0)

	makeLuaText('creditsArtist', 'Music by ' .. artist, 380, 56, 70)
	setTextSize('creditsArtist', 18)
	setTextColor('creditsArtist', 'FFFFFF')
	setTextBorder('creditsArtist', 2, '#000000')
	addLuaText('creditsArtist')
	setObjectCamera('creditsArtist', 'camHUD')
	setProperty('creditsArtist.alpha', 0)

	makeLuaText('creditsCharter', 'Charted by ' .. charter, 380, 56, 94)
	setTextSize('creditsCharter', 18)
	setTextColor('creditsCharter', 'FFFFFF')
	setTextBorder('creditsCharter', 2, '#000000')
	addLuaText('creditsCharter')
	setObjectCamera('creditsCharter', 'camHUD')
	setProperty('creditsCharter.alpha', 0)

	doTweenAlpha('bgIn', 'creditsBG', 0.85, 0.4, 'linear')
	doTweenAlpha('accentIn', 'creditsAccent', 1, 0.4, 'linear')
	doTweenAlpha('titleIn', 'creditsTitle', 1, 0.5, 'quadOut')
	doTweenAlpha('artistIn', 'creditsArtist', 1, 0.5, 'quadOut')
	doTweenAlpha('charterIn', 'creditsCharter', 1, 0.5, 'quadOut')

	runTimer('creditsHide', 3.5)
end

function onUpdate()
	if shown and not skipped and (keyJustPressed('accept') or keyJustPressed('space')) then
		hideCredits()
	end
end

function hideCredits()
	if skipped then return end
	skipped = true

	doTweenAlpha('bgOut', 'creditsBG', 0, 0.3, 'linear')
	doTweenAlpha('accentOut', 'creditsAccent', 0, 0.3, 'linear')
	doTweenAlpha('titleOut', 'creditsTitle', 0, 0.3, 'linear')
	doTweenAlpha('artistOut', 'creditsArtist', 0, 0.3, 'linear')
	doTweenAlpha('charterOut', 'creditsCharter', 0, 0.3, 'linear')

	runTimer('creditsRemove', 0.35)
end

function onTimerCompleted(tag)
	if tag == 'creditsHide' then
		hideCredits()
	elseif tag == 'creditsRemove' then
		removeLuaSprite('creditsBG')
		removeLuaSprite('creditsAccent')
		removeLuaText('creditsTitle')
		removeLuaText('creditsArtist')
		removeLuaText('creditsCharter')
	end
end