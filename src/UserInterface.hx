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
			ui = new UIDisplay(0, 0, window.width, window.height, Color.BLACK);
			peoteView.addDisplay(ui);
			
			var mySkin = new Skin();
			var myStyle = new Style();
			myStyle.color = Color.GREY1;
			myStyle.borderColor = Color.GREY5;
			
			trace("NEW BUTTON -----");
			var b1:Button = new Button(20, 10, 200, 100, mySkin, myStyle);
			ui.add(b1);
			
			b1.onMouseOver = onOver.bind(Color.GREY2);
			b1.onMouseOut = onOut.bind(Color.GREY1);
			b1.onMouseUp = onUp.bind(Color.GREY5);
			b1.onMouseDown = onDown.bind(Color.YELLOW);
			b1.onMouseClick = onClick;
			
			trace("NEW BUTTON -----");
			var b2:Button = new Button(20, 120, 200, 100, mySkin, myStyle);
			ui.add(b2);
			
			b2.onMouseOver = onOver.bind(Color.GREY2);
			b2.onMouseOut = onOut.bind(Color.GREY1);
			b2.onMouseUp = onUp.bind(Color.GREY5);
			b2.onMouseDown = onDown.bind(Color.RED);
			b2.onMouseClick = onClick;
			
			//trace("REMOVE onMouseClick -----"); b1.onMouseClick = null;	
			//ui.remove(b1);
			//ui.add(b1);
						
			//ui.update(b1);
			//ui.updateAll();
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}
	
	// --------------------------------------------------
	public function onOver(color:Color, uiDisplay:UIDisplay, button:Button, x:Int, y:Int) {
		button.style.color = color;
		button.style.borderColor = Color.GREY7;
		button.update();
		trace(" -----> onMouseOver", x, y, button.label);
	}
	
	public function onOut(color:Color, uiDisplay:UIDisplay, button:Button, x:Int, y:Int) {
		button.style.color = color;
		button.style.borderColor = Color.GREY5;
		button.update();
		trace(" -----> onMouseOut", x, y, button.label);
	}
	
	public function onUp(borderColor:Color, uiDisplay:UIDisplay, button:Button, x:Int, y:Int) {
		button.style.borderColor = borderColor;
		button.update();
		trace(" -----> onMouseUp", x, y, button.label);
	}
	
	public function onDown(borderColor:Color, uiDisplay:UIDisplay, button:Button, x:Int, y:Int) {
		button.style.borderColor = borderColor;
		//button.x += 30;
		button.update();
		trace(" -----> onMouseDown", x, y, button.label);
		ui.onMouseMove(peoteView, x, y);
	}
	
	public function onClick(uiDisplay:UIDisplay, button:Button, x:Int, y:Int) {
		//button.y += 30; button.update();
		trace(" -----> onMouseClick", x, y, button.label);
		ui.onMouseMove(peoteView, x, y);
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