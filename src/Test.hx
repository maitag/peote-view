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
	var element:ElementSimple;
	var buffer:Buffer<ElementSimple>;
	
	public function new(window:Window)
	{
		try {
		peoteView = new PeoteView(window.context, window.width, window.height);
		
		buffer = new Buffer<ElementSimple>(100);

		var display   = new Display(10,10, window.width-20, window.height-20, Color.GREEN);
		var display1  = new Display(10,10, window.width-20, window.height-20, Color.GREEN);
		var program   = new Program(buffer);
		
		peoteView.addDisplay(display1);
		display1.addProgram(program);
		
		display.addProgram(program);  
		peoteView.addDisplay(display);
	
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
		} catch (e:Dynamic) trace("ERROR:", e);
	}
	
	public function onPreloadComplete ():Void { trace("preload complete"); }
	
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		element.x += 100;
		buffer.updateElement(element);		
	}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			//case KeyCode.:
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