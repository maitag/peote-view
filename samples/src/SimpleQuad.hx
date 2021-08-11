package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;

import elements.ElementSimple;

class SimpleQuad extends Application
{
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
		var peoteView = new PeoteView(window);
		
		var buffer = new Buffer<ElementSimple>(4, 4, true);

		var display   = new Display(10,10, window.width-20, window.height-20, Color.GREEN);
		var program   = new Program(buffer);
		
		peoteView.addDisplay(display);
		display.addProgram(program);
		
		var element = new ElementSimple();
		buffer.addElement(element);		
	}
		
}