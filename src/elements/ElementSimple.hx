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
	
	@zIndex public var z:Int = 0;

	// type("color") is default
	@texUnit @type("color", "alpha") public var unit:Int;
	@texSlot @type("color", "alpha") public var slot:Int;
	@texTile @type("color", "alpha") public var tile:Int;
	// innerhalb des Tiles oder Slots oder der gesammten Texture
	@texX @type("color") public var txOffset:Int;
	@texY @type("color") public var tyOffset:Int;
	@texW @type("alpha") public var twOffset:Int;
	@texH @type("alpha") public var thOffset:Int;
	//TODO: @texXOffset @type("color") public var tx:Int;
	
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100, c:Int=0xFF0000FF )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.c = c;
	}


}
