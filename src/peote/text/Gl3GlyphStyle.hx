package peote.text;

import peote.view.Color;

@gl3Font @multiRange @multiTexture 
class Gl3GlyphStyle 
{

	// same as with full GylphStyle
	public var color:Color = Color.GREY1;
	
	public var width:Float = 20;
	public var height:Float = 20;
	
	public var bold:Bool = false;
	public var italic:Bool = false;
	
	
	// special for gl3-font
	public var boldness:Float = 1.0;
	public var sharpness:Float = 1.0;
	
/*	public var borderColor:Color = Color.GREY7;

	public var borderSize:Float = 1.0;
	public var borderRadius:Float = 10.0;
*/	
	public function new() 
	{
		
	}
	
}