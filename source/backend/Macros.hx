package backend;

class Macros
{
	public static macro function getDefine(define:String, ?defaultValue:String):haxe.macro.Expr
	{
		var value:Null<String> = haxe.macro.Context.definedValue(define);
		if (value == null && defaultValue != null)
			value = defaultValue;

		return macro $v{value};
	}
}
