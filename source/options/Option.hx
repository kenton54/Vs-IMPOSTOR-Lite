package options;

typedef Keybind =
{
	keyboard:String,
	gamepad:String
}

enum OptionType
{
	Boolean;
	Number;
	Choice;
	Percentage;
	Keybind;
}

class Option
{
	public var child:Alphabet;
	public var text(get, set):String;

	/**
	 * Triggered when the option changes value.
	 */
	public var onChange:Void->Void = null;

	/**
	 * The type of option.
	 */
	public var type(default, null):OptionType = Boolean;

	public var scrollSpeed:Float = 50; //Only works on int/float, defines how fast it scrolls per second while holding left/right
	public var variable(default, null):String = null; //Variable from ClientPrefs.hx
	public var defaultValue:Dynamic = null;

	public var curOption:Int = 0; //Don't change this
	public var options:Array<String> = null; //Only used in string type
	public var changeValue:Dynamic = 1; //Only used in int/float/percent type, how much is changed when you PRESS
	public var minValue:Dynamic = null; //Only used in int/float/percent type
	public var maxValue:Dynamic = null; //Only used in int/float/percent type
	public var decimals:Int = 1; //Only used in float/percent type

	public var displayFormat:String = '%v'; //How String/Float/Percent/Int values are shown, %v = Current value, %d = Default value

	/**
	 * The name of the option.
	 */
	public var name(default, null):String = 'Unknown';

	/**
	 * The description to display when hovering this option.
	 */
	public var description(default, null):String = '';

	public var defaultKeys:Keybind = null; // Only used in keybind type
	public var keys:Keybind = null; // Only used in keybind type

	public function new(name:String, description:String = '', variable:String, type:OptionType = Boolean, ?options:Array<String> = null)
	{
		this.name = name;
		this.description = description;
		this.variable = variable;
		this.type = type;
		this.options = options;

		this.defaultValue = Reflect.getProperty(ClientPrefs.defaultData, variable);
		switch(this.type)
		{
			case Boolean:
				if (defaultValue == null) defaultValue = false;

			case Number:
				if (defaultValue == null) defaultValue = 0;

			case Percentage:
				if (defaultValue == null) defaultValue = 1;
				displayFormat = '%v%';
				changeValue = 0.01;
				minValue = 0;
				maxValue = 1;
				scrollSpeed = 0.5;
				decimals = 2;

			case Choice:
				if (defaultValue == null) defaultValue = '';
				if (options.length > 0) {
					defaultValue = options[0];
				}

			default:
		}

		try
		{
			if (getValue() == null) {
				setValue(defaultValue);
			}
	
			switch(this.type)
			{
				case Choice:
					var num:Int = options.indexOf(getValue());
					if (num > -1)
						curOption = num;
				
				default:
			}
		}
		catch(e) {}
	}

	public function change()
	{
		//nothing lol
		if (onChange != null)
			onChange();
	}

	dynamic public function getValue():Dynamic
	{
		return Reflect.getProperty(ClientPrefs.data, variable);
	}

	dynamic public function setValue(value:Dynamic)
	{
		Reflect.setProperty(ClientPrefs.data, variable, value);
	}

	function get_text():Null<String>
	{
		if(child != null) {
			return child.text;
		}
		return null;
	}

	function set_text(newValue:String):Null<String>
	{
		if(child != null) {
			child.text = newValue;
		}
		return null;
	}
}