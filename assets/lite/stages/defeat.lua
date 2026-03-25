function onCreate()
    makeLuaSprite("blackBG", nil, -2600, -1900)
    makeGraphic("blackBG", screenWidth * 2, screenHeight * 2, "000000")
    scaleObject("blackBG", 2.2, 2.2)
    addLuaSprite("blackBG")

    makeLuaSprite("mainBG", "bg/defeat/main", -1700, -1400)
    scaleObject("mainBG", 2.2, 2.2)
    addLuaSprite("mainBG")

    --[[
    makeLuaSprite("bgCorpses", "bg/defeat/bg-corpses", -1700, -1200)
    scaleObject("bgCorpses", 4.2, 4)
    setProperty("bgCorpses.angle", -4)
    addLuaSprite("bgCorpses")
    ]]

    makeLuaSprite("light", "bg/defeat/light", -1480, -1200)
    scaleObject("light", 2, 2)
    setScrollFactor("light", 0.9, 0.9)
    setBlendMode("light", "add")
    addLuaSprite("light", true)

    makeLuaSprite("leftCorpses", "bg/defeat/left-corpses", -2200, -440)
    scaleObject("leftCorpses", 2.8, 2.8)
    setScrollFactor("leftCorpses", 1.6, 1.6)
    addLuaSprite("leftCorpses", true)

    makeLuaSprite("rightCorpses", "bg/defeat/right-corpses", -890, -480)
    scaleObject("rightCorpses", 2.8, 2.8)
    setScrollFactor("rightCorpses", 1.6, 1.6)
    addLuaSprite("rightCorpses", true)

    makeLuaSprite("vignette", "bg/defeat/vignette", 0, 0)
    setGraphicSize("vignette", screenWidth, screenHeight)
    setObjectCamera("vignette", "hud")
    setBlendMode("vignette", "screen")
    setProperty("vignette.alpha", 0)
    addLuaSprite("vignette")
end
