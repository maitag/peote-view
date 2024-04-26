package peote.view;

import peote.view.PeoteGL.GLUniformLocation;

/**
	Set up a custom "uniform" that can be accessed within glsl shadercode.
**/
class UniformFloat
{
	/**The value that can be changed at runtime**/
	public var value:Float;

	/**The identifier to be used within shadercode**/
	public var name(default, null):String;
	
	/**
		Creates a new `UniformFloat` instance.
		@param name identifier to be used within shadercode
		@param value start value
	**/
	public inline function new(name:String, value:Float) 
	{
		this.name = name;
		this.value = value;
	}
	
}
