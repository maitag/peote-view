package peote.text;
import peote.view.Element;
import peote.view.Color;


class ColorGlyph implements Element
{
	public var charcode:Int=0;

	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	@sizeX @const public var w:Int=16;
	@sizeY @const public var h:Int=16;

	@color public var c:Color;
	
	public function new(charcode:Int, x:Int, y:Int, color:Color) 
	{
		this.charcode = charcode;
		this.x = x;
		this.y = y;
		this.c = color;
	}
	
}
