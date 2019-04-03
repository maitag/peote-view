package peote.ui;

import peote.view.Element;

@:allow(peote.ui)
class Pickable implements Element
{
	public var uiElement:UIElement; 
	
	@posX public var x:Int=0;
	@posY public var y:Int=0;	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	@zIndex public var z:Int = 0;	
	var OPTIONS = { picking:true };
	
	private function new(uiElement:UIElement, x:Int, y:Int, w:Int, h:Int, z:Int )
	{
		this.uiElement = uiElement;
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.z = z;
	}

}
