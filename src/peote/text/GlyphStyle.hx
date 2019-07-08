package peote.text;

import peote.view.Color;


class GlyphStyle 
{

	public var color:Color = Color.GREY1;
	public var width:Null<Float> = null;
	public var height:Null<Float> = null;
	
	public var bold:Bool = false;
	public var italic:Bool = false;
	
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