package peote.ui.skin;

import peote.view.Element;
import peote.view.Color;

@:allow(peote.ui)
class SkinElement implements Element
{
	// TODO optimizing: generate index inside macro and update that index while add/remove-Element inside Buffer
	// @index public var buffIndex:Int;
	
	@color public var c:Color;
	
	@posX public var x:Int=0;
	@posY public var y:Int=0;	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	@zIndex public var z:Int = 0;	
	//var OPTIONS = {  };
	
	public function new(uiElement:UIElement, color:Color )
	{
		update(uiElement, color);
	}
	
	private inline function update(uiElement:UIElement, color:Color )
	{
		x = uiElement.x;
		y = uiElement.y;
		w = uiElement.w;
		h = uiElement.h;
		z = uiElement.z;
		c = (uiElement.color != null) ? uiElement.color : color;
	}
}
