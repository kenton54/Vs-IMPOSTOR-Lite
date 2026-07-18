local introPlayed = false

function onCreatePost()
    setProperty('defaultCamZoom', 0.65)
    setProperty('camGame.zoom', 0.65)
    setProperty('camHUD.alpha', 0)

    makeLuaSprite('whiteThing', nil, 0, 0)
    makeSolid('whiteThing', screenWidth, screenHeight, 'FFFFFF')
    setObjectCamera('whiteThing', 'camOther')
    setProperty('whiteThing.alpha', 1)
    addLuaSprite('whiteThing', true)

    setProperty('isCameraOnForcedPos', true)
end

function onSongStart()
    doTweenAlpha('tweenAlpha', 'whiteThing', 0, 11)
    doTweenZoom('tweenZoom', 'camGame', 0.5, 10.5, 'quadInOut')
    setProperty('camGame.scroll.x', -500)
    setProperty('camGame.scroll.y', -2000)
    setProperty('camFollow.x', -500)
    setProperty('camFollow.y', -2000)

    setProperty('isCameraOnForcedPos', true)
end

local tweened = false
local hudvisible = false

function onStepHit()
    if not introPlayed then
        if curStep >= 32 and not tweened then
            tweened = true
            doTweenY('tweenY', 'camGame.scroll', 100, 9, 'quadInOut')
        end
        if curStep >= 112 and not hudvisible then
            hudvisible = true
            doTweenAlpha('tweenAlpha', 'camHUD', 1, 1)
        end
        if curStep >= 127 then
            setProperty('isCameraOnForcedPos', false)
        end
        if curStep >= 128 then
            introPlayed = true
            cancelTween('tweenY')
            setProperty('defaultCamZoom', 0.6)
        end
    end
end

function onTweenCompleted(t)
    if t == 'tweenZoom' then
        setProperty('defaultCamZoom', getProperty('camGame.zoom'))
    end
end
