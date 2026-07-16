package backend;

import flixel.addons.display.FlxRuntimeShader;

import lime.graphics.opengl.GLProgram;

@:access(openfl.display3D.Context3D)
@:access(openfl.display3D.Program3D)
@:access(openfl.display.ShaderInput)
@:access(openfl.display.ShaderParameter)
class FunkinRuntimeShader extends FlxRuntimeShader
{
	public static final VALID_GLSL_VERSIONS:Array<Int> = [110, 120, 130, 140, 150, 330, 400, 410, 420, 430, 440, 450, 460];

	public var glslVersion(get, set):Int;

	@:noCompletion private var __glslVersion:Int;

	public function new(?frag:String, ?vert:String, ?glslVersion:Int)
	{
		super(frag, vert);

		if (glslVersion != null)
			__glslVersion = glslVersion;
	}

	@:noCompletion override function __initGL()
	{
		if (__glSourceDirty || __paramBool == null)
		{
			__glSourceDirty = false;
			program = null;

			__inputBitmapData = new Array();
			__paramBool = new Array();
			__paramFloat = new Array();
			__paramInt = new Array();

			__processGLData(glVertexSource, "attribute");
			__processGLData(glVertexSource, "uniform");
			__processGLData(glFragmentSource, "uniform");
		}

		if (__context != null && program == null)
		{
			var gl = __context.gl;

			var prefix:String = '#version ${__glslVersion}\n';

			#if (js && html5)
			prefix += (precisionHint == FULL ? "precision mediump float;\n" : "precision lowp float;\n");
			#else
			prefix += "#ifdef GL_ES\n";
			if (precisionHint == FULL)
			{
				prefix += "#ifdef GL_FRAGMENT_PRECISION_HIGH\n";
				prefix += "precision highp float;\n";
				prefix += "#else\n";
				prefix += "precision mediump float;\n";
				prefix += "#endif\n";
			}
			else
				prefix += "precision lowp float;\n";

			prefix += "#endif";
			#end

			var vertex:String = prefix + glVertexSource;
			var fragment:String = prefix + glFragmentSource;

			var id:String = vertex + fragment;

			if (__context.__programs.exists(id))
				program = __context.__programs.get(id);
			else
			{
				program = __context.createProgram(GLSL);
				program.__glProgram = __createGLProgram(vertex, fragment);
				__context.__programs.set(id, program);
			}

			if (program != null)
			{
				glProgram = program.__glProgram;

				for (input in __inputBitmapData)
				{
					if (input.__isUniform)
						input.index = gl.getUniformLocation(glProgram, input.name);
					else
						input.index = gl.getAttribLocation(glProgram, input.name);
				}

				for (parameter in __paramBool)
				{
					if (parameter.__isUniform)
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					else
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
				}

				for (parameter in __paramFloat)
				{
					if (parameter.__isUniform)
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					else
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
				}

				for (parameter in __paramInt)
				{
					if (parameter.__isUniform)
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					else
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
				}
			}
		}
	}

	// prevents the program from dying
	@:noCompletion override function __createGLProgram(vertexSource:String, fragmentSource:String):GLProgram
	{
		try
		{
			return super.__createGLProgram(vertexSource, fragmentSource);
		}
		catch (e:Dynamic)
		{
			return null;
		}
	}

	@:noCompletion function get_glslVersion():Int
	{
		return __glslVersion;
	}

	@:noCompletion function set_glslVersion(value:Int):Int
	{
		if (!VALID_GLSL_VERSIONS.contains(value))
			return value;

		if (value != __glslVersion)
		{
			__glSourceDirty = true;
		}

		return __glslVersion = value;
	}
}
