function onCreate()
    makeAnimatedLuaSprite("sparky", "characters/sparky", getProperty("gf.x") - 586, getProperty("gf.y") - 384)
    addAnimationByPrefix("sparky", "idle", "BopA", 12, false)
    scaleObject("sparky", getProperty("gf.scale.x"), getProperty("gf.scale.y"))
    addLuaSprite("sparky", false)
    setProperty("sparky.antialiasing", false)
    setObjectOrder("sparky", getObjectOrder("gfGroup"))
end

function onBeatHit()
    playAnim("sparky", "idle", true)
end