package peote.text;

import peote.view.Color;
import peote.view.Buffer;
import peote.view.Program;

class Glyphes
{

	
	public var font:Font;
	public var color:Color;
	
	public var letterWidth:Int;
	public var letterHeight:Int;
	
	public var program:Program;
	public var buffer:Buffer<Glyph>;
	
	public function new(font:Font, letterWidth:Null<Int>, letterHeight:Null<Int>,  color:Color = Color.BLACK)
	{
		if (letterWidth == null) {
			// use default from Font
		} else this.letterWidth = letterWidth;
		if (letterHeight == null) {
			// use default from Font
		} else this.letterHeight = letterHeight;
		
		
		this.font = font;
		this.color = color;
		
		buffer = new Buffer<Glyph>(100);
		program = new Program(buffer);		
		
		// TODO: inject global fontsize and color into shader
		
		
		// set texture
		
		// colorformula
		
		
		
	}
	
	public inline function add(glyph:Glyph) {
		buffer.addElement(glyph);
	}
	
}