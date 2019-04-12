package peote.ui.skin;

import peote.view.Element;
import peote.view.Color;

@:allow(peote.ui)
class SkinElement implements Element
{
	// TODO optimizing: generate index inside macro and update that index while add/remove-Element inside Buffer
	// @index public var buffIndex:Int;
	
	// from style
	@color("color") public var color:Color;
	@color("borderColor") public var borderColor:Color;
	
	//@custom("borderSize")   public var borderSize:Float;
	//@custom("borderRadius") public var borderRadius:Float;
	//@custom("borderColor")  public var borderColor:Float;
	
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
	}
}
