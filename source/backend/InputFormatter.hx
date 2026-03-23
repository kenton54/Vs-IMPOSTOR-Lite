package backend;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadManager;

class InputFormatter {
	public static function getKeyName(key:FlxKey):String
	{
		switch (key) {
			case BACKSPACE:
				return "BckSpc";
			case CONTROL:
				return "Ctrl";
			case ALT:
				return "Alt";
			case CAPSLOCK:
				return "Caps";
			case PAGEUP:
				return "PgUp";
			case PAGEDOWN:
				return "PgDown";
			case ZERO:
				return "0";
			case ONE:
				return "1";
			case TWO:
				return "2";
			case THREE:
				return "3";
			case FOUR:
				return "4";
			case FIVE:
				return "5";
			case SIX:
				return "6";
			case SEVEN:
				return "7";
			case EIGHT:
				return "8";
			case NINE:
				return "9";
			case NUMPADZERO:
				return "#0";
			case NUMPADONE:
				return "#1";
			case NUMPADTWO:
				return "#2";
			case NUMPADTHREE:
				return "#3";
			case NUMPADFOUR:
				return "#4";
			case NUMPADFIVE:
				return "#5";
			case NUMPADSIX:
				return "#6";
			case NUMPADSEVEN:
				return "#7";
			case NUMPADEIGHT:
				return "#8";
			case NUMPADNINE:
				return "#9";
			case NUMPADMULTIPLY:
				return "#*";
			case NUMPADPLUS:
				return "#+";
			case NUMPADMINUS:
				return "#-";
			case NUMPADPERIOD:
				return "#.";
			case SEMICOLON:
				return ";";
			case COMMA:
				return ",";
			case PERIOD:
				return ".";
			//case SLASH:
			//	return "/";
			case GRAVEACCENT:
				return "`";
			case LBRACKET:
				return "[";
			//case BACKSLASH:
			//	return "\\";
			case RBRACKET:
				return "]";
			case QUOTE:
				return "'";
			case PRINTSCREEN:
				return "PrtScrn";
			case NONE:
				return '---';
			default:
				var label:String = Std.string(key);
				if(label.toLowerCase() == 'null') return '---';

				var arr:Array<String> = label.split('_');
				for (i in 0...arr.length) arr[i] = CoolUtil.capitalize(arr[i]);
				return arr.join(' ');
		}
	}

	public static function getGamepadName(button:FlxGamepadInputID):String
	{
		var gamepad:FlxGamepad = FlxG.gamepads.firstActive;
		var model:FlxGamepadModel = gamepad != null ? gamepad.detectedModel : UNKNOWN;

		return switch(button)
		{
			// Analogs
			case LEFT_STICK_DIGITAL_LEFT: "Left";
			case LEFT_STICK_DIGITAL_RIGHT: "Right";
			case LEFT_STICK_DIGITAL_UP: "Up";
			case LEFT_STICK_DIGITAL_DOWN: "Down";
			case LEFT_STICK_CLICK: getGamepadModelButtonName(LEFT_STICK_CLICK, model);

			case RIGHT_STICK_DIGITAL_LEFT: "C. Left";
			case RIGHT_STICK_DIGITAL_RIGHT: "C. Right";
			case RIGHT_STICK_DIGITAL_UP: "C. Up";
			case RIGHT_STICK_DIGITAL_DOWN: "C. Down";
			case RIGHT_STICK_CLICK: getGamepadModelButtonName(RIGHT_STICK_CLICK, model);

			// Directional
			case DPAD_LEFT: "D. Left";
			case DPAD_RIGHT: "D. Right";
			case DPAD_UP: "D. Up";
			case DPAD_DOWN: "D. Down";

			// Top buttons
			case LEFT_SHOULDER: getGamepadModelButtonName(LEFT_SHOULDER, model);
			case RIGHT_SHOULDER: getGamepadModelButtonName(RIGHT_SHOULDER, model);

			case LEFT_TRIGGER: getGamepadModelButtonName(LEFT_TRIGGER, model);
			case RIGHT_TRIGGER: getGamepadModelButtonName(RIGHT_TRIGGER, model);

			case LEFT_TRIGGER_BUTTON: getGamepadModelButtonName(LEFT_TRIGGER_BUTTON, model);
			case RIGHT_TRIGGER_BUTTON: getGamepadModelButtonName(RIGHT_TRIGGER_BUTTON, model);

			// Buttons
			case A: getGamepadModelButtonName(A, model);
			case B: getGamepadModelButtonName(B, model);
			case X: getGamepadModelButtonName(X, model);
			case Y: getGamepadModelButtonName(Y, model);

			case START: getGamepadModelButtonName(START, model);
			case BACK: getGamepadModelButtonName(BACK, model);
			case GUIDE: getGamepadModelButtonName(GUIDE, model);

			case NONE: '---';

			default:
				var label:String = Std.string(button);
				if (label.toLowerCase() == 'null') return '---';

				var arr:Array<String> = label.split('_');
				for (i in 0...arr.length) arr[i] = CoolUtil.capitalize(arr[i]);
				return arr.join(' ');
		}
	}

