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
	
	public var simpleGlyphProgram:Program;
	public var simpleGlyphBuffer:Buffer<SimpleGlyph>;
	
	public var monoGlyphProgram:Program;
	public var monoGlyphBuffer:Buffer<MonoGlyph>;
	
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
		
		// TODO: create on demand ?
		simpleGlyphBuffer = new Buffer<SimpleGlyph>(100);		
		simpleGlyphProgram = new Program(simpleGlyphBuffer);
		
		monoGlyphBuffer = new Buffer<MonoGlyph>(100);		
		monoGlyphProgram = new Program(monoGlyphBuffer);
		
		// TODO: inject global fontsize and color into shader
		
		
		// set texture
		
		// colorformula
		
		
		
	}
	
	public function createSimpleLetter(charCode:Int, x:Int, y:Int, w:Int, h:Int):SimpleGlyph {
		var glyph = new SimpleGlyph(charCode, x, y, w, h);
		simpleGlyphBuffer.addElement(glyph);
		return (glyph);
	}
	
	public function createMonoLetter(charCode:Int, x:Int, y:Int):MonoGlyph {
		var glyph = new MonoGlyph(charCode, x, y);
		monoGlyphBuffer.addElement(glyph);
		return (glyph);
	}
	
}