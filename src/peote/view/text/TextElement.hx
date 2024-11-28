package peote.view.text;

import peote.view.Element;
import peote.view.Color;

class TextElement implements Element {

	@posX public var x:Int;
	@posY public var y:Int;
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	@color public var fgColor:Color = 0xf0f0f0ff;
	@color public var bgColor:Color = 0;
	@texTile public var tile:Int;
	@zIndex public var z:Int;

	public function new(x:Int, y:Int, w:Int, h:Int, fgColor:Color, bgColor:Color, tile:Int, z:Int) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.fgColor = fgColor;
		this.bgColor = bgColor;
		this.tile = tile;
		this.z = z;
	}
}

