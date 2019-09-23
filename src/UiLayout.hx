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
			ui = new UIDisplay(0, 0, window.width, window.height, Color.GREY3);
			peoteView.addDisplay(ui);
			
			redStyle.color = Color.RED;	greenStyle.color = Color.GREEN;	blueStyle.color = Color.BLUE;

			//testManualConstraints();			
			//testManualHboxConstraints();			
			testContainerConstraints();		
			
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
				(peoteView.layout.x == 0) | Strength.REQUIRED,
				(peoteView.layout.y == 0) | Strength.REQUIRED,

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
		
	public function testManualHboxConstraints()
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
			[
				(peoteView.layout.x == 0) | Strength.REQUIRED,
				(peoteView.layout.y == 0) | Strength.REQUIRED,

				ui.layout.centerX == peoteView.layout.centerX,
				ui.layout.top == 10,
				(ui.layout.width == peoteView.layout.width - 20) | Strength.STRONG,
				(ui.layout.bottom == peoteView.layout.bottom - 10) | Strength.STRONG,
				(ui.layout.width <= 1000) | Strength.WEAK,
			].concat(
			[
				(red.layout.width <= 300) | Strength.MEDIUM,
				(red.layout.width >= 100) | Strength.MEDIUM,
				//(red.layout.width == 200) | Strength.MEDIUM,
				
				(green.layout.width <= 300) | Strength.MEDIUM,
				(green.layout.width >= 100) | Strength.MEDIUM,
				//(green.layout.width == 300) | Strength.MEDIUM,
				
				//(blue.layout.width <= 300) | Strength.MEDIUM,
				(blue.layout.width >= 150) | Strength.MEDIUM,
				//(blue.layout.width == 300) | Strength.MEDIUM,
				
				
/*				(red.layout.width <= (ui.layout.width-20) / 3) | Strength.WEAK,
				(green.layout.width <= (ui.layout.width-20) / 3) | Strength.WEAK,
				(blue.layout.width <= (ui.layout.width-20) / 3) | Strength.WEAK,
*/				
				(red.layout.width == green.layout.width) | Strength.WEAK,
				(red.layout.width == blue.layout.width) | Strength.WEAK,
				(green.layout.width == blue.layout.width) | Strength.WEAK,
				
				(red.layout.left == ui.layout.left) | Strength.MEDIUM,
				(green.layout.left == red.layout.right + 10 ) | Strength.MEDIUM,
				(blue.layout.left == green.layout.right + 10 ) | Strength.MEDIUM,
				(blue.layout.right == ui.layout.right) | new Strength(500),
				
				(red.layout.top == ui.layout.top) | Strength.MEDIUM,
				(red.layout.bottom == ui.layout.bottom) | Strength.MEDIUM,
				(green.layout.top == ui.layout.top) | Strength.MEDIUM,
				(green.layout.bottom == ui.layout.bottom) | Strength.MEDIUM,
				(blue.layout.top == ui.layout.top) | Strength.MEDIUM,
				(blue.layout.bottom == ui.layout.bottom) | Strength.MEDIUM,
				
			]
			)

		);
		
		layoutSolver.suggestValues([peoteView.width, peoteView.height]).update();	
	}

	// ----------------------------------------------------------------
		
	public function testContainerConstraints()
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
			new Hbox([ui]).getViewConstraints(peoteView).concat(
				// constraints for the Elements into ui-Display
				new Hbox([
					red,
					green,
					blue
				]).getConstraints(ui)
			
			)

		);
/*		layoutSolver = new ViewLayout( peoteView,
			[
				new Hbox([
							new DisplayLayout( ui,
							[	new Hbox( [	red, green,	blue ] )
								// ,new Hbox( [	... ] )
								// ,more containers or custom constraints
							])
							// , new DisplayLayout( ...)
				])
				// ,new Hbox( [	... ] )
				// ,more containers or custom constraints for Displays
			]
		);
*/				
		layoutSolver.suggestValues([peoteView.width, peoteView.height]).update();	
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