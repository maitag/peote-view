package;

#if sampleAnimation
import haxe.Timer;

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;

import elements.ElementAnim;


import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
//import peote.view.Texture;


class Animation 
{
	var peoteView:PeoteView;
	var element:ElementAnim;
	var buffer:Buffer<ElementAnim>;
	
	public function new(window:Window)
	{	
		peoteView = new PeoteView(window.context, window.width, window.height);
		
		buffer = new Buffer<ElementAnim>(100);

		var display   = new Display(10,10, window.width-20, window.height-20); display.color = Color.GREEN;
		var program   = new Program(buffer);
		
		peoteView.addDisplay(display);  // display to peoteView
		display.addProgram(program);    // programm to display
	
		element  = new ElementAnim();
		buffer.addElement(element);     // element to buffer
		
		// --------------------------
		peoteView.start();
		
		element.setPosSize(20, 0, 50, 50);
		
		element.animPosition(10, 400);
		element.animColor(Color.RED, 0x0000FF00);
		element.timePosition(0.0, 6.0);

		element.setPivot(25, 25);
		
		element.animRotation(0, 45);
		element.timeRotation(1.0, 1.0);
		
		buffer.updateElement(element);
				
		Timer.delay(function() {
			element.animSize(50,50,100,100);
			element.animPivot(25, 25, 50, 0);
			element.animRotation(45, -90);
			element.timeRotation(peoteView.time, 1.0);
			element.timeSize(peoteView.time , 1);
			buffer.updateElement(element);
		}, 3000);
	}
	
	// ---------------------------------------------------------------
	
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		element.x += 100;
		element.cStart.randomize();
		element.cEnd.randomize();
		buffer.updateElement(element);
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
#end