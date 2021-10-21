package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;


import elements.ElementSimple;

class Multidisplay extends Application
{
	var peoteView:PeoteView;
	var element:ElementSimple;
	var buffer:Buffer<ElementSimple>;
	var displayLeft:Display;
	var displayRight:Display;
	var program:Program;
	var programBG :Program;
	
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	public function startSample(window:Window)
	{	
		peoteView = new PeoteView(window);
		displayLeft  = new Display(0, 0, 400, 400);
		displayLeft.color = Color.BLUE;
		
		displayRight = new Display(400, 0, 400, 400);
		displayRight.color = Color.GREEN;
		
		peoteView.addDisplay(displayLeft);
		peoteView.addDisplay(displayRight);
		
		// Changing order of the Displays into the RenderList:
		// displayRight.x = 150;
		
		// move the right display before the left display
		//peoteView.addDisplay(displayRight, displayLeft, true);
		
		// move the left display to the end of the list
		//peoteView.addDisplay(displayLeft);
		
		buffer  = new Buffer<ElementSimple>(100);
		element = new ElementSimple(100, 100, 100, 100, Color.YELLOW);
		buffer.addElement(element);
		program = new Program(buffer);
		
		displayLeft.addProgram(program);
		
		var bufferBG  = new Buffer<ElementSimple>(100);
		bufferBG.addElement(new ElementSimple(0, 0));
		bufferBG.addElement(new ElementSimple(300, 0));
		bufferBG.addElement(new ElementSimple(300, 300));
		bufferBG.addElement(new ElementSimple(0, 300));
		programBG = new Program(bufferBG);
		
		displayLeft.addProgram(programBG);
		displayRight.addProgram(programBG);
		
		// Changing order of the Programs into the RenderList:
		// displayLeft.addProgram(program);
	}

	// ----------- Lime events ------------------

	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
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
					else if (modifier.shiftKey) displayLeft.zoom += 0.25;					
					else if (modifier.altKey) displayRight.zoom += 0.25;					
					else peoteView.zoom += 0.25;
			case KeyCode.NUMPAD_MINUS:
					if (modifier.ctrlKey) {element.w = Std.int(element.w/2); element.h = Std.int(element.h/2); buffer.updateElement(element);}
					else if (modifier.shiftKey) displayLeft.zoom -= 0.25;
					else if (modifier.altKey) displayRight.zoom -= 0.25;
					else peoteView.zoom -= 0.25;
			
			// hide or show displays		
			case KeyCode.NUMBER_1:
					displayLeft.isVisible = !displayLeft.isVisible;
			case KeyCode.NUMBER_2:
					if (displayRight.isVisible) displayRight.hide() else displayRight.show();
					
			// hide or show programs		
			case KeyCode.NUMBER_3:
					program.isVisible = !program.isVisible;
			case KeyCode.NUMBER_4:
					if (programBG.isVisible) programBG.hide() else programBG.show();
					
			default:
		}
	}


}
