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
import peote.ui.skin.Skin;

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
			
			var mySkin = new Skin(Color.GREY3);
			
			trace("NEW BUTTON -----");
			var b1:Button = new Button(10, 0, 300, 200, mySkin);
			ui.add(b1);
			
			b1.onMouseOver = function(uiDisplay:UIDisplay, button:Button, x:Int, y:Int) {
				trace(" -----> onMouseOver", button.label);
			}
			
			b1.onMouseOut = function(uiDisplay:UIDisplay, button:Button, x:Int, y:Int) {
				trace(" -----> onMouseOut", button.label);
			}
			
			b1.onMouseUp = function(uiDisplay:UIDisplay, button:Button, x:Int, y:Int) {
				trace(" -----> onMouseUp", button.label);
			}
			
			b1.onMouseDown = function(uiDisplay:UIDisplay, button:Button, x:Int, y:Int) {
				trace(" -----> onMouseDown", button.label);
			}
			
			b1.onMouseClick = function(uiDisplay:UIDisplay, button:Button, x:Int, y:Int) {
				trace(" -----> onMouseClick", button.label);
			}
			
			//trace("REMOVE onMouseClick -----"); b1.onMouseClick = null;	
			//ui.remove(b1);
			//ui.add(b1);
						
			//ui.update(b1);
			//ui.updateAll();
			
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