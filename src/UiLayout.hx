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
import peote.ui.UIContainer;
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
	
	var grey:Button; var red:Button; var green:Button; var blue:Button;	var yellow:Button;
			
	var layoutSolver:LayoutSolver;
	
	public function new(window:Window)
	{
		try {			
			peoteView = new PeoteView(window.context, window.width, window.height);
			ui = new UIDisplay(0, 0, window.width, window.height, Color.GREY3);
			peoteView.addDisplay(ui);
			
			grey  = new Button(mySkin, new Style(Color.GREY1));		
			red   = new Button(mySkin, new Style(Color.RED));
			green = new Button(mySkin, new Style(Color.GREEN));
			blue  = new Button(mySkin, new Style(Color.BLUE));
			yellow= new Button(mySkin, new Style(Color.YELLOW));

			//ui.add(grey); testManualConstraints();
			
			ui.add(red); ui.add(green); ui.add(blue);
			//testManualHboxConstraints();			
			//testContainerConstraints();
			
			ui.add(yellow);
			//testManualNestedContainerConstraints();		
			//testNestedContainerConstraints();	
			
			simplifyingAPI();
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}

	// ----------------------------------------------------------------
	
	public function testManualConstraints() {
		layoutSolver = new LayoutSolver (
			
			[peoteView.layout.width, peoteView.layout.height], // editable Vars (used in suggest() and suggestValues())
			
			[ui, grey], // UI-Displays and UI-Elements to update
			
			// constraints
			[
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
			]
		);
		
		// adding constraints afterwards:
		var limitHeight:Constraint = (ui.layout.height <= 800) | Strength.WEAK;
		layoutSolver.addConstraint(limitHeight);
		
		// that constraints can also be removed again:
		// layoutSolver.removeConstraint(limitHeight);

		// set the constraints editable values to actual view size and updating (same as in onResize)
		layoutSolver.suggestValues([peoteView.width, peoteView.height]).update();
	}

	// ----------------------------------------------------------------
		
	public function testManualHboxConstraints()
	{
		layoutSolver = new LayoutSolver (
			
			[peoteView.layout.width, peoteView.layout.height], // editable Vars (used in suggest() and suggestValues())			
			
			[ui, red, green, blue], // UI-Displays and UI-Elements to update
			
			// constraints
			[	// for the Displays
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
				//(red.layout.width == 200) | new Strength(500),
				
				(green.layout.width <= 200) | new Strength(500),
				(green.layout.width >= 100) | new Strength(500),
				//(green.layout.width == 300) | new Strength(500),
				
				//(blue.layout.width <= 300) | new Strength(500),
				(blue.layout.width >= 150) | new Strength(500),
				(blue.layout.width <= 300) | new Strength(500),
				
				// manual hbox constraints
				
				(red.layout.width   == (ui.layout.width) * ((100+ 50)/2) / ((100+50)/2 + (200+100)/2 + (300+150)/2)) | Strength.WEAK,
				(green.layout.width == (ui.layout.width) * ((200+100)/2) / ((100+50)/2 + (200+100)/2 + (300+150)/2)) | Strength.WEAK,
				//(blue.layout.width  == (ui.layout.width) * ((300+150)/2) / ((100+50)/2 + (200+100)/2 + (300+150)/2)) | Strength.WEAK,
				
/*				(red.layout.width == green.layout.width) | Strength.WEAK,
				(red.layout.width == blue.layout.width) | Strength.WEAK,
				(green.layout.width == blue.layout.width) | Strength.WEAK,
*/				
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
				
			]
		);
		layoutSolver.suggestValues([peoteView.width, peoteView.height]).update();	
	}

	// ----------------------------------------------------------------
		
	public function testContainerConstraints()
	{
		layoutSolver = new LayoutSolver (
			peoteView, // root Layout (automatically set its width and height as editable Vars)
			[	
				// constraints for the Displays
				new Hbox([ui]).getViewConstraints(peoteView),
				
				// constraints for the Elements into ui-Display
				new Hbox([
					red,
					green,
					blue
				]).getConstraints(ui)			
			]
		);
		layoutSolver.suggestValues([peoteView.width, peoteView.height]).update();	
	}

	// ----------------------------------------------------------------
		
	public function testManualNestedContainerConstraints()
	{
		var innerHbox = new Hbox(0,0,0,0,-1,mySkin, new Style(0x440011ff), [ red, yellow ]); 
		ui.add(innerHbox);
		
		layoutSolver = new LayoutSolver (
			peoteView, // root Layout (automatically set its width and height as editable Vars)
			[ui, innerHbox, red, yellow, green, blue], // elements that needs to update
			
			// constraints
			[
				// size restriction
				(red.layout.width <= 100) | Strength.MEDIUM,
				(red.layout.width >= 50) | Strength.MEDIUM,
				(yellow.layout.width >= 50) | Strength.MEDIUM,
				(yellow.layout.width <= 250) | Strength.MEDIUM,
				(green.layout.width >= 50) | Strength.MEDIUM,
				(blue.layout.width == 200) | Strength.MEDIUM,

				// constraints for the Displays
				new Hbox([ui]).getViewConstraints(peoteView),

				(innerHbox.layout.width == green.layout.width) | Strength.WEAK,
				(innerHbox.layout.width == blue.layout.width) | Strength.WEAK,
				(green.layout.width == blue.layout.width) | Strength.WEAK,

				(innerHbox.layout.left == ui.layout.left) | Strength.MEDIUM,
				(green.layout.left == innerHbox.layout.right + 10 ) | Strength.MEDIUM,
				(blue.layout.left == green.layout.right + 10 ) | Strength.MEDIUM,
				(blue.layout.right == ui.layout.right) | new Strength(500),

				(innerHbox.layout.top == ui.layout.top) | Strength.MEDIUM,
				(innerHbox.layout.bottom == ui.layout.bottom) | Strength.MEDIUM,
				(green.layout.top == ui.layout.top) | Strength.MEDIUM,
				(green.layout.bottom == ui.layout.bottom) | Strength.MEDIUM,
				(blue.layout.top == ui.layout.top) | Strength.MEDIUM,
				(blue.layout.bottom == ui.layout.bottom) | Strength.MEDIUM,

				// inner:
					(red.layout.width == yellow.layout.width) | Strength.WEAK,
				
					(red.layout.left == innerHbox.layout.left) | Strength.MEDIUM,
					(yellow.layout.left == red.layout.right + 10 ) | Strength.MEDIUM,
					(yellow.layout.right == innerHbox.layout.right) | new Strength(500),

					(red.layout.top == innerHbox.layout.top) | Strength.MEDIUM,
					(red.layout.bottom == innerHbox.layout.bottom) | Strength.MEDIUM,
					(yellow.layout.top == innerHbox.layout.top) | Strength.MEDIUM,
					(yellow.layout.bottom == innerHbox.layout.bottom) | Strength.MEDIUM,

			]
		);
		layoutSolver.suggestValues([peoteView.width, peoteView.height]).update();
	}

	// ----------------------------------------------------------------
		
	public function testNestedContainerConstraints()
	{
		// TODO: keep aspect ration!
		
		//restrict size:
		red.layout.minSize(50, 50);      red.layout.maxSize(100, 100);
		yellow.layout.minSize(100, 100); yellow.layout.maxSize(200, 200);		
		green.layout.minSize(200, 200);  green.layout.maxSize(300, 300);
		blue.layout.minSize(400, 400);   blue.layout.maxSize(800,800);
		
		//ui.layout.minSize(70, 70);	
		//ui.layout.maxSize(1600, 1000);
		
		
		layoutSolver = new LayoutSolver (	
			peoteView, // root Layout (automatically set its width and height as editable Vars)
			[
				// constraints for the Displays
				new Hbox([ui]).getViewConstraints(peoteView),
				
				// constraints for the Elements into ui-Display
				new Hbox([
					new Hbox([ new Hbox([red]), yellow ]),
					new Hbox([ blue ]),
					green
				]).getConstraints(ui)

			]
		);
		layoutSolver.suggestValues([peoteView.width, peoteView.height]).update();
	}

	
	// ----------------------------------------------------------------
		
	public function simplifyingAPI()
	{
		// testing LayoutContainer abstracts
		layoutSolver = new LayoutSolver (
			peoteView, // root Layout (automatically set its width and height as editable Vars)
			[
				[ (peoteView.layout.x == 0) | Strength.REQUIRED, (peoteView.layout.y == 0) | Strength.REQUIRED ],

				new Box(peoteView, [
					new Box(ui,
					[
						new Box(red, Width.max(400), Height.max(300),
						[
							new Box(green, Align.Left, HSpace.px(10), VSpace.min(20), Width.px(100, 50, 200), Height.min(200),
							[
								blue
							])
						])
					])
				]),
				
				
			]
		);
		
/*		layoutSolver = new LayoutSolver
		(	
			// new Shelf( peoteView, Orientation.Horizontal, Align.Top, {width:320, minWidth:200, maxWidth:400, height:170, minHeight:100, maxHeight:200},
			// new HShelf( peoteView, Align.Top, sizeOptions,   // Align.Center is default
			// HorizontalShelf // alias should also work
			HShelf.Top( peoteView, sizeOptions,    // ".Center", ".Top", ".Bottom" , ".Left", ".Right" or in combination like ".TopLeft"
			[
				new HShelf( uiDisplay, {minWidth:200, maxWidth:400}
				[
					new Spacer( {min:200, max:300} ),
					
					blueWidget, // no size limits !
					
					new Box( greenWidget, Align.BottomRight,{width:300, minHeight:100, maxHeight:200} ),
					// same as: new Box( Align.CenterRight, {width:300, minHeight:100, maxHeight:200}, [ greenWidget ] ),
					// or like Box.bottomRight(greenWidget, {width:300, minHeight:100, maxHeight:200})
					
					new Spacer(250)
				]),
					
				new VShelf( {height:150},
				[
					magentaDisplay,
					orangeDisplay
				]),
				
			]),
			
			// optional/additional manual constraints
			// []
		);
*/		
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