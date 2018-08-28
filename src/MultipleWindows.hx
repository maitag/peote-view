package;

import haxe.Timer;

import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.MouseButton;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import elements.ElementSimple;


class MultipleWindows extends Application
{	
	var peoteView_1:PeoteView;
	var display_1  :Display;
	var program_1  :Program;
	var buffer_1   :Buffer<ElementSimple>;
	
	var peoteView_2:PeoteView;
	var display_2  :Display;
	var program_2  :Program;
	var buffer_2   :Buffer<ElementSimple>;
	
	var peoteView_3:PeoteView;
	var display_3  :Display;
	var program_3  :Program;
	var buffer_3   :Buffer<ElementSimple>;
	
	public function new() {	super(); }
	
	public override function onWindowCreate():Void {
		
		window.context.attributes.background = 1;

		peoteView_1 = new PeoteView(  window.context.gl,  window.width,  window.height);
		display_1   = new Display(10, 10, window.width - 20, window.height - 20);
		display_1.green = 1.0;
		buffer_1    = new Buffer<ElementSimple>(100);
		program_1   = new Program(buffer_1);
		display_1.addProgram(program_1);
		peoteView_1.addDisplay(display_1);
		
		window.onRender.add    (onRender_1.bind (window));
		window.onMouseDown.add (onMouseDown_1.bind (window));
		window.onResize.add    (onResize_1.bind (window));
		window.onKeyDown.add   (onKeyDown_.bind (window));
		
		Timer.delay( function() {
			createWindow_2();
		}, 1000);
		Timer.delay( function() {
			createWindow_3();
		}, 2000);
	}
	
	var window_2:Window;
	private function createWindow_2():Void
	{
		var attributes = {	title: "Window_2", x:0, y:0, width: 600, height: 800, resizable:true,
		                    context: { background: 2 }  };
		window_2 = createWindow(attributes);
		
		peoteView_2 = new PeoteView(  window_2.context.gl,  window_2.width,  window_2.height);
		display_2   = new Display(10, 10, window_2.width - 20, window_2.height - 20);
		display_2.blue = 1.0;
		buffer_2    = new Buffer<ElementSimple>(100);
		program_2   = new Program(buffer_2);
		display_2.addProgram(program_2);
		peoteView_2.addDisplay(display_2);
		
		window_2.onRender.add    (onRender_2.bind   (window_2));
		window_2.onMouseDown.add (onMouseDown_2.bind(window_2));
		window_2.onResize.add    (onResize_2.bind   (window_2));
		window_2.onKeyDown.add   (onKeyDown_.bind   (window_2));
	}
	
	var window_3:Window;
	private function createWindow_3():Void
	{
		var attributes = {	title: "Window_3", x:0, y:0, width: 800, height: 580, resizable:true,
		                    context: { background: 3 }  };
		window_3 = createWindow(attributes);
		
		peoteView_3 = new PeoteView(  window_3.context.gl,  window_3.width,  window_3.height);
		display_3   = new Display(10, 10, window_3.width - 20, window_3.height - 20);
		display_3.green = 1.0;display_3.red = 1.0;
		buffer_3    = new Buffer<ElementSimple>(100);
		program_3   = new Program(buffer_3);
		display_3.addProgram(program_3);
		peoteView_3.addDisplay(display_3);
		
		window_3.onRender.add    (onRender_3.bind   (window_3));
		window_3.onMouseDown.add (onMouseDown_3.bind(window_3));
		window_3.onResize.add    (onResize_3.bind   (window_3));
		window_3.onKeyDown.add   (onKeyDown_.bind   (window_3));		
	}
	
	// ------------------------------------------------------------	
	// ----------- spawn new element on mouse down ----------------
	// ------------------------------------------------------------	
	var elem_1:Int = 0;
	private function onMouseDown_1 (window:Window, x:Float, y:Float, button:MouseButton):Void
	{
		trace("onMouseDown_1:", window.context.attributes.background); 
		buffer_1.addElement(new ElementSimple(10 + 12 * elem_1++, 10, 10, 10));
	}
	
	var elem_2:Int = 0;
	private function onMouseDown_2 (window:Window, x:Float, y:Float, button:MouseButton):Void
	{	
		trace("onMouseDown_2:", window.context.attributes.background);
		buffer_2.addElement(new ElementSimple(5, 5 + 12 * elem_2++, 10, 10));
	}
	
	var elem_3:Int = 0;
	private function onMouseDown_3 (window:Window, x:Float, y:Float, button:MouseButton):Void
	{	
		trace("onMouseDown_3:", window.context.attributes.background);
		buffer_3.addElement(new ElementSimple(10 + 12 * elem_3++, 10, 10, 10));
	}
	
	// ------------------------------------------------------------	
	// ----------- Render Loops -----------------------------------
	// ------------------------------------------------------------	
	private function onRender_1 (window:Window, context:RenderContext):Void
	{
		peoteView_1.render();
	}
	
	private function onRender_2 (window:Window, context:RenderContext):Void
	{	
		peoteView_2.render();
	}

	private function onRender_3 (window:Window, context:RenderContext):Void
	{	
		peoteView_3.render();
	}

	// ------------------------------------------------------------	
	// ----------- resize events ----------------------------------
	// ------------------------------------------------------------	
	private function onResize_1 (window:Window, width:Int, height:Int):Void
	{
		peoteView_1.resize(width, height);
	}
	
	
	private function onResize_2 (window:Window, width:Int, height:Int):Void
	{
		peoteView_2.resize(width, height);
	}

	private function onResize_3 (window:Window, width:Int, height:Int):Void
	{
		peoteView_3.resize(width, height);
	}

	
	
	// ------------------------------------------------------------	
	// ----------- fullscreen keyboardhandler ---------------------
	// ------------------------------------------------------------	
	private function onKeyDown_ (window:Window, keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.F:
				window.fullscreen = !window.fullscreen;
			case KeyCode.NUMBER_1:
				Timer.delay( function() {
					buffer_1.addElement(new ElementSimple(10 + 12 * elem_1++, 10, 10, 10));
				}, 100);
			case KeyCode.NUMBER_2:
				Timer.delay( function() {
					buffer_2.addElement(new ElementSimple(5, 5 + 12 * elem_2++, 10, 10));
				}, 200);
			case KeyCode.NUMBER_3:
				Timer.delay( function() {
					buffer_3.addElement(new ElementSimple(10 + 12 * elem_3++, 10, 10, 10));
				}, 300);
			default:
		}
	}
	
	
	
}
