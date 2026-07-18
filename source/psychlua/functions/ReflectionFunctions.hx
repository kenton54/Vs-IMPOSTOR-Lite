package psychlua.functions;

#if LUA_ALLOWED
import Type.ValueType;

import flixel.FlxBasic;
import flixel.util.typeLimit.OneOfTwo;

import haxe.Constraints;

//
// Functions that use a high amount of Reflections, which are somewhat CPU intensive
// These functions are held together by duct tape (LMFAO shadow mario)
//
class ReflectionFunctions
{
	@:access(flixel.group.FlxTypedGroup)
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;

		Lua_helper.add_callback(lua, "getProperty", function(variable:String, ?checkForMaps:Bool = false):Dynamic
		{
			return LuaUtils.getLuaProperty(variable, checkForMaps);
		});
		Lua_helper.add_callback(lua, "setProperty", function(variable:String, value:Dynamic, checkForMaps:Bool = false):Dynamic
		{
			return LuaUtils.setLuaProperty(variable, value, checkForMaps);
		});
		Lua_helper.add_callback(lua, "getPropertyFromClass", function(classVar:String, variable:String, ?checkForMaps:Bool = false):Dynamic
		{
			var myClass:Class<Dynamic> = Type.resolveClass(classVar);
			if (myClass == null)
			{
				FunkinLua.luaTrace('getPropertyFromClass: Class $classVar not found', false, false, FlxColor.RED);
				return null;
			}

			var split:Array<String> = variable.split('.');
			if (split.length > 1)
			{
				var obj:Dynamic = LuaUtils.getDynamicProperty(myClass, split[0], checkForMaps);
				for (i in 1...(split.length - 1))
					obj = LuaUtils.getDynamicProperty(obj, split[i], checkForMaps);

				return LuaUtils.getDynamicProperty(obj, split[split.length - 1], checkForMaps);
			}
			else
				return LuaUtils.getDynamicProperty(myClass, variable, checkForMaps);
		});
		Lua_helper.add_callback(lua, "setPropertyFromClass", function(classVar:String, variable:String, value:Dynamic, ?checkForMaps:Bool = false):Dynamic
		{
			var myClass:Class<Dynamic> = Type.resolveClass(classVar);
			if (myClass == null)
			{
				FunkinLua.luaTrace('setPropertyFromClass: Class $classVar not found', false, false, FlxColor.RED);
				return null;
			}

			var split:Array<String> = variable.split('.');
			if (split.length > 1)
			{
				var obj:Dynamic = LuaUtils.getDynamicProperty(myClass, split[0], checkForMaps);
				for (i in 1...(split.length - 1))
					obj = LuaUtils.getDynamicProperty(obj, split[i], checkForMaps);

				LuaUtils.getDynamicProperty(obj, split[split.length - 1], checkForMaps);
				return value;
			}
			else
			{
				LuaUtils.setDynamicProperty(myClass, variable, value, checkForMaps);
				return value;
			}
		});
		Lua_helper.add_callback(lua, "getPropertyFromGroup", function(group:String, index:Int, variable:Dynamic, ?allowMaps:Bool = false):Dynamic
		{
			var split:Array<String> = group.split('.');
			var realObject:Dynamic = null;
			if (split.length > 1)
				realObject = LuaUtils.getPropertyLoop(split, allowMaps);
			else
				realObject = Reflect.getProperty(LuaUtils.getTargetInstance(), group);

			var groupOrArray:OneOfTwo<Array<FlxBasic>, FlxGroup> = Reflect.getProperty(LuaUtils.getTargetInstance(), group);
			if (groupOrArray != null)
			{
				switch (Type.typeof(groupOrArray))
				{
					case TClass(Array): // Is Array
						var leArray:Dynamic = realObject[index];
						if (leArray != null)
						{
							var result:Dynamic = null;
							if (Type.typeof(variable) == ValueType.TInt)
								result = leArray[variable];
							else
								result = LuaUtils.getGroupStuff(leArray, variable, allowMaps);
							return result;
						}
						FunkinLua.luaTrace('getPropertyFromGroup: Object #$index from group: $group doesn\'t exist!', false, false, FlxColor.RED);

					default: // Is Group
						var result:Dynamic = LuaUtils.getGroupStuff(realObject.members[index], variable, allowMaps);
						return result;
				}
			}

			FunkinLua.luaTrace('getPropertyFromGroup: Group/Array $group doesn\'t exist!', false, false, FlxColor.RED);
			return null;
		});
		Lua_helper.add_callback(lua, "setPropertyFromGroup", function(group:String, index:Int, variable:Dynamic, value:Dynamic, ?allowMaps:Bool = false, ?allowInstances:Bool = false):Dynamic
		{
			var split:Array<String> = group.split('.');
			var realObject:Dynamic = null;
			if (split.length > 1)
				realObject = LuaUtils.getPropertyLoop(split, allowMaps);
			else
				realObject = Reflect.getProperty(LuaUtils.getTargetInstance(), group);

			if (realObject != null)
			{
				switch (Type.typeof(realObject))
				{
					case TClass(Array): // Is Array
						var leArray:Dynamic = realObject[index];
						if (leArray != null)
						{
							if (Type.typeof(variable) == ValueType.TInt)
							{
								leArray[variable] = allowInstances ? LuaUtils.parseArguments(value) : value;
								return value;
							}
							LuaUtils.setGroupStuff(leArray, variable, allowInstances ? LuaUtils.parseArguments(value) : value, allowMaps);
						}

					default: // Is Group
						LuaUtils.setGroupStuff(realObject.members[index], variable, allowInstances ? LuaUtils.parseArguments(value) : value, allowMaps);
				}
			}
			else
				FunkinLua.luaTrace('setPropertyFromGroup: Group/Array $group doesn\'t exist!', false, false, FlxColor.RED);

			return value;
		});
		Lua_helper.add_callback(lua, "addToGroup", function(group:String, tag:String, ?index:Int = -1)
		{
			var basic:FlxBasic = LuaUtils.getLuaProperty(tag);

			if (basic == null)
			{
				FunkinLua.luaTrace('addToGroup: Object $tag is not valid!', false, false, FlxColor.RED);
				return;
			}

			var groupOrArray:OneOfTwo<Array<FlxBasic>, FlxGroup> = Reflect.getProperty(LuaUtils.getTargetInstance(), group);
			if (groupOrArray == null)
			{
				FunkinLua.luaTrace('addToGroup: Group/Array $group is not valid!', false, false, FlxColor.RED);
				return;
			}

			if (index < 0)
			{
				switch (Type.typeof(groupOrArray))
				{
					case TClass(Array): // Is Array
						var arr:Array<FlxBasic> = cast groupOrArray;
						arr.push(basic);

					default: // Is Group
						var grp:FlxGroup = FlxTypedGroup.resolveGroup(cast groupOrArray);
						grp.add(basic);
				}
			}
			else
			{
				switch (Type.typeof(groupOrArray))
				{
					case TClass(Array): // Is Array
						var arr:Array<FlxBasic> = cast groupOrArray;
						arr.insert(index, basic);

					default: // Is Group
						var grp:FlxGroup = FlxTypedGroup.resolveGroup(cast groupOrArray);
						grp.insert(index, basic);
				}
			}
		});
		Lua_helper.add_callback(lua, "removeFromGroup", function(group:String, index:Int = -1, ?tag:String, destroy:Bool = true)
		{
			var basic:FlxBasic = null;
			if (tag != null)
			{
				basic = LuaUtils.getLuaProperty(tag);

				if (basic == null)
				{
					FunkinLua.luaTrace('removeFromGroup: Object $tag is not valid!', false, false, FlxColor.RED);
					return;
				}
			}

			var groupOrArray:OneOfTwo<Array<FlxBasic>, FlxGroup> = Reflect.getProperty(LuaUtils.getTargetInstance(), group);
			if (groupOrArray == null)
			{
				FunkinLua.luaTrace('removeFromGroup: Group/Array $group is not valid!', false, false, FlxColor.RED);
				return;
			}

			switch (Type.typeof(groupOrArray))
			{
				case TClass(Array): // Is Array
					var arr:Array<FlxBasic> = cast groupOrArray;

					if (basic != null)
					{
						arr.remove(basic);

						if (destroy)
							basic.destroy();
					}
					else
						arr.remove(arr[index]);

				default: // Is Group
					var grp:FlxGroup = FlxTypedGroup.resolveGroup(cast groupOrArray);

					if (basic == null)
						basic = grp.members[index];

					grp.remove(basic, true);

					if (destroy)
						basic.destroy();
			}
		});

