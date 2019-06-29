package;
#if sampleTextRendering
import haxe.Timer;

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Color;

import peote.text.Font;

import peote.text.Glyphes;
import peote.text.SimpleGlyph;
//import peote.text.Line;
//import peote.text.Page;


class TextRendering
{
	var peoteView:PeoteView;
	var display:Display;
	var timer:Timer;
	
	public function new(window:Window)
	{
		try {	
			peoteView = new PeoteView(window.context, window.width, window.height);
			display   = new Display(10,10, window.width-20, window.height-20, Color.GREY1);
			peoteView.addDisplay(display);  // display to peoteView
			
			var font = new Font("assets/gl3fonts/unifont/");
			
			//                        defaultfont, defaultsizes, default-color
			var glyphes = new Glyphes(font, 16, 16, Color.YELLOW); // manage the Programs to render glyphes in different size/colors/fonts
			display.addProgram(glyphes.monoGlyphProgram);
			display.addProgram(glyphes.simpleGlyphProgram);
			
			
			// -------- Letters --------			
			var ml1 = glyphes.createMonoLetter(65, 0, 0);
			
			var sl1 = glyphes.createSimpleLetter(65, 0, 20, 18, 18);
			//var sl2 = glyphes.createSimpleLetter(66, 0, 0, font1);
			
			
			/*
			// -------- Lines  ---------
			
			var line = new Line(0, 100, "Hello Word!");
			//line.add( "B" );
			fontProgram.addLine(line);
			
			
			// -------- Pages ??? (namespace!!!) <--------
			
			var page = new Page( 0, 200,
				  "Um einen Feuerball rast eine Kotkugel, auf der Damenseidenstrümpfe verkauft und Gauguins geschätzt werden."
			    + "\n"
				+ "Ein fürwahr überaus betrüblicher Aspekt, der aber immerhin ein wenig unterschiedlich ist: Seidenstrümpfe können begriffen werden, Gauguins nicht."
			);
			//page.add( new Line("(Bernheim als prestigieuser Biologe zu imaginieren.)") );

			fontProgram.addPage(page);
			
			*/
			

			
			
			
			
			
		} catch (e:Dynamic) trace("ERROR:", e);
		// ---------------------------------------------------------------
	}

	var isZooming:Bool = false;
	public function zoomIn() {
		var fz:Float = 1.0;		
		timer.run = function() {
			if (isZooming) {
				if (fz < 10.0) fz *= 1.01; else zoomOut();
				display.zoom = fz;
			}
		}
	}
	
	public function zoomOut() {
		var fz:Float = 10.0;
		timer.run = function() {
			if (isZooming) {
				if (fz > 1.0) fz /= 1.01; else zoomIn();
				display.zoom = fz;
			}
		}
	}
	
	public function onPreloadComplete ():Void {
		// sync loading did not work with html5!
		// texture.setImage(Assets.getImage("assets/images/wabbit_alpha.png"));
	}
	
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		isZooming = ! isZooming;
	}
	
	public function onMouseMove (x:Float, y:Float):Void {}
	public function onWindowLeave ():Void {}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{	
		switch (keyCode) {
			case KeyCode.NUMPAD_PLUS:
					if (modifier.shiftKey) peoteView.zoom+=0.01;
					else display.zoom+=0.1;
			case KeyCode.NUMPAD_MINUS:
					if (modifier.shiftKey) peoteView.zoom-=0.01;
					else display.zoom -= 0.1;
			case KeyCode.UP: display.yOffset -= (modifier.shiftKey) ? 8 : 1;
			case KeyCode.DOWN: display.yOffset += (modifier.shiftKey) ? 8 : 1;
			case KeyCode.RIGHT: display.xOffset += (modifier.shiftKey) ? 8 : 1;
			case KeyCode.LEFT: display.xOffset -= (modifier.shiftKey) ? 8 : 1;
			default:
		}
	}

	public function render()
	{
		peoteView.render();
	}
	public function update(deltaTime:Int):Void {}
	public function onMouseUp (x:Float, y:Float, button:MouseButton):Void {}

	public function resize(width:Int, height:Int)
	{
		peoteView.resize(width, height);
		display.width  = width - 20;
		display.height = height - 20;
	}

}
#end