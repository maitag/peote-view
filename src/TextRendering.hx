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

import peote.text.Font;

import peote.text.FontProgram;
import peote.text.Glyph;
import peote.text.Range;

//import peote.text.GlyphStyle;
//import peote.text.Gl3GlyphStyle;

import peote.text.Line;
//import peote.text.Page;

//@packed
//@multiSlot    // multiple slots per texture to store multiple unicode-ranges
//@multiTexture // multiple textures to store multiple unicode-ranges
//@useInt // TODO
class GlyphStyle {
	//@global public var color:Color = Color.BLUE;
	public var color:Color = Color.GREEN;
	
	//@global public var width:Float = 10.0;
	public var width:Float = 10.0;
	//@global public var height:Float = 16.0;
	public var height:Float = 16.0;
	
	//@global public var zIndex:Int = 0;
	//public var zIndex:Int = 0;
	
	//@global public var rotation:Float = -45;
	//public var rotation:Float = 0;
	
	// TODO: bold/italic/glow/outline...
	
	public function new() {}
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
			peoteView.addDisplay(display);
			
			var font = new Font<GlyphStyle>("assets/fonts/tiled/ascii.json");
			//var font = new Font<GlyphStyle>("assets/fonts/tiled/peote.json");
			//var font = new Font<GlyphStyle>("assets/fonts/packed/hack/config.json");
			//var font = new Font<GlyphStyle>("assets/fonts/packed/unifont/config.json");
			//var font = new Font<GlyphStyle>("assets/fonts/packed/unifont/config.json", [new Range(0x0000,0x0fff)]);
			
			font.load( function() {
			
				var fontStyle = new GlyphStyle();
				
				var fontProgram = new FontProgram<GlyphStyle>(font, fontStyle); // manage the Programs to render glyphes in different size/colors/fonts
				display.addProgram(fontProgram);
				
				
				var glyphStyle1 = new GlyphStyle();
				glyphStyle1.color = Color.YELLOW;
				glyphStyle1.width = 50.0;
				glyphStyle1.height = 80.0;
				//glyphStyle1.zIndex = 1;
				//glyphStyle1.rotation = 22.5;
								
				
				// -----------

				var glyph1 = new Glyph<GlyphStyle>();
				fontProgram.addGlyph(glyph1, 65, 0, 50, glyphStyle1);
				

				//fontProgram.setCharcode(glyph1, 0x1201);
				//glyph1.color = Color.BLUE;
				//glyph1.height = 30;
				//fontProgram.updateGlyph(glyph1);
				//fontProgram.removeGlyph( glyph1 );
				
				// -----------
				
				var glyphStyle2 = new GlyphStyle();
				glyphStyle2.color = Color.RED;
				glyphStyle2.width = 100.0;
				glyphStyle2.height = 160.0;
				
				//fontProgram.setFontStyle(glyphStyle2);
				
				var glyph2 = new Glyph<GlyphStyle>();
				//0x2e25
				if (fontProgram.addGlyph( glyph2, 66, 20, 0, glyphStyle2)) {
					//glyph2.setStyle(glyphStyle1);
					//fontProgram.updateGlyph(glyph2);
				}
				else trace(" ----> Charcode not inside Font");
				
				
				// -------- Lines  ---------
				
				var line = new Line<GlyphStyle>();
				fontProgram.addLine(line, "Hello World...", 0, 120);
				
				//line.setStyle(glyphStyle2, 0, 4);
				//line.x = 30; // all gylphes inside will change
				//line.y = 40; // all gylphes inside will change
				//fontProgram.updateLine(line);
				/*
				fontProgram.addGlyphToLine(line, 68 , 0, true); // true -> from end
				fontProgram.addGlyphesToLine(line,  Glyphes.fromString("brave new "), 6);
				
				fontProgram.clearLine(line);
				fontProgram.removeGlyphFromLine(line, 6);
				fontProgram.removeGlyphesFromLine(line, 0, 4, true); // true -> from end

				fontProgram.changeLine(line, 77, 0);
				fontProgram.changeInLine(line, "test", 6);

				fontProgram.removeLine(line);
				
				// -------- Pages ??? (namespace!!!) <--------
				
				var page = new Page( 0, 200,
					  "Um einen Feuerball rast eine Kotkugel, auf der Damenseidenstrümpfe verkauft und Gauguins geschätzt werden."
					+ "\n"
					+ "Ein fürwahr überaus betrüblicher Aspekt, der aber immerhin ein wenig unterschiedlich ist: Seidenstrümpfe können begriffen werden, Gauguins nicht."
				);
				//page.add( new Line("(Bernheim als prestigieuser Biologe zu imaginieren.)") );

				fontProgram.addPage(page 0, 200);
				fontProgram.removePage(line);
				*/
			});

			
			
			
			timer = new Timer(40); zoomIn();
			
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