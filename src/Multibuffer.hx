package;

#if sampleMultibuffer
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

class Multibuffer
{
	var peoteView:PeoteView;

	public function new(window:Window)
	{	

		peoteView = new PeoteView(window.context, window.width, window.height);
		var displayLeft  = new Display(10, 10, 280, 280);
		displayLeft.color = Color.BLUE;
		
		var displayRight = new Display(300, 10, 280, 280);
		displayRight.color = Color.GREEN;
		
		var bufferLeft = new Buffer<ElementSimple>(100);
		var bufferRight = new Buffer<ElementSimple>(100);

		var programLeft   = new Program(bufferLeft);
		var programRight   = new Program(bufferRight);
		
		displayLeft.addProgram(programLeft);
		displayRight.addProgram(programRight);
		
		peoteView.addDisplay(displayLeft);
		peoteView.addDisplay(displayRight);		
		
		var elementLeft  = new elements.ElementSimple(10, 10);
		bufferLeft.addElement(elementLeft);

		var elementRight  = new elements.ElementSimple(10, 10);
		bufferRight.addElement(elementRight);
			
			
		Timer.delay(function() { 
			bufferLeft.addElement(new elements.ElementSimple(10, 120));
		}, 1000);
		Timer.delay(function() { 
			bufferRight.addElement(new elements.ElementSimple(10, 120));
		}, 2000);
		
		
	}

	public function onPreloadComplete ():Void { trace("preload complete"); }

	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void	{}
	public function onMouseMove (x:Float, y:Float):Void {}
	public function onWindowLeave ():Void {}

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