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
	var readyToRender_1:Bool = false;
	
	var peoteView_2:PeoteView;
	var display_2  :Display;
	var program_2  :Program;
	var buffer_2   :Buffer<ElementSimple>;
	var readyToRender_2:Bool = false;
	
	public function new() {	super(); }
	
	public override function onWindowCreate():Void {

		peoteView_1 = new PeoteView(  window.context.gl,  window.width,  window.height);
		display_1   = new Display(10, 10, window.width - 20, window.height - 20);
		display_1.green = 1.0;
		buffer_1    = new Buffer<ElementSimple>(100);
		program_1   = new Program(buffer_1);
		display_1.addProgram(program_1);    // programm to display
		peoteView_1.addDisplay(display_1);  // display to peoteView
		
		window.onRender.add    (onRender_1.bind (window));
		window.onMouseDown.add (onMouseDown_1.bind (window));
		window.onResize.add    (onResize_1.bind (window));
		window.onKeyDown.add   (onKeyDown_.bind (window));
		window.context.attributes.background = 1;
		
		readyToRender_1 = true;
		
		Timer.delay( function() {
			createWindow_2();
		}, 3000);
	}
	
	private function createWindow_2():Void
	{
		var attributes = {	title: "Window_2", x:0, y:0, width: 600, height: 800, resizable:true,
		                    context: { background: 2 }  };
		var window_2 = createWindow(attributes);
		
		window_2.onRender.add    (onRender_2.bind   (window_2));
		window_2.onMouseDown.add (onMouseDown_2.bind(window_2));
		window_2.onResize.add    (onResize_2.bind   (window_2));
		window_2.onKeyDown.add   (onKeyDown_.bind   (window_2));
		
		peoteView_2 = new PeoteView(  window_2.context.gl,  window_2.width,  window_2.height);
		display_2   = new Display(10, 10, window_2.width - 20, window_2.height - 20);
		display_2.blue = 1.0;
		buffer_2    = new Buffer<ElementSimple>(100);
		program_2   = new Program(buffer_2);
		display_2.addProgram(program_2);    // programm to display
		peoteView_2.addDisplay(display_2);  // display to peoteView
		
		readyToRender_2 = true;
	}
	
	// ------------------------------------------------------------	
	// ----------- spawn new element on mouse down ----------------
	// ------------------------------------------------------------	
	var trigger = false;
	var elem_1:Int = 0;
	private function onMouseDown_1 (window:Window, x:Float, y:Float, button:MouseButton):Void
	{
		trace("onMouseDown_1:", window.context.attributes.background); 
		/*
		readyToRender_1 = false;
		buffer_1.addElement(new ElementSimple(10 + 12 * elem_2++, 10, 10, 10));
		readyToRender_1 = true;
		*/
		trigger = true;
	}
	
	var elem_2:Int = 0;
	private function onMouseDown_2 (window:Window, x:Float, y:Float, button:MouseButton):Void
	{	
		trace("onMouseDown_2:", window.context.attributes.background);
		readyToRender_2 = false;
		buffer_2.addElement(new ElementSimple(5, 5 + 12 * elem_1++, 10, 10));
		readyToRender_2 = true;
	}
	
	// ------------------------------------------------------------	
	// ----------- Render Loops -----------------------------------
	// ------------------------------------------------------------	
	private function onRender_1 (window:Window, context:RenderContext):Void
	{
		if (trigger) { trigger = false; buffer_1.addElement(new ElementSimple(10 + 12 * elem_2++, 10, 10, 10)); }
		if (readyToRender_1) peoteView_1.render();
	}
	
	private function onRender_2 (window:Window, context:RenderContext):Void
	{	
		if (readyToRender_2) peoteView_2.render();
	}

	// ------------------------------------------------------------	
	// ----------- resize events ----------------------------------
	// ------------------------------------------------------------	
	private function onResize_1 (window:Window, width:Int, height:Int):Void
	{
		if (readyToRender_1) peoteView_1.resize(width, height);
	}
	
	
	private function onResize_2 (window:Window, width:Int, height:Int):Void
	{
		if (readyToRender_2) peoteView_2.resize(width, height);
	}

	
	
	// ------------------------------------------------------------	
	// ----------- fullscreen keyboardhandler ---------------------
	// ------------------------------------------------------------	
	private function onKeyDown_ (window:Window, keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.F:
				window.fullscreen = !window.fullscreen;
			default:
		}
	}
	
	
	
}
