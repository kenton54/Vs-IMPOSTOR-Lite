local introPlayed = false

function onCreatePost()
    setProperty('defaultCamZoom', 0.65)
    setProperty('camGame.zoom', 0.65)
    setProperty('camHUD.alpha', 0);

    makeLuaSprite('whiteThing', '', 0, 0)
    makeGraphic('whiteThing', 2000, 2000, 'FFFFFF')
    setObjectCamera('whiteThing', 'camOther')
    setProperty('whiteThing.alpha', 1)
    addLuaSprite('whiteThing', false)

    setProperty('isCameraOnForcedPos', true)
end

function onSongStart()
    doTweenAlpha('tweenAlpha', 'whiteThing', 0, 11)
    doTweenZoom('tweenZoom', 'camGame', 0.5, 10.5, 'quadInOut')
    setProperty('camGame.scroll.x', -500)
    setProperty('camGame.scroll.y', -2000)
    setProperty('camFollow.x', -500)
    setProperty('camFollow.y', -2000)
end

local tweened = false
local hudvisible = false

function onStepHit()
    if not introPlayed then
        if curStep >= 32 and not tweened then
            tweened = true
            doTweenY('tweenY', 'camGame.scroll', 0, 9, 'quadInOut')
            setProperty('camFollow.y', 0)
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