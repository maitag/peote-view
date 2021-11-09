package peote.view;

import peote.view.PeoteGL.GLUniformLocation;

class UniformFloat
{
	public var value:Float;
	public var name(default, null):String;
		
	public inline function new(name:String, value:Float) 
	{
		this.name = name;
		this.value = value;
	}
	
}
