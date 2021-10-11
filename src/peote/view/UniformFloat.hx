package peote.view;

import peote.view.PeoteGL.GLUniformLocation;

@:allow(peote.view)
class UniformFloat
{
	public var value:Float;
	public var name(default, null):String;
	
	var location:GLUniformLocation;
	var pick_location:GLUniformLocation;

	
	public inline function new(name:String, value:Float) 
	{
		this.name = name;
		this.value = value;
	}
	
}
