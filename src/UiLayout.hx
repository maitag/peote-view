package;
import peote.ui.skin.Style;
#if sampleUiLayout
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;

import peote.view.PeoteView;
import peote.view.Color;
import peote.ui.UIDisplay;
import peote.ui.Button;
import peote.ui.skin.Skin;
import peote.ui.Layout;

import jasper.*;
//import jasper.Solver;

@:access(peote.ui, peote.view.PeoteView)
class UiLayout 
{
	var peoteView:PeoteView;
	var ui:UIDisplay;
	
	var solver:Solver;
	
	var b1:Button;
	
	public function new(window:Window)
	{
		try {			
			peoteView = new PeoteView(window.context, window.width, window.height);
			ui = new UIDisplay(0, 0, window.width, window.height, Color.GREY1);
			peoteView.addDisplay(ui);

			solver = new Solver();

			var mySkin = new Skin();		
			var myStyle = new Style();

			b1 = new Button(20, 10, 200, 100, mySkin, myStyle);
			ui.add(b1);

			// cassowary constraints (jasper)
			peoteView.layout = new LayoutView();
			solver.addEditVariable(peoteView.layout.width, Strength.MEDIUM);
			solver.addEditVariable(peoteView.layout.height, Strength.MEDIUM);


			ui.layout = new Layout();
			//solver.addConstraint(ui.layout.left == peoteView.layout.left);
			solver.addConstraint(ui.layout.centerX == peoteView.layout.centerX);
			solver.addConstraint(ui.layout.top == 10);
			solver.addConstraint((ui.layout.width == peoteView.layout.width - 20) | Strength.WEAK);
			solver.addConstraint((ui.layout.bottom == peoteView.layout.bottom - 10) | Strength.WEAK);

			//solver.addConstraint((ui.layout.width <= 1000) | Strength.MEDIUM);
			var limitHeight:Constraint = (ui.layout.height <= 800) | Strength.MEDIUM;
			solver.addConstraint(limitHeight);
			//solver.removeConstraint(limitHeight);

			b1.layout = new Layout();
			//solver.addConstraint(b1.layout.x == 10);
			solver.addConstraint((b1.layout.centerX == ui.layout.centerX) | Strength.WEAK);
			solver.addConstraint((b1.layout.y == ui.layout.y + 0.1*ui.layout.height) | Strength.WEAK);
			//solver.addConstraint((b1.layout.centerY == ui.layout.centerY) | Strength.MEDIUM);

			solver.addConstraint((b1.layout.width  == ui.layout.width  / 1.1) | Strength.WEAK);
			solver.addConstraint((b1.layout.height == ui.layout.height / 2.0  - 20) | Strength.WEAK);

			solver.addConstraint((b1.layout.width <= 600) | Strength.MEDIUM);
			solver.addConstraint((b1.layout.width >= 200) | Strength.MEDIUM);
			solver.addConstraint((b1.layout.height <= 400) | Strength.MEDIUM);
			solver.addConstraint((b1.layout.height >= 200) | Strength.MEDIUM);


			resolve(ui.width, ui.height);
			
/*			
			var layoutSolver = new LayoutSolver
  			(
				peoteView, // peoteView is envolved
				[ui],      // involved UI-Displays
				[b1],      // involved UI-Elements
				
				// editable Vars used in "suggest()" and "suggestValues()" (for values that will be in change)
				[
					peoteView.layout.width,
					peoteView.layout.height
				],
				
				// TODO: new HBox([b1, VBox()]) ...
				
				// --  customconstraints ---
				[
					ui.layout.centerX == peoteView.layout.centerX,
					ui.layout.top == 10,
					(ui.layout.width == peoteView.layout.width - 20) | Strength.WEAK,
					(ui.layout.bottom == peoteView.layout.bottom - 10) | Strength.WEAK,

					(b1.layout.centerX == ui.layout.centerX) | Strength.WEAK,
					(b1.layout.y == ui.layout.y + 0.1*ui.layout.height) | Strength.WEAK,
					//(b1.layout.centerY == ui.layout.centerY) | Strength.MEDIUM,
					
					(b1.layout.width  == ui.layout.width  / 1.1) | Strength.WEAK
					(b1.layout.height == ui.layout.height / 2.0  - 20) | Strength.WEAK
					
					(b1.layout.width <= 600) | Strength.MEDIUM,
					(b1.layout.width >= 200) | Strength.MEDIUM,
					(b1.layout.height <= 400) | Strength.MEDIUM,
					(b1.layout.height >= 200) | Strength.MEDIUM
				]
			);
			
			var limitHeight:Constraint = (ui.layout.height <= 800) | Strength.MEDIUM;
			layoutSolver.addConstraint(limitHeight);
			//layoutSolver.removeConstraint(limitHeight);

			suggestValues([peoteView.width, peoteView.height]).update();
*/			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}

	// --------------------------------------------------
	
	
	public function resolve(width:Int, height:Int) {

		solver.suggestValue(peoteView.layout.width, width);
        solver.suggestValue(peoteView.layout.height, height);
		
        solver.updateVariables();
		
		ui.updateConstraints();
		b1.updateConstraints();
		
	}
	
	
	
	// --------------------------------------------------
	// delegate mouse-events to UIDisplay
	public function onWindowLeave () ui.onWindowLeave();
	public function onMouseMove (x:Float, y:Float) ui.onMouseMove(peoteView, x, y);
	public function onMouseDown (x:Float, y:Float, button:MouseButton) ui.onMouseDown(peoteView, x, y, button);
	public function onMouseUp (x:Float, y:Float, button:MouseButton) ui.onMouseUp(peoteView, x, y, button);
	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier) ui.onKeyDown(keyCode, modifier);
	
	public function render() peoteView.render();
	public function resize(width:Int, height:Int) {
		peoteView.resize(width, height);
		resolve(width,height);
/*		layoutSolver.suggestValues([width, height]).update(); // calculates new Layout and updates all Elements 
		// or  LayoutSolver.suggest(peoteView.layout.width, width);
		//     LayoutSolver.suggest(peoteView.layout.height, height);
		//     layoutSolver.update();
*/
	}

	
	public function onPreloadComplete ():Void { trace("preload complete"); }
	public function update(deltaTime:Int):Void {}
}
#end