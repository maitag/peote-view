package peote.ui.skin;

import peote.view.Element;
import peote.view.Color;

@:allow(peote.ui)
class SkinElement implements Element
{
	// from style
	@color public var color:Color;
	@color public var borderColor:Color;
	
	@custom @varying public var borderSize:Float;
	@custom @varying public var borderRadius:Float;
	
	@posX public var x:Int=0;
	@posY public var y:Int=0;	
	@sizeX @varying public var w:Int=100;
	@sizeY @varying public var h:Int=100;
	@zIndex public var z:Int = 0;	
	//var OPTIONS = {  };
	
	public function new(uiElement:UIElement)
	{
		update(uiElement);
	}
	
	private inline function update(uiElement:UIElement)
	{
		x = uiElement.x;
		y = uiElement.y;
		w = uiElement.w;
		h = uiElement.h;
		z = uiElement.z;
		color = uiElement.style.color;
		borderColor = uiElement.style.borderColor;
		borderSize = uiElement.style.borderSize;
		borderRadius = uiElement.style.borderRadius;
	}
}
