package peote.ui.skin;

import peote.ui.UIDisplay;
import peote.ui.UIElement;
import peote.view.Color;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Element;

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
	
	public inline function update(uiElement:UIElement, color:Color )
	{
		x = uiElement.x;
		y = uiElement.y;
		w = uiElement.w;
		h = uiElement.h;
		z = uiElement.z;
		c = (uiElement.color != null) ? uiElement.color : color;
	}
}

@:allow(peote.ui)
class Skin 
{

	var color:Color;
	var bgColor:Color;
	
	var displayProgBuff= new Map<UIDisplay,{program:Program, buffer:Buffer<SkinElement>}>();
	
	public function new(color:Color = Color.BLUE, bgColor:Color = Color.YELLOW)
	{
		this.color = color;
		this.bgColor = bgColor;
	}
	
	private function addElement(uiDisplay:UIDisplay, uiElement:UIElement) {
		
		var d = displayProgBuff.get(uiDisplay);		
		if (d == null) {
			var buffer = new Buffer<SkinElement>(16, 8);
			d = { program: new Program(buffer), buffer: buffer }; // TODO: put into createProgram
			displayProgBuff.set(uiDisplay, d);
			uiDisplay.addProgram(d.program);
		}		
		uiElement.skinElement = new SkinElement(uiElement, color);
		d.buffer.addElement(uiElement.skinElement);
	}
	
	private function removeElement(uiDisplay:UIDisplay, uiElement:UIElement) {
		var d = displayProgBuff.get(uiDisplay);		
		if (d != null) {
			d.buffer.removeElement( uiElement.skinElement );
			if (d.buffer.length() == 0) {
				uiDisplay.removeProgram(d.program);
				trace("ui-skin: clear buffer and program");
				// TODO:
				//d.buffer.clear();
				//d.program.clear();
				displayProgBuff.remove(uiDisplay);
			}
		} else throw("Error: can not removeElement() from skin!"); //TODO: this should never be thrown
		
	}
	
	private function updateElement(uiDisplay:UIDisplay, uiElement:UIElement) {
		var d = displayProgBuff.get(uiDisplay);		
		if (d != null) {
			uiElement.skinElement.update(uiElement, color);
			d.buffer.updateElement( uiElement.skinElement );
		}
		
	}
}