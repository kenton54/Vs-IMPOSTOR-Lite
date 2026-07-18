---Returns the value of an object's variable, or a variable of PlayState.
---@param variable string The name of the variable.
---@param checkForMaps? boolean Whether to check maps with matching names. Defaults to `false`.
---@return any # The value of the variable.
function getProperty(variable, checkForMaps)
    return nil
end

---Sets the value of an object's variable, or a variable of PlayState.
---@param variable string The name of the variable.
---@param value any The value to set to the variable.
---@param checkForMaps? boolean Whether to check maps with matching names. Defaults to `false`.
---@return any # The passed value.
function setProperty(variable, value, checkForMaps)
    return nil
end

---Returns the value of a class's variable.
---@param classVar string The package name of the class.
---@param variable string The name of the variable inside the class.
---@param checkForMaps? boolean Whether to check maps with matching names. Defaults to `false`.
---@return any # The value of the variable.
function getPropertyFromClass(classVar, variable, checkForMaps)
    return nil
end

---Sets the value of a class's variable.
---@param classVar string The package name of the class.
---@param variable string The name of the variable inside the class.
---@param value any The value to set to the variable.
---@param checkForMaps? boolean Whether to check maps with matching names. Defaults to `false`.
---@return any # The passed value.
function setPropertyFromClass(classVar, variable, value, checkForMaps)
    return nil
end

---Returns the value of a group object's variable.
---@param group string The variable name of the group.
---@param index integer The position of the object inside the group.
---@param variable string The name of the variable inside the object.
---@param checkForMaps? boolean Whether to check maps with matching names. Defaults to `false`.
---@return any # The value of the variable.
function getPropertyFromGroup(group, index, variable, checkForMaps)
    return nil
end

---Sets the value of a group object's variable.
---@param group string The variable name of the group.
---@param index integer The index of the object inside the group.
---@param variable string The name of the variable inside the object.
---@param value any The value to set to the variable.
---@param checkForMaps? boolean Whether to check maps with matching names. Defaults to `false`.
---@param allowInstances? boolean Uses `instanceArg` to check for values. Defaults to `false`.
---@return any # The passed value.
function setPropertyFromGroup(group, index, variable, value, checkForMaps, allowInstances)
    return nil
end

---Adds an object to a group.
---@param group string The variable name of the group.
---@param tag string The tag of the object.
---@param index? integer Whether to add the object to a specific index inside the group. Defaults to `-1`.
function addToGroup(group, tag, index)
end

---Removes an object to a group.
---@param group string The variable name of the group.
---@param index? integer Position of the object inside the group. Defaults to `-1`.
---@param tag? string  The tag of the object.
---@param destroy? boolean Whether to destroy the object.
function removeFromGroup(group, index, tag, destroy)
end

---Calls the function.
---@param funcToRun string The name of the function.
---@param args? table The arguments of the function. Defaults to an empty table.
---@return any # The returnable value of the function, if it has one.
function callMethod(funcToRun, args)
    return nil
end

---Calls the function from the class.
---@param classVar string The package name of the class.
---@param funcToRun string The name of the function.
---@param args? table The arguments of the function. Defaults to an empty table.
---@return any # The returnable value of the function, if it has one.
function callMethodFromClass(classVar, funcToRun, args)
    return nil
end
