package peote.view;

import haxe.io.Bytes;
import haxe.io.UInt8Array;
import haxe.io.Float32Array;
import peote.view.TextureFormat;

/*             bytes per pixel
RGBA               4
RGB                3
LUMINANCE_ALPHA    2
RG                 2
R                  1
LUMINANCE          1
ALPHA              1

FLOAT_RGBA        16
FLOAT_RGB         12
FLOAT_RG           8
FLOAT_R            4
*/	

/**
	Stores image data into different `TextureFormat`s to use it for `Texture`s.  
	It supports basic converting functions and a low level api to edit pixels.
**/
#if (!doc_gen) private #end
class TextureDataImpl
{
	/**
		the used `TextureFormat`
	**/
	public var format:TextureFormat = TextureFormat.RGBA;

	/**
		horizontal image size
	**/
	public var width:Int;

	/**
		vertical image size
	**/
	public var height:Int;

	/**
		represents the bytes data of an image
	**/
	public var bytes:Bytes;

	/**
		Creates a new `TextureDataImpl` instance.
		@param width horizontal size
		@param height vertical size
		@param format the used `TextureFormat` (RGBA by default)
		@param color background color
		@param bytes to create from existing `Bytes` data
	**/
	public function new(width:Int, height:Int, format:TextureFormat = TextureFormat.RGBA, color:Color = 0, ?bytes:Bytes)
	{
		this.width = width;
		this.height = height;
		this.format = format;
		if (bytes == null) {
			this.bytes = Bytes.alloc(width * height * format.bytesPerPixel );
			if (color != 0) clear(color);
		}
		else this.bytes = bytes;
	}

	/**
		Fills the entire texturedata with a color.
		@param color a `Color` value
	**/
	public function clear(color:Color = 0)
	{
		if ( format.isFloat ) clearFloat(color.redF, color.greenF, color.blueF, color.alphaF);
		else {
			var pos:Int = 0;
			switch (format) {
				case RGBA:
					for (i in 0...width * height) {
						bytes.set(pos++, color.red);
						bytes.set(pos++, color.green);
						bytes.set(pos++, color.blue);
						bytes.set(pos++, color.alpha);
					}
				case RGB:
					for (i in 0...width * height) {
						bytes.set(pos++, color.red);
						bytes.set(pos++, color.green);
						bytes.set(pos++, color.blue);
					}
				case RG:
					for (i in 0...width * height) {
						bytes.set(pos++, color.red);
						bytes.set(pos++, color.green);
					}
				case R:         for (i in 0...width * height) bytes.set(pos++, color.red);
				case LUMINANCE:	for (i in 0...width * height) bytes.set(pos++, color.luminance);
				case ALPHA:     for (i in 0...width * height) bytes.set(pos++, color.alpha);
				case LUMINANCE_ALPHA:
					for (i in 0...width * height) {
						bytes.set(pos++, color.luminance);
						bytes.set(pos++, color.alpha);
					}
				default:
			}
		}
	}

	/**
		Fills the entire texturedata with a color if using float `TextureFormat`.
		@param red value (0.0 to 1.0) for red color channel
		@param green value (0.0 to 1.0) for green color channel
		@param blue value (0.0 to 1.0) for blue color channel
		@param alpha value (0.0 to 1.0) for alpha channel
	**/
	public function clearFloat(red:Float=0.0, green:Float=0.0, blue:Float=0.0, alpha:Float=0.0)
	{
		if ( !format.isFloat ) throw("error, use clear() for INTEGER textureformats");
		var pos:Int = 0;
		switch (format) {
			case FLOAT_RGBA:
				for (i in 0...width * height) {
					bytes.setFloat(pos, red); pos+=4;
					bytes.setFloat(pos, green); pos+=4;
					bytes.setFloat(pos, blue); pos+=4;
					bytes.setFloat(pos, alpha); pos+=4;
				}
			case FLOAT_RGB:
				for (i in 0...width * height) {
					bytes.setFloat(pos, red); pos+=4;
					bytes.setFloat(pos, green); pos+=4;
					bytes.setFloat(pos, blue); pos+=4;
				}
			case FLOAT_RG:
				for (i in 0...width * height) {
					bytes.setFloat(pos, red); pos+=4;
					bytes.setFloat(pos, green); pos+=4;
				}
			default:
				for (i in 0...width * height) bytes.setFloat(pos, red); pos+=4;
		}
	}


	// -------------------------------------------------------------
	// ------- to clone or convert into other TextureFormats -------
	// -------------------------------------------------------------

	/**
		Creates a new texturedata and copies all data into it.
	**/
	public function clone():TextureDataImpl {
		var t = new TextureDataImpl(width, height, format);
		t.bytes.blit( 0, bytes, 0, bytes.length);
		return t;
	}

