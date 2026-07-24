---Creates a sprite.
---@param tag string The tag to store the sprite, so it can be retrieved later.
---@param image? string The directory of the image.
---@param x? number The position of the sprite in the X coordinate. Defaults to `0`.
---@param y? number The position of the sprite in the Y coordinate. Defaults to `0`.
function makeLuaSprite(tag, image, x, y)
end

---Creates a sprite with the ability to add animations to it.
---@param tag string The tag to store the sprite, so it can be retrieved later.
---@param image? string The directory of the image.
---@param x? number The position of the sprite in the X coordinate. Defaults to `0`.
---@param y? number The position of the sprite in the Y coordinate. Defaults to `0`.
---@param spriteType? SpriteType The type of sprite. Handles how the frames are loaded onto the sprite. Defaults to `auto`.
function makeAnimatedLuaSprite(tag, image, x, y, spriteType)
end

---Loads a graphic onto a sprite.
---
---When setting the `gridX` or `gridY`, you're saying that the image is a spritesheet, meaning that the sprite can play animations.
---
---To add animations from the spritesheet, use the function `addAnimation`.
---@param tag string The tag of the sprite.
---@param image string The directory of the image.
---@param gridX integer The width of the frame grid, in pixels. Defaults to `0`.
---@param gridY integer The height of the frame grid, in pixels. Defaults to `0`.
function loadGraphic(tag, image, gridX, gridY)
end

---Loads a spritesheet to the sprite, so it can play and display animations.
---@param tag string The tag of the sprite.
---@param image string The directory of the spritesheet.
---@param spriteType SpriteType The type of sprite. Handles how the frames are loaded onto the sprite. Defaults to `auto`.
function loadFrames(tag, image, spriteType)
end

---Loads multiple spritesheets onto the sprite, so it can play and display animations.
---@param tag string The tag of the sprite.
---@param images table A table holding the directories of the spritesheets.
function loadMultipleFrames(tag, images)
end

---Creates a flat-colored rectangle and loads it into a sprite.
---
---Unless you want to modify the pixels of the rectangle, I strongly recommend using the function `makeSolid` instead of this one, to improve performance.
---@param tag string The tag of the sprite.
---@param width? integer The width of the rectangle. Defaults to `256`.
---@param height? integer The height of the rectangle. Defaults to `256`.
---@param color? string The color of the rectangle. Defaults to white.
function makeGraphic(tag, width, height, color)
end

---Creates a flat-colored rectangle and loads it into a sprite.
---
---It's faster and more optimized than `makeGraphic`, but it doesn't allow modifying the rectangle's pixels, and scaling doesn't work properly.
---@param tag string The tag of the sprite.
---@param width? integer The width of the rectangle. Defaults to `256`.
---@param height? integer The height of the rectangle. Defaults to `256`.
---@param color? string The color of the rectangle. Defaults to white.
function makeSolid(tag, width, height, color)
end

---Adds an animation to a sprite by matching frame names.
---@param tag string The tag of the sprite.
---@param name string The name of the animation.
---@param prefix string The characters that the internal animation name starts with.
---@param framerate? number The speed of the animation, in frames per second. Defaults to `24`.
---@param loop? boolean Whether the animation should loop indefinitely. Defaults to `true`.
---@param flipX? boolean Whether the animation should be flipped horizontally. Defaults to `false`.
---@param flipY? boolean Whether the animation should be flipped vertically. Defaults to `false`.
function addAnimationByPrefix(tag, name, prefix, framerate, loop, flipX, flipY)
end

---Adds an animation to a sprite by a specific set of frame indexes.
---@param tag string The tag of the sprite.
---@param name string The name of the animation.
---@param frames table The frames indexes that will be added to the animation.
---@param framerate? number The speed of the animation, in frames per second. Defaults to `24`.
---@param loop? boolean Whether the animation should loop indefinitely. Defaults to `true`.
---@param flipX? boolean Whether the animation should be flipped horizontally. Defaults to `false`.
---@param flipY? boolean Whether the animation should be flipped vertically. Defaults to `false`.
function addAnimation(tag, name, frames, framerate, loop, flipX, flipY)
end

