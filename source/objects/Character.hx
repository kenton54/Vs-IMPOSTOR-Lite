package objects;

import backend.animation.PsychAnimationController;

import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSort;

import haxe.Json;

import psychlua.ModchartSprite;

typedef CharacterFile =
{
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var flip_y:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
	var vocals_file:String;
	var ?_editor_isPlayer:Null<Bool>;
}

typedef AnimArray =
{
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
	var flipX:Bool;
	var flipY:Bool;
}

class Character extends ModchartSprite
{
	/**
	 * In case a character is missing, it will use this on its place
	**/
	public static final DEFAULT_CHARACTER:String = 'bf';

	public var debugMode:Bool = false;
	public var extraData:Map<String, Dynamic> = [];

	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 4; // Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; // Character use "danceLeft" and "danceRight" instead of "idle"
	public var skipDance:Bool = false;

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];
	public var healthColorArray:Array<Int> = [255, 0, 0];

	public var hasMissAnimations:Bool = false;
	public var vocalsFile:String = '';

	// Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var originalFlipY:Bool = false;
	public var editorIsPlayer:Null<Bool> = null;

	public function new(x:Float = 0, y:Float = 0, ?character:String = 'bf', ?isPlayer:Bool = false)
	{
		super(x, y);

		curCharacter = character;
		this.isPlayer = isPlayer;

		var path:String = Paths.getPath('characters/$curCharacter.json');

		if (!Assets.exists(path))
		{
			path = Paths.getLitePath('characters/$DEFAULT_CHARACTER.json'); // If a character couldn't be found, change him to BF just to prevent a crash
			color = FlxColor.BLACK;
			alpha = 0.6;
		}

		try
		{
			loadCharacterFile(Json.parse(Assets.getText(path)));
		}
		catch (e:Dynamic)
		{
			trace('Error loading character file of "$character": $e');
		}
	}

	override function initVars()
	{
		super.initVars();

		animation = new PsychAnimationController(this);
	}

	public function loadCharacterFile(json:CharacterFile):Character
	{
		animOffsets.clear();
		extraData.clear();

		imageFile = json.image;
		jsonScale = json.scale;

		frames = Paths.getMultiAtlas(imageFile.split(","));

		if (json.scale != 1)
			scale.set(jsonScale, jsonScale);
		else
			scale.set(1, 1);

		updateHitbox();

		// positioning
		positionArray = json.position;
		cameraPosition = json.camera_position;

		// data
		healthIcon = json.healthicon;
		singDuration = json.sing_duration;
		flipX = (json.flip_x != isPlayer);
		flipY = json.flip_y ?? false;
		healthColorArray = (json.healthbar_colors != null && json.healthbar_colors.length > 2) ? json.healthbar_colors : [161, 161, 161];
		vocalsFile = json.vocals_file != null ? json.vocals_file : '';
		originalFlipX = json.flip_x;
		originalFlipY = json.flip_y;
		editorIsPlayer = json._editor_isPlayer;

		// antialiasing
		noAntialiasing = json.no_antialiasing;
		antialiasing = ClientPrefs.data.antialiasing ? !noAntialiasing : false;

		// animations
		animationsArray = json.animations;
		if (animationsArray != null && animationsArray.length > 0)
		{
			for (anim in animationsArray)
			{
				var animAnim:String = anim.anim ?? '';
				var animName:String = anim.name ?? '';
				var animFps:Float = anim.fps;
				var animLoop:Bool = anim.loop;
				var animIndices:Null<Array<Int>> = anim.indices;
				var animFlipX:Bool = anim.flipX ?? false;
				var animFlipY:Bool = anim.flipY ?? false;

				if (animIndices != null && animIndices.length > 0)
					animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
				else
					animation.addByPrefix(animAnim, animName, animFps, animLoop);

				if (anim.offsets != null && anim.offsets.length > 1)
					addOffset(animAnim, anim.offsets[0], anim.offsets[1]);
				else
					addOffset(animAnim, 0, 0);
			}
		}

		hasMissAnimations = animOffsets.exists('singLEFTmiss') || animOffsets.exists('singDOWNmiss') || animOffsets.exists('singUPmiss') || animOffsets.exists('singRIGHTmiss');
		recalculateDanceIdle();
		dance();

		return this;
	}

	override function update(elapsed:Float)
	{
		if (debugMode || isAnimationNull())
		{
			super.update(elapsed);
			return;
		}

		if (heyTimer > 0)
		{
			var rate:Float = (PlayState.instance != null ? PlayState.instance.playbackRate : 1.0);
			heyTimer -= elapsed * rate;
			if (heyTimer <= 0)
			{
				var anim:String = getAnimationName();
				if (specialAnim && (anim == 'hey' || anim == 'cheer'))
				{
					specialAnim = false;
					dance();
				}
				heyTimer = 0;
			}
		}
		else if (specialAnim && isAnimationFinished())
		{
			specialAnim = false;
			dance();
		}
		else if (getAnimationName().endsWith('miss') && isAnimationFinished())
		{
			dance();
			finishAnimation();
		}

		if (getAnimationName().startsWith('sing'))
			holdTimer += elapsed;
		else if (isPlayer)
			holdTimer = 0;

		if (!isPlayer
			&& holdTimer >= Conductor.stepCrochet * (0.0011 #if FLX_PITCH / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1) #end) * singDuration)
		{
			dance();
			holdTimer = 0;
		}

		var name:String = getAnimationName();
		if (isAnimationFinished() && animOffsets.exists('$name-loop'))
			playAnim('$name-loop');

		super.update(elapsed);
	}

	inline public function isAnimationNull():Bool
		return animation.curAnim == null;

	inline public function getAnimationName():String
	{
		var name:String = '';

		if (!isAnimationNull())
			name = animation.curAnim.name;

		return name;
	}

	public function isAnimationFinished():Bool
	{
		return isAnimationNull() ? false : animation.curAnim.finished;
	}

	public function finishAnimation():Void
	{
		if (isAnimationNull())
			return;
		animation.curAnim.finish();
	}

	public function animationExists(Anim:String):Bool
	{
		return animation.getByName(Anim) != null;
	}

	public var animPaused(get, set):Bool;

	private function get_animPaused():Bool
	{
		if (isAnimationNull())
			return false;
		return animation.curAnim.paused;
	}

	private function set_animPaused(value:Bool):Bool
	{
		if (isAnimationNull())
			return value;
		animation.curAnim.paused = value;

		return value;
	}

	public var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !skipDance && !specialAnim)
		{
			if (danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight' + idleSuffix);
				else
					playAnim('danceLeft' + idleSuffix);
			}
			else if (animOffsets.exists('idle' + idleSuffix))
			{
				playAnim('idle' + idleSuffix);
			}
		}
	}

	override function playAnim(name:String, forced:Bool = false, ?reserve:Bool = false, ?startFrame:Int = 0):Void
	{
		if (!animationExists(name))
			return;

		specialAnim = false;

		if (curCharacter.startsWith('gf'))
		{
			if (name == 'singLEFT')
				danced = true;
			else if (name == 'singRIGHT')
				danced = false;

			if (name == 'singUP' || name == 'singDOWN')
				danced = !danced;
		}

		super.playAnim(name, forced, reserve, startFrame);
	}

	function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	public var danceEveryNumBeats:Int = 2;

	private var settingCharacterUp:Bool = true;

	public function recalculateDanceIdle()
	{
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (animOffsets.exists('danceLeft' + idleSuffix) && animOffsets.exists('danceRight' + idleSuffix));

		if (settingCharacterUp)
		{
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		}
		else if (lastDanceIdle != danceIdle)
		{
			var calc:Float = danceEveryNumBeats;
			if (danceIdle)
				calc /= 2;
			else
				calc *= 2;

			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}
}
