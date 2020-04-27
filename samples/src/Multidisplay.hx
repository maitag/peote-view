package;

#if Multidisplay
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
import peote.view.Color;
//import peote.view.Texture;

import elements.ElementSimple;

class Multidisplay 
{
	var peoteView:PeoteView;

	var element:ElementSimple;
	var buffer:Buffer<ElementSimple>;
	var displayLeft:Display;
	var displayRight:Display;
	var program:Program;
	var programBG :Program;
	
	public function new(window:Window)
	{	

		peoteView = new PeoteView(window.context, window.width, window.height);
		displayLeft  = new Display(0, 0, 400, 400);
		displayLeft.color = Color.BLUE;
		
		displayRight = new Display(400, 0, 400, 400);
		displayRight.color = Color.GREEN;
		
		peoteView.addDisplay(displayLeft);
		peoteView.addDisplay(displayRight);
		
		buffer  = new Buffer<ElementSimple>(100);
		element = new elements.ElementSimple(100, 100);
		buffer.addElement(element);
		program = new Program(buffer);
		
		displayLeft.addProgram(program);
		
		var bufferBG  = new Buffer<ElementSimple>(100);
		bufferBG.addElement(new elements.ElementSimple(0, 0));
		bufferBG.addElement(new elements.ElementSimple(300, 0));
		bufferBG.addElement(new elements.ElementSimple(300, 300));
		bufferBG.addElement(new elements.ElementSimple(0, 300));
		programBG = new Program(bufferBG);
		
		displayLeft.addProgram(programBG);
		displayRight.addProgram(programBG);
		
	}

	public function onPreloadComplete ():Void { trace("preload complete"); }

	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void {}
	public function onMouseMove (x:Float, y:Float):Void {}
	public function onMouseUp (x:Float, y:Float, button:MouseButton):Void {}
	
	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		var steps = 10;
		var esteps = element.w;
		switch (keyCode) {
			case KeyCode.P: //  switch the program to the other display
				if (displayLeft.hasProgram(program)) {
					displayLeft.removeProgram(program);
					displayRight.addProgram(program);
				}
				else {
					displayRight.removeProgram(program);
					displayLeft.addProgram(program);
				}
			case KeyCode.LEFT:
					if (modifier.ctrlKey) {element.x-=esteps; buffer.updateElement(element);}
					else if (modifier.shiftKey) displayLeft.xOffset-=steps;
					else if (modifier.altKey) displayRight.xOffset-=steps;
					else peoteView.xOffset-=steps;
			case KeyCode.RIGHT:
					if (modifier.ctrlKey) {element.x+=esteps; buffer.updateElement(element);}
					else if (modifier.shiftKey) displayLeft.xOffset+=steps;
					else if (modifier.altKey) displayRight.xOffset+=steps;
					else peoteView.xOffset+=steps;
			case KeyCode.UP:
					if (modifier.ctrlKey) {element.y-=esteps; buffer.updateElement(element);}
					else if (modifier.shiftKey) displayLeft.yOffset-=steps;
					else if (modifier.altKey) displayRight.yOffset-=steps;
					else peoteView.yOffset-=steps;
			case KeyCode.DOWN:
					if (modifier.ctrlKey) {element.y+=esteps; buffer.updateElement(element);}
					else if (modifier.shiftKey) displayLeft.yOffset+=steps;
					else if (modifier.altKey) displayRight.yOffset+=steps;
					else peoteView.yOffset+=steps;
			case KeyCode.NUMPAD_PLUS:
					if (modifier.ctrlKey) {element.w*=2; element.h*=2; buffer.updateElement(element);}
					else if (modifier.shiftKey) displayLeft.zoom+=0.25;
					else if (modifier.altKey) displayRight.zoom+=0.25;
					else peoteView.zoom+=0.25;
			case KeyCode.NUMPAD_MINUS:
					if (modifier.ctrlKey) {element.w = Std.int(element.w/2); element.h = Std.int(element.h/2); buffer.updateElement(element);}
					else if (modifier.shiftKey) displayLeft.zoom-=0.25;
					else if (modifier.altKey) displayRight.zoom-=0.25;
					else peoteView.zoom-=0.25;
			default:
		}
	}

	public function render() peoteView.render();
	public function update(deltaTime:Int):Void {}
	
	public function resize(width:Int, height:Int) peoteView.resize(width, height);

}
#end