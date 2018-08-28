import haxe.Timer;
import peote.view.PeoteGL;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
//import peote.view.Texture;

import elements.ElementSimple;

class Test 
{
	var peoteView:PeoteView;

	public function new(gl:PeoteGL, width:Int, height:Int)
	{	

		peoteView = new PeoteView(gl, width, height);
		var display   = new Display(10,10, width-20, height-20); display.green = 1.0;
		var buffer    = new Buffer<ElementSimple>(100);
		var program   = new Program(buffer);
		
		peoteView.addDisplay(display);  // display to peoteView
		display.addProgram(program);    // programm to display
	
		var element  = new ElementSimple(10, 10);
		buffer.addElement(element);     // element to buffer
		
		var element1  = new ElementSimple(10, 150);
		buffer.addElement(element1);     // element to buffer
		
		Timer.delay( function() {
			element.x += 100;
			buffer.updateElement(element);
		} , 1000);
		
		// ---------------------------------------------------------------
		//peoteView.render();
		
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