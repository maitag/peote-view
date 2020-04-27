package;
#if SimpleQuad
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

class SimpleQuad 
{
	var peoteView:PeoteView;
	
	public function new(window:Window)
	{
		try {
			
			peoteView = new PeoteView(window.context, window.width, window.height);
			
			var buffer = new Buffer<ElementSimple>(4, 4, true);

			var display   = new Display(10,10, window.width-20, window.height-20, Color.GREEN);
			var program   = new Program(buffer);
			
			peoteView.addDisplay(display);
			display.addProgram(program);
			
			var element = new ElementSimple();
			buffer.addElement(element);
			
		
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}
		
	public function onPreloadComplete ():Void { trace("preload complete"); }
	
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void {}
	public function onMouseMove (x:Float, y:Float):Void {}
	public function onMouseUp (x:Float, y:Float, button:MouseButton):Void {}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void {}

	public function render() peoteView.render();
	public function update(deltaTime:Int):Void {}

	public function resize(width:Int, height:Int) peoteView.resize(width, height);

}
#end