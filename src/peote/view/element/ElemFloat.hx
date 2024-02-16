package peote.view.element;

import peote.view.Color;
import peote.view.Element;

class ElemFloat implements Element
{
	// Position in pixel (relative to upper left corner of Display)
	@posX public var x:Float = 0.0;
	@posY public var y:Float = 0.0;
	
	// Size in pixel
	@sizeX public var w:Float = 100.0;
	@sizeY public var h:Float = 100.0;
	
	// Rotation around pivot point
	@rotation public var r:Float;
	
	// pivot x (rotation offset)
	@pivotX public var px:Float = 0.0;

	// pivot y (rotation offset)
	@pivotY public var py:Float = 0.0;
		
	// Color (RGBA)
	@color public var c:Color = 0xff0000ff;
		
	// z-index for depth
	@zIndex public var z:Int = 0; // signed 2 bytes integer
	
	
	public function new(positionX:Float, positionY:Float, width:Float, height:Float, rotation:Float, pivotX:Float, pivotY:Float, zIndex:Int, color:Int )
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
