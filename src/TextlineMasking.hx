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

#if html5
@:access(lime._internal.backend.html5.HTML5Window)
@:access(lime.ui.Window)
#end
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
		
	var cursor:Int = 0;
	var cursorElem:ElementSimple;
	var cursor_x:Float = 0;
	
	var selectElem:ElementSimple;
	var select_x:Float = 0;
	var select_from:Int = 0;
	var select_to:Int = 0;
	var hasSelection(get, set):Bool;
	inline function get_hasSelection():Bool return (select_from != select_to);
	inline function set_hasSelection(has:Bool) {
		if (!has) select_to = select_from;
		return has;
	}
	
	var window:Window;
	
	public function new(window:Window)
	{
		this.window=window;
		
		window.textInputEnabled = true; // this is disabled on default for html5

		try {	
			peoteView = new PeoteView(window.context, window.width, window.height);
			display   = new Display(10, 10, window.width - 20, window.height - 20, Color.GREY1);
			#if mobile
			display.zoom = 3.0;
			#end
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
				
				// ------------------- Styles  -------------------				
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
				
				// -------- background and helperlines ---------				
				addHelperLines(line, line.fullWidth, 20);
				addHelperLines(lineMasked, lineMasked.maxX-lineMasked.x, lineMasked.maxY-lineMasked.y);
				
				// ----------------- Cursor  -------------------				
				cursorElem = new ElementSimple(cursor_x, line_y, 1, 30, Color.RED);
				helperLinesBuffer.addElement(cursorElem);
				
				// --------------- Selection  -------------------				
				selectElem = new ElementSimple(cursor_x, line_y, 0, 20, Color.GREY4);
				helperLinesBuffer.addElement(selectElem);
				
					
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
	
	public function lineDeleteChar(isCtrl:Bool)
	{
		if (hasSelection) {
			lineDeleteChars(select_from, select_to);
		}
		else if (cursor < line.glyphes.length) {
			if (isCtrl) {
				var to = cursor;
				if (line.glyphes[to].char != 32) do to++ while (to < line.glyphes.length && line.glyphes[to].char != 32);
				do to++ while (to < line.glyphes.length && line.glyphes[to].char == 32);
				lineDeleteChars(cursor, to);
			}
			else {
				fontProgram.lineDeleteChar(line, cursor);
				fontProgram.lineDeleteChar(lineMasked, cursor);
				lineUpdate();
			}
		}
	}
	
	public function lineDeleteCharBack(isCtrl:Bool)
	{
		if (hasSelection) {
			lineDeleteChars(select_from, select_to);
		}
		else if (cursor > 0) {
			if (isCtrl) {
				var from = cursor;
				do cursor-- while (cursor > 0 && line.glyphes[cursor].char == 32);
				while (cursor > 0 && line.glyphes[cursor-1].char != 32) cursor--;
				lineDeleteChars(from, cursor);
			}
			else {
				cursor--;
				moveCursor(fontProgram.lineDeleteChar(line, cursor));
				fontProgram.lineDeleteChar(lineMasked, cursor);
				lineUpdate();
			}
		}
	}
	
	function lineDeleteChars(from:Int, to:Int)
	{
		if (to < from) {var tmp = to; to = from; from = tmp; }
		fontProgram.lineDeleteChars(line, from, to);
		fontProgram.lineDeleteChars(lineMasked, from, to);
		lineUpdate();
		selectionSetFrom(from);
		selectionSetTo(from);
		cursorSet(from);
	}
	
	public function lineCutChars():String
	{
		var cut = "";
		if (hasSelection) {
			var from = select_from;
			var to = select_to;
			if (to < from) {to = select_from; from = select_to; }
			cut = fontProgram.lineCutChars(line, from, to);
			fontProgram.lineDeleteChars(lineMasked, from, to);
			lineUpdate();
			selectionSetTo(select_from);
			cursorSet(from);
		}
		return cut;
	}
	
	public function lineCopyChars():String
	{
		var copy = "";
		if (hasSelection) {
			var from = select_from;
			var to = select_to;
			if (to < from) {to = select_from; from = select_to; }
			for (i in ((from < line.visibleFrom) ? line.visibleFrom : from)...((to < line.visibleTo) ? to : line.visibleTo)) {
				copy += String.fromCharCode(line.glyphes[i].char);
			}
		}
		return copy;		
	}
	
	public function lineChangeStyle()
	{
		if (hasSelection) {
			var from = select_from;
			var to = select_to;
			if (to < from) {to = select_from; from = select_to; }
			fontProgram.lineSetStyle(line, glyphStyle[actual_style], from, to);
			fontProgram.lineSetStyle(lineMasked, glyphStyle[actual_style], from, to);
			lineUpdate();
			selectionSetFrom(select_from);
			selectionSetTo(select_to);
			cursorSet(cursor);
		}
	}
	
	public function lineSetXOffset(xOffset:Float)
	{
		fontProgram.lineSetXOffset(line, line_xOffset + xOffset);
		fontProgram.lineSetXOffset(lineMasked, lineMasked_xOffset + xOffset);
		lineUpdate();
		cursorElem.x = cursor_x + xOffset;
		helperLinesBuffer.updateElement(cursorElem);
		selectElem.x = select_x + xOffset;
		helperLinesBuffer.updateElement(selectElem);
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
	
	public function cursorRight(isShift:Bool, isCtrl:Bool)
	{
		// TODO: if already selected and no shift -> remove selection & cursor at end of selection
		if (cursor < line.glyphes.length) {
			if (!hasSelection && isShift) selectionStart(cursor);
			if (isCtrl) {
				do cursor++ while (cursor < line.glyphes.length && line.glyphes[cursor].char != 32);
				while (cursor < line.glyphes.length && line.glyphes[cursor].char == 32) cursor++;
			}
			else cursor++;
			cursorElem.x = fontProgram.lineGetCharPosition(line, cursor);
			helperLinesBuffer.updateElement(cursorElem);
			if (isShift) selectionSetTo(cursor);
		}
		if (!isShift) selectionSetTo(select_from);
	}
	
	public function cursorLeft(isShift:Bool, isCtrl:Bool)
	{
		// TODO: if already selected and no shift -> remove selection & cursor at start of selection
		if (cursor > 0) {
			if (!hasSelection && isShift) selectionStart(cursor);
			if (isCtrl) {
				do cursor-- while (cursor > 0 && line.glyphes[cursor].char == 32);
				while (cursor > 0 && line.glyphes[cursor-1].char != 32) cursor--;
			}
			else cursor--;
			cursorElem.x = fontProgram.lineGetCharPosition(line, cursor);
			helperLinesBuffer.updateElement(cursorElem);
			if (isShift) selectionSetTo(cursor);
		}
		if (!isShift) selectionSetTo(select_from);
	}
	
	public function cursorSet(position:Int)
	{
		if (position >= 0 && position <= line.glyphes.length) {
			cursor = position;
			cursorElem.x = fontProgram.lineGetCharPosition(line, cursor);
			helperLinesBuffer.updateElement(cursorElem);
		}
	}
	
	// TODO:
	public function selectionStart(from:Int)
	{
		if (from >= 0) {
			select_from = select_to = from;
			selectElem.x = fontProgram.lineGetCharPosition(line, from);
			selectElem.w = 0;
			helperLinesBuffer.updateElement(selectElem);
		}
	}

	public function selectionSetFrom(from:Int)
	{
		if (from >= 0) {
			select_from = from;
			selectElem.x = fontProgram.lineGetCharPosition(line, from);
			helperLinesBuffer.updateElement(selectElem);
		}
	}
	
	public function selectionSetTo(to:Int)
	{
		if (to <= line.glyphes.length) {
			select_to = to;
			selectElem.w = fontProgram.lineGetCharPosition(line, to) - selectElem.x;
			helperLinesBuffer.updateElement(selectElem);
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
	
	var selecting = false;
	var dragging = false;
	var dragX:Float = 0.0;
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{	
		if ((y-display.y)/display.zoom > line.y && (y-display.y)/display.zoom < line.y + 30) {
			cursorSet(fontProgram.lineGetCharAtPosition(line, (x - display.x) / display.zoom));
			selectionStart(cursor);
			selecting = true;
		}
		else {
			dragX = x;
			cursor_x = cursorElem.x;
			select_x = selectElem.x;
			dragging = true;
		}
	}
	
	public function onMouseUp (x:Float, y:Float, button:MouseButton):Void {
		selecting = false;
		dragging = false;
		line_xOffset = line.xOffset;
		lineMasked_xOffset = lineMasked.xOffset;
		cursor_x = cursorElem.x;
		select_x = selectElem.x;
	}
	
	public function onMouseMove (x:Float, y:Float):Void {
		if (selecting) {
			cursorSet(fontProgram.lineGetCharAtPosition(line, (x - display.x) / display.zoom));
			selectionSetTo(cursor);
		}
		else if (dragging) {
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
			
			case KeyCode.PAGE_UP:
				actual_style = (actual_style+1) % glyphStyle.length;
				lineChangeStyle();
			case KeyCode.PAGE_DOWN:
				actual_style = (actual_style>0) ? actual_style-1 : glyphStyle.length-1;
				lineChangeStyle();

			case KeyCode.HOME: cursorSet(0);
			case KeyCode.END: cursorSet(line.glyphes.length);

			// SELECT ALL
			case KeyCode.A: 
				if (modifier.ctrlKey || modifier.metaKey) {
					selectionSetFrom(0);
					selectionSetTo(line.glyphes.length);
				}
				
			// CUT
			case KeyCode.X: 
				if (modifier.ctrlKey || modifier.metaKey) {
					lime.system.Clipboard.text = lineCutChars();
					#if html5
					//window.__backend.setClipboard(value);
					//reFocus();
					#end
				}

			// COPY
			case KeyCode.C:
				if (modifier.ctrlKey || modifier.metaKey) {
					lime.system.Clipboard.text = lineCopyChars();
					#if html5
					//reFocus();
					#end
				}
				
			// PASTE                 // TODO: in native-windowstarget crashes if there is linebreak
			case KeyCode.V: 
				if (modifier.ctrlKey || modifier.metaKey) {
					selectionSetTo(select_from);
					#if html5
					//reFocus();
					#else
					if (lime.system.Clipboard.text != null) lineInsertChars(lime.system.Clipboard.text);
					#end
				}
			
			case KeyCode.DELETE: lineDeleteChar(modifier.ctrlKey || modifier.metaKey);
			case KeyCode.BACKSPACE: lineDeleteCharBack(modifier.ctrlKey || modifier.metaKey);
			case KeyCode.RIGHT: if (modifier.metaKey) cursorSet(line.glyphes.length) else cursorRight(modifier.shiftKey, modifier.ctrlKey || modifier.altKey);
			case KeyCode.LEFT: if (modifier.metaKey) cursorSet(0) else cursorLeft(modifier.shiftKey, modifier.ctrlKey || modifier.altKey);
			default:
		}
	}
	
	public function onWindowActivate():Void 
	{
		#if html5
		reFocus();
		#end
	}
	
	#if html5
	public function reFocus():Void 
	{
		Timer.delay(function() {
			lime._internal.backend.html5.HTML5Window.textInput.focus();
		}, 200);
	}
	#end
	
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