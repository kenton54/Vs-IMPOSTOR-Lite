---Gets all the running scripts.
---@return table # All running scripts's directory location.
function getRunningScripts()
    return {}
end

---Sets a variable with a value to all running Lua and Haxe scripts.
---@param varName string The name of the variable.
---@param arg any The variable's value.
---@param ignoreSelf? boolean Whether to not set the variable to the script running this function. Defaults to `false`.
---@param exclusions? table A table holding the scripts that won't have the variable.
function setOnScripts(varName, arg, ignoreSelf, exclusions)
end

---Sets a variable with a value to all running Haxe scripts.
---@param varName string The name of the variable.
---@param arg any The variable's value.
---@param ignoreSelf? boolean Whether to not set the variable to the script running this function. Defaults to `false`.
---@param exclusions? table A table holding the scripts that won't have the variable.
function setOnHScript(varName, arg, ignoreSelf, exclusions)
end

---Sets a variable with a value to all running Lua scripts.
---@param varName string The name of the variable.
---@param arg any The variable's value.
---@param ignoreSelf? boolean Whether to not set the variable to the script running this function. Defaults to `false`.
---@param exclusions? table A table holding the scripts that won't have the variable.
function setOnLuas(varName, arg, ignoreSelf, exclusions)
end

---Calls a function to all running scripts.
---@param funcName string The function to call and execute.
---@param args? table The arguments of the function.
---@param ignoreStops? boolean Whether the stops that any of the functions return should be ignored. Defaults to `false`.
---@param ignoreSelf? boolean Whether to not call the function to the script running this function. Defaults to `true`.
---@param excludeScripts? table A table holding the scripts that the function won't get called.
---@param excludeValues? table A table holding the return values that should be ignored.
---@return any # A value that any of the functions returned.
function callOnScripts(funcName, args, ignoreStops, ignoreSelf, excludeScripts, excludeValues)
    return nil
end

---Calls a function to all running Lua scripts.
---@param funcName string The function to call and execute.
---@param args? table The arguments of the function.
---@param ignoreStops? boolean Whether the stops that any of the functions return should be ignored. Defaults to `false`.
---@param ignoreSelf? boolean Whether to not call the function to the script running this function. Defaults to `true`.
---@param excludeScripts? table A table holding the scripts that the function won't get called.
---@param excludeValues? table A table holding the return values that should be ignored.
---@return any # A value that any of the functions returned.
function callOnLuas(funcName, args, ignoreStops, ignoreSelf, excludeScripts, excludeValues)
    return nil
end

---Calls a function to all running Haxe scripts.
---@param funcName string The function to call and execute.
---@param args? table The arguments of the function.
---@param ignoreStops? boolean Whether the stops that any of the functions return should be ignored. Defaults to `false`.
---@param ignoreSelf? boolean Whether to not call the function to the script running this function. Defaults to `true`.
---@param excludeScripts? table A table holding the scripts that the function won't get called.
---@param excludeValues? table A table holding the return values that should be ignored.
---@return any # A value that any of the functions returned.
function callOnHScript(funcName, args, ignoreStops, ignoreSelf, excludeScripts, excludeValues)
    return nil
end

---Calls a function to a specific script.
---@param scriptFile string The script to call the function.
---@param funcName string The function to call and execute.
---@param args? table The arguments of the function.
---@return any # A value that the function returned.
function callScript(scriptFile, funcName, args)
    return nil
end

---Checks whether a script is running.
---@param scriptFile string The script to check for.
---@return boolean # Whether the script is running.
function isRunning(scriptFile)
    return false
end

---Sets a variable with a value to the global variable map.
---@param varName string The name of the variable.
---@param value any The variable's value.
---@return any # The passed value.
function setVar(varName, value)
    return nil
end

---Retrieves a variable's value from the global variable map.
---@param varName string The name of the variable.
---@return any # The value of the variable, or `nil` if the variable doesn't exist.
function getVar(varName)
    return nil
end

---Loads a Lua script.
---@param luaFile string The Lua script to run.
---@param ignoreAlreadyRunning? boolean Whether to rerun the Lua script if it's already running. Defaults to `false`.
function addLuaScript(luaFile, ignoreAlreadyRunning)
end

