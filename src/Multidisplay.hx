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
		var displayLeft  = new Display();
		displayLeft.x = 10;
		displayLeft.y = 10;
		displayLeft.width = 280;
		displayLeft.height = 280;
		displayLeft.blue = 1.0;
		
		var displayRight = new Display();
		displayRight.x = 300;
		displayRight.y = 10;
		displayRight.width = 280;
		displayRight.height = 280;
		displayRight.green = 1.0;
		
		var buffer    = new Buffer<ElementSimple>(100);
		var program   = new Program(buffer);
		
		peoteView.addDisplay(displayLeft);
		peoteView.addDisplay(displayRight);
		
		displayLeft.addProgram(program);
		displayRight.addProgram(program);
		
		var element  = new elements.ElementSimple();
		element.x = 20;
		element.y = 20;
		buffer.addElement(element);     // element to buffer
		/*
		var element1  = new elements.ElementSimple();
		element1.x = 10;
		element1.y = 200;
		buffer.addElement(element1);     // element to buffer
		*/
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