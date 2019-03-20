package;
#if sampleUserInterface
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;

import peote.view.PeoteView;
import peote.view.Color;
import peote.ui.UIDisplay;
import peote.ui.Button;


class UserInterface 
{
	var peoteView:PeoteView;
	var ui:UIDisplay;
	
	public function new(window:Window)
	{
		try {			
			peoteView = new PeoteView(window.context, window.width, window.height);
			ui = new UIDisplay(0, 0, window.width, window.height, Color.GREEN);
			peoteView.addDisplay(ui);
			
			trace("NEW BUTTON -----");
			var b1:Button = new Button(10, 10, 100, 20);
			
			b1.test();
			
			trace("ADD 1 onMouseClick -----");
			b1.onMouseClick = function(uiDisplay:UIDisplay, button:Button, x:Int, y:Int) {
				trace(" -----> b1 on click", button.label);
			}
			
			b1.test();
			
			trace("REMOVE onMouseClick-----");
			b1.onMouseClick = null;
			
			b1.test();
			
			trace("ADD 2 onMouseClick -----");
			b1.onMouseClick = function(uiDisplay:UIDisplay, button:Button, x:Int, y:Int) {
				trace(" -----> b2 on click", button.label);
			}
			
			b1.test();
			
			ui.add(b1);
			ui.remove(b1);
			ui.update(b1);
			ui.updateAll();
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}
	
	// --------------------------------------------------

	// delegate mouse-events to UIDisplay
	public function onWindowLeave () ui.onWindowLeave();
	public function onMouseMove (x:Float, y:Float) ui.onMouseMove(peoteView, x, y);
	public function onMouseDown (x:Float, y:Float, button:MouseButton) ui.onMouseDown(peoteView, x, y, button);
	public function onMouseUp (x:Float, y:Float, button:MouseButton) ui.onMouseUp(peoteView, x, y, button);
	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier) ui.onKeyDown(keyCode, modifier);
	
	public function render() peoteView.render();
	public function resize(width:Int, height:Int) peoteView.resize(width, height);
	
	public function onPreloadComplete ():Void { trace("preload complete"); }
	public function update(deltaTime:Int):Void {}
}
#end