---Loads a Haxe script.
---@param luaFile string The Haxe script to run (ignore the argument name).
---@param ignoreAlreadyRunning? boolean Whether to rerun the Haxe script if it's already running. Defaults to `false`.
function addHScript(luaFile, ignoreAlreadyRunning)
end

---Stops a Lua script from running.
---@param luaFile string The Lua script to stop.
---@return boolean # Whether if it was successful on stopping the script or not.
function removeLuaScript(luaFile)
    return false
end

---Stops a Haxe script from running.
---@param scriptFile string The Haxe script to stop.
---@return boolean # Whether if it was successful on stopping the script or not.
function removeHScript(scriptFile)
    return false
end

---Loads a song onto PlayState and begins gameplay immediately.
---@param name? string The song to play. Defaults to the one thats already playing.
function loadSong(name)
end

---Checks whether the mouse has been clicked.
---@param button? MouseButton The type of mouse button to check for. Defaults to `left`.
---@return boolean # Whether the mouse button was clicked.
function mouseClicked(button)
    return false
end

---Checks whether the mouse is being pressed.
---@param button? MouseButton The type of mouse button to check for. Defaults to `left`.
---@return boolean # Whether the mouse button is being pressed.
function mousePressed(button)
    return false
end

---Checks whether the mouse stopped clicking.
---@param button? MouseButton The type of mouse button to check for. Defaults to `left`.
---@return boolean # Whether the mouse button stopped clicking.
function mouseReleased(button)
    return false
end

---Starts a timer. Once the timer is completed, it calls the function `onTimerCompleted`, with the first argument value as the `tag` value.
---@param tag string The tag of the timer.
---@param time? number How long it takes for the timer to complete, in seconds. Defaults to `1`.
---@param loops? integer How many loops should the timer do. Defaults to `1`.
function runTimer(tag, time, loops)
end

---Cancels any active timer.
---@param tag string The tag of the timer.
function cancelTimer(tag)
end

---Adds a specific amount of score to the player's score.
---@param value integer The amount to add to the player's score.
function addScore(value)
end

---Adds a specific amount of misses to the player's misses counter.
---@param value integer The amount to add to the player's misses counter.
function addMisses(value)
end

---Adds a specific amount of note hits to the player's note hits counter.
---@param value integer The amount to add to the player's note hits counter.
function addHits(value)
end

---Sets the player's score.
---@param value integer The amount to set to the player's score.
function setScore(value)
end

---Sets the player's misses amount.
---@param value integer The amount to set to the player's misses counter.
function setMisses(value)
end

---Sets the player's note hits amount.
---@param value integer The amount to set to the player's note hits counter.
function setHits(value)
end

---Sets the player's health value.
---@param value number The amount to set to the player's health.
function setHealth(value)
end

---Adds a specific amount of health to the player's health value.
---@param value number The amount to add to the player's health.
function addHealth(value)
end

---Gets the player's current health value.
---@return number # The player's current health value.
function getHealth()
    return 0.0
end

---Converts a string to a color.
---@param color string The color, as a string. Can be formatted as a hxedecimal value (`#FFFFFF`), bytes (`0xFFFFFF`), or the name of a color (`WHITE`).
---@return integer # The value of the color.
function FlxColor(color)
    return -1
end

---Converts a string to a color.
---@param color string The name of a color, for example: `WHITE`.
---@return integer # The value of the color.
function getColorFromName(color)
    return -1
end

---Converts a string to a color.
---@param color string The color, as a string. Can be formatted as a hxedecimal value (`#FFFFFF`), bytes (`0xFFFFFF`), or the name of a color (`WHITE`).
---@return integer # The value of the color.
function getColorFromString(color)
    return -1
end

---Converts a string to a color.
---@param color string The hxedecimal value of the color, as a string, for example: `#FFFFFF`.
---@return integer # The value of the color.
function getColorFromHex(color)
    return -1
end

---@alias MouseButton
---| `left`
---| `middle`
---| `right`
