package peote.ui.skin;

import peote.ui.UIDisplay;
import peote.ui.UIElement;
import peote.view.Color;
import peote.view.Buffer;
import peote.view.Program;

@:allow(peote.ui)
class Skin 
{

	var displayProgBuff= new Map<UIDisplay,{program:Program, buffer:Buffer<SkinElement>}>();
	
	public function new()
	{
	}
	
	private function addElement(uiDisplay:UIDisplay, uiElement:UIElement)
	{		
		var d = displayProgBuff.get(uiDisplay);		
		if (d == null) {
			var buffer = new Buffer<SkinElement>(16, 8);
			d = { program: createProgram(buffer), buffer: buffer };
			displayProgBuff.set(uiDisplay, d);
			uiDisplay.addProgram(d.program);
		}		
		uiElement.skinElement = new SkinElement(uiElement);
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
			cast(uiElement.skinElement, SkinElement).update(uiElement);
			d.buffer.updateElement( cast(uiElement.skinElement, SkinElement) );
		}
		
	}
	
	private function createDefaultStyle():Style {
		return new Style();
	}
	
	private function createProgram(buffer:Buffer<SkinElement>):Program {
		var program = new Program(buffer);
		
		program.injectIntoFragmentShader(
			"
			float roundedFrame (vec2 pos, vec2 size, float radius, float thickness)
			{
				//float d = length(max(abs(pos), size) - size) - radius;
				//return smoothstep(0.55, 0.45, abs(d / thickness) * 100.0);

				//float d = (length(max(abs(pos*100.0), size*100.0) - size*100.0) ) - (radius * 100.0);
				float d = length(max(abs(pos), size) - size)*100.0 - radius*100.0;
				//float d = length(max(abs(pos), size) - size)*100.0 - radius*length(pos*vec2(200.0,100.0));
				return smoothstep(0.55, 0.45, abs(d / thickness));
			}
			
			vec4 compose (vec4 c)
			{
				float intensity = 0.0;
				//--- rounded rectangle ---
				//const vec3 rectColor = vec3(0.1, 0.8, 0.5);
				//pos = vec2(-sin(time), 0.6);
				//size = vec2(0.16, 0.02);
				//intensity = 0.6 * roundedRectangle (pos, size, 0.1, 0.2);
				//col = mix(col, rectColor, intensity);
				
				//--- rounded frame ---
				vec4 frameColor = vec4(1.0, 0.8, 0.6, 1.0);
				float thickness = 5.0;
				float radius = 0.2;
				vec2 pos = vTexCoord - vec2(0.5, 0.5);
				vec2 size = vec2(0.5-radius-(thickness/100.0/2.0), 0.5-radius-(thickness/100.0/2.0));
				intensity = roundedFrame (pos, size, radius, thickness);
				c = mix(c, frameColor, intensity);
				return c;
			}
			"
		);
		program.setColorFormula('compose(color)');

		return program;
	}
}