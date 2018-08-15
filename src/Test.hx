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
		var display   = new Display();
		var buffer    = new Buffer<ElementSimple>(100);
		var program   = new Program(buffer);
		
		peoteView.addDisplay(display);  // display to peoteView
		display.addProgram(program);    // programm to display

		var element  = new elements.ElementSimple();
		element.x = 10;
		element.y = 20;
		buffer.addElement(element);     // element to buffer
		
		var element1  = new elements.ElementSimple();
		element1.x = 10;
		element1.y = 200;
		buffer.addElement(element1);     // element to buffer
		
		/*
		element.x = 100;
		element1.x =100;
		
		buffer.updateElement(element);
		buffer.updateElement(element1);
		*/
		
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