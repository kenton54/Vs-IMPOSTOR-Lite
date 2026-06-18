package states.editors;

#if EDITORS_ALLOWED
import cutscenes.DialogueCharacter;
import cutscenes.DialogueLiteBox;

class DialogueEditorState extends MusicBeatState
{
    var dialogueBox:DialogueLiteBox;

    var linesText:FlxText;
    var exprText:FlxText;

    var curAnim:Int = 0;
    var curLine(get, never):Int;
    var curCharacter(get, never):DialogueCharacter;

    override function create()
    {
        super.create();

        persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF808080);
        add(bg);

		dialogueBox = new DialogueLiteBox();
		dialogueBox.loadFromData(DialogueLiteBox.getDefaultDialogue());
		dialogueBox.allowControls = false;
        add(dialogueBox);

		dialogueBox.start(true);

        var replayDialogueText:FlxText = new FlxText(10, 10, FlxG.width - 20, "Press SPACE to replay the current line", 16);
		replayDialogueText.setFormat(Paths.font("vcr"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        add(replayDialogueText);

        var addLineText:FlxText = new FlxText(10, 32, FlxG.width - 20, "Press O to remove the current line, Press P to add a line after the current one", 16);
		addLineText.setFormat(Paths.font("vcr"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        add(addLineText);

		linesText = new FlxText(10, 62, FlxG.width - 20, "Line 0 / 0", 20);
		linesText.setFormat(Paths.font("vcr"), 20, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		add(linesText);

		exprText = new FlxText(10, 96, FlxG.width - 20, "Expression: idk (0 / 0)", 20);
		exprText.setFormat(Paths.font("vcr"), 20, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		add(exprText);

		updateDialogue();

		FlxG.mouse.visible = true;
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
			dialogueBox.curLine = curLine; // forces an update
			dialogueBox.updateLine();
			updateDialogue();
        }
        else if (FlxG.keys.justPressed.P)
        {
			dialogueBox.addLine(DialogueLiteBox.getDefaultLine(), curLine + 1);
			dialogueBox.advanceDialogue(false);
			updateDialogue();
        }

        if (FlxG.keys.justPressed.W)
        {
			var char:DialogueCharacter = curCharacter;

			curAnim = FlxMath.wrap(curAnim - 1, 0, char.data.expressions.length - 1);

			var expression:String = char.data.expressions[curAnim].name;
			char.changeExpression(expression);
			dialogueBox.dialogueLines[curLine].expression = expression;

			updateDialogue();
        }
		else if (FlxG.keys.justPressed.S)
        {
			var char:DialogueCharacter = curCharacter;

			curAnim = FlxMath.wrap(curAnim + 1, 0, char.data.expressions.length - 1);

			var expression:String = char.data.expressions[curAnim].name;
			char.changeExpression(expression);
			dialogueBox.dialogueLines[curLine].expression = expression;

			updateDialogue();
        }

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(() -> new MasterEditorMenu());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

        super.update(elapsed);
    }

	function updateDialogue()
    {
		curAnim = getCurExpressionIndex(dialogueBox.dialogueLines[curLine].expression);

		linesText.text = 'Line ${curLine + 1} / ${dialogueBox.dialogueLines.length} - Press A or D to scroll';
		exprText.text = 'Expression: ${curCharacter.animation.name} (${curAnim + 1} / ${curCharacter.data.expressions.length}) - Press W or S to scroll';
    }

    function getCurExpressionIndex(expression:String):Int
    {
		for (i => expr in curCharacter.data.expressions)
        {
            if (expr.name == expression)
                return i;
        }

        return -1;
    }

	function get_curLine():Int
    {
        return dialogueBox.curLine;
    }

    function get_curCharacter():DialogueCharacter
    {
		return dialogueBox.getPortraitMatchingID(dialogueBox.dialogueLines[curLine].portrait);
    }
}
#end