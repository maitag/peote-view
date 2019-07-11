package peote.text;

import peote.view.Color;


class GlyphStyle 
{

	public var color:Color = Color.GREY1;
	public var bgColor:Color = Color.MAGENTA; // TODO
	
	public var width:Int = 16;
	public var height:Int = 16;
	
	public var rotation:Int = 0;
		
	public var bold:Bool = false;
	public var italic:Bool = false;
	
	
	public function new() 
	{
		
	}
	
}