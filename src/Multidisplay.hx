import haxe.Timer;
import peote.view.PeoteGL;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
//import peote.view.Texture;

import elements.ElementSimple;

class Multidisplay 
{
	var peoteView:PeoteView;

	public function new(gl:PeoteGL, width:Int, height:Int)
	{	

		peoteView = new PeoteView(gl, width, height);
		var displayLeft  = new Display(10, 10, 280, 280);
		displayLeft.blue = 1.0;
		
		var displayRight = new Display(300, 10, 280, 280);
		displayRight.green = 1.0;
		
		var buffer    = new Buffer<ElementSimple>(100);

		var element  = new elements.ElementSimple(20, 20);
		buffer.addElement(element);

		var program   = new Program(buffer);
		
		peoteView.addDisplay(displayLeft);
		peoteView.addDisplay(displayRight);
		
		displayLeft.addProgram(program);
		
		Timer.delay(function() { // switch the program to the other display
			displayRight.addProgram(program);
		}, 1000);
		Timer.delay(function() { // switch the program to the other display
			displayLeft.addProgram(program);
		}, 2000);
		
		
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