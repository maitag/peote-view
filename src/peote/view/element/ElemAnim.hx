package peote.view.element;

import peote.view.Color;
import peote.view.Element;

class ElemAnim implements Element
{
	// Position in pixel (relative to upper left corner of Display)
	@posX @set("Position") @time("Position") @anim("Position") //@constStart(0) //@constEnd(100)
	public var x:Int;
	
	@posY @set("Position") @time("Position") @anim("Position") //@constStart(0) //@constEnd(100) 
	public var y:Int;
	
	
	// Size in pixel
	@sizeX @set("Size") @time("Size") @anim("Size") //@constStart(300) //@constEnd(400) 
	public var w=100;
	
	@sizeY @set("Size") @time("Size") @anim("Size") //@constEnd(200)
	public var h:Int=100;
	
	
	// Rotation around pivot point
	@rotation @time("Rotation") @anim("Rotation")
	public var r:Float;
	
	// pivot x (rotation offset)
	@pivotX @set("Pivot")
	public var px:Int = 0;

	// pivot y (rotation offset)
	@pivotY @set("Pivot")
	public var py:Int = 0;
	
	
	// Color (RGBA)
	@color @anim("Color") @time("Color") // @constStart(0xFF112200) @constEnd(0x0000FE00) 
	public var c:Color;
	
		
	// z-index for depth
	@zIndex 	
	public var z:Int = 0; //@const(1) // max 0x3FFFFFFF , min -0xC0000000
	
	
	
	public function new(positionX:Int, positionY:Int, width:Int, height:Int, rotation:Float, pivotX:Int, pivotY:Int, zIndex:Int, color:Int )
	{
		x = positionX;
		y = positionY;
		w = width;
		h = height;
		r = rotation;
		px = pivotX;
		py = pivotY;
		z = zIndex;
		c = color;
	}

}
