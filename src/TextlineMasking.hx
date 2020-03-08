package;
#if sampleTextlineMasking
import haxe.Timer;

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.ScanCode;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Element;

import peote.text.Font;

import peote.text.FontProgram;
import peote.text.Glyph;
//import peote.text.Range;

//import peote.text.GlyphStyle;
//import peote.text.Gl3GlyphStyle;

import peote.text.Line;
//import peote.text.Page;
class ElementSimple implements Element
{
	@posX public var x:Float;
	@posY public var y:Float;
	
	@sizeX public var w:Float=100.0;
	@sizeY public var h:Float=100.0;
	
	@color public var c:Color = 0xff0000ff;
		
	public function new(x:Float=0, y:Float=0, w:Float=100, h:Int=100, c:Int=0xFF0000FF )
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.c = c;
	}
}

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
	var helperElems = new Map<Line<GlyphStyle>, {bg:ElementSimple,top:ElementSimple,asc:ElementSimple,base:ElementSimple,desc:ElementSimple}>();
	
	var fontProgram:FontProgram<GlyphStyle>;
	
	var line:Line<GlyphStyle>;
	var line_x:Float = 0;
	var line_xOffset:Float = 0;
	var line_y:Float = 100;
	
	var lineMasked:Line<GlyphStyle>;
	var lineMasked_x:Float = 61;
	var lineMasked_xOffset:Float = -61;
	var lineMasked_y:Float = 150;
	
	var actual_style:Int = 0;
	var glyphStyle = new Array<GlyphStyle>();
		
	var cursor = 0;
	var cursorElem:ElementSimple;
	var cursor_x:Float = 0;
	
	//var window:Window;
	
	public function new(window:Window)
	{
		//this.window=window;
		
		window.textInputEnabled = true; // this is disabled on default for html5

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
				
				var style:GlyphStyle;
				
				style = new GlyphStyle();
				style.width = font.config.width;
				style.height = font.config.height;
				glyphStyle.push(style);
				
				style = new GlyphStyle();
				style.color = Color.YELLOW;
				style.width = font.config.width * 2.0;
				style.height = font.config.height * 2.0;
				glyphStyle.push(style);
				
				style = new GlyphStyle();
				style.color = Color.RED;
				style.width = font.config.width * 3.0;
				style.height = font.config.height * 3.0;
				glyphStyle.push(style);				
				
				// ------------------- line  -------------------
				
				
				line = new Line<GlyphStyle>();
				line.xOffset = line_xOffset;

				lineMasked = new Line<GlyphStyle>();
				lineMasked.maxX = lineMasked_x + 300;
				lineMasked.maxY = lineMasked_y + 50;
				lineMasked.xOffset = lineMasked_xOffset;

				setLine("Testing input textline and masking. (page up/down is toggling glyphstyle)");
				
				//trace('visibleFrom: ${line.visibleFrom} visibleTo:${line.visibleTo} fullWidth:${line.fullWidth}');
				
				// background
				addHelperLines(line, line.fullWidth, 20);
				addHelperLines(lineMasked, lineMasked.maxX-lineMasked.x, lineMasked.maxY-lineMasked.y);
				
				cursorElem = new ElementSimple(cursor_x, line_y, 1, 30, Color.RED);
				helperLinesBuffer.addElement(cursorElem);
				
				//fontProgram.lineSetStyle(line, glyphStyle2, 1, 5);
					
				//fontProgram.lineSetChar(line, "A".charCodeAt(0) , 0, glyphStyle2);
				
				//fontProgram.lineSetPosition(line, line.x+10, line.y+10);
			});
			
		} catch (e:Dynamic) trace("ERROR:", e);
	}
	
	// ---------------------------------------------------------------

	public function setLine(s:String)
	{
		fontProgram.setLine(line, s, line_x, line_y, glyphStyle[actual_style]);
		fontProgram.setLine(lineMasked, s, lineMasked_x, lineMasked_y, glyphStyle[actual_style]);
	}
	
	public function lineInsertChar(charcode:Int)
	{
		if (fontProgram.lineInsertChar(line, charcode, cursor, glyphStyle[actual_style]) != 0) {
			moveCursor(fontProgram.lineInsertChar(lineMasked, charcode, cursor, glyphStyle[actual_style]));
			lineUpdate();
			cursor ++;
		}
	}
	
	public function lineInsertChars(text:String)
	{
		if (fontProgram.lineInsertChars(line, text, cursor, glyphStyle[actual_style]) != 0) {
			var old_length = lineMasked.glyphes.length;
			moveCursor(fontProgram.lineInsertChars(lineMasked, text, cursor, glyphStyle[actual_style]));
			lineUpdate();
			cursor += lineMasked.glyphes.length - old_length;
		}
	}
	
	public function lineDeleteChar()
	{
		if (cursor < line.glyphes.length) {
			fontProgram.lineDeleteChar(line, cursor);
			fontProgram.lineDeleteChar(lineMasked, cursor);
			lineUpdate();
		}
	}
	
	public function lineDeleteCharBack()
	{
		if (cursor > 0) {
			cursor--;
			moveCursor(fontProgram.lineDeleteChar(line, cursor));
			fontProgram.lineDeleteChar(lineMasked, cursor);
			lineUpdate();
		}
	}
	
	public function lineDeleteChars(from:Int, to:Int)
	{
		fontProgram.lineDeleteChars(line, from, to);
		fontProgram.lineDeleteChars(lineMasked, from, to);
		lineUpdate();
	}
	
	public function lineSetXOffset(xOffset:Float)
	{
		fontProgram.lineSetXOffset(line, line_xOffset + xOffset);
		fontProgram.lineSetXOffset(lineMasked, lineMasked_xOffset + xOffset);
		lineUpdate();
		cursorElem.x = cursor_x + xOffset;
		helperLinesBuffer.updateElement(cursorElem);
	}
	
	public function lineUpdate()
	{
		fontProgram.updateLine(line);
		fontProgram.updateLine(lineMasked);
		updateHelperLines(line, line_x + line.xOffset, line.fullWidth, 20);
	}
	
	public function moveCursor(offset:Float)
	{
		cursorElem.x += offset;
		helperLinesBuffer.updateElement(cursorElem);
	}
	
	public function cursorRight()
	{
		if (cursor < line.glyphes.length) {
			cursor++;
			cursorElem.x = fontProgram.lineGetCharPosition(line, cursor);
			helperLinesBuffer.updateElement(cursorElem);
		}
	}
	
	public function cursorLeft()
	{
		if (cursor > 0) {
			cursor--;
			cursorElem.x = fontProgram.lineGetCharPosition(line, cursor);
			helperLinesBuffer.updateElement(cursorElem);
		}
	}
	
	public function cursorSet(position:Int)
	{
		if (position >= 0 && position <= line.glyphes.length) {
			cursor = position;
			cursorElem.x = fontProgram.lineGetCharPosition(line, cursor);
			helperLinesBuffer.updateElement(cursorElem);
		}
	}
	
	// ---------------------------------------------------------------
	
	public function addHelperLines(line:Line<GlyphStyle>, width:Float, height:Float) {
		// bg
		var bg = new ElementSimple(Std.int(line.x), Std.int(line.y), Std.int(width), Std.int(height), Color.GREY2);
		helperLinesBuffer.addElement(bg);
		// top line
		var top = new ElementSimple(Std.int(line.x), Std.int(line.y), Std.int(width), 1, Color.GREY4);				
		helperLinesBuffer.addElement(top);				
		// ascender line
		var asc = new ElementSimple(Std.int(line.x), Std.int(line.y + line.asc), Std.int(width), 1, Color.GREY3);
		helperLinesBuffer.addElement(asc);
		// baseline
		var base = new ElementSimple(Std.int(line.x), Std.int(line.y + line.base), Std.int(width), 1, Color.GREY3);
		helperLinesBuffer.addElement(base);
		// descender line
		var desc = new ElementSimple(Std.int(line.x), Std.int(line.y + height), Std.int(width), 1, Color.GREY4);
		helperLinesBuffer.addElement(desc);
		
		helperElems.set(line, {bg:bg, top:top, asc:asc, base:base, desc:desc});
	}
	
	public function updateHelperLines(line:Line<GlyphStyle>, x:Float, width:Float, height:Float) {
		var elem = helperElems.get(line);
		elem.bg.x = elem.top.x = elem.asc.x = elem.base.x = elem.desc.x = x;
		elem.bg.w = elem.top.w = elem.asc.w = elem.base.w = elem.desc.w = width;
		elem.bg.h = height;
		helperLinesBuffer.updateElement(elem.bg);
		helperLinesBuffer.updateElement(elem.top);
		helperLinesBuffer.updateElement(elem.asc);
		helperLinesBuffer.updateElement(elem.base);
		helperLinesBuffer.updateElement(elem.desc);
	}

	// ---------------------------------------------------------------
	
	var dragging = false;
	var dragX:Float = 0.0;
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{	
		if ((y-display.y)/display.zoom > line.y && (y-display.y)/display.zoom < line.y + 30) {
			//trace("char at position:", fontProgram.lineGetCharAtPosition(line, x / display.zoom));
			cursorSet(fontProgram.lineGetCharAtPosition(line, (x - display.x) / display.zoom));
		}
		else {
			dragging = true;
			dragX = x;
			cursor_x = cursorElem.x;
		}
	}
	
	public function onMouseUp (x:Float, y:Float, button:MouseButton):Void {
		dragging = false;
		line_xOffset = line.xOffset;
		lineMasked_xOffset = lineMasked.xOffset;
		cursor_x = cursorElem.x;
	}
	
	public function onMouseMove (x:Float, y:Float):Void {
		if (dragging) {
			//trace(x - dragX);
			lineSetXOffset((x - dragX)/display.zoom);
		}
	}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{	
		switch (keyCode) {
			case KeyCode.NUMPAD_PLUS:
					if (modifier.shiftKey) peoteView.zoom+=0.01;
					else display.zoom+=0.1;
			case KeyCode.NUMPAD_MINUS:
					if (modifier.shiftKey) peoteView.zoom-=0.01;
					else display.zoom -= 0.1;
			
			case KeyCode.PAGE_UP: actual_style = (actual_style+1) % glyphStyle.length;
			case KeyCode.PAGE_DOWN: actual_style = (actual_style>0) ? actual_style-1 : glyphStyle.length-1;

			case KeyCode.HOME: cursorSet(0);
			case KeyCode.END: cursorSet(line.glyphes.length);

			// CUT
			//case KeyCode.x: if (modifier.ctrlKey) lime.system.Clipboard.text = lineCutSelection();
			// COPY
			//case KeyCode.C: if (modifier.ctrlKey) lime.system.Clipboard.text = lineGetSelection();
			// PASTE
			#if (neko || cpp)
			case KeyCode.V: if (modifier.ctrlKey && lime.system.Clipboard.text != null) lineInsertChars(lime.system.Clipboard.text);
			#end
			
			case KeyCode.DELETE: lineDeleteChar();
			case KeyCode.BACKSPACE: lineDeleteCharBack();
			case KeyCode.RIGHT: cursorRight();
			case KeyCode.LEFT: cursorLeft();
			default:
		}
	}
	
	public function onTextInput(text:String):Void 
	{
		//trace("onTextInput", text);
		
/*		haxe.Utf8.iter(text, function(charcode)
		{
			lineInsertChar(charcode);
		});
*/	
		lineInsertChars(text);
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