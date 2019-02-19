package;
#if sampleTest
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

class Test 
{
	var peoteView:PeoteView;
	var element = new Array<ElementSimple>();
	var buffer:Buffer<ElementSimple>;
	
	var elemNumber:Int = 0;
	
	public function new(window:Window)
	{
		try {
			
			peoteView = new PeoteView(window.context, window.width, window.height);
			
			buffer = new Buffer<ElementSimple>(4, 4, true);

			var display   = new Display(10,10, window.width-20, window.height-20, Color.GREEN);
			var program   = new Program(buffer);
			
			peoteView.addDisplay(display);
			display.addProgram(program);  
		
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}
	
	public function onPreloadComplete ():Void { trace("preload complete"); }
	
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		element[elemNumber]  = new ElementSimple(10+elemNumber*50, 10, 40, 40);
		buffer.addElement(element[elemNumber]);
		elemNumber++; trace("elements " + elemNumber);
	}

	public function onMouseMove (x:Float, y:Float):Void {}
	public function onWindowLeave ():Void {}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.NUMPAD_PLUS:
				element[elemNumber]  = new ElementSimple(10+elemNumber*50, 10, 40, 40);
				buffer.addElement(element[elemNumber]);
				elemNumber++; trace("elements " + elemNumber);
			case KeyCode.NUMPAD_MINUS:
				elemNumber--;  trace("elements " + elemNumber);
				buffer.removeElement(element[elemNumber]);
				element[elemNumber] = null;
			default:
		}
	}
	
	public function update(deltaTime:Int):Void {}
	public function onMouseUp (x:Float, y:Float, button:MouseButton):Void {}

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