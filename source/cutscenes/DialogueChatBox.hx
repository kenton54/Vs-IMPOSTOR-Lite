package cutscenes;

import flixel.addons.text.FlxTypeText;
import objects.HealthIcon;

class DialogueChatBox extends FlxTypedSpriteGroup<FlxSprite>
{
    public var chatBox:FlxSprite;
    public var text:FlxTypeText;
    public var charName:FlxText;
    public var icon:HealthIcon;

    public var finishedTyping(default, null):Bool = false;

    public function new(x:Float = 0, y:Float = 0)
    {
        super(x, y);

		chatBox = new FlxSprite().loadGraphic(Paths.image('dialogue/chatbox'));
		chatBox.scale.set(1.08, 1.08);
		chatBox.updateHitbox();
		add(chatBox);

		text = new FlxTypeText(120, 44, Std.int(chatBox.width - 132));
		text.setFormat(Paths.font("vcr"), 24, FlxColor.BLACK, LEFT);
		text.completeCallback = () -> finishedTyping = true;
		add(text);

        icon = new HealthIcon('face');
		icon.setPosition(-12, -16);
		icon.scale.set(0.85, 0.85);
		icon.updateHitbox();
		add(icon);

		charName = new FlxText(120, 10, 0, '');
		charName.setFormat(Paths.font("vcr"), 32, FlxColor.BLACK, LEFT);
		add(charName);
    }

    public function changeDisplay(text:String, icon:String, name:String)
    {
        this.text.clearFormats();
		this.text.resetText(text);
		this.icon.changeIcon(icon);
		charName.text = name;
    }

    public function addFormat(format:FlxTextFormat, start:Int = -1, end:Int = -1)
    {
        text.addFormat(format, start, end);
    }

    public function startText(delay:Float = 0.05, force:Bool = true)
    {
		finishedTyping = false;
		text.start(delay, force);
    }

    public function finishText()
    {
		text.skip();
		finishedTyping = true;
    }
}