---Adds an animation to a sprite by a specific set of frame indexes.
---@param tag string The tag of the sprite.
---@param name string The name of the animation.
---@param prefix string The characters that the internal animation name starts with.
---@param indices any The frames indexes that will be added to the animation.
---@param framerate? number The speed of the animation, in frames per second. Defaults to `24`.
---@param loop? boolean Whether the animation should loop indefinitely. Defaults to `true`.
---@param flipX? boolean Whether the animation should be flipped horizontally. Defaults to `false`.
---@param flipY? boolean Whether the animation should be flipped vertically. Defaults to `false`.
function addAnimationByIndices(tag, name, prefix, indices, framerate, loop, flipX, flipY)
end

---Plays an object's animation.
---@param tag string The tag of the object.
---@param anim string The name of the animation.
---@param forced? boolean Whether to force the animation to play when the same animation is already playing.
---@param reverse? boolean Whether to play the animation in reverse.
---@param startFrame? integer In which frame to start playing the animation.
---@return boolean # Whether the animation started playing successfully.
function playAnim(tag, anim, forced, reverse, startFrame)
    return false
end

---Adds offset to an object's animation.
---@param tag string The tag of the object.
---@param anim string The name of the animation.
---@param x number Horizontal offset.
---@param y number Vertical offset.
---@return boolean # Whether the offsets were set successfully.
function addOffset(tag, anim, x, y)
    return false
end

---Sets the relative scroll of the object.
---
---`==0` = The object stays in place, no mather if the camera moves.
---
---`<1` = The object moves less than the camera, adding depth to the world.
---
---`==1` = The object stays in place and moves along the camera, like it's part of the world.
---
---`>1` = The object moves more than the camera, adding depth to the world.
---@param tag string
---@param scrollX number How much the object scrolls horizontally relative to the camera.
---@param scrollY number How much the object scrolls vertically relative to the camera.
function setScrollFactor(tag, scrollX, scrollY)
end

---Sets the size of an object.
---@param tag string The tag of the object.
---@param x number The width of the object.
---@param y? number The height of the object. Defaults to whatever is set in `x`.
---@param updateHitbox? boolean Whether to update its hitbox automatically. Defaults to `true`.
function setGraphicSize(tag, x, y, updateHitbox)
end

---Scales an object.
---@param tag string The tag of the object.
---@param x number The horizontal scale.
---@param y? number The vertical scale. Defaults to whatever is set in `x`.
---@param updateHitbox? boolean Whether to update its hitbox automatically. Defaults to `true`.
function scaleObject(tag, x, y, updateHitbox)
end

---Updates the hitbox of an object.
---@param tag string The tag of the object.
function updateHitbox(tag)
end

---Sets the camera of an object
---@param tag string The tag of the object.
---@param camera? string The camera. Defaults to the main camera of the current state.
function setObjectCamera(tag, camera)
end

---Sets the blend mode of an object.
---@param tag string The tag of the object.
---@param blend? BlendMode The blend mode. Defaults to `nil`.
function setBlendMode(tag, blend)
end

---Adds an object to the current state.
---@param tag string The tag of the object.
---@param inFront? boolean Whether to add it on top of everything.
function addLuaSprite(tag, inFront)
end

---Adds an object to the current state to the given index.
---@param tag string The tag of the object.
---@param position integer The index of the state to add the object.
function insertLuaSprite(tag, position)
end

---Removes an object from the current state.
---@param tag string The tag of the object.
---@param destroy? boolean Whether to destroy the object. Defaults to `true`.
---@param group? string (Optional) The group to remove the object from.
function removeLuaSprite(tag, destroy, group)
end

---Gets the middle horizontal point of an object.
---@param tag string The tag of the object.
---@return number # The middle horizontal point of the object.
function getMidpointX(tag)
    return 0.0
end

---Gets the middle vertical point of an object.
---@param tag string The tag of the object.
---@return number # The middle vertical point of the object.
function getMidpointY(tag)
    return 0.0
end

---Gets the middle horizontal point of a sprite's graphic.
---@param tag string The tag of the sprite.
---@return number # The middle horizontal point of the sprite's graphic.
function getGraphicMidpointX(tag)
    return 0.0
end

---Gets the middle vertical point of a sprite's graphic.
---@param tag string The tag of the sprite.
---@return number # The middle vertical point of the sprite's graphic.
function getGraphicMidpointY(tag)
    return 0.0
end