		Lua_helper.add_callback(lua, "callMethod", function(funcToRun:String, ?args:Array<Dynamic>):Dynamic
		{
			var parent:Dynamic = PlayState.instance;
			var split:Array<String> = funcToRun.split('.');
			var varParent:Dynamic = MusicBeatState.getVariables().get(split[0].trim());
			if (varParent != null)
			{
				split.shift();
				funcToRun = split.join('.').trim();
				parent = varParent;
			}

			if (funcToRun.length > 0)
				return callMethodFromObject(parent, funcToRun, LuaUtils.parseArguments(args));

			return Reflect.callMethod(null, parent, LuaUtils.parseArguments(args));
		});
		Lua_helper.add_callback(lua, "callMethodFromClass", function(className:String, funcToRun:String, ?args:Array<Dynamic>):Dynamic
		{
			return callMethodFromObject(Type.resolveClass(className), funcToRun, LuaUtils.parseArguments(args));
		});
	}

	static function callMethodFromObject(classObj:Dynamic, funcStr:String, ?args:Array<Dynamic>):Null<Dynamic>
	{
		if (classObj == null)
			return null;

		if (args == null)
			args = [];

		var split:Array<String> = funcStr.split('.');
		var funcToRun:Function = null;
		var obj:Dynamic = classObj;

		for (i in 0...split.length)
			obj = LuaUtils.getDynamicProperty(obj, split[i].trim());

		funcToRun = cast obj;
		return funcToRun != null ? Reflect.callMethod(obj, funcToRun, args) : null;
	}
}
#end