	/**
		Converts and returns a new created texturedata into `RGBA` integer `TextureFormat`.  
		The alpha value will be 255 (opaque) if the source texturedata have no alpha channel.
	**/
	public function toRGBA():TextureData {
		var t = new TextureData(width, height, TextureFormat.RGBA);
		var d:Int = 0; // destination pos
		var s:Int = 0; // source pos
		switch (format) {
			case RGBA: t.bytes.blit( 0, bytes, 0, bytes.length);
			case RGB: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++)); t.bytes.set(d++, bytes.get(s++)); t.bytes.set(d++, bytes.get(s++));
				t.bytes.set(d++, 0xff);
			}
			case RG: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++)); t.bytes.set(d++, bytes.get(s++));
				d++; t.bytes.set(d++, 0xff);
			}
			case R: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++));
				d+=2; t.bytes.set(d++, 0xff);
			}
			case LUMINANCE_ALPHA: while (d < t.bytes.length ) {
				var lum = bytes.get(s++);
				t.bytes.set(d++, lum);
				t.bytes.set(d++, lum);
				t.bytes.set(d++, lum);				
				t.bytes.set(d++, bytes.get(s++));				
			}
			case LUMINANCE: while (d < t.bytes.length ) {
				var lum = bytes.get(s++);
				t.bytes.set(d++, lum);
				t.bytes.set(d++, lum);
				t.bytes.set(d++, lum);
				t.bytes.set(d++, 0xff);
			}
			case ALPHA: while (d < t.bytes.length ) {
				d+=3; t.bytes.set(d++, bytes.get(s++));
			}

			// from FLOAT:
			case FLOAT_RGBA: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
			}
			case FLOAT_RGB: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				t.bytes.set(d++, 0xff);
			}
			case FLOAT_RG: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				d++; t.bytes.set(d++, 0xff);
			}
			case FLOAT_R: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				d+=2; t.bytes.set(d++, 0xff);
			}
			default:
		}
		return t;
	}

	/**
		Converts and returns a new created texturedata into `RGB` integer `TextureFormat`.  
		If the source format is of type `ALPHA`, the alpha value will be converted into the red colorchannel.
	**/
	public function toRGB():TextureData {
		var t = new TextureData(width, height, TextureFormat.RGB);
		var d:Int = 0; // destination pos
		var s:Int = 0; // source pos
		switch (format) {
			case RGB: t.bytes.blit( 0, bytes, 0, bytes.length);
			case RGBA: while (d < t.bytes.length ) {
				 t.bytes.set(d++, bytes.get(s++)); t.bytes.set(d++, bytes.get(s++)); t.bytes.set(d++, bytes.get(s++));
				 s++;
			}
			case RG: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++)); t.bytes.set(d++, bytes.get(s++));
				d++;
			}
			case R | ALPHA: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++));
				d+=2;
			}
			case LUMINANCE_ALPHA: while (d < t.bytes.length ) {
				var lum = bytes.get(s++); s++;
				t.bytes.set(d++, lum);
				t.bytes.set(d++, lum);
				t.bytes.set(d++, lum);				
			}
			case LUMINANCE: while (d < t.bytes.length ) {
				var lum = bytes.get(s++);
				t.bytes.set(d++, lum);
				t.bytes.set(d++, lum);
				t.bytes.set(d++, lum);
			}

			// from FLOAT:
			case FLOAT_RGBA: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=8;
			}
			case FLOAT_RGB: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
			}
			case FLOAT_RG: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				d++;
			}
			case FLOAT_R: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				d+=2;
			}
			default:
		}
		return t;
	}

	/**
		Converts and returns a new created texturedata into `RG` integer `TextureFormat`.  
		If the source format is of type `ALPHA`, the alpha value will be converted into the red colorchannel.
	**/
	public function toRG():TextureData {
		var t = new TextureData(width, height, TextureFormat.RG);
		var d:Int = 0; // destination pos
		var s:Int = 0; // source pos
		switch (format) {
			case RG: t.bytes.blit( 0, bytes, 0, bytes.length);
			case RGBA: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++)); t.bytes.set(d++, bytes.get(s++)); s+=2;
			}
			case RGB: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++)); t.bytes.set(d++, bytes.get(s++)); s++;
			}
			case R | ALPHA: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++)); d++;
			}
			case LUMINANCE_ALPHA: while (d < t.bytes.length ) {
				var lum = bytes.get(s++); s++;
				t.bytes.set(d++, lum);
				t.bytes.set(d++, lum);			
			}
			case LUMINANCE: while (d < t.bytes.length ) {
				var lum = bytes.get(s++);
				t.bytes.set(d++, lum);
				t.bytes.set(d++, lum);
			}

			// from FLOAT:
			case FLOAT_RGBA: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=12;
			}
			case FLOAT_RGB: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=8;
			}
			case FLOAT_RG: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
			}
			case FLOAT_R: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				d++;
			}
			default:
		}
		return t;
	}

	/**
		Converts and returns a new created texturedata into `R` integer `TextureFormat`.  
		If the source format is of type `ALPHA`, the alpha value will be converted into the red colorchannel.
	**/
	public function toR():TextureData {
		var t = new TextureData(width, height, TextureFormat.R);
		var d:Int = 0; // destination pos
		var s:Int = 0; // source pos
		switch (format) {
			case R: t.bytes.blit( 0, bytes, 0, bytes.length);
			case RGBA: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++)); s+=3;
			}
			case RGB: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++)); s+=2;
			}
			case RG | LUMINANCE_ALPHA: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++)); s++;
			}
			case LUMINANCE | ALPHA: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++));
			}

			// from FLOAT:
			case FLOAT_RGBA: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=16;
			}
			case FLOAT_RGB: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=12;
			}
			case FLOAT_RG: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=8;
			}
			case FLOAT_R: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
			}
			default:
		}
		return t;
	}

	/**
		Converts and returns a new created texturedata into `LUMINANCE_ALPHA` integer `TextureFormat`.  
		The alpha value will be 255 (opaque) if the source texturedata have no alpha channel.
	**/
	public function toLuminanceAlpha():TextureData {
		var t = new TextureData(width, height, TextureFormat.LUMINANCE_ALPHA);
		var d:Int = 0; // destination pos
		var s:Int = 0; // source pos
		switch (format) {
			case LUMINANCE_ALPHA: t.bytes.blit( 0, bytes, 0, bytes.length);
			case RGBA: while (d < t.bytes.length ) {
				t.bytes.set(d++, Math.round( (bytes.get(s++) + bytes.get(s++) + bytes.get(s++)) / 3) );
				t.bytes.set(d++, bytes.get(s++));
			}
			case RGB: while (d < t.bytes.length ) {
				t.bytes.set(d++, Math.round( (bytes.get(s++) + bytes.get(s++) + bytes.get(s++)) / 3) );
				t.bytes.set(d++, 0xff); s++;
			}
			case RG: while (d < t.bytes.length ) {
				t.bytes.set(d++, Math.round( (bytes.get(s++) + bytes.get(s++)) / 2) );
				t.bytes.set(d++, 0xff);
			}
			case R: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++));
				t.bytes.set(d++, 0xff);
			}
			case LUMINANCE: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++));
				t.bytes.set(d++, 0xff);
			}
			case ALPHA: while (d < t.bytes.length ) {
				d++; t.bytes.set(d++, bytes.get(s++));
			}

			// from FLOAT:
			case FLOAT_RGBA: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int( (bytes.getFloat(s) + bytes.getFloat(s+=4) + bytes.getFloat(s+=4)) * 85) );
				t.bytes.set(d++, Std.int(bytes.getFloat(s+=4)*255)); s+=4;
			}
			case FLOAT_RGB: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int( (bytes.getFloat(s) + bytes.getFloat(s+=4) + bytes.getFloat(s+=4)) * 85) ); s+=4;
				t.bytes.set(d++, 0xff);
			}
			case FLOAT_RG: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int( (bytes.getFloat(s) + bytes.getFloat(s+=4)) * 127) ); s+=4;
				t.bytes.set(d++, 0xff);
			}
			case FLOAT_R: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
				t.bytes.set(d++, 0xff);
			}
			default:
		}
		return t;
	}

	/**
		Converts and returns a new created texturedata into `LUMINANCE` integer `TextureFormat`.  
		If the source format is of type `ALPHA`, the alpha value will be used for luminance.
	**/
	public function toLuminance():TextureData {
		var t = new TextureData(width, height, TextureFormat.LUMINANCE);
		var d:Int = 0; // destination pos
		var s:Int = 0; // source pos
		switch (format) {
			case LUMINANCE: t.bytes.blit( 0, bytes, 0, bytes.length);
			case RGBA: while (d < t.bytes.length ) {
				t.bytes.set(d++, Math.round( (bytes.get(s++) + bytes.get(s++) + bytes.get(s++)) / 3) ); s++;
			}
			case RGB: while (d < t.bytes.length ) {
				t.bytes.set(d++, Math.round( (bytes.get(s++) + bytes.get(s++) + bytes.get(s++)) / 3) );
			}
			case RG: while (d < t.bytes.length ) {
				t.bytes.set(d++, Math.round( (bytes.get(s++) + bytes.get(s++)) / 2) );
			}
			case LUMINANCE_ALPHA: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++)); s++;
			}
			case R | ALPHA: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++));
			}

			// from FLOAT:
			case FLOAT_RGBA: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int( (bytes.getFloat(s) + bytes.getFloat(s+=4) + bytes.getFloat(s+=4)) * 85) ); s+=4;
			}
			case FLOAT_RGB: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int( (bytes.getFloat(s) + bytes.getFloat(s+=4) + bytes.getFloat(s+=4)) * 85) ); s+=4;
			}
			case FLOAT_RG: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int( (bytes.getFloat(s) + bytes.getFloat(s+=4)) * 127) ); s+=4;
			}
			case FLOAT_R: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
			}
			default:
		}
		return t;
	}

	/**
		Converts and returns a new created texturedata into `ALPHA` integer `TextureFormat`.  
		If the source have no alpha channel it will convert the red color channel into alpha.
	**/
	public function toAlpha():TextureData {
		var t = new TextureData(width, height, TextureFormat.ALPHA);
		var d:Int = 0; // destination pos
		var s:Int = 0; // source pos
		switch (format) {
			case ALPHA: t.bytes.blit( 0, bytes, 0, bytes.length);
			case RGBA: while (d < t.bytes.length ) {
				s+=3; t.bytes.set(d++, bytes.get(s++) );
			}
			case RGB: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++) ); s+=2;
			}
			case RG: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++) ); s++;
			}
			case R: while (d < t.bytes.length ) {
				t.bytes.set(d++, bytes.get(s++));
			}

			// from FLOAT:
			case FLOAT_RGBA: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s+=12)*255)); s+=4;
			}
			case FLOAT_RGB: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=12;
			}
			case FLOAT_RG: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=8;
			}
			case FLOAT_R: while (d < t.bytes.length ) {
				t.bytes.set(d++, Std.int(bytes.getFloat(s)*255)); s+=4;
			}
			default:
		}
		return t;
	}

	/**
		Converts and returns a new created texturedata into `FLOAT_RGBA` `TextureFormat`.  
		The alpha value will be 1.0 (opaque) if the source texturedata have no alpha channel.
	**/
	public function toFloatRGBA():TextureData {
		var t = new TextureData(width, height, TextureFormat.FLOAT_RGBA);
		var d:Int = 0; // destination pos
		var s:Int = 0; // source pos
		switch (format) {
			case FLOAT_RGBA: t.bytes.blit( 0, bytes, 0, bytes.length);
			case FLOAT_RGB: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=4; s+=4;
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=4; s+=4;
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=4; s+=4;
				t.bytes.setFloat(d, 1.0); d+=4;
			}
			case FLOAT_RG: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=4; s+=4;
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=4; s+=4;
				d+=4;
				t.bytes.setFloat(d, 1.0); d+=4;
			}
			case FLOAT_R: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=4; s+=4;
				d+=8;
				t.bytes.setFloat(d, 1.0); d+=4;
			}

			// from INTEGER:
			case RGBA: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
			}
			case RGB: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
				t.bytes.setFloat(d, 1.0); d+=4;
			}
			case RG: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=8;
				t.bytes.setFloat(d, 1.0); d+=4;
			}
			case R: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=12;
				t.bytes.setFloat(d, 1.0); d+=4;
			}
			case LUMINANCE_ALPHA: while (d < t.bytes.length ) {
				var lum = bytes.get(s++)/255;
				t.bytes.setFloat(d, lum); d+=4;
				t.bytes.setFloat(d, lum); d+=4;
				t.bytes.setFloat(d, lum); d+=4;
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
			}
			case LUMINANCE: while (d < t.bytes.length ) {
				var lum = bytes.get(s++)/255;
				t.bytes.setFloat(d, lum); d+=4;
				t.bytes.setFloat(d, lum); d+=4;
				t.bytes.setFloat(d, lum); d+=4;
				t.bytes.setFloat(d, 1.0); d+=4;
			}
			case ALPHA: while (d < t.bytes.length ) {
				t.bytes.setFloat(d+=12, bytes.get(s++)/255); d+=4;
			}
			default:
		}
		return t;
	}

	/**
		Converts and returns a new created texturedata into `FLOAT_RGB` `TextureFormat`.  
		If the source format is of type `ALPHA`, the alpha value will be converted into the red colorchannel.
	**/
	public function toFloatRGB():TextureData {
		var t = new TextureData(width, height, TextureFormat.FLOAT_RGB);
		var d:Int = 0; // destination pos
		var s:Int = 0; // source pos
		switch (format) {
			case FLOAT_RGB: t.bytes.blit( 0, bytes, 0, bytes.length);
			case FLOAT_RGBA: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=4; s+=4;
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=4; s+=4;
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=4; s+=8;
			}
			case FLOAT_RG: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=4; s+=4;
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=8; s+=4;
			}
			case FLOAT_R: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=12; s+=4;
			}

			// from INTEGER:
			case RGBA: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4; s++;
			}
			case RGB: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
			}
			case RG: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=8;
			}
			case R | ALPHA: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=12;
			}
			case LUMINANCE_ALPHA: while (d < t.bytes.length ) {
				var lum = bytes.get(s++)/255;
				t.bytes.setFloat(d, lum); d+=4;
				t.bytes.setFloat(d, lum); d+=4;
				t.bytes.setFloat(d, lum); d+=4;
				s++;
			}
			case LUMINANCE: while (d < t.bytes.length ) {
				var lum = bytes.get(s++)/255;
				t.bytes.setFloat(d, lum); d+=4;
				t.bytes.setFloat(d, lum); d+=4;
				t.bytes.setFloat(d, lum); d+=4;
			}
			default:
		}
		return t;
	}

	/**
		Converts and returns a new created texturedata into `FLOAT_RG` `TextureFormat`.  
		If the source format is of type `ALPHA`, the alpha value will be converted into the red colorchannel.
	**/
	public function toFloatRG():TextureData {
		var t = new TextureData(width, height, TextureFormat.FLOAT_RG);
		var d:Int = 0; // destination pos
		var s:Int = 0; // source pos
		switch (format) {
			case FLOAT_RG: t.bytes.blit( 0, bytes, 0, bytes.length);
			case FLOAT_RGBA: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=4; s+=4;
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=4; s+=12;
			}
			case FLOAT_RGB: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=4; s+=4;
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=4; s+=8;
			}
			case FLOAT_R: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=8; s+=4;
			}

			// from INTEGER:
			case RGBA: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4; s+=2;
			}
			case RGB: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4; s++;
			}
			case RG: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
			}
			case R | ALPHA: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=8;
			}
			case LUMINANCE_ALPHA: while (d < t.bytes.length ) {
				var lum = bytes.get(s++)/255; s++;
				t.bytes.setFloat(d, lum); d+=4;
				t.bytes.setFloat(d, lum); d+=4;				
			}
			case LUMINANCE: while (d < t.bytes.length ) {
				var lum = bytes.get(s++)/255;
				t.bytes.setFloat(d, lum); d+=4;
				t.bytes.setFloat(d, lum); d+=4;
			}
			default:
		}
		return t;
	}

	/**
		Converts and returns a new created texturedata into `FLOAT_R` `TextureFormat`.  
		If the source format is of type `ALPHA`, the alpha value will be converted into the red colorchannel.
	**/
	public function toFloatR():TextureData {
		var t = new TextureData(width, height, TextureFormat.FLOAT_R);
		var d:Int = 0; // destination pos
		var s:Int = 0; // source pos
		switch (format) {
			case FLOAT_R: t.bytes.blit( 0, bytes, 0, bytes.length);
			case FLOAT_RGBA: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=4; s+=16;
			}
			case FLOAT_RGB: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=4; s+=12;
			}
			case FLOAT_RG: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.getFloat(s)); d+=4; s+=8;
			}

			// from INTEGER:
			case RGBA: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.get(s)/255); d+=4; s+=4;
			}
			case RGB: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.get(s)/255); d+=4; s+=3;
			}
			case RG | LUMINANCE_ALPHA: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.get(s)/255); d+=4; s+=2;
			}
			case R | LUMINANCE | ALPHA: while (d < t.bytes.length ) {
				t.bytes.setFloat(d, bytes.get(s++)/255); d+=4;
			}
			default:
		}
		return t;
	}


	// ---------------------------------------------------------------
	// ----------- set colors for Integer textureformat --------------
	// ---------------------------------------------------------------

	/**
		Sets the `Color` of a pixel for integer `TextureFormat`s.
		@param x horizontal position
		@param y vertical position
		@param color color value
	**/
	public function setColor(x:Int, y:Int, color:Color)
	{
		if ( format.isFloat ) throw("error, use setFloat() for FLOAT textureformats");
		var pos = (y * width + x) * format.bytesPerPixelInt;
		switch (format) {
			case RGBA: _setRGBABytes(pos, color);
			case LUMINANCE: bytes.set(pos, color.luminance);
			case ALPHA: bytes.set(pos, color.alpha);
			case LUMINANCE_ALPHA:
				bytes.set(pos, color.luminance);
				bytes.set(pos+1, color.alpha);
			default: 
				bytes.set(pos, color.red);
				if ( format.isGreaterR() ) {
					bytes.set(pos+1, color.green);
					if ( format.isGreaterRG() ) {
						bytes.set(pos+2, color.blue);
					}
				}
		}
	}

	/**
		Sets the `Color` of a pixel optimized for the `RGBA` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
		@param color color value
	**/
	public inline function setColor_RGBA(x:Int, y:Int, color:Color) _setRGBABytes((y * width + x) << 2, color);

	inline function _setRGBABytes(pos:Int, color:Color) {
		bytes.set(pos, color.red);
		bytes.set(pos + 1, color.green);
		bytes.set(pos + 2, color.blue);
		bytes.set(pos + 3, color.alpha);
	}

	/**
		Sets the colorchannels of a pixel optimized for the `RGBA` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
		@param red value from 0 to 255
		@param green value from 0 to 255
		@param blue value from 0 to 255
		@param alpha value from 0 (full transparent) to 255 (opaque)
	**/
	public inline function set_RGBA(x:Int, y:Int, red:Int, green:Int, blue:Int, alpha:Int) {
		var pos = (y * width + x) * 3;
		bytes.set(pos, red); bytes.set(pos+1, green); bytes.set(pos+2, blue); bytes.set(pos+3, alpha);
	}

	/**
		Sets the colorchannels of a pixel optimized for the `RGB` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
		@param red value from 0 to 255
		@param green value from 0 to 255
		@param blue value from 0 to 255
	**/
	public inline function set_RGB(x:Int, y:Int, red:Int, green:Int, blue:Int) {
		var pos = (y * width + x) * 3;
		bytes.set(pos, red); bytes.set(pos+1, green); bytes.set(pos+2, blue);
	}

	/**
		Sets the colorchannels of a pixel optimized for the `RG` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
		@param red value from 0 to 255
		@param green value from 0 to 255
	**/
	public inline function set_RG(x:Int, y:Int, red:Int, green:Int) {
		var pos = (y * width + x) << 1;
		bytes.set(pos, red); bytes.set(pos+1, green);
	}

	/**
		Sets the colorchannels of a pixel optimized for the `R` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
		@param red value from 0 to 255
	**/
	public inline function set_R(x:Int, y:Int, red:Int) bytes.set(y * width + x, red);

	/**
		Sets the colorchannels of a pixel optimized for the `LUMINANCE_ALPHA` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
		@param luminance value from 0 to 255
		@param alpha value from 0 (full transparent) to 255 (opaque)
	**/
	public inline function set_LUMINANCE_ALPHA(x:Int, y:Int, luminance:Int, alpha:Int) set_RG(x, y, luminance, alpha);

	/**
		Sets the colorchannels of a pixel optimized for the `LUMINANCE` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
		@param luminance value from 0 to 255
	**/
	public inline function set_LUMINANCE(x:Int, y:Int, luminance:Int) set_R(x, y, luminance);

	/**
		Sets the colorchannels of a pixel optimized for the `ALPHA` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
		@param alpha value from 0 (full transparent) to 255 (opaque)
	**/
	public inline function set_ALPHA(x:Int, y:Int, alpha:Int) set_R(x, y, alpha);


	// ----------------------------------------------------------------------------------------
	// ----- sets a single value for one specific colorchannel for integer TextureFormats -----
	// ----------------------------------------------------------------------------------------

	/**
		Sets the red channel of a pixel optimized for `RGBA`, `RGB`, `RG` or `R` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
		@param red value from 0 to 255
	**/
	public inline function setRed(x:Int, y:Int, red:Int) {
		if (format.isInRGBA()) bytes.set((y * width + x) * format.bytesPerPixelInt, red);
		else throw("Error: Textureformat have no red channel");
	}

	/**
		Sets the green channel of a pixel optimized for `RGBA`, `RGB` or`RG` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
		@param green value from 0 to 255
	**/
	public inline function setGreen(x:Int, y:Int, green:Int) {
		if (format.isGreaterR() && format.isInRGBA()) bytes.set( (y * width + x) * format.bytesPerPixelInt + 1, green );
		else throw("Error: Textureformat have no green channel");
	}
	
	/**
		Sets the blue channel of a pixel optimized for `RGBA` or `RGB` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
		@param blue value from 0 to 255
	**/
	public inline function setBlue(x:Int, y:Int, blue:Int) {
		if (format.isGreaterRG() && format.isInRGBA()) bytes.set( (y * width + x) * format.bytesPerPixelInt + 2, blue );
		else throw("Error: Textureformat have no blue channel");
	}
	
	/**
		Sets the alpha channel of a pixel optimized for `RGBA`, `LUMINANCE_ALPHA` or `ALPHA` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
		@param alpha value from 0 (full transparent) to 255 (opaque)
	**/
	public inline function setAlpha(x:Int, y:Int, alpha:Int) {
		switch (format) {
			case RGBA:            bytes.set( (y * width + x) * 4 + 3, alpha );
			case LUMINANCE_ALPHA: bytes.set( (y * width + x) * 2 + 1, alpha );
			case ALPHA:           bytes.set( (y * width + x), alpha);
			default: throw("Error: Textureformat have no alpha channel");
		}
	}
	
	/**
		Sets the luminance of a pixel optimized for `RGBA`, `RGB`, `RG`, `R`, `LUMINANCE` or `LUMINANCE_ALPHA` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
		@param luminance value from 0 to 255
	**/
	public inline function setLuminance(x:Int, y:Int, luminance:Int) {
		var pos = (y * width + x) * format.bytesPerPixelInt;
		switch (format) {
			case LUMINANCE:       bytes.set(pos, luminance);
			case LUMINANCE_ALPHA: bytes.set(pos, luminance);	
			case ALPHA: throw("Error: Textureformat have no red, green or blue channel to set luminance");
			default: 
				bytes.set(pos, luminance);
				if ( format.isGreaterR() ) {
					bytes.set(pos+1, luminance);
					if ( format.isGreaterRG() ) {
						bytes.set(pos+2, luminance);
					}
				}
		}
	}


	// ---------------------------------------------------------------
	// ----------- get colors for Integer textureformat --------------
	// ---------------------------------------------------------------

	/**
		Gets the `Color` of a pixel for integer `TextureFormat`s.
		@param x horizontal position
		@param y vertical position
	**/
	public function getColor(x:Int, y:Int):Color
	{
		if ( format.isFloat ) throw("error, use getFloat...() for FLOAT textureformats");
		var pos = (y * width + x) * format.bytesPerPixelInt;
		return switch (format) {
			case RGBA: _getRGBABytes(pos);
			case LUMINANCE: Color.Luminance( bytes.get(pos) );
			case ALPHA: Color.Alpha( bytes.get(pos) );
			case LUMINANCE_ALPHA: Color.LuminanceAlpha( bytes.get(pos), bytes.get(pos+1) );
			default: 
				var color:Color = Color.BLACK;
				color.r = bytes.get(pos);
				if ( format.isGreaterR() ) {
					color.g = bytes.get(pos+1);
					if ( format.isGreaterRG() ) {
						color.b = bytes.get(pos+2);
					}
				}
				color;
		}
	}

	/**
		Gets the `Color` of a pixel optimized for the `RGBA` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
	**/
	public inline function getColor_RGBA(x:Int, y:Int):Color return _getRGBABytes((y * width + x) << 2);

	inline function _getRGBABytes(pos:Int):Color {
		return Color.RGBA( bytes.get(pos), bytes.get(pos + 1), bytes.get(pos + 2), bytes.get(pos + 3) );
	}

	/**
		Gets the `Color` of a pixel optimized for the `RGB` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
	**/
	public inline function getColor_RGB(x:Int, y:Int):Color {
		var pos = (y * width + x) * 3;
		return Color.RGB( bytes.get(pos), bytes.get(pos + 1), bytes.get(pos + 2) );
	}

	/**
		Gets the `Color` of a pixel optimized for the `RG` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
	**/
	@:access(peote.view.Color) // Color.RG is not public!
	public inline function getColor_RG(x:Int, y:Int):Color {
		var pos = (y * width + x) << 1;
		return Color.RG( bytes.get(pos), bytes.get(pos + 1) );
	}

	/**
		Gets the `Color` of a pixel optimized for the `LUMINANCE_ALPHA` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
	**/
	public inline function getColor_LUMINANCE_ALPHA(x:Int, y:Int):Color {
		var pos = (y * width + x) << 1;
		return Color.LuminanceAlpha( bytes.get(pos), bytes.get(pos + 1) );
	}

	/**
		Gets the `Color` of a pixel optimized for the `R` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
	**/
	public inline function getColor_R(x:Int, y:Int):Color return Color.Red( get_R(x, y) );

	/**
		Gets the `Color` of a pixel optimized for the `LUMINANCE` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
	**/
	public inline function getColor_LUMINANCE(x:Int, y:Int):Color return Color.Luminance( get_R(x, y) );

	/**
		Gets the `Color` of a pixel optimized for the `ALPHA` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
	**/
	public inline function getColor_ALPHA(x:Int, y:Int):Color return Color.Alpha    ( get_R(x, y) );
	
	/**
		Gets the red value as an integer (0-255) of a pixel, optimized for the `R` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
	**/
	public inline function get_R(x:Int, y:Int):Int return bytes.get(y * width + x);

	/**
		Gets the luminance value as an integer (0-255) of a pixel, optimized for the `LUMINANCE` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
	**/
	public inline function get_LUMINANCE(x:Int, y:Int):Int return get_R(x, y);

	/**
		Gets the alpha value as an integer (0-255) of a pixel, optimized for the `ALPHA` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
	**/
	public inline function get_ALPHA(x:Int, y:Int):Int return get_R(x, y);
	
	
	// --- get single value for one specific colorchannel in depend of Integer TextureFormat ---

	/**
		Gets the red value as an integer (0-255) of a pixel for integer `TextureFormat`s.
		@param x horizontal position
		@param y vertical position
	**/
	public inline function getRed(x:Int, y:Int):Int {
		if (!format.isInRGBA()) throw("Error: Textureformat have no red channel");
		return bytes.get((y * width + x) * format.bytesPerPixel);
	}

	/**
		Gets the green value as an integer (0-255) of a pixel for integer `TextureFormat`s.
		@param x horizontal position
		@param y vertical position
	**/
	public inline function getGreen(x:Int, y:Int):Int {
		if (!format.isGreaterR()) throw("Error: Textureformat have no green channel");
		return bytes.get(((y * width + x) * format.bytesPerPixel) + 1);
	}

	/**
		Gets the blue value as an integer (0-255) of a pixel for integer `TextureFormat`s.
		@param x horizontal position
		@param y vertical position
	**/
	public inline function getBlue(x:Int, y:Int):Int {
		if (!format.isGreaterRG()) throw("Error: Textureformat have no blue channel");
		return bytes.get(((y * width + x) * format.bytesPerPixel) + 2);
	}

	/**
		Gets the alpha value as an integer (0-255) of a pixel for integer `TextureFormat`s.
		@param x horizontal position
		@param y vertical position
	**/
	public inline function getAlpha(x:Int, y:Int):Int {
		return switch (format) {
			case ALPHA:           bytes.get( (y * width + x) );
			case LUMINANCE_ALPHA: bytes.get( (y * width + x) * 2 + 1 );
			case RGBA:            bytes.get( (y * width + x) * 4 + 3 );
			default: throw("Error: Textureformat have no alpha channel");
		}
	}

	/**
		Gets the luminance value as an integer (0-255) of a pixel for integer `TextureFormat`s.
		@param x horizontal position
		@param y vertical position
	**/
	public inline function getLuminance(x:Int, y:Int):Int {
		var pos = (y * width + x) * format.bytesPerPixelInt;
		return switch (format) {
			case LUMINANCE:       bytes.get(pos);
			case LUMINANCE_ALPHA: bytes.get(pos);	
			case R:               bytes.get(pos);
			case RGBA: Std.int( (bytes.get(pos) + bytes.get(pos + 1) + bytes.get(pos + 2)) / 3 );
			case RGB:  Std.int( (bytes.get(pos) + bytes.get(pos + 1) + bytes.get(pos + 2)) / 3 );
			case RG:   Std.int( (bytes.get(pos) + bytes.get(pos + 1)) / 2 );
			default: throw("Error: Textureformat have no red, green or blue channel to get luminance");
		}
	}

	// -------------------------------------------------------------
	// ------- sets the color values for Float textureformat -------
	// -------------------------------------------------------------

	/**
		Sets the colors as float values for the float `TextureFormat`s.
		@param x horizontal position
		@param y vertical position
		@param red value from 0.0 to 1.0 
		@param green value from 0.0 to 1.0 
		@param blue value from 0.0 to 1.0 
		@param alpha value from 0.0 (full transparent) to 1.0 (opaque) 
	**/
	public inline function setFloat(x:Int, y:Int, red:Float, green:Float, blue:Float, alpha:Float = 0.0)
	{
		if ( !format.isFloat ) throw("error, use setPixel() for INTEGER textureformats");
		
		var pos:Int = (y * width + x) * format.bytesPerPixelFloat;

		bytes.setFloat(pos, red);
		if ( format.isGreaterFloatR() ) {
			bytes.setFloat(pos+4, green);
			if ( format.isGreaterFloatRG() ) {
				bytes.setFloat(pos+8, blue);
				if ( format.isGreaterFloatRGB() ) {
					bytes.setFloat(pos+12, alpha);
				}
			}
		}
	}

	// --- optimized variants for setPixelFloat for the specific Float TextureFormat ---

	/**
		Sets the colors as float values of a pixel, optimized for the `FLOAT_RGBA` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
		@param red value from 0.0 to 1.0 
		@param green value from 0.0 to 1.0 
		@param blue value from 0.0 to 1.0 
		@param alpha value from 0.0 (full transparent) to 1.0 (opaque) 
	**/
	public inline function setFloat_RGBA(x:Int, y:Int, red:Float, green:Float, blue:Float, alpha:Float) {
		var pos:Int = (y * width + x) << 4;
		bytes.setFloat(pos     , red);
		bytes.setFloat(pos + 4 , green);
		bytes.setFloat(pos + 8 , blue);
		bytes.setFloat(pos + 12, alpha);
	}

	/**
		Sets the colors as float values of a pixel, optimized for the `FLOAT_RGB` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
		@param red value from 0.0 to 1.0 
		@param green value from 0.0 to 1.0 
		@param blue value from 0.0 to 1.0 
	**/
	public inline function setFloat_RGB(x:Int, y:Int, red:Float, green:Float, blue:Float) {
		var pos:Int = (y * width + x) * 12;
		bytes.setFloat(pos     , red);
		bytes.setFloat(pos + 4 , green);
		bytes.setFloat(pos + 8 , blue);
	}

	/**
		Sets the colors as float values of a pixel, optimized for the `FLOAT_RG` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
		@param red value from 0.0 to 1.0 
		@param green value from 0.0 to 1.0 
	**/
	public inline function setFloat_RG(x:Int, y:Int, red:Float, green:Float) {
		var pos:Int = (y * width + x) << 3;
		bytes.setFloat(pos     , red);
		bytes.setFloat(pos + 4 , green);
	}

	/**
		Sets the colors as float values of a pixel, optimized for the `FLOAT_R` `TextureFormat`.
		@param x horizontal position
		@param y vertical position
		@param red value from 0.0 to 1.0 
	**/
	inline public function setFloat_R(x:Int, y:Int, red:Float) {
		bytes.setFloat((y * width + x) << 2, red);
	}
	

	// --- set single value for one specific colorchannel in depend of Float TextureFormat ---

	/**
		Sets the red color channel of a pixel for the float `TextureFormat`s.
		@param x horizontal position
		@param y vertical position
		@param red value from 0.0 to 1.0 
	**/
	public inline function setFloatRed(x:Int, y:Int, red:Float) {
		bytes.setFloat((y * width + x) * format.bytesPerPixelFloat, red);
	}

	/**
		Sets the green color channel of a pixel for the float `TextureFormat`s.
		@param x horizontal position
		@param y vertical position
		@param green value from 0.0 to 1.0 
	**/
	public inline function setFloatGreen(x:Int, y:Int, green:Float) {
		if (format.isGreaterFloatR()) bytes.setFloat(((y * width + x) * format.bytesPerPixelFloat) + 4, green);
		else throw("Error: Textureformat have no green channel");
	}

	/**
		Sets the blue color channel of a pixel for the float `TextureFormat`s.
		@param x horizontal position
		@param y vertical position
		@param blue value from 0.0 to 1.0 
	**/
	public inline function setFloatBlue(x:Int, y:Int, blue:Float) {
		if (format.isGreaterFloatRG()) bytes.setFloat(((y * width + x) * format.bytesPerPixelFloat) + 8, blue);
		else throw("Error: Textureformat have no blue channel");
	}

	/**
		Sets the alpha channel of a pixel for the float `TextureFormat`s.
		@param x horizontal position
		@param y vertical position
		@param alpha value from 0.0 (full transparent) to 1.0 (opaque) 
	**/
	public inline function setFloatAlpha(x:Int, y:Int, alpha:Float) {
		if (format.isGreaterFloatRGB()) bytes.setFloat(((y * width + x) * format.bytesPerPixelFloat) + 12, alpha);
		else throw("Error: Textureformat have no alpha channel");
	}


	// -------------------------------------------------------------
	// ---------- gets the values for Float textureformat ----------
	// -------------------------------------------------------------

	/**
		Gets the red color channel of a pixel for the float `TextureFormat`s.
		@param x horizontal position
		@param y vertical position
	**/
	public inline function getFloatRed(x:Int, y:Int):Float {
		return bytes.getFloat((y * width + x) * format.bytesPerPixelFloat);
	}

	/**
		Gets the green color channel of a pixel for the float `TextureFormat`s.
		@param x horizontal position
		@param y vertical position
	**/
	public inline function getFloatGreen(x:Int, y:Int):Float {
		if (!format.isGreaterFloatR()) throw("Error: Textureformat have no green channel");
		return bytes.getFloat(((y * width + x) * format.bytesPerPixelFloat) + 4);
	}

	/**
		Gets the blue color channel of a pixel for the float `TextureFormat`s.
		@param x horizontal position
		@param y vertical position
	**/
	public inline function getFloatBlue(x:Int, y:Int):Float {
		if (!format.isGreaterFloatRG()) throw("Error: Textureformat have no blue channel");
		return bytes.getFloat(((y * width + x) * format.bytesPerPixelFloat) + 8);
	}

	/**
		Gets the alpha channel of a pixel for the float `TextureFormat`s.
		@param x horizontal position
		@param y vertical position
	**/
	public inline function getFloatAlpha(x:Int, y:Int):Float {
		if (!format.isGreaterFloatRGB()) throw("Error: Textureformat have no alpha channel");
		return bytes.getFloat(((y * width + x) * format.bytesPerPixelFloat) + 12);
	}

}