	public static function getGamepadModelButtonName(button:FlxGamepadInputID, model:FlxGamepadModel)
	{
		var gamepad:FlxGamepad = FlxG.gamepads.firstActive;
		var attachment:FlxGamepadAttachment = gamepad != null ? gamepad.attachment : NONE;

		return switch (button)
		{
			case LEFT_STICK_CLICK:
				switch (model)
				{
					case PS4 | PS5 | PSVITA | OUYA: "L3";
					case SWITCH_PRO: "L. Stick Click";
					case SWITCH_JOYCON_LEFT | SWITCH_JOYCON_RIGHT: "Stick Click";
					case XINPUT: "LS";
					default: "L. Analog Click";
				}

			case RIGHT_STICK_CLICK:
				switch (model)
				{
					case PS4 | PS5 | PSVITA | OUYA: "R3";
					case SWITCH_PRO: "R. Stick Click";
					case SWITCH_JOYCON_LEFT | SWITCH_JOYCON_RIGHT: "Stick Click";
					case XINPUT: "RS";
					default: "R. Analog Click";
				}

			case A:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_NUNCHUCK | NONE: "A";
							case WII_CLASSIC_CONTROLLER: "Classic Controller B";
						}
					case PS4 | PS5 | PSVITA: "Cross";
					case SWITCH_PRO | SWITCH_JOYCON_RIGHT: "B";
					case SWITCH_JOYCON_LEFT: "D. Down";
					case XINPUT: "A";
					case OUYA: "O";
					default: "Action Down";
				}

			case B:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_NUNCHUCK | NONE: "B";
							case WII_CLASSIC_CONTROLLER: "Classic Controller A";
						}
					case PS4 | PS5 | PSVITA: "Circle";
					case SWITCH_PRO | SWITCH_JOYCON_RIGHT | OUYA: "A";
					case SWITCH_JOYCON_LEFT: "D. Right";
					case XINPUT: "B";
					default: "Action Right";
				}

			case X:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_NUNCHUCK | NONE: "1";
							case WII_CLASSIC_CONTROLLER: "Classic Controller Y";
						}
					case PS4 | PS5 | PSVITA: "Square";
					case SWITCH_PRO | SWITCH_JOYCON_RIGHT: "Y";
					case SWITCH_JOYCON_LEFT: "D. Right";
					case XINPUT: "X";
					case OUYA: "U";
					default: "Action Left";
				}

			case Y:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_NUNCHUCK | NONE: "2";
							case WII_CLASSIC_CONTROLLER: "Classic Controller X";
						}
					case PS4 | PS5 | PSVITA: "Triangle";
					case SWITCH_PRO | SWITCH_JOYCON_RIGHT: "X";
					case SWITCH_JOYCON_LEFT: "D. Up";
					case XINPUT | OUYA: "Y";
					default: "Action Up";
				}

			case LEFT_SHOULDER:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_NUNCHUCK: "C";
							case WII_CLASSIC_CONTROLLER: "Classic Controller ZL";
							default: "Unknown";
						}
					case PS4 | PS5 | OUYA: "L1";
					case SWITCH_PRO | PSVITA: "L";
					case SWITCH_JOYCON_LEFT | SWITCH_JOYCON_RIGHT: "SL";
					case XINPUT: "LB";
					default: "L. Bumper";
				}

			case RIGHT_SHOULDER:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_CLASSIC_CONTROLLER: "Classic Controller ZR";
							default: "Unknown";
						}
					case PS4 | PS5 | OUYA: "R1";
					case SWITCH_PRO | PSVITA: "R";
					case SWITCH_JOYCON_LEFT | SWITCH_JOYCON_RIGHT: "SR";
					case XINPUT: "RB";
					default: "R. Bumper";
				}

			case LEFT_TRIGGER | LEFT_TRIGGER_BUTTON:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_NUNCHUCK: "Z";
							case WII_CLASSIC_CONTROLLER: "Classic Controller L";
							default: "Unknown";
						}
					case PS4 | PS5 | OUYA: "L2";
					case SWITCH_PRO | SWITCH_JOYCON_LEFT | SWITCH_JOYCON_RIGHT: "ZL";
					case XINPUT: "LT";
					default: "L. Trigger";
				}

			case RIGHT_TRIGGER | RIGHT_TRIGGER_BUTTON:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_CLASSIC_CONTROLLER: "Classic Controller R";
							default: "Unknown";
						}
					case PS4 | PS5 | OUYA: "R2";
					case SWITCH_PRO | SWITCH_JOYCON_LEFT | SWITCH_JOYCON_RIGHT: "ZR";
					case XINPUT: "RT";
					default: "R. Trigger";
				}

			case START:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_NUNCHUCK | NONE: "Plus";
							case WII_CLASSIC_CONTROLLER: "Start";
						}
					case PS4 | PS5: "Options";
					case SWITCH_PRO | SWITCH_JOYCON_RIGHT: "Plus";
					case SWITCH_JOYCON_LEFT: "Minus";
					default: "Start";
				}

			case BACK:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_NUNCHUCK | NONE: "Minus";
							case WII_CLASSIC_CONTROLLER: "Select";
						}
					case PS4 | PS5: "Share";
					case SWITCH_PRO: "Minus";
					default: "Select";
				}

			case GUIDE:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_NUNCHUCK | WII_CLASSIC_CONTROLLER | NONE: "Home";
						}
					case PS4 | PS5: "PS";
					case SWITCH_PRO | OUYA: "Home";
					default: "Guide";
				}

			case EXTRA_0:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_CLASSIC_CONTROLLER: "1";
							default: "Extra #1";
						}
					case SWITCH_PRO: "Capture";
					default: "Extra #1";
				}

			case EXTRA_1:
				switch (model)
				{
					case WII_REMOTE | MAYFLASH_WII_REMOTE:
						switch (attachment)
						{
							case WII_CLASSIC_CONTROLLER: "2";
							default: "Extra #2";
						}
					default: "Extra #2";
				}

			default: "---";
		}
	}
}