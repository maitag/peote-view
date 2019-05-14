package peote.text;
import peote.view.Element;
import peote.view.Color;


class Glyph implements Element
{
	public var charcode:Int=0;

	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	public function new(charcode:Int, x:Int, y:Int) 
	{
		this.charcode = charcode;
		this.x = y;
		this.y = y;
	}
	
}
