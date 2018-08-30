import haxe.Timer;
import lime.ui.MouseButton;
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
	var element:ElementSimple;
	var buffer:Buffer<ElementSimple>;
	
	public function new(gl:PeoteGL, width:Int, height:Int)
	{	
		buffer = new Buffer<ElementSimple>(100);

		peoteView = new PeoteView(gl, width, height);
		var display   = new Display(10,10, width-20, height-20); display.green = 1.0;
		var program   = new Program(buffer);
		
		peoteView.addDisplay(display);  // display to peoteView
		display.addProgram(program);    // programm to display
	
		element  = new ElementSimple(10, 10);
		buffer.addElement(element);     // element to buffer
		
		var element1  = new ElementSimple(10, 150);
		buffer.addElement(element1);     // element to buffer
		
		Timer.delay( function() {
			element1.x += 100;
			buffer.updateElement(element1);
		} , 1000);
		
		
		// ---------------------------------------------------------------
		//peoteView.render();
		
	}
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		element.x += 100;
		buffer.updateElement(element);		
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