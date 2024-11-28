package peote.view.text;

import haxe.io.Bytes;
import peote.view.TextureData;
import peote.view.TextureFormat;

/**
	BMFontData provides the `TextureData` for `TextProgram`s by using the data of a embedded 8x8 pixels monospace bitmapfont.  
**/
class BMFontData {

	/**
		The number of glyphes the font contains.
	**/
	public var length(default, null):Int;

	/**
		The generated `TextureData`.
	**/
	public var textureData(default, null):TextureData;

	var ranges:Array<Int> = null;	

	/**
		Creates a new `BMFontData` instance and generates the x-tiled `TextureData` for all glyphes.		
		@param fontData the data of `BMFont` or a custom class what defines the font-data.  
		@param fontRanges is need if the custom font is limited by charcode-ranges
	**/
	public function new(fontData:Array<Int>, ?fontRanges:Array<Array<Int>>) {

		if (fontRanges != null) {
			ranges = new Array<Int>();
			for (r in fontRanges) ranges.push( (r[0] << 16) + r[1] );
		}

		length = fontData.length >> 3;
		var width = length << 3;
		var height = 8;

		var bytes = Bytes.alloc(width * height);

		var i:Int;
		var b:Int;
		var c:Int = 0;

		while (c < fontData.length) {
			for (row in 0...8) {
				i = row * width + c;
				b = fontData[c + row];
				if (b & 0x80 > 0) bytes.set(i, 0xFF); i++;
				if (b & 0x40 > 0) bytes.set(i, 0xFF); i++;
				if (b & 0x20 > 0) bytes.set(i, 0xFF); i++;
				if (b & 0x10 > 0) bytes.set(i, 0xFF); i++;
				if (b & 0x08 > 0) bytes.set(i, 0xFF); i++;
				if (b & 0x04 > 0) bytes.set(i, 0xFF); i++;
				if (b & 0x02 > 0) bytes.set(i, 0xFF); i++;
				if (b & 0x01 > 0) bytes.set(i, 0xFF); i++;
			}
			c += 8; // next line
		}

		textureData = new TextureData(width, height, TextureFormat.R, bytes);
	}
	
	/**
		Returns the tile-number of the `TextElement` to map the glyph to the charCode in depend of the ranges.  
		@param charCode the ascii charcode
	**/
	public function getTile(charCode:UInt):Int
	{
		var tile:Int;

		if (ranges == null) tile = charCode;
		else 
		{
			tile = 0;
			for (range in ranges)
			{
				if ( charCode >= (range >> 16) && charCode <= (range & 0xffff) ) {
					tile += charCode - (range >> 16);
					break;
				} 
				else tile += (range & 0xffff) - (range >> 16) + 1;
			}
		}

		if (tile >= length) throw("Error, charCode don't exists into font range");

		return tile;
	}

}
