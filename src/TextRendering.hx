package;
#if sampleTextRendering
import haxe.Timer;

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;

import peote.text.Gl3Font;

import peote.text.FontProgram;
import peote.text.Glyph;
//import peote.text.GlyphStyle;
import peote.text.Gl3FontStyle;
//import peote.text.Line;
//import peote.text.Page;

class GlyphStyle  {
	public var color:Color = Color.GREEN;
}

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
			
			var font = new Gl3Font("assets/gl3fonts/unifont/", false);
			var fontStyle = new Gl3FontStyle();
			fontStyle.color = Color.WHITE;
			fontStyle.width = 20.0;
			
			var fontProgram = new FontProgram<Glyph<Gl3Font,GlyphStyle>>(font, fontStyle); // manage the Programs to render glyphes in different size/colors/fonts
			display.addProgram(fontProgram);
			
			var simpleGlyph = new Glyph<Gl3Font,GlyphStyle>(65, 0, 0);
			fontProgram.add(simpleGlyph); //glyphes.remove(simpleGlyph);
			
			simpleGlyph.color = Color.BLUE;
			fontProgram.update(simpleGlyph);
			
			// TODO: set auto-style for all new Glypes
			// fontProgram.setCurrentStyle( new GlyphStyle(...) );
			
			//fontProgram.add(new Glyph<Gl3Font,GlyphStyle>(66, 22, 0));
			
			/*
			// -------- Lines  ---------
			
			var line = new Line(0, 100, "Hello Word!");
			//line.add( "B" );
			glyphes.addLine(line);
			
			
			// -------- Pages ??? (namespace!!!) <--------
			
			var page = new Page( 0, 200,
				  "Um einen Feuerball rast eine Kotkugel, auf der Damenseidenstrümpfe verkauft und Gauguins geschätzt werden."
			    + "\n"
				+ "Ein fürwahr überaus betrüblicher Aspekt, der aber immerhin ein wenig unterschiedlich ist: Seidenstrümpfe können begriffen werden, Gauguins nicht."
			);
			//page.add( new Line("(Bernheim als prestigieuser Biologe zu imaginieren.)") );

			.addPage(page);
			
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