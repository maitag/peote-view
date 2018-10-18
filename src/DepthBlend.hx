package;
import peote.view.Color;

#if sampleDepthBlend
import haxe.Timer;

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;

import peote.view.PeoteGL;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
//import peote.view.Texture;

import elements.ElementSimple;

class DepthBlend 
{
	var peoteView:PeoteView;

	var activeElement:ElementSimple;
	
	var element1:ElementSimple;
	var element2:ElementSimple;
	var element3:ElementSimple;
	var element4:ElementSimple;
	
	var bufferL:Buffer<ElementSimple>;
	var displayL:Display;
	var programL:Program;
	
	var bufferR:Buffer<ElementSimple>;
	var displayR:Display;
	var programR:Program;
	
	public function new(window:Window)
	{	

		peoteView = new PeoteView(window.context, window.width, window.height);
		
		displayL  = new Display(0, 0, 400, 400);
		displayL.color = Color.GREY3;
		bufferL  = new Buffer<ElementSimple>(100);
		programL = new Program(bufferL);
		displayL.addProgram(programL);
		peoteView.addDisplay(displayL);
		
		displayR = new Display(300, 100, 400, 400);
		displayR.color = 0x00FFFF99;
		bufferR  = new Buffer<ElementSimple>(100);
		programR = new Program(bufferR);
		displayR.addProgram(programR);
		peoteView.addDisplay(displayR);
		
		element1 = new ElementSimple(100, 100, 100, 100, 0xFF000033); element1.z = ElementSimple.MAX_ZINDEX;
		element2 = new ElementSimple(150, 150, 100, 100, 0x00FF0044); element2.z = ElementSimple.MAX_ZINDEX;
		bufferL.addElement(element1);
		bufferL.addElement(element2);
		
		element3 = new ElementSimple(100, 100, 100, 100, 0x0000FFaa);
		element4 = new ElementSimple(150, 150, 100, 100, 0xFFFF0022);
		bufferR.addElement(element3);
		bufferR.addElement(element4);
		
		activeElement = element1;
		trace(bufferL.alphaEnabled);
	}

	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		element2.z -= 1;
		element4.z -= 1;
		bufferL.update(); bufferR.update();
	}
	
	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.A: displayR.backgroundAlpha = !displayR.backgroundAlpha;
			case KeyCode.B: displayR.backgroundEnabled = !displayR.backgroundEnabled;
			case KeyCode.X: bufferL.alphaEnabled = !bufferL.alphaEnabled;
			case KeyCode.Y: bufferR.alphaEnabled = !bufferR.alphaEnabled;
			case KeyCode.C: bufferL.zIndexEnabled = !bufferL.zIndexEnabled;
			case KeyCode.V: bufferR.zIndexEnabled = !bufferR.zIndexEnabled;
			case KeyCode.Z: displayR.backgroundDepth = !displayR.backgroundDepth;
			case KeyCode.NUMBER_1: activeElement = element1;
			case KeyCode.NUMBER_2: activeElement = element2;
			case KeyCode.NUMBER_3: activeElement = element3;
			case KeyCode.NUMBER_4: activeElement = element4;
			case KeyCode.LEFT:  activeElement.x -= 10;
			case KeyCode.RIGHT: activeElement.x += 10;
			case KeyCode.UP:    activeElement.y -= 10;
			case KeyCode.DOWN:  activeElement.y += 10;
			case KeyCode.NUMPAD_PLUS: activeElement.z += 1; trace(activeElement.z);
			case KeyCode.NUMPAD_MINUS:activeElement.z -= 1; trace(activeElement.z);
			default:
		}
		bufferL.update(); bufferR.update();
	}

	public function render()
	{
		peoteView.render();
	}

	public function resize(width:Int, height:Int)
	{
		peoteView.resize(width, height);
	}

}
#end