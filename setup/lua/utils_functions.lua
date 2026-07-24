---Executes Haxe code.
---
---Examples of usage:
---```lua
---runHaxeCode('game.boyfriend.color = FlxColor.RED;') -- makes the player character red.
---runHaxeCode('game.boyfriend.scale.y = myValue;', {myValue = 1.5}) -- adds the myValue to the Haxe code and uses its value to set the player character's vertical scale
---```
---@param codeToRun string The code to execute.
---@param varsToBring? table A set of values to add to the haxe code interp.
---@param funcToRun? string A function to run when the code is executed.
---@param funcArgs? table The arguments of the function.
---@return any # The Haxe code's return value.
function runHaxeCode(codeToRun, varsToBring, funcToRun, funcArgs)
    return nil
end

---Calls a function to a previously executed Haxe code with the `runHaxeCode` function.
---@param funcToRun string The function to call and execute.
---@param funcArgs? table The arguments of the function.
---@return any # The function's return value.
function runHaxeFunction(funcToRun, funcArgs)
    return nil
end

---Adds a package to a previously executed Haxe code with the `runHaxeCode` function.
---@param libName string The class package name.
---@param libPackage? string The package path leading to the class.
---@deprecated
function addHaxeLibrary(libName, libPackage)
end

---Checks whether a keyboard key was just pressed.
---@param name string The key to check.
---@return boolean # Whether the key was just pressed.
function keyboardJustPressed(name)
    return false
end

---Checks whether a keyboard key is pressed.
---@param name string The key to check.
---@return boolean # Whether the key is pressed.
function keyboardPressed(name)
    return false
end

---Checks whether a keyboard key was just released.
---@param name string The key to check.
---@return boolean # Whether the key was just released.
function keyboardReleased(name)
    return false
end

---Checks whether a gamepad button from all active gamepads was just pressed.
---@param name string The button to check.
---@return boolean # Whether the button was just pressed.
function anyGamepadJustPressed(name)
    return false
end

---Checks whether a gamepad button from all active gamepads is pressed.
---@param name string The button to check.
---@return boolean # Whether the button is pressed.
function anyGamepadPressed(name)
    return false
end

---Checks whether a gamepad button from all active gamepads was just released.
---@param name string The button to check.
---@return boolean # Whether the button was just released.
function anyGamepadReleased(name)
    return false
end

---Gets the current horizontal position of a gamepad's analog stick.
---@param id integer The ID of the gamepad. For example: `0` is for the first active gamepad.
---@param leftStick? boolean Whether to get the position from the left analog stick. Defaults to `true`.
---@return number # The horizontal position of the analog stick.
function gamepadAnalogX(id, leftStick)
    return 0.0
end

---Gets the current vertical position of a gamepad's analog stick.
---@param id integer The ID of the gamepad. For example: `0` is for the first active gamepad.
---@param leftStick? boolean Whether to get the position from the left analog stick. Defaults to `true`.
---@return number # The vertical position of the analog stick.
function gamepadAnalogY(id, leftStick)
    return 0.0
end

---Checks whether a gamepad button from a specific gamepad was just pressed.
---@param id integer The ID of the gamepad. For example: `0` is for the first active gamepad.
---@param name string The button to check.
---@return boolean # Whether the button was just pressed.
function gamepadJustPressed(id, name)
    return false
end

---Checks whether a gamepad button from a specific gamepad is pressed.
---@param id integer The ID of the gamepad. For example: `0` is for the first active gamepad.
---@param name string The button to check.
---@return boolean # Whether the button is pressed.
function gamepadPressed(id, name)
    return false
end

---Checks whether a gamepad button from a specific gamepad was just released.
---@param id integer The ID of the gamepad. For example: `0` is for the first active gamepad.
---@param name string The button to check.
---@return boolean # Whether the button was just released.
function gamepadReleased(id, name)
    return false
end

---Checks whether a key was just pressed.
---@param name string The key to check.
---@return boolean # Whether the key was just pressed.
function keyJustPressed(name)
    return false
