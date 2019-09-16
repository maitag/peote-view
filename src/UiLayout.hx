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
			peoteView.layoutVars = new LayoutViewVars();
			solver.addEditVariable(peoteView.layoutVars.width, Strength.MEDIUM);
            solver.addEditVariable(peoteView.layoutVars.height, Strength.MEDIUM);
			

			ui.layoutVars = new LayoutVars();
            //solver.addConstraint(ui.layoutVars.left == peoteView.layoutVars.left);
            solver.addConstraint(ui.layoutVars.centerX == peoteView.layoutVars.centerX);
            solver.addConstraint(ui.layoutVars.top == 10);
			solver.addConstraint((ui.layoutVars.width == peoteView.layoutVars.width - 20) | Strength.WEAK);
			solver.addConstraint((ui.layoutVars.bottom == peoteView.layoutVars.bottom - 10) | Strength.WEAK);
            
			//solver.addConstraint((ui.layoutVars.width <= 1000) | Strength.MEDIUM);
            var limitHeight:Constraint = (ui.layoutVars.height <= 800) | Strength.MEDIUM;
			solver.addConstraint(limitHeight);
			//solver.removeConstraint(limitHeight);

			b1.layoutVars = new LayoutVars();
            //solver.addConstraint(b1.layoutVars.x == 10);
            solver.addConstraint((b1.layoutVars.centerX == ui.layoutVars.centerX) | Strength.WEAK);
            solver.addConstraint((b1.layoutVars.y == ui.layoutVars.y + 0.1*ui.layoutVars.height) | Strength.WEAK);
            //solver.addConstraint((b1.layoutVars.centerY == ui.layoutVars.centerY) | Strength.MEDIUM);

            solver.addConstraint((b1.layoutVars.width  == ui.layoutVars.width  / 1.1) | Strength.WEAK);
            solver.addConstraint((b1.layoutVars.height == ui.layoutVars.height / 2.0  - 20) | Strength.WEAK);
            
			solver.addConstraint((b1.layoutVars.width <= 600) | Strength.MEDIUM);
            solver.addConstraint((b1.layoutVars.width >= 200) | Strength.MEDIUM);
            solver.addConstraint((b1.layoutVars.height <= 400) | Strength.MEDIUM);
            solver.addConstraint((b1.layoutVars.height >= 200) | Strength.MEDIUM);
			
			
			resolve(ui.width, ui.height);
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}

	// --------------------------------------------------
	
	
	public function resolve(width:Int, height:Int) {

		solver.suggestValue(peoteView.layoutVars.width, width);
        solver.suggestValue(peoteView.layoutVars.height, height);
		
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
	}

	
	public function onPreloadComplete ():Void { trace("preload complete"); }
	public function update(deltaTime:Int):Void {}
}
#end