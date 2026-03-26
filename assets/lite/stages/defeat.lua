local positionFixV4 = {
    x = -440,
    y = -180
}

function onCreate()
    makeLuaSprite("blackBG", nil, -2600, -1900)
    makeGraphic("blackBG", screenWidth * 2, screenHeight * 2, "000000")
    scaleObject("blackBG", 2.2, 2.2)
    addLuaSprite("blackBG")

    makeLuaSprite("mainBG", "bg/defeat/main", -1700, -1400)
    scaleObject("mainBG", 2.2, 2.2)
    addLuaSprite("mainBG")

    makeAnimatedLuaSprite("legacyBG", "bg/defeat/legacy-defeat", -400 + positionFixV4.x, -150 + positionFixV4.y)
    addAnimationByPrefix("legacyBG", "bop", "defeat", 24, false)
    playAnim("legacyBG", "bop")
    setGraphicSize("legacyBG", getProperty("legacyBG.width") * 1.3, 0, false)
    setScrollFactor("legacyBG", 0.8, 0.8)
    setProperty("legacyBG.antialiasing", true)
    setProperty("legacyBG.visible", false)
    addLuaSprite("legacyBG")

    makeLuaSprite("bgCorpses", "bg/defeat/bg-corpses", -1520, -600)
    scaleObject("bgCorpses", 2, 2)
    setProperty("bgCorpses.alpha", 0)
    addLuaSprite("bgCorpses")

    makeLuaSprite("legacyBGCorpses", "bg/defeat/legacy-bgCorpses", -560 + positionFixV4.x, 118 + positionFixV4.y)
    setGraphicSize("legacyBGCorpses", getProperty("bgCorpses.width") * 1, 0, false)
    setScrollFactor("legacyBGCorpses", 0.9, 0.9)
    setProperty("legacyBGCorpses.antialiasing", true)
    setProperty("legacyBGCorpses.visible", false)
    addLuaSprite("legacyBGCorpses")

    makeLuaSprite("legacyBackCorpses", "bg/defeat/legacycorpses-bg", -2760 + positionFixV4.x, 0 + positionFixV4.y)
    setGraphicSize("legacyBackCorpses", getProperty("legacyBackCorpses.width") * 0.4, 0, false)
    setScrollFactor("legacyBackCorpses", 0.9, 0.9)
    setProperty("legacyBackCorpses.antialiasing", true)
    setProperty("legacyBackCorpses.visible", false)
    addLuaSprite("legacyBackCorpses")

    makeLuaSprite("light", "bg/defeat/light", -1480, -1200)
    scaleObject("light", 2, 2)
    setScrollFactor("light", 0.9, 0.9)
    setBlendMode("light", "add")
    setProperty("light.alpha", 0)
    addLuaSprite("light", true)

    makeLuaSprite("leftCorpses", "bg/defeat/left-corpses", -2220, -440)
    scaleObject("leftCorpses", 2.8, 2.8)
    setScrollFactor("leftCorpses", 1.6, 1.6)
    setProperty("leftCorpses.alpha", 0)
    addLuaSprite("leftCorpses", true)

    makeLuaSprite("rightCorpses", "bg/defeat/right-corpses", -890, -480)
    scaleObject("rightCorpses", 2.8, 2.8)
    setScrollFactor("rightCorpses", 1.6, 1.6)
    setProperty("rightCorpses.alpha", 0)
    addLuaSprite("rightCorpses", true)

    makeLuaSprite("legacyFrontCorpses", "bg/defeat/legacycorpses-fg", -2700 + positionFixV4.x, 0 + positionFixV4.y)
    setGraphicSize("legacyFrontCorpses", getProperty("legacyFrontCorpses.width") * 0.4, 0, false)
    setScrollFactor("legacyFrontCorpses", 0.5, 1)
    setProperty("legacyFrontCorpses.antialiasing", true)
    setProperty("legacyFrontCorpses.visible", false)
    addLuaSprite("legacyFrontCorpses", true)

    makeLuaSprite("legacyLight", "bg/defeat/legacy-glow", -550, -100)
    setProperty("legacyLight.antialiasing", true)
    setBlendMode("legacyLight", "add")
    setProperty("legacyLight.visible", false)
    addLuaSprite("legacyLight", true)

    makeLuaSprite("vignette", "bg/defeat/vignette", 0, 0)
    setGraphicSize("vignette", screenWidth, screenHeight)
    setObjectCamera("vignette", "hud")
    setBlendMode("vignette", "screen")
    setProperty("vignette.alpha", 0)
    addLuaSprite("vignette")
end

function onBeatHit()
    if curBeat % 4 == 0 then
        playAnim("legacyBG", "bop", true)
    end
end
