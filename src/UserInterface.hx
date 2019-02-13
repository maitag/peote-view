package;
#if sampleUserInterface
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

class UserInterface 
{
	var peoteView:PeoteView;
	
	public function new(window:Window)
	{
		try {
			
			peoteView = new PeoteView(window.context, window.width, window.height);
			var display   = new Display(10, 10, window.width - 20, window.height - 20, Color.GREEN);
			peoteView.addDisplay(display);
			//display.addProgram(UI);  
		
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}
	
	public function onPreloadComplete ():Void { trace("preload complete"); }
	
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
	}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			//case KeyCode.NUMPAD_PLUS:
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