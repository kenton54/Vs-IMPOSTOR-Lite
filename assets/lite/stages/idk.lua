function onCreate()
    makeLuaSprite("stage", "bg/idk/background", -1500, -1000)
    scaleObject("stage", 2, 2)
    setProperty("stage.antialiasing", false)
    addLuaSprite("stage")
end
