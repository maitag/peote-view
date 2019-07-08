package peote.text;

import peote.view.Element;
import peote.view.Program;
import peote.view.Color;


class ColorGlyph implements Element
{
	public var charcode:Int=0; // TODO: get/set to change the Tile at unicode-range

	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	@sizeX @const public var w:Float=16.0;
	@sizeY @const public var h:Float=16.0;
	
	@color public var color:Color;
	
	public function new(charcode:Int, x:Int, y:Int) 
	{
		this.charcode = charcode;
		this.x = x;
		this.y = y;
	}
	
	public static function setGlobalStyle(program:Program, style:GlyphStyle) {
		// inject global fontsize and color into shader
		program.setFormula("w", '${style.width}');
		program.setFormula("h", '${style.height}');
		program.setColorFormula('${style.color.toGLSL()}');
	}
	
}