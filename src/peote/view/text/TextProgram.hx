package peote.view.text;

import peote.view.Texture;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Color;

@:access(peote.view.text.Text)
class TextProgram extends Program {

	static var defaultBmFontData:BMFontData = null;
	public var fontData(default, null):BMFontData;

	public var buff(get, never):Buffer<TextElement>;
	inline function get_buff() return cast this.buffer;

	public var texts(default, null) = new Array<Text>();

	public var defaultOptions:TextOptions = {
		fgColor: 0xf0f0f0ff,
		bgColor: 0,
		letterWidth: 8,
		letterHeight: 8,
		letterSpace: 0,
		lineSpace: 0,
		zIndex: 0
	};

	public function new(?fontData:BMFontData, ?textOptions:TextOptions, minBufferSize:Int = 1024 , growBufferSize:Int = 1024)
	{
		if (fontData == null) {
			if (defaultBmFontData == null) defaultBmFontData = new BMFontData(BMFont.data);
			fontData = defaultBmFontData;
		}
		this.fontData = fontData;

		if (textOptions != null) textOptions.copyNotNullValuesTo(defaultOptions);

		super( new Buffer<TextElement>(minBufferSize , growBufferSize) );

		var texture = Texture.fromData(fontData.textureData);

		texture.tilesX = fontData.length;
		texture.tilesY = 1;

		addTexture(texture, "base", false);
		setColorFormula("( base.r > 0.0) ? fgColor : bgColor");
	}

	public function add(text:Text) {
		if (texts.indexOf(text) >= 0) throw ("Error, text instance is already added");

		if (text.elements == null) {
			text.elements = new Array<TextElement>();
			createAddUpdate(text, true, true, true);
		}
		else {
			if (text.update == Text.POS) // only position changed
			{
				if (text.elements.length > 0) {
					var dx = text.x - text.elements[0].x;
					var dy = text.y - text.elements[0].y;
					for (e in text.elements) { e.x+=dx; e.y+=dy; e.z=text.zIndex; buff.addElement(e); }			
				}
			}
			else if (text.update & Text.TXT > 0) createAddUpdate(text, false, true, true); // text changed
			else createAddUpdate(text, false, true, false); // options changed
		}
		text.update = 0;

		texts.push(text);
	}

	public function update(text:Text) {
		if (texts.indexOf(text) < 0) throw ("Error, text instance is not added");

		if (text.update == 0) return; // nothing to update
		
		if (text.update == Text.POS) // only position changed
		{
			if (text.elements.length > 0) {
				var dx = text.x - text.elements[0].x;
				var dy = text.y - text.elements[0].y;
				for (e in text.elements) { e.x+=dx; e.y+=dy; e.z=text.zIndex; buff.updateElement(e); }			
			}
		}
		else if (text.update & Text.TXT > 0) createAddUpdate(text, false, false, true); // text changed
		else createAddUpdate(text, false, false, false); // options changed

		text.update = 0;
	}

	inline function createAddUpdate(text:Text, create:Bool, bufferAdd:Bool, changeTXT:Bool) 
	{
		var x:Int = text.x;
		var y:Int = text.y;

		var fgColor:Color = (text.fgColor != null) ? text.fgColor : defaultOptions.fgColor;
		var bgColor:Color = (text.bgColor != null) ? text.bgColor : defaultOptions.bgColor;
		var w:Int = (text.letterWidth  != null) ? text.letterWidth  : defaultOptions.letterWidth;
		var h:Int = (text.letterHeight != null) ? text.letterHeight : defaultOptions.letterHeight;
		var letterSpace:Int = (text.letterSpace != null) ? text.letterSpace : defaultOptions.letterSpace;
		var lineSpace:Int = (text.lineSpace != null) ? text.lineSpace : defaultOptions.lineSpace;
		var zIndex:Int = (text.zIndex != null) ? text.zIndex : defaultOptions.zIndex;

		letterSpace += w;
		lineSpace += h;

		var charCode:Int;
		var e:TextElement;
		var index = 0;
		for (i in 0...text.text.length)
		{
			charCode = text.text.charCodeAt(i); // trace("charcode:", charCode);
			if (text.text.charCodeAt(i) == 10) { // new line
				x = text.x;
				y += lineSpace;
			}
			else {
				if (create) {
					e = new TextElement(x, y, w, h, fgColor, bgColor, fontData.getTile(text.text.charCodeAt(i)), zIndex );
					buff.addElement(e);
					text.elements.push(e);
				} 
				else {
					if (changeTXT) {
						if (index < text.elements.length) {
							e = text.elements[index];
							e.x = x; e.y = y; e.w = w; e.h = h; e.fgColor = fgColor; e.bgColor = bgColor; e.z = zIndex;
							e.tile = fontData.getTile(text.text.charCodeAt(i));
							if (bufferAdd) buff.addElement(e) else buff.updateElement(e);
						}
						else {
							e = new TextElement(x, y, w, h, fgColor, bgColor, fontData.getTile(text.text.charCodeAt(i)), zIndex );
							text.elements.push(e);
							buff.addElement(e);
						}
					}
					else {
						e = text.elements[index];
						e.x = x; e.y = y; e.w = w; e.h = h; e.fgColor = fgColor; e.bgColor = bgColor; e.z = zIndex;
						if (bufferAdd) buff.addElement(e) else buff.updateElement(e);
					}
					index++;
				} 
				x += letterSpace;
			}
		}
		
		// if new text is smaller -> remove needles letters
		if (!create && changeTXT) {
			if (bufferAdd) for (i in index...text.elements.length) text.elements.pop(); // TODO: better split end of array here
			else for (i in index...text.elements.length) buff.removeElement( text.elements.pop() );
		}
	}

	// ----------------------------------

	public function remove(text:Text) {
		if (! texts.remove(text) ) throw ("Error, text instance not exists into TextProgram");
		for (e in text.elements) buff.removeElement(e);
	}


	public function create(x:Int, y:Int, textString:String, textOptions:TextOptions):Text {
		var text = new Text(x, y, textString, textOptions);
		add(text);
		return text;
	}

}
