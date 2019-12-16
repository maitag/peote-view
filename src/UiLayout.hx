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
import peote.ui.skin.Skin;
import peote.ui.skin.Style;
import peote.ui.Layout;
import peote.ui.LayoutSolver;
import peote.ui.LayoutContainer;

import jasper.Constraint;
import jasper.Strength;

class UiLayout 
{
	var peoteView:PeoteView;
	var ui:UIDisplay;
	var mySkin = new Skin();
	
	var red:Button; var green:Button; var blue:Button;	var yellow:Button; var grey:Button; var cyan:Button;
			
	var layoutSolver:LayoutSolver;
	
	public function new(window:Window)
	{
		try {			
			peoteView = new PeoteView(window.context, window.width, window.height);
			ui = new UIDisplay(0, 0, window.width, window.height, Color.GREY3);
			peoteView.addDisplay(ui);
			
			red   = new Button(-100, mySkin, new Style(Color.RED));
			green = new Button(-100, mySkin, new Style(Color.GREEN));
			blue  = new Button(-100, mySkin, new Style(Color.BLUE));
			yellow= new Button(-100, mySkin, new Style(Color.YELLOW));
			grey  = new Button(-100, mySkin, new Style(Color.GREY1));		
			cyan  = new Button(-100, mySkin, new Style(Color.CYAN));		

			ui.add(red); ui.add(green); ui.add(blue); ui.add(yellow); ui.add(grey); ui.add(cyan); 
			
			//testManualConstraints();
			//testManualRowConstraints();
			//testLayoutNestedBoxes();
			testLayoutRows();
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}

	// ----------------------------------------------------------------
	
	public function testManualConstraints()
	{
		layoutSolver = new LayoutSolver ([
				// constraints
				(peoteView.layout.x == 0) | Strength.REQUIRED,
				(peoteView.layout.y == 0) | Strength.REQUIRED,

				ui.layout.centerX == peoteView.layout.centerX,
				ui.layout.top == 10,
				(ui.layout.width == peoteView.layout.width - 20) | Strength.WEAK,
				(ui.layout.bottom == peoteView.layout.bottom - 10) | Strength.WEAK,
				(ui.layout.width <= 1000) | Strength.WEAK,

				(grey.layout.centerX == ui.layout.centerX) | Strength.WEAK,
				(grey.layout.y == ui.layout.y + 0.1*ui.layout.height) | Strength.WEAK,
				//(grey.layout.centerY == ui.layout.centerY) | Strength.MEDIUM,
				
				(grey.layout.width  == ui.layout.width  / 1.1) | Strength.WEAK,
				(grey.layout.height == ui.layout.height / 2.0  - 20) | Strength.WEAK,
				
				(grey.layout.width <= 600) | Strength.MEDIUM,
				(grey.layout.width >= 200) | Strength.MEDIUM,
				(grey.layout.height <= 400) | Strength.MEDIUM,
				(grey.layout.height >= 200) | Strength.MEDIUM
		]);
		
		// adding constraints afterwards:
		var limitHeight:Constraint = (ui.layout.height <= 800) | Strength.WEAK;
		layoutSolver.addConstraint(limitHeight);
		
		// that constraints can also be removed again:
		// layoutSolver.removeConstraint(limitHeight);
		
		// UI-Displays and UI-Elements to update
		layoutSolver.toUpdate([ui, grey]);
		
		// editable Vars (used in suggest() and suggestValues())	
		layoutSolver.toSuggest([peoteView.layout.width, peoteView.layout.height]);
		
		// set the constraints editable values to actual view size and updating (same as in onResize)
		layoutSolver.suggestValues([peoteView.width, peoteView.height]).update();
	}

	// ----------------------------------------------------------------
		
	public function testManualRowConstraints()
	{
		layoutSolver = new LayoutSolver ([
			// constraints for the Displays
			(peoteView.layout.x == 0) | Strength.REQUIRED,
			(peoteView.layout.y == 0) | Strength.REQUIRED,

			(ui.layout.centerX == peoteView.layout.centerX) | new Strength(200),
			//(ui.layout.left == peoteView.layout.left) | new Strength(300),
			//(ui.layout.right == peoteView.layout.right) | new Strength(200),
			(ui.layout.width == peoteView.layout.width) | new Strength(100),
			
			(ui.layout.top == 0) | Strength.MEDIUM,
			(ui.layout.bottom == peoteView.layout.bottom) | Strength.MEDIUM,
			(ui.layout.width <= 1000) | Strength.MEDIUM,
		
			// constraints for ui-elements
			
			// size restriction
			(red.layout.width <= 100) | new Strength(500),
			(red.layout.width >= 50) | new Strength(500),
			//(red.layout.width == 100) | new Strength(500),
			
			(green.layout.width <= 200) | new Strength(500),
			(green.layout.width >= 100) | new Strength(500),
			//(green.layout.width == 200) | new Strength(500),
			
			(blue.layout.width <= 300) | new Strength(500),
			(blue.layout.width >= 150) | new Strength(500),
			//(blue.layout.width == 300) | new Strength(500),
			
			// manual hbox constraints
			
			//(red.layout.width   == (ui.layout.width) * ((100+ 50)/2) / ((100+50)/2 + (200+100)/2 + (300+150)/2)) | Strength.WEAK,
			//(green.layout.width == (ui.layout.width) * ((200+100)/2) / ((100+50)/2 + (200+100)/2 + (300+150)/2)) | Strength.WEAK,
			//(blue.layout.width  == (ui.layout.width) * ((300+150)/2) / ((100+50)/2 + (200+100)/2 + (300+150)/2)) | Strength.WEAK,
			
			(red.layout.width == green.layout.width) | Strength.WEAK,
			//(red.layout.width == blue.layout.width) | Strength.WEAK,
			(green.layout.width == blue.layout.width) | Strength.WEAK,
			
			(red.layout.left == ui.layout.left) | new Strength(400),
			(green.layout.left == red.layout.right ) | new Strength(400),
			(blue.layout.left == green.layout.right ) | new Strength(400),
			(blue.layout.right == ui.layout.right) | new Strength(300),
			//(blue.layout.right == ui.layout.right) | Strength.WEAK,
			
			(red.layout.top == ui.layout.top) | Strength.MEDIUM,
			(red.layout.bottom == ui.layout.bottom) | Strength.MEDIUM,
			(green.layout.top == ui.layout.top) | Strength.MEDIUM,
			(green.layout.bottom == ui.layout.bottom) | Strength.MEDIUM,
			(blue.layout.top == ui.layout.top) | Strength.MEDIUM,
			(blue.layout.bottom == ui.layout.bottom) | Strength.MEDIUM,			
		]);
		
		layoutSolver.toUpdate([ui, red, green, blue]); // UI-Displays and UI-Elements to update
		layoutSolver.toSuggest([peoteView.layout.width, peoteView.layout.height]); // editable Vars (used in suggest() and suggestValues())	
		layoutSolver.suggestValues([peoteView.width, peoteView.height]).update(); // set the constraints editable values to actual view size and updating (same as in onResize)
	}


	
	
	// ----------------------------------------------------------------
	
	
	
	public function testLayoutNestedBoxes()
	{
		layoutSolver = new LayoutSolver
		(
			peoteView, // root Layout (automatically set width and height as suggestable and all childs toUpdate)
			[
				new Box(peoteView,
				[
					new Box( ui   , Width.is(100,700),
					[                                                          
						new Box( red  , Width.is(100,600),
						[                                                      
							new Box( green,  Width.is(50, 300),  Height.is(100,400)),							
							new Box( blue,   Width.min(50, 150), Height.is(100,300), LSpace.min(50) ),
							new Box( yellow, Width.is(50, 150),  Height.is(200,200), LSpace.min(0,100), RSpace.is(50) ),
						])
					])
				])
				
			]
		);
		layoutSolver.suggestValues([peoteView.width, peoteView.height]).update();
	}

	
	// ----------------------------------------------------------------

		
	public function testLayoutRows()
	{
		layoutSolver = new LayoutSolver
		(
			peoteView, // root Layout (automatically set width and height as suggestable and all childs toUpdate)
			[
				new Box(peoteView,
				[
					new HBox(ui,
					[
						new Box(red,   200, 200 ,LSpace.is(10,50)),
						new Box(green, Width.is(200,250),  LSpace.is(10,20), RSpace.is(10,20), TSpace.is(50) ),
						new VBox(blue,  Width.is(100, 250), RSpace.is(10, 50), 
						[	
							new Box(yellow, 100, Height.is(50,100), TSpace.is(50,100) ),
							new Box(cyan, Width.is(100,150), 100, LSpace.is(0,50), TSpace.is(0,15)),
							new Box(grey, Height.is(50), TSpace.is(0,30), BSpace.min(50) )
						])
					])
				]),
				
				
			]
		);
		layoutSolver.suggestValues([peoteView.width, peoteView.height]).update();
	}

	
	
	
	// ----------------------------------------
	// -------------- events ------------------
	// ----------------------------------------
	
	public function resize(width:Int, height:Int)
	{
		peoteView.resize(width, height);
		
		// calculates new Layout and updates all Elements 
		layoutSolver.suggestValues([width, height]).update();
		// or layoutSolver.suggest(peoteView.layout.width, width).suggest(peoteView.layout.height, height).update();
		trace(ui.width);
	}
	
	public function render() peoteView.render();

	
	var sizeEmulation = false;
	// delegate mouse-events to UIDisplay
	public function onWindowLeave () ui.onWindowLeave();
	public function onMouseMove (x:Float, y:Float) {
		ui.onMouseMove(peoteView, x, y);
		if (sizeEmulation) layoutSolver.suggestValues([Std.int(x),Std.int(y)]).update();
	}
	public function onMouseDown (x:Float, y:Float, button:MouseButton) ui.onMouseDown(peoteView, x, y, button);
	public function onMouseUp (x:Float, y:Float, button:MouseButton) {
		ui.onMouseUp(peoteView, x, y, button);
		sizeEmulation = !sizeEmulation; 
		if (sizeEmulation) layoutSolver.suggestValues([Std.int(x), Std.int(y)]).update();
		else layoutSolver.suggestValues([peoteView.width, peoteView.height]).update();
	}
	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier) ui.onKeyDown(keyCode, modifier);	
	public function onPreloadComplete ():Void { trace("preload complete"); }
	public function update(deltaTime:Int):Void {}
}

#end