---Gets the horizontal position of an object relative to a camera.
---@param tag string The tag of the object.
---@param camera? string The camera. Defaults to the main camera of the current state.
---@return number # The horizontal position of the object relative to the camera.
function getScreenPositionX(tag, camera)
    return 0.0
end

---Gets the vertical position of an object relative to a camera.
---@param tag string The tag of the object.
---@param camera? string The camera. Defaults to the main camera of the current state.
---@return number # The vertical position of the object relative to the camera.
function getScreenPositionY(tag, camera)
    return 0.0
end

---Centers an object on the screen, either by the X axis, Y axis, or both.
---@param tag string The tag of the object.
---@param axes? Axes The axes to center the object to. Defaults to `xy`.
function screenCenter(tag, axes)
end

---Gets the index of an object inside the current state, or a group.
---@param tag string The tag of the object.
---@param group? string In what group to get the index of the object.
---@return integer # The index of the object inside the state or group.
function getObjectOrder(tag, group)
    return -1
end

---Sets the index of an object inside the current state, or a group.
---@param tag string The tag of the object.
---@param position integer The index of the state or group to set the object.
---@param group? string In what group to set the index of the object.
function setObjectOrder(tag, position, group)
end

---Gets the color of a pixel of a sprite's graphic.
---@param tag string The tag of the sprite.
---@param x integer The position of the pixel in the X coordinate.
---@param y integer The position of the pixel in the Y coordinate.
---@return integer # The color of the sprite.
function getPixelColor(tag, x, y)
    return -1
end

---Sets the color of a pixel of a sprite's graphic.
---@param tag string The tag of the sprite.
---@param x integer The position of the pixel in the X coordinate.
---@param y integer The position of the pixel in the Y coordinate.
---@param color string The color to set.
---@return integer # The passed color.
function setPixelColor(tag, x, y, color)
    return -1
end

---Checks whether 2 objects overlap with each other.
---@param tag1 string The tag of the first object.
---@param tag2 string The tag of the second object.
---@return boolean # Whether the 2 objects are overlapping.
function objectsOverlap(tag1, tag2)
    return false
end

---Checks whether 2 objects collide with each other.
---@param tag1 string The tag of the first object.
---@param tag2 string The tag of the second object.
---@return boolean # Whether the 2 objects are colliding.
function objectsCollide(tag1, tag2)
    return false
end

---Creates a class object.
---@param variableToSave string The tag to store the object, so it can be retrieved later.
---@param classVar string The package name of the class.
---@param args table The arguments of the object creation function.
---@return boolean # Whether it was successfully created.
function createInstance(variableToSave, classVar, args)
    return false
end

---Adds a class object to the current state.
---@param objectName string The tag of the object.
---@param inFront boolean Whether to add it on top of everything.
function addInstance(objectName, inFront)
end

---Meant to be used with `callMethod`, `callMethodFromClass`, `createInstance`, `setProperty`, `setPropertyFromClass`, `setPropertyFromGroup` and `setVar`.
---
---Formats a string in a specific way to tell the functions listed above that the string is meant to be an instance.
---
---Usage examples:
---```lua
---callMethod('spawnNoteSplashOnNote', {instanceArg('notes.members[0]')}) -- Spawns a note splash in the first note on screen.
---setVar('leftStrum', {instanceArg('playerStrums.members[0]')}) -- Creates a shortcut to the player's left strum note.
---```
---@param instanceName string The name of the variable.
---@param className? string The package name of the class.
---@return string # The formatted string.
function instanceArg(instanceName, className)
    return ""
end

---Checks whether an object exists.
---@param tag string The tag of the object.
---@return boolean # Whether the object exists or not.
function luaSpriteExists(tag)
    return false
end

---@alias SpriteType
---| `asprite`
---| `ase`
---| `json`
---| `packer`
---| `packeratlas`
---| `pac`
---| `sparrow`
---| `sparrowv2`
---| `sparrowatlas`
---| `xml`
---| `auto`

---@alias BlendMode
---| `add`
---| `alpha`
---| `darken`
---| `difference`
---| `erase`
---| `hardlight`
---| `invert`
---| `layer`
---| `lighten`
---| `multiply`
---| `normal`
---| `overlay`
---| `screen`
---| `shader`
---| `subtract`

---@alias Axes
---| `x`
---| `y`
---| `xy`
