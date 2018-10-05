package elements;

import peote.view.Element;

class ElementAnim implements Element
{
	// Position in pixel (relative to upper left corner of Display)
	@posX @set("PosSize") //@time("Position") @anim("Position") //@constStart(0) //@constEnd(100)
	public var x;
	
	@posY @set("PosSize") @anim("Position") //@constStart(0) //@constEnd(100) 
	public var y:Int;
	
	// Size in pixel
	@sizeX @set("PosSize") @time("Size") @anim("Size") //@constStart(300) //@constEnd(400) 
	public var w=100;
	
	@sizeY @set("PosSize") @time("Size") @anim("Size") //@constEnd(200)
	public var h:Int=100;
	
	// Color (RGBA)
	@color @anim("Color") @time("Position") // @constStart(0xFF112200) @constEnd(0x0000FE00) 
	public var c:Int; // TODO: different coloring methods and gradients
	
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
