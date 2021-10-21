package elements;

import peote.view.Color;
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
	public var c:Color; // TODO: different coloring methods and gradients
	
	// Rotation around pivot point
	@rotation @anim("Rotation")
	public var r:Float;
	
	// pivot x (rotation offset)
	@pivotX @anim("Pivot") @set("Pivot") @time("Size") 
	public var px:Int = 0;

	// pivot y (rotation offset)
	@pivotY @anim("Pivot") @set("Pivot") @time("Size") 
	public var py:Int = 0;
	
	// z-index
	@zIndex 
	//@const(1) // max 0x3FFFFFFF , min -0xC0000000
	public var z:Int = 0;
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100, c:Int=0xFF0000FF )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.c = c;
	}

}
