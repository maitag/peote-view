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
	
	public var colorGlyphProgram:Program;
	public var colorGlyphBuffer:Buffer<ColorGlyph>;
	
	//public var styledGlyphProgram:Program;
	//public var styledGlyphBuffer:Buffer<StyledGlyph>;
	
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
		
		colorGlyphBuffer = new Buffer<ColorGlyph>(100);		
		colorGlyphProgram = new Program(colorGlyphBuffer);
		
		// TODO: inject global fontsize and color into shader
		
		
		// set texture
		
		// colorformula
		
		
		
	}
	
	// monospace with global size and color
	public function createLetter(charCode:Int, x:Int, y:Int):SimpleGlyph {
		var glyph = new SimpleGlyph(charCode, x, y);
		simpleGlyphBuffer.addElement(glyph);
		return (glyph);
	}
	
	// monospace with global size individual colors per Letter
	public function createColoredLetter(charCode:Int, x:Int, y:Int, color:Color):ColorGlyph {
		var glyph = new ColorGlyph(charCode, x, y, color);
		colorGlyphBuffer.addElement(glyph);
		return (glyph);
	}
	
}