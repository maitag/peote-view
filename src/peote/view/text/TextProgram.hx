package peote.view.text;

import peote.view.Texture;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Color;

/**
	The TextProgram extends a `Program` to display text by using a 8x8 pixels monospace bitmapfont.  
	It can handle multiple `Text`-instances and uses a `BMFontData` with `BMFont.data` by default.
**/
@:access(peote.view.text.Text)
class TextProgram extends Program {

	static var defaultBmFontData:BMFontData = null;

	/**
		The assigned `BMFontData` instance.
	**/
	public var fontData(default, null):BMFontData;

	/**
		A helper to access the `Buffer` of the Program.
	**/
	public var buff(get, never):Buffer<TextElement>;
	inline function get_buff() return cast this.buffer;

	/**
		Contains all added `Text` instances.
	**/
	public var texts(default, null) = new Array<Text>();

	/**
		These are the default `TextOptions` values that are used if an option has not been defined within the `Text` instance.
	**/
	public var defaultOptions:TextOptions = {
		fgColor: 0xf0f0f0ff,
		bgColor: 0,
		letterWidth: 8,
		letterHeight: 8,
		letterSpace: 0,
		lineSpace: 0,
		zIndex: 0
	};

	/**
		Creates a new `TextProgram` instance.		
		@param fontData the `BMFontData` what specifies the bitmap-font
		@param textOptions the `TextOptions` what is used as defaults if not set inside of a `Text` instance
		@param minBufferSize how many glyphes the buffer should contain as a minimum
		@param growBufferSize the size by which the buffer should grow when it is full
	**/
	public function new(?fontData:BMFontData, ?textOptions:TextOptions, minBufferSize:Int = 1024 , growBufferSize:Int = 1024) {
		if (fontData == null) {
			if (defaultBmFontData == null) defaultBmFontData = new BMFontData(BMFont.data);
			fontData = defaultBmFontData;
		}
		this.fontData = fontData;

		if (textOptions != null) textOptions.copyNotNullValuesTo(defaultOptions);

		super( #if doc_gen cast #end new Buffer<TextElement>(minBufferSize, growBufferSize) );

		var texture = Texture.fromData(fontData.textureData);

		texture.tilesX = fontData.length;
		texture.tilesY = 1;

		addTexture(texture, "base", false);
		setColorFormula("( base.r > 0.0) ? fgColor : bgColor");
	}

	/**
		Create a new `Text` instance automatically by a defined text-string and adds it.  
		@param text the `Text` instance to update
	**/
	public function create(x:Int, y:Int, textString:String, textOptions:TextOptions):Text {
		var text = new Text(x, y, textString, textOptions);
		add(text);
		return text;
	}

	/**
		Adds a `Text` to the program.  
		@param text the `Text` instance to add
		@param updateDefaultOptions to force an update of the programs default options
	**/
	public function add(text:Text, updateDefaultOptions:Bool = false):Text {
		if (texts.indexOf(text) >= 0) throw ("Error, text instance is already added");

		if (text.elements == null) {
			text.elements = new Array<TextElement>();
			createAddUpdate(text, true, true, true);
		}
		else {
			if (!updateDefaultOptions && text.update == 0) for (e in text.elements) buff.addElement(e); // only add it
			else if (!updateDefaultOptions && text.update == Text.POS) // only position changed
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
		return text;
	}

	/**
		Updates the changes of a `Text` isntance that have been added.  
		@param text the `Text` instance to update
		@param updateDefaultOptions to force an update of the programs default options
	**/
	public function update(text:Text, updateDefaultOptions:Bool = false) {
		if (texts.indexOf(text) < 0) throw ("Error, text instance is not added");

		if (!updateDefaultOptions && text.update == 0) return; // nothing to update
		
		if (!updateDefaultOptions && text.update == Text.POS) // only position changed
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

	/**
		Updates the changes of all `Text` instances that have been added.  
		@param updateDefaultOptions to force an update of the programs default options
	**/
	public function updateAll(updateDefaultOptions:Bool = false) {
		for (text in texts) update(text, updateDefaultOptions);
	}


	inline function createAddUpdate(text:Text, create:Bool, bufferAdd:Bool, changeTXT:Bool) {
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

	/**
		Removes a `Text` from the program.  
		@param text the `Text` instance to remove
	**/
	public function remove(text:Text) {
		if (! texts.remove(text) ) throw ("Error, text instance not exists into TextProgram");
		for (e in text.elements) buff.removeElement(e);
	}

	/**
		Removes all `Text` instances that have been added.  
	**/
	public function removeAll(text:Text) {
		for (text in texts) remove(text);
	}

}
