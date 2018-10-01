package elements;

import peote.view.Element;

class ElementAnim implements Element
{
	// Position in pixel (relative to upper left corner of Display)
	@posX @set("PosSize") //@time("Position") @anim("Position") //@constStart(0) //@constEnd(100)
	public var x:Int;
	
	@posY @set("PosSize") @time("Position") @anim("Position") //@constStart(0) //@constEnd(100) 
	public var y:Int=0;
	
	// Size in pixel
	@sizeX @set("PosSize") @time("Size") @anim("Size") //@constStart(300) //@constEnd(400) 
	public var w:Int=100;
	
	@sizeY @set("PosSize") @time("Size") @anim("Size") //@constEnd(200)
	public var h:Int=100;
	
	// Color (RGBA)
	@color @anim("Color") @time("Position") @constStart(0x1133FF00) // @constEnd(0xFF142300) 
	public var c:Int = 0xFFFF0000; // TODO: different coloring methods and gradients
	
	// TODO
	/*
	// Rotation around pivot point
	@rotation
	public var r:Float = 45.4;
	
	@pivotX 
	// pivot x (position offset)
	public var px:Int = 0;
	@pivotY
	// pivot y (position offset)
	public var py:Int = 0;
	*/
	
}
