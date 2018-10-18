package;

#if sampleGLPicking
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

class GLPicking 
{
	var peoteView:PeoteView;

	var element:ElementSimple;
	var buffer:Buffer<ElementSimple>;
	var programLeft:Program;
	var programRight:Program; 
	
	public function new(window:Window)
	{	

		peoteView = new PeoteView(window.context, window.width, window.height, Color.GREY1);
		var displayLeft  = new Display(10, 10, 280, 280, Color.BLUE);
		var displayRight = new Display(300, 10, 280, 280, Color.YELLOW);
		
		peoteView.addDisplay(displayLeft);
		peoteView.addDisplay(displayRight);
		
		buffer   = new Buffer<ElementSimple>(100);

		element  = new elements.ElementSimple(20, 20);
		buffer.addElement(element);

		
		programLeft  = new Program(buffer);
		programRight = new Program(buffer);
		
		displayLeft.addProgram(programLeft);
		displayRight.addProgram(programRight);
		
		
		
		var timer = new Timer(60);
		timer.run =  function() {
			element.x++; buffer.updateElement(element);		
		};
		
		
	}

	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		// TODO
		// TODO
		// TODO
		var pickedElement = buffer.pickElementAt(Std.int(x), Std.int(y), programLeft);
		if (pickedElement != null) pickedElement.y += 100;
	}
	
	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		
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