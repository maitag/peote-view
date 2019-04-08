package;
import peote.ui.skin.Style;
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
			
			var mySkin = new Skin();
			var myStyle = new Style();
			myStyle.borderColor = Color.GREY6;
			
			trace("NEW BUTTON -----");
			var b1:Button = new Button(10, 0, 200, 100, mySkin, myStyle);
			ui.add(b1);
			
			b1.onMouseOver = function(uiDisplay:UIDisplay, button:Button, x:Int, y:Int) {
				button.style.color = Color.GREY5;
				button.update();
				trace(" -----> onMouseOver", x, y, button.label);
			}
			
			b1.onMouseOut = function(uiDisplay:UIDisplay, button:Button, x:Int, y:Int) {
				button.style.color = Color.GREY1;
				button.update();
				trace(" -----> onMouseOut", x, y, button.label);
			}
			
			b1.onMouseUp = function(uiDisplay:UIDisplay, button:Button, x:Int, y:Int) {
				trace(" -----> onMouseUp", x, y, button.label);
			}
			
			b1.onMouseDown = function(uiDisplay:UIDisplay, button:Button, x:Int, y:Int) {
				button.x += 30;
				button.update();
				trace(" -----> onMouseDown", x, y, button.label);
				ui.onMouseMove(peoteView, x, y);
			}
			
			b1.onMouseClick = function(uiDisplay:UIDisplay, button:Button, x:Int, y:Int) {
				button.y += 30;
				button.update();
				trace(" -----> onMouseClick", x, y, button.label);
				ui.onMouseMove(peoteView, x, y);
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