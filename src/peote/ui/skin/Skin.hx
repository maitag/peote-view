package peote.ui.skin;

import peote.ui.UIDisplay;
import peote.ui.UIElement;
import peote.view.Color;
import peote.view.Buffer;
import peote.view.Program;

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
	
	private function addElement(uiDisplay:UIDisplay, uiElement:UIElement)
	{		
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
	
	private function removeElement(uiDisplay:UIDisplay, uiElement:UIElement)
	{
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
	
	private function updateElement(uiDisplay:UIDisplay, uiElement:UIElement)
	{
		var d = displayProgBuff.get(uiDisplay);		
		if (d != null) {
			cast(uiElement.skinElement, SkinElement).update(uiElement, color);
			d.buffer.updateElement( cast(uiElement.skinElement, SkinElement) );
		}
		
	}
}