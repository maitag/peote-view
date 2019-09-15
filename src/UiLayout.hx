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

import jasper.*;
//import jasper.Solver;


class UiLayout 
{
	var peoteView:PeoteView;
	var ui:UIDisplay;
	
	var solver:Solver;
	var ui_width = new Variable();
	var ui_height = new Variable();
	
	var b1:Button;
	
	public function new(window:Window)
	{
		try {			
			peoteView = new PeoteView(window.context, window.width, window.height);
			ui = new UIDisplay(0, 0, window.width, window.height, Color.GREEN);
			peoteView.addDisplay(ui);
			
            solver = new Solver();

			var mySkin = new Skin();		
			var myStyle = new Style();
			
			b1 = new Button(20, 10, 200, 100, mySkin, myStyle);
			ui.add(b1);

			// cassowary constraints (jasper)
			solver.addEditVariable(ui_width, Strength.MEDIUM);
            solver.addEditVariable(ui_height, Strength.MEDIUM);

            solver.addConstraint(b1.left == 10);
            solver.addConstraint(b1.top == 10);
            solver.addConstraint((b1.right  - b1.left == ui_width  / 1.75  - 20) | Strength.WEAK);
            solver.addConstraint((b1.bottom - b1.top  == ui_height / 2.0   - 20) | Strength.WEAK);
            solver.addConstraint((b1.width <= 400) | Strength.MEDIUM);
            solver.addConstraint((b1.width >= 200) | Strength.MEDIUM);
            solver.addConstraint((b1.height <= 400) | Strength.MEDIUM);
            solver.addConstraint((b1.height >= 200) | Strength.MEDIUM);
			
			
			resolve(ui.width, ui.height);
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}

	// --------------------------------------------------
	
	
	public function resolve(width:Int, height:Int) {

		solver.suggestValue(ui_width, width);
        solver.suggestValue(ui_height, height);
        solver.updateVariables();
		
		ui.width = Std.int(ui_width.m_value);
		ui.height = Std.int(ui_height.m_value);
		
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