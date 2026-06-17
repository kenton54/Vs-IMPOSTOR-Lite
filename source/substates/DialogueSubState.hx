package substates;

class DialogueSubState extends MusicBeatSubstate
{
    public function new() {
        super();
    }

    // box for dialogue
    // text is its own thing
    // NEXT LINE SPRITE
    // box for speaker
    // text for speaker name
    // box for portrait
    // sprite for portrait

    override function create() {
        trace('hi');
        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }

    override function destroy() {
        super.destroy();
    }    
}