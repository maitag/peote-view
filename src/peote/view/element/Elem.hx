package peote.view.element;

import peote.view.Color;
import peote.view.Element;

class Elem implements Element
{
	// Position in pixel (relative to upper left corner of Display)
	@posX public var x:Int = 0; // signed 2 bytes integer
	@posY public var y:Int = 0; // signed 2 bytes integer
	
	// Size in pixel
	@sizeX public var w:Int = 100; // signed 2 bytes integer
	@sizeY public var h:Int = 100; // signed 2 bytes integer
	
	// Rotation around pivot point
	@rotation public var r:Float;
	
	// pivot x (rotation offset)
	@pivotX public var px:Int = 0; // signed 2 bytes integer

	// pivot y (rotation offset)
	@pivotY public var py:Int = 0; // signed 2 bytes integer
		
	// Color (RGBA)
	@color public var c:Color = 0xff0000ff;
		
	// z-index for depth
	@zIndex public var z:Int = 0; // signed 2 bytes integer
	
	
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
