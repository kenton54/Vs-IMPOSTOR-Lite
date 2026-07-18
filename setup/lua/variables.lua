--- Stops subsequent lua scripts from getting the same named function executed.
--- 
--- Redundant in HScript, since it has lower priority.
--- @type string
Function_StopLua = "##PSYCHLUA_FUNCTIONSTOPLUA"

--- Stops subsequent haxe scripts from getting the same named function executed.
--- @type string
Function_StopHScript = "##PSYCHLUA_FUNCTIONSTOPHSCRIPT"

--- Stops all subsequent scripts from getting the same named function executed.
--- @type string
Function_StopAll = "##PSYCHLUA_FUNCTIONSTOPALL"

--- Stops the function's base behavior from running, if it allows it.
--- @type string
Function_Stop = "##PSYCHLUA_FUNCTIONSTOP"

--- Allows the function to run its base behavior from running.
--- @type string
Function_Continue = "##PSYCHLUA_FUNCTIONCONTINUE"

--- Toggles showing errors.
--- @type boolean
luaDebugMode = false

--- Warns about the script using deprecated functions, and shows you their updated alternative.
--- 
--- Requires `luaDebugMode` to be enabled.
--- @type boolean
luaDeprecatedWarnings = true

--- Psych Engine's version.
--- @type string
version = "0.7.3"

--- The operating system running the game.
--- @type BuildTarget
buildTarget = "windows"

--- The type of device running the game.
--- @type PlatformTarget
platformTarget = "desktop"

--- Where the Lua Script running is located.
--- @type string
scriptName = ""

--- The width of the game screen, in pixels.
--- @type integer
screenWidth = 1200

--- The height of the game screen, in pixels.
--- @type integer
screenHeight = 900

--- The name of the current song.
--- @type string
songName = "Sussus Moongus"

--- The internal name of the current song.
--- @type string
songPath = "sussus-moongus"

--- The starting BPM of the current song.
--- @type number
bpm = 100

--- The length of the current song, in milliseconds.
--- @type number
songLength = 0

--- Whether the countdown has started.
--- @type boolean
startedCountdown = false

--- Whether the player has already watched a cutscene.
--- @type boolean
seenCutscene = false

--- Whether the player is currently in the game over screen.
--- @type boolean
inGameOver = false

--- The current stage background.
--- @type string
curStage = "stage"

--- The scroll speed of the chart.
--- @type number
scrollSpeed = 1

--- Whether the song has vocals enabled.
--- @type boolean
hasVocals = true

--- The ID of the current song's difficulty.
--- @type integer
difficulty = 1

--- The name of the current song's difficulty.
--- @type string
difficultyName = "normal"

--- The internal name of the current song's difficulty.
--- @type string
difficultyPath = "normal"

--- Whether the player is playing the song from Story Mode.
--- @type boolean
isStoryMode = false

--- The ID of the current week.
--- @type integer
weekRaw = 1

--- The internal name of the current week.
--- @type string
week = "week1"

--- The current BPM of the current song.
--- @type number
curBPM = 100

--- The current section of the current song.
--- @type integer
curSection = 0

--- The current beat of the current song.
--- @type integer
curBeat = 0

--- The current step of the current song.
--- @type integer
curStep = 0

--- The current decimal beat of the current song.
--- @type number
curDecBeat = 0

--- The current decimal step of the current song.
--- @type number
curDecStep = 0

--- How long a beat takes in the current section, in milliseconds.
--- @type number
crochet = 0

--- How long a step takes in the current section, in milliseconds.
--- @type number
stepCrochet = 0

--- Whether the current section is focused on the player.
--- @type boolean
mustHitSection = false

--- Whether the current section plays alternate singing animations when pressing a note.
--- @type boolean
altAnim = false

--- Whether the current section is focused on girlfriend.
--- @type boolean
gfSection = false

--- The speed of the song playback.
--- @type number
playbackRate = 1

--- How much does the health gain multiplies.
--- @type number
healthGainMult = 1

--- How much does the health loss multiplies.
--- @type number
healthLossMult = 1

--- Whether the player immediately when missing a note.
--- @type boolean
instakillOnMiss = false

--- Whether Practice Mode is enabled.
--- @type boolean
practice = false

--- Whether Botplay Mode is enabled.
--- @type boolean
botPlay = false

--- The default position of the player's 1st strum note in the X coordinate.
--- @type number
defaultPlayerStrumX0 = 732

--- The default position of the player's 1st strum note in the Y coordinate.
--- @type number
defaultPlayerStrumY0 = 50

--- The default position of the player's 2nd strum note in the X coordinate.
--- @type number
defaultPlayerStrumX1 = 884

