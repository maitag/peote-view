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
import peote.view.Program;
import peote.view.Color;
import elements.ElementSimple;

import peote.text.Font;

import peote.text.FontProgram;
import peote.text.Glyph;
//import peote.text.Range;

//import peote.text.GlyphStyle;
//import peote.text.Gl3GlyphStyle;

import peote.text.Line;
import peote.text.Page;

//@multiSlot    // multiple slots per texture to store multiple unicode-ranges
//@multiTexture // multiple textures to store multiple unicode-ranges
//@useInt // TODO
#if packed
@packed        // glyphes are packed into textureatlas with ttfcompile (gl3font)
#end
class GlyphStyle {
	//@global public var color:Color = Color.BLUE;
	public var color:Color = Color.GREEN;
	
	//@global public var width:Float = 10.0;
	public var width:Float = 16;
	//@global public var height:Float = 16.0;
	public var height:Float = 16;
	
	//@global public var zIndex:Int = 0;
	//public var zIndex:Int = 0;
	
	//@global public var rotation:Float = -45;
	//public var rotation:Float = 0;
	
	//@global public var tilt:Float = 0.5;
	public var tilt:Float = 0.0;
	
	//@global public var weight = 0.48;
	public var weight:Float = 0.5;
	
	// TODO: additional spacing after each letter
	//@global public var letterSpacing:Float = 0.0;
	//public var letterSpacing:Float = 2.0;
	
	// TODO: for adjusting Glyphes inside Line
	// letterSpace
	
	// TODO: bgColor:Color = Color.ORANGE
	// TODO: outline/glow for distance field fonts
	
	public function new() {}
}

class TextRendering
{
	var peoteView:PeoteView;
	var display:Display;
	var timer:Timer;
	var helperLinesBuffer:Buffer<ElementSimple>;
	var helperLinesProgram:Program;
	
