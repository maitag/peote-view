package peote.text;
import peote.view.Element;
import peote.view.Color;


class MonoGlyph implements Element
{
	public var charcode:Int=0;

	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	@sizeX @const public var w:Int=16;
	@sizeY @const public var h:Int=16;
	
	public function new(charcode:Int, x:Int, y:Int) 
	{
		this.charcode = charcode;
		this.x = y;
		this.y = y;
	}
	
}