end

---Checks whether a key is pressed.
---@param name string The key to check.
---@return boolean # Whether the key is pressed.
function keyPressed(name)
    return false
end

---Checks whether a key was just released.
---@param name string The key to check.
---@return boolean # Whether the key was just released.
function keyReleased(name)
    return false
end

---Instantiates custom save data.
---
---The save data gets saved in the directory:
--- - Windows: `C:\Users\<username>\AppData\Roaming\<folder>\<name>.sol`
--- - Linux: `/home/<username>/.local/share/<folder>/<name>.sol`
--- - Mac: `/Users/<username>/Library/Application Support/<folder>/<name>.sol`
---@param name string The name of the save data.
---@param folder string The folder to store the save data.
function initSaveData(name, folder)
end

---Flushes and saves custom save data.
---@param name string The name of the custom save data.
function flushSaveData(name)
end

---Gets a value from custom save data.
---@param name string The name of the custom save data.
---@param field string The variable inside the data.
---@param defaultValue? any A fallback value, in case the function fails to retrieve the value from the save data.
---@return any # The value of the variable inside the save data.
function getDataFromSave(name, field, defaultValue)
    return nil
end

---Sets a value of custom save data.
---@param name string The name of the custom save data.
---@param field string The variable inside the data.
---@param value any The value to set.
function setDataFromSave(name, field, value)
end

---Deletes custom save data.
---@param name string The name of the custom save data.
function eraseSaveData(name)
end

---Checks whether a file exists.
---@param filename string The directory leading to the file, including the file extension.
---@param absolute? boolean Whether the path you insert is absolute or a shortcut. Defaults to `false`.
---@return boolean # Whether the file exists.
function checkFileExists(filename, absolute)
    return false
end

---Gets the contents of a file.
---@param path string The directory leading to the file, including the file extension.
---@return string # The contents of the file, as a string.
function getTextFromFile(path)
    return ""
end

---Lists all the files inside a folder.
---@param folder string The directory leading to the folder.
---@return table # The files inside the folder.
function directoryFileList(folder)
    return {}
end

---Checks whether a string starts with a specific value.
---@param str string The string to check.
---@param start string The value to check.
---@return boolean # Whether the string starts with the string `start`.
function stringStartsWith(str, start)
    return false
end

---Checks whether a string ends with a specific value.
---@param str string The string to check.
---@param endW string The value to check.
---@return boolean # Whether the string end with the string `start`.
function stringEndsWith(str, endW)
    return false
end

---Split a string at each occurance of `split`.
---
---If no ocurrance of `split` is found, it returns a table with the passed string.
---@param str string The string to split.
---@param split string The characters to check to split the string.
---@return table # A table holding all of the splitted string parts.
function stringSplit(str, split)
    return {}
end

---Removes any leading and trailing spaces from the string.
---@param str string The string to trim.
---@return string # The trimmed string.
function strimTrim(str)
    return ""
end

---Gets a random integer value.
---@param min integer The minimum value that can be returned.
---@param max? integer The maximum value that can be returned. Defaults to the 32-bit integer limit (`2147483647`).
---@param exclude? string A string holding values that should not be returned. Each integer value must be separated with a comma, like `"1, 2, 3"`.
---@return integer # A random integer value.
function getRandomInt(min, max, exclude)
    return 0
end

---Gets a random float value.
---@param min number The minimum value that can be returned.
---@param max? number The maximum value that can be returned. Defaults to `1`.
---@param exclude? string A string holding values that should not be returned. Each integer value must be separated with a comma, like `"1.0, 2.5, 4.2"`.
---@return number # A random float value.
function getRandomFloat(min, max, exclude)
    return 0.0
end

---Randomizes the chances of returning `true`.
---@param chance number The chances of returning `true`. Must be a number between `0` and `100`.
---@return boolean # Randomly returns `true`.
function getRandomBool(chance)
    return false
end