	public function new(window:Window)
	{
		try {	
			peoteView = new PeoteView(window.context, window.width, window.height);
			display   = new Display(10,10, window.width-20, window.height-20, Color.GREY1);
			peoteView.addDisplay(display);
			helperLinesBuffer = new Buffer<ElementSimple>(100);
			helperLinesProgram = new Program(helperLinesBuffer);
			display.addProgram(helperLinesProgram);
			
			#if packed
			var font = new Font<GlyphStyle>("assets/fonts/packed/hack/config.json");
			//var font = new Font<GlyphStyle>("assets/fonts/packed/unifont/config.json", [new peote.text.Range(0x0000,0x0fff)]);
			//var font = new Font<GlyphStyle>("assets/fonts/packed/unifont/config.json");
			//var font = new Font<GlyphStyle>("assets/fonts/packed/unifont/config.json", [peote.text.Range.C0ControlsBasicLatin(), peote.text.Range.C1ControlsLatin1Supplement()]);
			#else
			var font = new Font<GlyphStyle>("assets/fonts/tiled/hack_ascii.json");
			//var font = new Font<GlyphStyle>("assets/fonts/tiled/liberation_ascii.json");
			//var font = new Font<GlyphStyle>("assets/fonts/tiled/peote.json");
			#end
			
			font.load( function() {
			
				var fontStyle = new GlyphStyle();
				
				var fontProgram = new FontProgram<GlyphStyle>(font, fontStyle); // manage the Programs to render glyphes in different size/colors/fonts
				display.addProgram(fontProgram);
				
				var glyphStyle = new GlyphStyle();
				glyphStyle.width = font.config.width;
				glyphStyle.height = font.config.height;
				
				var glyphStyle1 = new GlyphStyle();
				glyphStyle1.color = Color.YELLOW;
				glyphStyle1.width = font.config.width * 1.0;
				glyphStyle1.height = font.config.height * 1.0;
				//glyphStyle1.zIndex = 1;
				//glyphStyle1.rotation = 22.5;
								
				
				// -----------

//				var glyph1 = fontProgram.createGlyph("A".charCodeAt(0), 0, 50, glyphStyle1);
				
				//fontProgram.glyphSetChar(glyph1, "x".charCodeAt(0));
				//glyph1.color = Color.BLUE;
				//glyph1.width = font.config.width * 2;
				//glyph1.height = font.config.height * 2;
				//fontProgram.updateGlyph(glyph1);
				//fontProgram.removeGlyph( glyph1 );
				
				// -----------
				
				var glyphStyle2 = new GlyphStyle();
				glyphStyle2.color = Color.RED;
				glyphStyle2.width = font.config.width * 2.0;
				glyphStyle2.height = font.config.height * 2.0;
				
				//fontProgram.setFontStyle(glyphStyle2);
				
/*				var glyph2 = new Glyph<GlyphStyle>();
				if (fontProgram.setGlyph( glyph2, "B".charCodeAt(0), 30, 50, glyphStyle1)) {
					Timer.delay(function() {
						fontProgram.glyphSetStyle(glyph2, glyphStyle2);
						fontProgram.updateGlyph(glyph2);
						Timer.delay(function() {
							fontProgram.removeGlyph(glyph2);
							Timer.delay(function() {
								fontProgram.addGlyph(glyph2);
							}, 1000);
						}, 1000);
					}, 1000);
				}
				else trace(" ----> Charcode not inside Font");
*/				
				
				// ------------------- Lines  -------------------
				
				var gl3font = font.getRange(65);
				var tilted = new GlyphStyle();
				tilted.tilt = 0.4;
				tilted.color = 0xaabb22ff;
				tilted.width = font.config.width;
				tilted.height = font.config.height;
				fontProgram.setLine(new Line<GlyphStyle>(), "tilted", 120, 50, tilted);
				
				var thick = new GlyphStyle();
				thick.weight = 0.48;
				thick.width = font.config.width;
				thick.height = font.config.height;
				fontProgram.setLine(new Line<GlyphStyle>(), "bold", 220, 50, thick);
				
				var line = fontProgram.createLine("hello World :)", 0, 100, glyphStyle);
				
				//TODO: line.setGlyphOffset(0, 3  , 5, 6);
				//TODO: line.getGlyph(2);
				
				Timer.delay(function() {
					fontProgram.setLine(line, "hello World (^_^)", line.x, line.y, glyphStyle);
					fontProgram.updateLine(line);
				}, 1000);
				
				Timer.delay(function() {
					fontProgram.lineSetStyle(line, glyphStyle2, 1, 5);
					fontProgram.lineSetStyle(line, glyphStyle1, 6, 12);
					//fontProgram.updateLine(line, 6);
					//trace('visibleFrom: ${line.visibleFrom} visibleTo:${line.visibleTo} fullWidth:${line.fullWidth}');
					fontProgram.lineSetPosition(line, 0, 130);
					fontProgram.updateLine(line);
				}, 2000);
				
				Timer.delay(function() {
					fontProgram.lineSetChar(line, "H".charCodeAt(0) , 0, glyphStyle2); // replace existing char into line
					fontProgram.lineSetChars(line, "Planet", 6);  // replace existing chars into line
					fontProgram.updateLine(line);
				}, 3000);

				Timer.delay(function() {
					fontProgram.lineInsertChar(line, "~".charCodeAt(0) , 12, glyphStyle1);
					fontProgram.lineInsertChars(line,  "Earth", 12, glyphStyle2);
					fontProgram.updateLine(line);
				}, 4000);
								
				Timer.delay(function() {
					fontProgram.lineDeleteChar(line, 5);
					fontProgram.updateLine(line);
				}, 5000);
				
				Timer.delay(function() {
					fontProgram.lineDeleteChars(line, 16);
					fontProgram.updateLine(line);
				}, 6000);
				
				Timer.delay(function() {
					fontProgram.removeLine(line);
				}, 7000);
				
				Timer.delay(function() {
					fontProgram.addLine(line);
				}, 8000);
				
				// TODO:
				// line.clear();
				
				
				// -------- Pages --------
				
				var page = fontProgram.createPage("hello\nworld\n\ntest", 0, 200, glyphStyle);
				
				Timer.delay(function() {
					var text = "Um einen Feuerball rast eine Kotkugel,\nauf der Damenseidenstrümpfe verkauft und Gauguins geschätzt werden.\n\n"
						     + "Ein fürwahr überaus betrüblicher Aspekt,\r\nder aber immerhin ein wenig unterschiedlich ist:\rSeidenstrümpfe können begriffen werden, Gauguins nicht.";
					fontProgram.setPage(page, text, 0, 200, glyphStyle);
				}, 1000);
				
				/*
				Timer.delay(function() {
					fontProgram.pageInsertLine(page, "(Bernheim als prestigieuser Biologe zu imaginieren.)", 2 , glyphStyle2);
				}, 2000);

				Timer.delay(function() {
					fontProgram.pageDeleteLine(page, 1);
				}, 3000);

				Timer.delay(function() {
					fontProgram.pageSetLine(page, 2, "TEST");
				}, 4000);
				
				Timer.delay(function() {
					fontProgram.removePage(page);
				}, 5000);
				
				Timer.delay(function() {
					fontProgram.addPage(page);
				}, 6000);
				
				
				// -- lines inside --

				Timer.delay(function() {
					var line = page.getLine(0);
					fontProgram.lineInsertChars(line, "Walther " 0, 2, glyphStyle2);
					fontProgram.lineInsertChar(line, ":" , glyphStyle2);
					fontProgram.updateLine(line);
				}, 7000);
				
				
				
				*/
			});

			
			
			
			timer = new Timer(40); zoomIn();
			
		} catch (e:Dynamic) trace("ERROR:", e);
		// ---------------------------------------------------------------
	}

	public function addHelperLines(line:Line<GlyphStyle>) {
		helperLinesBuffer.addElement(new ElementSimple(Std.int(line.x), Std.int(line.y), Std.int(line.maxX-line.x), Std.int(line.maxY-line.y), Color.GREY3));
		// top line
		helperLinesBuffer.addElement(new ElementSimple(Std.int(line.x), Std.int(line.y), Std.int(line.maxX-line.x), 1, Color.BLUE));				
		// ascender line
		helperLinesBuffer.addElement(new ElementSimple(Std.int(line.x), Std.int(line.y + line.asc), Std.int(line.maxX-line.x), 1, Color.YELLOW));
		// baseline
		helperLinesBuffer.addElement(new ElementSimple(Std.int(line.x), Std.int(line.y + line.base), Std.int(line.maxX-line.x), 1, Color.RED));
		// descender line
		helperLinesBuffer.addElement(new ElementSimple(Std.int(line.x), Std.int(line.maxY), Std.int(line.maxX-line.x), 1, Color.GREEN));
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