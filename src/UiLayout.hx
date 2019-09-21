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

import peote.ui.UIContainer;

import jasper.Constraint;
import jasper.Strength;


class UiLayout 
{
	var peoteView:PeoteView;
	var ui:UIDisplay;
	var mySkin = new Skin();		
	var greyStyle = new Style();
	var redStyle = new Style();
	var greenStyle = new Style();
	var blueStyle = new Style();
			
	var layoutSolver:LayoutSolver;
	
	public function new(window:Window)
	{
		try {			
			peoteView = new PeoteView(window.context, window.width, window.height);
			ui = new UIDisplay(0, 0, window.width, window.height, Color.GREY1);
			peoteView.addDisplay(ui);
			
			redStyle.color = Color.RED;	greenStyle.color = Color.GREEN;	blueStyle.color = Color.BLUE;

			testManualConstraints();
			
			// TODO:
			//testContainerConstraints();
			
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}

	// ----------------------------------------------------------------
	
	public function testManualConstraints() {
		var b1 = new Button(20, 10, 200, 100, mySkin, greyStyle);
		ui.add(b1);
		
		layoutSolver = new LayoutSolver (
			// editable Vars (used in suggest() and suggestValues())
			[peoteView.layout.width, peoteView.layout.height],
			
			// UI-Displays and UI-Elements to update
			[ui, b1],
			
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
		
		// adding constraints afterwards
		var limitHeight:Constraint = (ui.layout.height <= 800) | Strength.WEAK;
		layoutSolver.addConstraint(limitHeight);
		//layoutSolver.removeConstraint(limitHeight);

		layoutSolver.suggestValues([peoteView.width, peoteView.height]).update();
	}

	// ----------------------------------------------------------------
	
	
/*	public function testContainerConstraints()
	{
		var red = new Button(0, 10, 200, 100, mySkin, redStyle);
		ui.add(red);
		var green = new Button(200, 10, 200, 100, mySkin, greenStyle);
		ui.add(green);
		var blue = new Button(400, 10, 200, 100, mySkin, blueStyle);
		ui.add(blue);

		layoutSolver = new LayoutSolver (
			// editable Vars (used in suggest() and suggestValues())
			[peoteView.layout.width, peoteView.layout.height],
			
			// UI-Displays and UI-Elements to update
			[ui, red, green, blue],
			
			// constraints for the Displays
			new Hbox([ui]).getConstraints(peoteView).concat(
				// constraints for the Elements into ui-Display
				new Hbox([
					red,
					green,
					blue
				]).getConstraints(ui)
			)

		);
		
		layoutSolver.suggestValues([peoteView.width, peoteView.height]).update();	
	}
*/
	
	
	
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