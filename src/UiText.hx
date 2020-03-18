package;

#if sampleUiText

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

class UiText
{
	var peoteView:PeoteView;
	var ui:UIDisplay;
	var mySkin = new Skin();
	
	var button:Button;
			
	var layoutSolver:LayoutSolver;
	
	public function new(window:Window)
	{
		try {			
			peoteView = new PeoteView(window.context, window.width, window.height);
			ui = new UIDisplay(0, 0, window.width, window.height, Color.GREY3);
			peoteView.addDisplay(ui);
			
			button = new Button(mySkin, new Style(Color.RED));
			ui.add(button);
			
			putIntoLayout();
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}

	// ----------------------------------------------------------------
	

	// ----------------------------------------------------------------

		
	public function putIntoLayout()
	{
		layoutSolver = new LayoutSolver
		(
			peoteView, // root Layout (automatically set width and height as suggestable and all childs toUpdate)
			[
				new Box(peoteView,
				[
					new HBox(ui,
					[
						new Box(button, Width.min(200), Height.min(200) , LSpace.is(10,100), RSpace.is(10,100)),
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
		layoutSolver.suggestValues([width, height]).update(); // calculates new Layout and updates all Elements
	}
	
	public function render() peoteView.render();

	// delegate mouse-events to UIDisplay
	public function onWindowLeave () ui.onWindowLeave();
	public function onMouseMove (x:Float, y:Float) ui.onMouseMove(peoteView, x, y);
	public function onMouseDown (x:Float, y:Float, button:MouseButton) ui.onMouseDown(peoteView, x, y, button);
	public function onMouseUp (x:Float, y:Float, button:MouseButton) ui.onMouseUp(peoteView, x, y, button);
	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier) ui.onKeyDown(keyCode, modifier);	
	public function onWindowActivate() //ui.onWindowActivate();	
	{
		#if html5
		reFocus(); // TODO: delegate this event also to ui
		#end
	}
	
	public function onPreloadComplete ():Void { trace("preload complete"); }
	public function update(deltaTime:Int):Void {}
}

#end