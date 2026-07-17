local songTitle = "MELTDOWN"
local artist = "Choma41"
local charter = "Unknown"
local iconColor = "FF7E7E"
local skipped = false
local shown = false

local boxW = 620
local boxH = 220
local boxX = (1280 - boxW) / 2
local boxY = (720 - boxH) / 2

local titleSize = 75
if #songTitle > 14 then
	titleSize = 34
elseif #songTitle > 10 then
	titleSize = 44
elseif #songTitle > 7 then
	titleSize = 58
end

function showCredits()
	if shown then return end
	shown = true

	makeGraphic('creditsBG', boxW, boxH, '#000000')
	addLuaSprite('creditsBG', true)
	setObjectCamera('creditsBG', 'camHUD')
	setProperty('creditsBG.x', boxX)
	setProperty('creditsBG.y', boxY)
	setProperty('creditsBG.alpha', 0)

	makeGraphic('creditsAccent', boxW, 8, '#' .. iconColor)
	addLuaSprite('creditsAccent', true)
	setObjectCamera('creditsAccent', 'camHUD')
	setProperty('creditsAccent.x', boxX)
	setProperty('creditsAccent.y', boxY)
	setProperty('creditsAccent.alpha', 0)

	makeLuaText('creditsTitle', songTitle, boxW - 40, boxX + 20, boxY + 55)
	setTextSize('creditsTitle', titleSize)
	setTextAlignment('creditsTitle', 'center')
	setTextColor('creditsTitle', '#' .. iconColor)
	setTextBorder('creditsTitle', 2, '#000000')
	addLuaText('creditsTitle')
	setObjectCamera('creditsTitle', 'camHUD')
	setProperty('creditsTitle.alpha', 0)

	makeLuaText('creditsArtist', 'Music by ' .. artist, boxW - 80, boxX + 40, boxY + 160)
	setTextSize('creditsArtist', 22)
	setTextAlignment('creditsArtist', 'center')
	setTextColor('creditsArtist', 'FFFFFF')
	setTextBorder('creditsArtist', 2, '#000000')
	addLuaText('creditsArtist')
	setObjectCamera('creditsArtist', 'camHUD')
	setProperty('creditsArtist.alpha', 0)

	makeLuaText('creditsCharter', 'Charted by ' .. charter, boxW - 80, boxX + 40, boxY + 186)
	setTextSize('creditsCharter', 22)
	setTextAlignment('creditsCharter', 'center')
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

function goodNoteHit(id)
	showCredits()
end

function opponentNoteHit(id)
	showCredits()
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
