package;
#if sampleUiLayout

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;

import peote.view.PeoteView;
import peote.view.Color;
import peote.ui.UIDisplay;
import peote.ui.Button;
import peote.ui.Layout;
import peote.ui.skin.Skin;
import peote.ui.skin.Style;

import jasper.Constraint;
import jasper.Strength;


class UiLayout 
{
	var peoteView:PeoteView;
	var ui:UIDisplay;
	
	var layoutSolver:LayoutSolver;
	
	var b1:Button;
	
	public function new(window:Window)
	{
		try {			
			peoteView = new PeoteView(window.context, window.width, window.height);
			ui = new UIDisplay(0, 0, window.width, window.height, Color.GREY1);
			peoteView.addDisplay(ui);

			var mySkin = new Skin();		
			var myStyle = new Style();

			b1 = new Button(20, 10, 200, 100, mySkin, myStyle);
			
			ui.add(b1);

			layoutSolver = new LayoutSolver
  			(
				// editable Vars (used in suggest() and suggestValues())
				[peoteView.layout.width, peoteView.layout.height],
				
				[ui], // involved UI-Displays
				[b1], // involved UI-Elements
				
				// TODO: new HBox([b1, VBox()]) ...

				// constraints
				[
					ui.layout.centerX == peoteView.layout.centerX,
					ui.layout.top == 10,
					(ui.layout.width == peoteView.layout.width - 20) | Strength.WEAK,
					(ui.layout.bottom == peoteView.layout.bottom - 10) | Strength.WEAK,
					(ui.layout.width <= 1000) | Strength.WEAK,

					(b1.layout.centerX == ui.layout.centerX) | Strength.WEAK,
					(b1.layout.y == ui.layout.y + 0.1*ui.layout.height) | Strength.WEAK,
					//(b1.layout.centerY == ui.layout.centerY) | Strength.MEDIUM,
					
					(b1.layout.width  == ui.layout.width  / 1.1) | Strength.WEAK,
					(b1.layout.height == ui.layout.height / 2.0  - 20) | Strength.WEAK,
					
					(b1.layout.width <= 600) | Strength.MEDIUM,
					(b1.layout.width >= 200) | Strength.MEDIUM,
					(b1.layout.height <= 400) | Strength.MEDIUM,
					(b1.layout.height >= 200) | Strength.MEDIUM
				]
			);
			
			var limitHeight:Constraint = (ui.layout.height <= 800) | Strength.WEAK;
			layoutSolver.addConstraint(limitHeight);
			//layoutSolver.removeConstraint(limitHeight);

			layoutSolver.suggestValues([peoteView.width, peoteView.height]).update();
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}

	
	// -------------- events ------------------
	
	public function resize(width:Int, height:Int)
	{
		peoteView.resize(width, height);
		
		// calculates new Layout and updates all Elements 
		layoutSolver.suggestValues([width, height]).update();
		// or layoutSolver.suggest(peoteView.layout.width, width).suggest(peoteView.layout.height, height).update();
	}
	
	public function render() peoteView.render();

	// delegate mouse-events to UIDisplay
	public function onWindowLeave () ui.onWindowLeave();
	public function onMouseMove (x:Float, y:Float) ui.onMouseMove(peoteView, x, y);
	public function onMouseDown (x:Float, y:Float, button:MouseButton) ui.onMouseDown(peoteView, x, y, button);
	public function onMouseUp (x:Float, y:Float, button:MouseButton) ui.onMouseUp(peoteView, x, y, button);
	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier) ui.onKeyDown(keyCode, modifier);	
	public function onPreloadComplete ():Void { trace("preload complete"); }
	public function update(deltaTime:Int):Void {}
}

#end