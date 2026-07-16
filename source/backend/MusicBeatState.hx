package backend;

import backend.BaseStage;
import backend.CustomFadeTransition;

import flixel.FlxBasic;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.util.FlxSignal;

class MusicBeatState extends FlxUIState
{
	public static function getState():MusicBeatState
		return cast(FlxG.state, MusicBeatState);

	public inline static function getVariables()
		return getState().variables;

	public var onIntroDone:FlxSignal = new FlxSignal();
	public var onOutroDone:FlxSignal = new FlxSignal();

	private var stepsToDo:Int = 0;

	public var curSection(default, null):Int = 0;
	public var curStep(default, null):Int = 0;
	public var curBeat(default, null):Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;

	public var controls(get, never):Controls;

	function get_controls()
	{
		return Controls.instance;
	}

	var _psychCameraInitialized:Bool = true;

	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();

	override function create()
	{
		FlxG.camera.bgColor = FlxColor.WHITE;

		var cursorSprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image('cursor'));
		FlxG.mouse.load(cursorSprite.pixels);
		FlxG.mouse.cursor.pixelSnapping = ALWAYS;
		FlxG.mouse.cursor.smoothing = false;
		FlxG.mouse.visible = false;

		if (!_psychCameraInitialized)
			initPsychCamera();

		super.create();

		if (!FlxTransitionableState.skipNextTransOut)
			openSubState(new CustomFadeTransition(0.6, true));

		FlxTransitionableState.skipNextTransOut = false;
		timePassedOnState = 0;

		if (FlxG.save.data != null)
			FlxG.save.data.fullscreen = FlxG.fullscreen;
	}

	public function initPsychCamera():FlxCamera
	{
		_psychCameraInitialized = true;
		return FlxG.camera;
	}

	public static var timePassedOnState:Float = 0;

	override function update(elapsed:Float)
	{
		// everyStep();
		var oldStep:Int = curStep;
		timePassedOnState += elapsed;
		updateCurStep();
		updateBeat();
		if (oldStep != curStep)
		{
			if (curStep > 0)
				stepHit();
			if (PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		stagesFunc(function(stage:BaseStage)
		{
			stage.update(elapsed);
		});
		super.update(elapsed);
	}

	function updateSection():Void
	{
		if (stepsToDo < 1)
			stepsToDo = Math.round(getBeatsOnSection() * 4);
		while (curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	function rollbackSection():Void
	{
		if (curStep < 0)
			return;
		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if (stepsToDo > curStep)
					break;

				curSection++;
			}
		}
		if (curSection > lastSection)
			sectionHit();
	}

	function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep / 4;
	}

	function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);
		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	override function startOutro(onOutroComplete:() -> Void):Void
	{
		if (!FlxTransitionableState.skipNextTransIn)
		{
			FlxG.state.openSubState(new CustomFadeTransition(0.6, false));
			CustomFadeTransition.finishCallback = onOutroComplete;
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		onOutroComplete();
	}

	public function stepHit():Void
	{
		stagesFunc(function(stage:BaseStage)
		{
			stage.curStep = curStep;
			stage.curDecStep = curDecStep;
			stage.stepHit();
		});
		if (curStep % 4 == 0)
			beatHit();
	}

	public var stages:Array<BaseStage> = [];

	public function beatHit():Void
	{
		// trace('Beat: ' + curBeat);
		stagesFunc(function(stage:BaseStage)
		{
			stage.curBeat = curBeat;
			stage.curDecBeat = curDecBeat;
			stage.beatHit();
		});
	}

	public function sectionHit():Void
	{
		// trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
		stagesFunc(function(stage:BaseStage)
		{
			stage.curSection = curSection;
			stage.sectionHit();
		});
	}

	function stagesFunc(func:BaseStage->Void)
	{
		for (stage in stages)
			if (stage != null && stage.exists && stage.active)
				func(stage);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if (PlayState.SONG != null && PlayState.SONG.notes[curSection] != null)
			val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}

	override function finishTransIn()
	{
		super.finishTransIn();
		onIntroDone.dispatch();
	}

	override function finishTransOut()
	{
		super.finishTransOut();
		onOutroDone.dispatch();
	}
}
