package states.editors;

#if EDITORS_ALLOWED
import cutscenes.DialogueLiteBox;

class DialogueEditorState extends MusicBeatState
{
    var dialogueBox:DialogueLiteBox;

    var linesText:FlxText;

    var curLine(get, never):Int;

    override function create()
    {
        super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF808080);
        add(bg);

		dialogueBox = new DialogueLiteBox();
		dialogueBox.bgFade.visible = false;
		dialogueBox.loadFromData(getDefaultDialogue());
		dialogueBox.allowControls = false;
        add(dialogueBox);

		dialogueBox.start(true);

        var replayDialogueText:FlxText = new FlxText(10, 10, FlxG.width - 20, "Press SPACE to replay the current line", 16);
		replayDialogueText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        add(replayDialogueText);

        var addLineText:FlxText = new FlxText(10, 32, FlxG.width - 20, "Press O to remove the current line, Press P to add a line after the current one", 16);
		addLineText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        add(addLineText);

		linesText = new FlxText(10, 62, FlxG.width - 20, "Line 0 / 0", 16);
		linesText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		add(linesText);

		updateDialogue();
    }

    override function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.SPACE)
            dialogueBox.repeatLine(true);

		if (FlxG.keys.justPressed.A)
        {
			dialogueBox.retractDialogue();
			updateDialogue();
        }
        else if (FlxG.keys.justPressed.D)
        {
			dialogueBox.advanceDialogue(false);
			updateDialogue();
        }

        if (FlxG.keys.justPressed.O)
        {
			dialogueBox.dialogueLines.remove(dialogueBox.dialogueLines[curLine]);
			dialogueBox.curLine = curLine;
			dialogueBox.updateLine();
			updateDialogue();
        }
        else if (FlxG.keys.justPressed.P)
        {
			dialogueBox.addLine(getDefaultLine(), curLine + 1);
			dialogueBox.advanceDialogue(false);
			updateDialogue();
        }

		if (FlxG.keys.justPressed.ESCAPE)
		{
			@:privateAccess dialogueBox.dialogueMusic.stop();
			FlxG.switchState(() -> new MasterEditorMenu());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

        super.update(elapsed);
    }

	function updateDialogue()
    {
		linesText.text = 'Line ${curLine + 1} / ${dialogueBox.dialogueLines.length} - Press A or D to scroll.';
    }

	function get_curLine():Int
    {
        return dialogueBox.curLine;
    }

    function getDefaultDialogue():DialogueData
    {
        return {
			portraits: [
				{id: "test1", character: "red", position: 0.25},
				{id: "test2", character: "red", position: 0.75}
            ],
			lines: [getDefaultLine(), {text: "asdfnawfwqfnirughwregu", phoneColor: "#0000FF", portrait: "test2", expression: "realizing"}]
        };
    }

    function getDefaultLine():DialogueLineData
    {
        return {
            text: "Lorem ipsum dolor sit amet.",
            phoneColor: "#FF0000",
            portrait: "test1",
            expression: "neutral"
        };
    }
}
#end