// ---------------------------------------------------------------------
// ------------------------- TextureData -------------------------------
// ---------------------------------------------------------------------


/**
	Stores image data into different `TextureFormat`s to use it for `Texture`s.  
	It supports basic converting functions and a low level api to edit pixels.
**/
@:forward //@:forward.new
abstract TextureData(TextureDataImpl) to TextureDataImpl
{
	/**
		Creates a new `TextureData` instance.
		@param width horizontal size
		@param height vertical size
		@param format the used `TextureFormat` (RGBA by default)
		@param color background color
		@param bytes to create from existing `Bytes` data
	**/
	public function new(width:Int, height:Int, format:TextureFormat = TextureFormat.RGBA, color:Color = 0, ?bytes:Bytes) {
		this = new TextureDataImpl(width, height, format, color, bytes);
	}

	/**
		Creates a new Texture with 1 slot what is using the texturedata.
	**/
	@:to public inline function toTexture():Texture {
		return Texture.fromData(this);
	}

	/**
		Converts the texturedata bytes into an `UInt8Array`.
	**/
	@:to public inline function toUInt8Array():UInt8Array {
		return UInt8Array.fromBytes(this.bytes);
	}
	
	/**
		Converts the texturedata bytes into a `Float32Array`.
	**/
	@:to public inline function toFloat32Array():Float32Array {
		return Float32Array.fromBytes(this.bytes);
	}

	// ------------------------------------------------------------------------------------
	// --------- static functions to create and convert from other TextureFormats ---------
	// ------------------------------------------------------------------------------------

	/**
		Creates a new texturedata by converting into `RGBA` `TextureFormat`.  
		The alpha value will be 255 (opaque) if the source texturedata have no alpha channel.
		@param textureData source data to convert from
	**/
	static public inline function RGBAfrom(textureData:TextureData):TextureData return textureData.toRGBA();

	/**
		Creates a new texturedata by converting into `RGB` `TextureFormat`.  
		If the source format is of type `ALPHA`, the alpha value will be converted into the red colorchannel.
		@param textureData source data to convert from
	**/
	static public inline function RGBfrom(textureData:TextureData):TextureData return textureData.toRGB();

	/**
		Creates a new texturedata by converting into `RG` `TextureFormat`.  
		If the source format is of type `ALPHA`, the alpha value will be converted into the red colorchannel.
		@param textureData source data to convert from
	**/
	static public inline function RGfrom(textureData:TextureData):TextureData return textureData.toRG();

	/**
		Creates a new texturedata by converting into `R` `TextureFormat`.  
		If the source format is of type `ALPHA`, the alpha value will be converted into the red colorchannel.
		@param textureData source data to convert from
	**/
	static public inline function Rfrom(textureData:TextureData):TextureData return textureData.toR();

	/**
		Creates a new texturedata by converting into `LUMINANCE_ALPHA` `TextureFormat`.  
		The alpha value will be 255 (opaque) if the source texturedata have no alpha channel.
		@param textureData source data to convert from
	**/
	static public inline function LuminanceAlphaFrom(textureData:TextureData):TextureData return textureData.toLuminanceAlpha();

	/**
		Creates a new texturedata by converting into `LUMINANCE` `TextureFormat`.  
		If the source format is of type `ALPHA`, the alpha value will be used for luminance.
		@param textureData source data to convert from
	**/
	static public inline function LuminanceFrom(textureData:TextureData):TextureData return textureData.toLuminance();

	/**
		Creates a new texturedata by converting into `ALPHA` `TextureFormat`.  
		If the source have no alpha channel it will convert the red color channel into alpha.
		@param textureData source data to convert from
	**/
	static public inline function AlphaFrom(textureData:TextureData):TextureData return textureData.toAlpha();


	// ------------------ convert into float textureformats -----------------

	/**
		Creates a new texturedata by converting into `FLOAT_RGBA` `TextureFormat`.  
		The alpha value will be 1.0 (opaque) if the source texturedata have no alpha channel.
		@param textureData source data to convert from
	**/
	static public inline function FloatRGBAfrom(textureData:TextureData):TextureData return textureData.toFloatRGBA();

	/**
		Creates a new texturedata by converting into `FLOAT_RGB` `TextureFormat`.  
		If the source format is of type `ALPHA`, the alpha value will be converted into the red colorchannel.
		@param textureData source data to convert from
	**/
	static public inline function FloatRGBfrom(textureData:TextureData):TextureData return textureData.toFloatRGB();

	/**
		Creates a new texturedata by converting into `FLOAT_RG` `TextureFormat`.  
		If the source format is of type `ALPHA`, the alpha value will be converted into the red colorchannel.
		@param textureData source data to convert from
	**/
	static public inline function FloatRGfrom(textureData:TextureData):TextureData return textureData.toFloatRG();

	/**
		Creates a new texturedata by converting into `FLOAT_R` `TextureFormat`.  
		If the source format is of type `ALPHA`, the alpha value will be converted into the red colorchannel.
		@param textureData source data to convert from
	**/
	static public inline function FloatRfrom(textureData:TextureData):TextureData return textureData.toFloatR();



	// ----------------------------------------------------------------------------
	// ----------------- static functions to decode by format lib -----------------
	// ----------------------------------------------------------------------------

	/**
		Creates new texturedata from `png` imagedata by using the `format` haxelib.
		@param bytes `Bytes` data into encoded `png` format
	**/
	static public function fromFormatPNG(bytes:Bytes):TextureData {
		#if format

		var reader = new format.png.Reader( new haxe.io.BytesInput(bytes) );
		var data = reader.read();
		var header = format.png.Tools.getHeader(data);

		trace(header);

		var imageBytes:Bytes;
		var textureFormat:TextureFormat;

		switch (header.color) {
			case ColGrey(false):
				if (header.colbits == 8) {
					imageBytes = format.png.Tools.extractGrey(data);
					textureFormat =  TextureFormat.LUMINANCE;
				}
				else {
					imageBytes = format.png.Tools.extract(data);
					textureFormat = TextureFormat.FLOAT_R;
					var size:Int = header.width*header.height;
					var imageBytesFloats = new Float32Array(size);
					for (i in 0...size) {
						imageBytesFloats.set(i, imageBytes.getUInt16(i*2) / 0xffff);
					}
					// imageBytes = imageBytesFloats.getData().bytes;
					imageBytes = imageBytesFloats.view.buffer;
				}

			case ColGrey(true):
				imageBytes = format.png.Tools.extract(data);
				if (header.colbits == 8) textureFormat =  TextureFormat.LUMINANCE_ALPHA;
				else {
					textureFormat = TextureFormat.FLOAT_RG;
					var size:Int = header.width*header.height * 2;
					var imageBytesFloats = new Float32Array(size);
					for (i in 0...size) {
						imageBytesFloats.set(i, imageBytes.getUInt16(i*2) / 0xffff);
					}
					// imageBytes = imageBytesFloats.getData().bytes;
					imageBytes = imageBytesFloats.view.buffer;
				}

			case ColTrue(false):
				imageBytes = format.png.Tools.extract(data);
				if (header.colbits == 8) textureFormat =  TextureFormat.RGB;
				else {
					textureFormat = TextureFormat.FLOAT_RGB;
					var size:Int = header.width*header.height * 3;
					var imageBytesFloats = new Float32Array(size);
					for (i in 0...size) {
						imageBytesFloats.set(i, imageBytes.getUInt16(i*2) / 0xffff);
					}
					// imageBytes = imageBytesFloats.getData().bytes;
					imageBytes = imageBytesFloats.view.buffer;
				}

			case ColTrue(true):
				imageBytes = format.png.Tools.extract(data);
				if (header.colbits == 8) textureFormat =  TextureFormat.RGBA;
				else {
					textureFormat = TextureFormat.FLOAT_RGBA;
					var size:Int = header.width*header.height * 4;
					var imageBytesFloats = new Float32Array(size);
					for (i in 0...size) {
						imageBytesFloats.set(i, imageBytes.getUInt16(i*2) / 0xffff);
					}
					// imageBytes = imageBytesFloats.getData().bytes;
					imageBytes = imageBytesFloats.view.buffer;
				}

			case ColIndexed: throw("Error by decoding PNG for TextureData: indexed colors not supperted");
		}

		// TODO: for colbits => 16
		// var imageBytes = format.png.Tools.extract32(data);
		// format.png.Tools.reverseBytes(imageBytes);

		return new TextureData(header.width, header.height, textureFormat, imageBytes);

		#else
		throw('Error, pls install the "format" library to use "fromFormatPNG(bytes)".');
		return null;
		#end
	}

	
	// ----------- Read Image-Data from Lime -------------

	/**
		Creates new texturedata from a [Lime](https://www.openfl.org/learn/npm/api/pages/lime/graphics/Image.html) `Image`.
		@param image `Image` instance
	**/
	@:from static public inline function fromLimeImage(image:lime.graphics.Image) {
		return new TextureData(image.width, image.height, TextureFormat.RGBA, image.data.toBytes() );
	}

	//@:to
	//public function toLimeImage() {
		//return ;
	//}

	
	// ----------- Read Image-Data from other haxelibs -------------

	/**
		Creates new texturedata from a `Image` of the [Vision](https://lib.haxe.org/p/vision) library.
		@param image `Image` instance
	**/
	@:from static public inline function fromVisionImage(image #if vision :vision.ds.Image #end):TextureData {
		#if vision
		return new TextureData( image.width, image.height, TextureFormat.RGBA, image.toBytes(vision.ds.PixelFormat.RGBA) );
		#else
		throw('Error, pls install the "Vision" library to use "fromVisionImage(image)".');
		return null;
		#end
	}

	/**
		Creates new texturedata from a `Pixelimage` of the [pi_xy](https://github.com/nanjizal/pi_xy) library.
		@param pixelImage `Pixelimage` instance
	**/
	@:from static public inline function fromPixelImage(pixelImage #if pi_xy :pi_xy.Pixelimage #end):TextureData {
		#if pi_xy
		// return pixelImage.peoteTexture.toTextureData();
		// return new TextureData( pixelImage.width, pixelImage.height, TextureFormat.RGBA, pixelImage.peoteTexture.toPeotePixels(pixelImage) );
		return new TextureData( pixelImage.width, pixelImage.height, TextureFormat.RGBA, pixelImage.getBytes() );
		#else
		throw('Error, pls install the "pi_xy" library to use "fromPixelImage(image)".');
		return null;
		#end
	}
	

}