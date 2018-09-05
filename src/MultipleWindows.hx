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
		
		peoteView_1 = new PeoteView(window.context, window.width, window.height);
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
			createwindow();
		}, 2000);
		
	}
	
	private function createWindow_2():Void
	{
		#if desktop
		var attributes = {	title: "Window_2", x:0, y:0, width: 600, height: 800, resizable:true,
		                    context: { background: 2 }  };
		var window = createWindow(attributes);
		#end
		
		peoteView_2 = new PeoteView(window.context, window.width, window.height);
		display_2   = new Display(10, 10, window.width - 20, window.height - 20);
		display_2.blue = 1.0;
		buffer_2    = new Buffer<ElementSimple>(100);
		program_2   = new Program(buffer_2);
		display_2.addProgram(program_2);
		peoteView_2.addDisplay(display_2);
		
		#if desktop
		window.onRender.add    (onRender_2.bind   (window));
		window.onMouseDown.add (onMouseDown_2.bind(window));
		window.onResize.add    (onResize_2.bind   (window));
		window.onKeyDown.add   (onKeyDown_.bind   (window));
		#end
	}
	
	private function createwindow():Void
	{
		#if desktop
		var attributes = {	title: "window", x:0, y:0, width: 800, height: 580, resizable:true,
		                    context: { background: 3 }  };
		var window = createWindow(attributes);
		#end
		
		peoteView_3 = new PeoteView(window.context, window.width, window.height);
		display_3   = new Display(10, 10, window.width - 20, window.height - 20);
		display_3.green = 1.0;display_3.red = 1.0;
		buffer_3    = new Buffer<ElementSimple>(100);
		program_3   = new Program(buffer_3);
		display_3.addProgram(program_3);
		peoteView_3.addDisplay(display_3);
		
		#if desktop
		window.onRender.add    (onRender_3.bind   (window));
		window.onMouseDown.add (onMouseDown_3.bind(window));
		window.onResize.add    (onResize_3.bind   (window));
		window.onKeyDown.add   (onKeyDown_.bind   (window));
		#end
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
			case KeyCode.D:                                  // switching displays
				if (peoteView_1.hasDisplay(display_1)) {
					peoteView_1.addDisplay(display_2);
					peoteView_2.addDisplay(display_1);
				} else {
					peoteView_1.addDisplay(display_1);
					peoteView_2.addDisplay(display_2);
				}
			case KeyCode.P:                                  // switching programs
				if (display_1.hasProgram(program_1)) {
					display_2.addProgram(program_1);
					display_1.addProgram(program_2);
				} else {
					display_1.addProgram(program_1);
					display_2.addProgram(program_2);
				}
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
