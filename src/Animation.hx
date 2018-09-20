package;

import haxe.Timer;

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
//import peote.view.Texture;

import elements.ElementAnim;

class Animation 
{
	var peoteView:PeoteView;
	var element:ElementAnim;
	var buffer:Buffer<ElementAnim>;
	
	public function new(window:Window)
	{	


		peoteView = new PeoteView(window.context, window.width, window.height);
		
		buffer = new Buffer<ElementAnim>(100);

		var display   = new Display(10,10, window.width-20, window.height-20); display.green = 1.0;
		var program   = new Program(buffer);
		
		peoteView.addDisplay(display);  // display to peoteView
		display.addProgram(program);    // programm to display
	
		element  = new ElementAnim(10, 10);
		buffer.addElement(element);     // element to buffer
		/*
		element.animPosition(10,10,100,100);
		element.timePosition(2, 3);
		*/
		element.x = 100;
		element.y = 100;
		element.w = 20;
		element.h = 20;
		buffer.updateElement(element);
		
		// ---------------------------------------------------------------
		//peoteView.render();
		
	}
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
	}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			//case KeyCode.:
			default:
		}
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