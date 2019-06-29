package peote.text;
import peote.view.Element;
import peote.view.Color;


class SimpleGlyph implements Element
{
	public var charcode:Int=0;

	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	@sizeX public var w:Int=16;
	@sizeY public var h:Int=16;
	
	public function new(charcode:Int, x:Int, y:Int, w:Int, h:Int) 
	{
		this.charcode = charcode;
		this.x = y;
		this.y = y;
		this.w = w;
		this.h = h;
	}
	
}
