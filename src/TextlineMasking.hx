package;
import jasper.ds.FloatMap;
#if sampleTextlineMasking
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
//import peote.text.Page;

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

class TextlineMasking
{
	var peoteView:PeoteView;
	var display:Display;
	var timer:Timer;
	
	var helperLinesBuffer:Buffer<ElementSimple>;
	var helperLinesProgram:Program;
	
	var fontProgram:FontProgram<GlyphStyle>;
	
	var line:Line<GlyphStyle>;
	var line_x:Float = 0;
	var line_y:Float = 100;
	
	var lineMasked:Line<GlyphStyle>;
	var lineMasked_x:Float = 200;
	var lineMasked_y:Float = 200;
	
	var actual_glyphStyle:GlyphStyle;
		
	
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
				
				fontProgram = new FontProgram<GlyphStyle>(font, fontStyle); // manage the Programs to render glyphes in different size/colors/fonts
				display.addProgram(fontProgram);
				
				var glyphStyle = new GlyphStyle();
				glyphStyle.width = font.config.width;
				glyphStyle.height = font.config.height;
				
				var glyphStyle1 = new GlyphStyle();
				glyphStyle1.color = Color.YELLOW;
				glyphStyle1.width = font.config.width * 1.0;
				glyphStyle1.height = font.config.height * 1.0;
				
				var glyphStyle2 = new GlyphStyle();
				glyphStyle2.color = Color.RED;
				glyphStyle2.width = font.config.width * 2.0;
				glyphStyle2.height = font.config.height * 2.0;
								
				
				actual_glyphStyle = glyphStyle;

				// ------------------- line  -------------------
				
				
				line = new Line<GlyphStyle>();
				line.maxX = 104;
				line.maxY = 240;
				line.xOffset = -25.0;

				fontProgram.setLine(line, "0123456789", 50, 200, glyphStyle2);
				
				//trace('visibleFrom: ${line.visibleFrom} visibleTo:${line.visibleTo} fullWidth:${line.fullWidth}');
				
				// background
				addHelperLines(line);				
				
				//fontProgram.removeLine(line);
				//fontProgram.addLine(line);
				
				//fontProgram.setLine(line, "0123456789", line.x, line.y, glyphStyle1);
				//fontProgram.updateLine(line);

				//fontProgram.lineSetStyle(line, glyphStyle2, 1, 5);
					
				//fontProgram.lineSetChar(line, "A".charCodeAt(0) , 0, glyphStyle2);

				//fontProgram.lineDeleteChar(line, 0);
				//fontProgram.lineDeleteChars(line, 2, 5);

				//fontProgram.lineInsertChar(line, "A".charCodeAt(0) , 0 , glyphStyle2);
				//fontProgram.lineInsertChars(line, "hsxe" , 0, glyphStyle2);
				
				//fontProgram.lineSetPosition(line, line.x+10, line.y+10);

				//fontProgram.updateLine(line);
				
				
			});
			
		} catch (e:Dynamic) trace("ERROR:", e);
	}
	
	// ---------------------------------------------------------------

	public function setLine(s:String)
	{
		fontProgram.setLine(line, s, line_x, line_y, actual_glyphStyle);
		fontProgram.setLine(lineMasked, s, lineMasked_x, lineMasked_y, actual_glyphStyle);
	}
	
	// ---------------------------------------------------------------
	
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

	// ---------------------------------------------------------------
	
	
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
	}
	public function onMouseUp (x:Float, y:Float, button:MouseButton):Void {}
	
	public function onMouseMove (x:Float, y:Float):Void {}

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

	public function onWindowLeave ():Void {}
	public function onPreloadComplete ():Void {}
	public function update(deltaTime:Int):Void {}

	public function resize(width:Int, height:Int)
	{
		peoteView.resize(width, height);
		display.width  = width - 20;
		display.height = height - 20;
	}

}
#end