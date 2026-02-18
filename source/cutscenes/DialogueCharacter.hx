package cutscenes;

import openfl.utils.Assets;
import tjson.TJSON;

class DialogueCharacter extends FlxSprite
{
    public static final DEFAULT_CHARACTER:String = "bf";

    public var data(default, null):DialogueCharacterData;

    public var curCharacter(default, null):String;
    @:allow(cutscenes.DialogueLiteBox)
    public var dialogueID(default, null):String;
    public var icon(default, null):String;

    var animOffsets:Map<String, FlxPoint> = [];

    public function new(x:Float = 0, y:Float = 0, ?character:String)
    {
        super(x, y);
		load(character);
    }

    public function load(character:String)
    {
		animation.destroyAnimations();
		animOffsets.clear();

        var characterToLoad:String = character;

		if (!Paths.fileExists('data/dialogues/characters/$character.json', TEXT))
        {
			FlxG.log.warn('Dialogue Character "$character" doesn\'t exists!');
			characterToLoad = DEFAULT_CHARACTER;
        }

		var charData:DialogueCharacterData = TJSON.parse(Assets.getText(Paths.json('dialogues/characters/$characterToLoad')));

		data = {
			image: charData.image,
			scale: charData.scale ?? 1,
			offsets: charData.offsets ?? [0, 0],
			expressions: parseAnimations(charData.expressions)
		};

		frames = Paths.getAtlas('dialogue/portraits/${data.image}');

		for (animData in data.expressions)
		{
			animation.addByPrefix(animData.name, animData.prefix, animData.framerate, true, animData.flipX, animData.flipY);
			animOffsets.set(animData.name, FlxPoint.get(animData.offsets[0], animData.offsets[1]));
		}
		changeExpression(animation.getNameList()[0]);

		scale.x = scale.y = data.scale;
		updateHitbox();

		curCharacter = character;
    }

	function parseAnimations(animations:Array<DialogueCharacterAnimationData>):Array<DialogueCharacterAnimationData>
    {
		var result:Array<DialogueCharacterAnimationData> = [];
		for (data in animations)
        {
            result.push({
                name: data.name,
                prefix: data.prefix,
                framerate: data.framerate,
                offsets: data.offsets ?? [0, 0],
                flipX: data.flipX ?? false,
                flipY: data.flipY ?? false
            });
        }
		return result;
    }

    public function changeExpression(expression:String)
    {
		if (animation.exists(expression) || (animation.curAnim != null && animation.curAnim.name == expression))
        {
            animation.play(expression, true);

            var animOffset:FlxPoint = animOffsets.get(expression);
			var charOffset:FlxPoint = FlxPoint.get(data.offsets[0], data.offsets[1]);
			offset.set(charOffset.x + animOffset.x, charOffset.y + animOffset.y);
        }
    }

    override function destroy()
    {
        super.destroy();
		animOffsets = null;
		data = null;
    }
}

typedef DialogueCharacterData =
{
    var image:String;
    var ?scale:Float;
    var ?offsets:Array<Float>;
	var expressions:Array<DialogueCharacterAnimationData>;
}

typedef DialogueCharacterAnimationData =
{
    /**
     * The name of the animation.
     */
    var name:String;

    /**
     * The name inside the atlas to use to find all the animation's frames.
     */
    var prefix:String;

    /**
     * How fast the animation plays.
     */
    var framerate:Float;

	/**
	 * The animation offsets.
	 */
	var ?offsets:Array<Float>;

	/**
	 * Whether to flip the animation horizontally.
	 */
	var ?flipX:Bool;

	/**
	 * Whether to flip the animation vertically.
	 */
	var ?flipY:Bool;
}