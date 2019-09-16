package peote.ui.skin;

import peote.ui.UIDisplay;
import peote.ui.UIElement;
import peote.view.Buffer;
import peote.view.Program;

@:allow(peote.ui)
class Skin 
{
	var displayProgBuff = new Map<UIDisplay,{program:Program, buffer:Buffer<SkinElement>}>();
	
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
		var skinElement = new SkinElement(uiElement);
		d.buffer.addElement(skinElement);
		uiElement.skinElementIndex = d.buffer.getElementIndex(skinElement);
	}
	
	private function removeElement(uiDisplay:UIDisplay, uiElement:UIElement)
	{
		var d = displayProgBuff.get(uiDisplay);		
		if (d != null) {
			d.buffer.removeElement( d.buffer.getElement(uiElement.skinElementIndex) );
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
			var skinElement = d.buffer.getElement(uiElement.skinElementIndex);
			skinElement.update(uiElement);
			d.buffer.updateElement( skinElement );
		}
		
	}
	
	private function createDefaultStyle():Style {
		return new Style();
	}
	
	private function createProgram(buffer:Buffer<SkinElement>):Program {
		var program = new Program(buffer);
		
		// ------- ShaderStyle -------------
		
		program.injectIntoFragmentShader(
			"
			float roundedBox (vec2 pos, vec2 size, float padding, float radius)
			{
				radius -= padding;
				pos = (pos - 0.5) * size;
				size = 0.5 * size - vec2(radius, radius) - vec2(padding, padding);
				
				float d = length(max(abs(pos), size) - size) - radius;
				//return d;
				//return step(0.5, d );
				return smoothstep( 0.0, 1.0,  d );
			}
			
			float roundedBorder (vec2 pos, vec2 size, float thickness, float radius)
			{
				
				radius -= thickness / 2.0;
				pos = (pos - 0.5) * size;
				size = 0.5 * (size - vec2(thickness, thickness)) - vec2(radius, radius);
				
				float s = 0.5 / thickness * 2.0;
				
				float d = length(max(abs(pos), size) - size) - radius;				
				//return 1.0 - abs( d / thickness );
				//return 1.0 - step(0.5, abs( d / thickness ));
				return smoothstep( 0.5+s, 0.5-s, abs(d / thickness)  );
				//return smoothstep( 0.5+s, 0.5-s, abs( d / thickness ) * (1.0 + s) );
			}
			
			vec4 compose (vec4 c, vec4 borderColor, float borderSize, float borderRadius)
			{
				float radius =  max(borderSize+1.0, min(borderRadius, min(vSize.x, vSize.y) / 2.0));
				
				// rounded rectangle
				c = mix(c, vec4(0.0, 0.0, 0.0, 0.0), roundedBox(vTexCoord, vSize, borderSize, radius));				
				// border
				c = mix(c, borderColor, roundedBorder(vTexCoord, vSize, borderSize, radius));
				
				return c;
			}
			"
		);
		
		program.setColorFormula('compose(color, borderColor, borderSize, borderRadius)');
		program.discardAtAlpha(0.8);
		return program;
	}
}