--- The default position of the player's 2nd strum note in the Y coordinate.
--- @type number
defaultPlayerStrumY1 = 50

--- The default position of the player's 3rd strum note in the X coordinate.
--- @type number
defaultPlayerStrumX2 = 956

--- The default position of the player's 3rd strum note in the Y coordinate.
--- @type number
defaultPlayerStrumY2 = 50

--- The default position of the player's 4th strum note in the X coordinate.
--- @type number
defaultPlayerStrumX3 = 1068

--- The default position of the player's 4th strum note in the Y coordinate.
--- @type number
defaultPlayerStrumY3 = 50

--- The default position of the opponent's 1st strum note in the X coordinate.
--- @type number
defaultOpponentStrumX0 = 92

--- The default position of the opponent's 1st strum note in the Y coordinate.
--- @type number
defaultOpponentStrumY0 = 50

--- The default position of the opponent's 2nd strum note in the X coordinate.
--- @type number
defaultOpponentStrumX1 = 204

--- The default position of the opponent's 2nd strum note in the Y coordinate.
--- @type number
defaultOpponentStrumY1 = 50

--- The default position of the opponent's 3rd strum note in the X coordinate.
--- @type number
defaultOpponentStrumX2 = 316

--- The default position of the opponent's 3rd strum note in the Y coordinate.
--- @type number
defaultOpponentStrumY2 = 50

--- The default position of the opponent's 4th strum note in the X coordinate.
--- @type number
defaultOpponentStrumX3 = 428

--- The default position of the opponent's 4th strum note in the Y coordinate.
--- @type number
defaultOpponentStrumY3 = 50

--- The default position of the player character in the X coordinate.
--- @type number
defaultBoyfriendX = 770

--- The default position of the player character in the Y coordinate.
--- @type number
defaultBoyfriendY = 100

--- The default position of the opponent character in the X coordinate.
--- @type number
defaultOpponentX = 100

--- The default position of the opponent character in the Y coordinate.
--- @type number
defaultOpponentY = 100

--- The default position of the girlfriend character in the X coordinate.
--- @type number
defaultGirlfriendX = 400

--- The default position of the girlfriend character in the Y coordinate.
--- @type number
defaultGirlfriendY = 130

--- The internal name of the current player character.
--- @type string
boyfriendName = "bf"

--- The internal name of the current opponent character.
--- @type string
dadName = "dad"

--- The internal name of the current girlfriend character.
--- @type string
gfName = "gf"

--- Whether the notes are going down, instead of up.
--- @type boolean
downscroll = false

--- Whether the notes are centered.
--- @type boolean
middlescroll = false

--- The game's framerate.
--- @type number
framerate = 60

--- Whether ghost tapping is enabled.
--- 
--- Makes it so pressing a key while there're no notes won't cause a miss.
--- @type boolean
ghostTapping = true

--- Whether most elements of the HUD are hidden.
--- @type boolean
hideHud = true

--- The type of time bar the game is showing.
--- @type TimeBarType
TimeBarType = "Time Left"

--- Whether the score text bops when a note is pressed.
--- @type boolean
scoreZoom = true

--- Whether the camera showing the HUD bops along the song's beat.
--- @type boolean
cameraZoomOnBeat = true

--- Whether flashing lights are enabled.
--- @type boolean
flashingLights = true

--- How much the song is offset, in milliseconds.
--- @type number
noteOffset = 0

--- The health bar's opacity.
--- @type number
healthBarAlpha = 1

--- Whether the reset button is disabled.
--- @type boolean
noResetButton = false

--- Whether low quality is enabled.
--- @type boolean
lowQuality = false

--- Whether shaders are enabled.
--- @type boolean
shadersEnabled = true

--- Whether sustain notes act as one single note.
--- @type boolean
guitarHeroSustains = true

--- The type of skin the notes are using to render.
--- @type string
noteSkin = "Default"

--- The type of skin the spalshes are using to render.
--- @type string
splashSkin = "Psych"

--- The note splashes's opacity.
--- @type number
splashAlpha = 0.6

--- The notes skin's suffix.
--- 
--- For example: `-future`, `-chip`. Empty for `Default`.
--- @type string
noteSkinPostfix = ""

--- The notes skin's suffix.
---
--- For example: `-diamong`, `-vanilla`. Empty for `Psych`.
--- @type string
splashSkinPostfix = ""

---@alias BuildTarget
---| `windows`
---| `linux`
---| `mac`
---| `browser`
---| `android`
---| `ios`
---| `switch`
---| `unknown`

---@alias PlatformTarget
---| `desktop`
---| `mobile`
---| `web`
---| `console`
---| `unknown`

---@alias TimeBarType
---| `Disabled`
---| `Time Left`
---| `Time Elapsed`
---| `Song Name`
