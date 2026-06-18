package cutscenes;

class DialogueCharacter extends FlxSprite
{
    public static final DEFAULT_CHARACTER:String = "bf";

    public var data(default, null):DialogueCharacterData;

    public var curCharacter(default, null):String;

    @:allow(cutscenes.DialogueLiteBox)
    public var dialogueID(default, null):String;
    public var name:String;
    public var icon:String;

    public var positionArray:Array<Float> = [0, 0];

    var animOffsets:Map<String, Array<Float>> = [];

    public function new(x:Float = 0, y:Float = 0, ?character:String)
    {
        super(x, y);
		loadCharacter(character);
    }

	public function loadCharacter(character:String):DialogueCharacter
    {
		animation.destroyAnimations();
		animOffsets.clear();

		this.x -= positionArray[0];
		this.y -= positionArray[1];

        var characterToLoad:String = character;

		if (!Paths.fileExists('data/dialogues/characters/$character.json', TEXT))
        {
			FlxG.log.warn('Dialogue Character "$character" doesn\'t exists!');
			characterToLoad = DEFAULT_CHARACTER;
        }

		var charData:DialogueCharacterData = haxe.Json.parse(Assets.getText(Paths.json('dialogues/characters/$characterToLoad')));

		data = {
			image: charData.image,
            name: charData.name,
            icon: charData.icon ?? 'face',
			scale: charData.scale ?? 1,
			offsets: charData.offsets ?? [0, 0],
			expressions: parseAnimations(charData.expressions)
		};

        name = data.name;
        icon = data.icon;

		positionArray = [data.offsets[0], data.offsets[1]];

		frames = Paths.getAtlas('dialogue/portraits/${data.image}');

		for (animData in data.expressions)
		{
			animation.addByPrefix(animData.name, animData.anim, animData.fps, true, animData.flipX, animData.flipY);
			animOffsets.set(animData.name, [animData.offsets[0], animData.offsets[1]]);
		}
		changeExpression(animation.getNameList()[0]);

		scale.x = scale.y = data.scale;
		updateHitbox();

		this.x += positionArray[0];
		this.y += positionArray[1];

		curCharacter = character;

        return this;
    }

	function parseAnimations(animations:Array<DialogueCharacterAnimationData>):Array<DialogueCharacterAnimationData>
    {
		var result:Array<DialogueCharacterAnimationData> = [];
		for (data in animations)
        {
            result.push({
                name: data.name,
				anim: data.anim,
                fps: data.fps,
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

            var animOffset:Array<Float> = animOffsets.get(expression);
			offset.set(animOffset[0], animOffset[1]);
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
    var name:String;
    var ?icon:String;
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
	var anim:String;

    /**
     * How fast the animation plays.
     */
    var fps:Float;

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