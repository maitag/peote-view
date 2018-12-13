package elements;

import peote.view.Color;
import peote.view.Element;

class ElementSimple implements Element
{
	@posX public var x:Int=0; // signed 2 bytes integer
	@posY public var y:Int=0; // signed 2 bytes integer
	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	@color public var c:Color = 0xff0000ff;
	// TODO: make more colors available for program.colorFormula
	// @color("shift") var shiftColor:Color;
		
	@zIndex public var z:Int = 0;

	@texUnit public var unit:Int;  // unit (index of texture-array while set a TextureLayer)

	// what slot inside a Texture to use (texture can store many images)
	@texSlot public var slot:Int;  // unsigned 2 bytes integer

	// manual texture coordinates inside a slot (or inside all slots if no slot available)
	@texX("color") public var tx:Int;
	@texY("color") public var ty:Int;
	//@texW("color") public var tw:Int=512;
	//@texH("color") public var th:Int=512;	

	// tiles the slot or manual texture-coordinate into sub-slots
	@texTile() public var tile:Int;  // unsigned 2 bytes integer

	//TODO: let the texture shift inside slot/texCoords/tile area
	//@texOffsetX("color") public var txOffset:Int;
	//@texOffsetY("color") public var tyOffset:Int;
	
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100, c:Int=0xFF0000FF )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.c = c;
	}


}
