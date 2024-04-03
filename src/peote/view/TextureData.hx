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

private class TextureDataImpl
{
	public var width:Int = 0;
	public var height:Int = 0;
	public var format:TextureFormat = TextureFormat.RGBA;
	
	public var slot(default, null):Int = 0;
	
	public var bytes:Bytes = null;
	
	public function new(width:Int, height:Int, format:TextureFormat, color:Color = 0, bytes:Bytes = null)
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


	// ---------------------------------------------------------------
	// ------- getPixel and setPixel for Integer textureformat -------
	// ---------------------------------------------------------------

	public function setColor(x:Int, y:Int, color:Color)
	{
		if ( format.isFloat ) throw("error, use setPixelFloat() for FLOAT textureformats");		
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
	
	// optimized variants for setPixel in specific textureFormat
	public inline function setColor_RGBA(x:Int, y:Int, color:Color) _setRGBABytes((y * width + x) << 2, color);

	inline function _setRGBABytes(pos:Int, color:Color) {
		bytes.set(pos, color.red);
		bytes.set(pos + 1, color.green);
		bytes.set(pos + 2, color.blue);
		bytes.set(pos + 3, color.alpha);
	}

	public inline function set_RGBA(x:Int, y:Int, red:Int, green:Int, blue:Int, alpha:Int) {
		var pos = (y * width + x) * 3;
		bytes.set(pos, red); bytes.set(pos+1, green); bytes.set(pos+2, blue); bytes.set(pos+3, alpha);
	}

	public inline function set_RGB(x:Int, y:Int, red:Int, green:Int, blue:Int) {
		var pos = (y * width + x) * 3;
		bytes.set(pos, red); bytes.set(pos+1, green); bytes.set(pos+2, blue);
	}

	public inline function set_RG(x:Int, y:Int, red:Int, green:Int) {
		var pos = (y * width + x) << 1;
		bytes.set(pos, red); bytes.set(pos+1, green);
	}

	public inline function set_R(x:Int, y:Int, red:Int) bytes.set(y * width + x, red);

	public inline function set_LUMINANCE_ALPHA(x:Int, y:Int, luminance:Int, alpha:Int) set_RG(x, y, luminance, alpha);
	public inline function set_LUMINANCE(x:Int, y:Int, luminance:Int) set_R(x, y, luminance);
	public inline function set_ALPHA(x:Int, y:Int, alpha:Int) set_R(x, y, alpha);

	// set single value for one specific colorchannel in depend of Integer TextureFormat

	public inline function setRed(x:Int, y:Int, red:Int) {
		bytes.set((y * width + x) * format.bytesPerPixelInt, red);
	}

	public inline function setGreen(x:Int, y:Int, green:Int) {
		if (format.isGreaterR()) bytes.set( (y * width + x) * format.bytesPerPixelInt + 1, green );
		else throw("Error: Textureformat have no green channel");
	}
	
	public inline function setBlue(x:Int, y:Int, blue:Int) {
		if (format.isGreaterRG()) bytes.set( (y * width + x) * format.bytesPerPixelInt + 2, blue );
		else throw("Error: Textureformat have no green channel");
	}
	
	public inline function setAlpha(x:Int, y:Int, alpha:Int) {
		switch (format) {
			case RGBA:            bytes.set( (y * width + x) * 4 + 3, alpha );
			case LUMINANCE_ALPHA: bytes.set( (y * width + x) * 2 + 1, alpha );
			case ALPHA:           bytes.set( (y * width + x), alpha);
			default: throw("Error: Textureformat have no green channel");
		}
	}
	
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

	// get Pixels for integer textureformat

	public function getColor(x:Int, y:Int):Color
	{
		if ( format.isFloat ) throw("error, use getPixelFloat() for FLOAT textureformats");		
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

	// optimized variants of getPixel for the specific Integer TextureFormat

	public inline function getColor_RGBA(x:Int, y:Int):Color return _getRGBABytes((y * width + x) << 2);

	inline function _getRGBABytes(pos:Int):Color {
		return Color.RGBA( bytes.get(pos), bytes.get(pos + 1), bytes.get(pos + 2), bytes.get(pos + 3) );
	}

	public inline function getColor_RGB(x:Int, y:Int):Color {
		var pos = (y * width + x) * 3;
		return Color.RGB( bytes.get(pos), bytes.get(pos + 1), bytes.get(pos + 2) );
	}

	@:access(peote.view.Color) // Color.RG is not public!
	public inline function getColor_RG(x:Int, y:Int):Color {
		var pos = (y * width + x) << 1;
		return Color.RG( bytes.get(pos), bytes.get(pos + 1) );
	}

	public inline function getColor_LUMINANCE_ALPHA(x:Int, y:Int):Color {
		var pos = (y * width + x) << 1;
		return Color.LuminanceAlpha( bytes.get(pos), bytes.get(pos + 1) );
	}

	public inline function getColor_R(x:Int, y:Int):Color         return Color.Red      ( get_R(x, y) );
	public inline function getColor_LUMINANCE(x:Int, y:Int):Color return Color.Luminance( get_R(x, y) );
	public inline function getColor_ALPHA(x:Int, y:Int):Color     return Color.Alpha    ( get_R(x, y) );
	
	public inline function get_R(x:Int, y:Int):Int         return bytes.get(y * width + x);
	public inline function get_LUMINANCE(x:Int, y:Int):Int return get_R(x, y);
	public inline function get_ALPHA(x:Int, y:Int):Int     return get_R(x, y);
	
	
	// get single value for one specific colorchannel in depend of Integer TextureFormat

	public inline function getRed(x:Int, y:Int):Int {
		return bytes.get((y * width + x) * format.bytesPerPixel);
	}

	public inline function getGreen(x:Int, y:Int):Int {
		if (!format.isGreaterR()) throw("Error: Textureformat have no green channel");
		return bytes.get(((y * width + x) * format.bytesPerPixel) + 1);
	}

	public inline function getBlue(x:Int, y:Int):Int {
		if (!format.isGreaterRG()) throw("Error: Textureformat have no blue channel");
		return bytes.get(((y * width + x) * format.bytesPerPixel) + 2);
	}

	public inline function getAlpha(x:Int, y:Int):Int {
		return switch (format) {
			case ALPHA:           bytes.get( (y * width + x) );
			case LUMINANCE_ALPHA: bytes.get( (y * width + x) * 2 + 1 );
			case RGBA:            bytes.get( (y * width + x) * 4 + 3 );
			default: throw("Error: Textureformat have no alpha channel");
		}
	}

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
	// ------- getPixel and setPixel for Float textureformat -------
	// -------------------------------------------------------------

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

	// optimized variants for setPixelFloat for the specific Float TextureFormat

	public inline function setFloat_RGBA(x:Int, y:Int, red:Float, green:Float, blue:Float, alpha:Float) {
		var pos:Int = (y * width + x) << 4;
		bytes.setFloat(pos     , red);
		bytes.setFloat(pos + 4 , green);
		bytes.setFloat(pos + 8 , blue);
		bytes.setFloat(pos + 12, alpha);
	}

	public inline function setFloat_RGB(x:Int, y:Int, red:Float, green:Float, blue:Float) {
		var pos:Int = (y * width + x) * 12;
		bytes.setFloat(pos     , red);
		bytes.setFloat(pos + 4 , green);
		bytes.setFloat(pos + 8 , blue);
	}

	public inline function setFloat_RG(x:Int, y:Int, red:Float, green:Float) {
		var pos:Int = (y * width + x) << 3;
		bytes.setFloat(pos     , red);
		bytes.setFloat(pos + 4 , green);
	}

	inline public function setFloat_R(x:Int, y:Int, red:Float) {
		bytes.setFloat((y * width + x) << 2, red);
	}
	

	// set single value for one specific colorchannel in depend of Float TextureFormat

	public inline function setFloatRed(x:Int, y:Int, red:Float) {
		bytes.setFloat((y * width + x) * format.bytesPerPixelFloat, red);
	}
	
	public inline function setFloatGreen(x:Int, y:Int, green:Float) {
		if (format.isGreaterFloatR()) bytes.setFloat(((y * width + x) * format.bytesPerPixelFloat) + 4, green);
		else throw("Error: Textureformat have no green channel");
	}
	
	public inline function setFloatBlue(x:Int, y:Int, blue:Float) {
		if (format.isGreaterFloatRG()) bytes.setFloat(((y * width + x) * format.bytesPerPixelFloat) + 8, blue);
		else throw("Error: Textureformat have no blue channel");
	}
	
	public inline function setFloatAlpha(x:Int, y:Int, alpha:Float) {
		if (format.isGreaterFloatRGB()) bytes.setFloat(((y * width + x) * format.bytesPerPixelFloat) + 12, alpha);
		else throw("Error: Textureformat have no alpha channel");
	}
	

	// get single float for one specific colorchannel in depend of Float TextureFormat

	public inline function getFloatRed(x:Int, y:Int):Float {
		return bytes.getFloat((y * width + x) * format.bytesPerPixelFloat);
	}
	
	public inline function getFloatGreen(x:Int, y:Int):Float {
		if (!format.isGreaterFloatR()) throw("Error: Textureformat have no green channel");
		return bytes.getFloat(((y * width + x) * format.bytesPerPixelFloat) + 4);
	}
	
	public inline function getFloatBlue(x:Int, y:Int):Float {
		if (!format.isGreaterFloatRG()) throw("Error: Textureformat have no blue channel");
		return bytes.getFloat(((y * width + x) * format.bytesPerPixelFloat) + 8);
	}
	
	public inline function getFloatAlpha(x:Int, y:Int):Float {
		if (!format.isGreaterFloatRGB()) throw("Error: Textureformat have no alpha channel");
		return bytes.getFloat(((y * width + x) * format.bytesPerPixelFloat) + 12);
	}
	
}

// -------------------- TextureData -------------------

@:forward
abstract TextureData(TextureDataImpl) to TextureDataImpl 
{
	public inline function new(width:Int, height:Int, format:TextureFormat = TextureFormat.RGBA, bytes:Bytes = null) {
		this = new TextureDataImpl(width, height, format, bytes);
	}

	@:to
	public inline function toUInt8Array():UInt8Array {
		return UInt8Array.fromBytes(this.bytes);
	}
	
	@:to
	public inline function toFloat32Array():Float32Array {
		return Float32Array.fromBytes(this.bytes);
	}


	// ----------- decode by format lib ---------
	#if format
	static public function fromFormatPNG(bytes:Bytes):TextureData {
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
	}

	#end
	
	// ----------- Read Image-Data from Lime -------------
	@:from
	static public inline function fromLimeImage(image:lime.graphics.Image) {
		return new TextureData(image.width, image.height, TextureFormat.RGBA, image.data.toBytes() );
	}

	//@:to
	//public function toLimeImage() {
		//return ;
	//}

	
	// ----------- Read Image-Data from other haxelibs -------------

	#if vision
	// Vision: https://lib.haxe.org/p/vision/, https://github.com/ShaharMS/Vision
	@:from
	static public inline function fromVisionImage(image:vision.ds.Image):TextureData {
		return new TextureData( image.width, image.height, TextureFormat.RGBA, image.toBytes(vision.ds.PixelFormat.RGBA) );
	}
	#end

	#if pi_xy
	// pi_xy: https://github.com/nanjizal/pi_xy
	@:from
	static public inline function fromPixelImage(pixelImage:pi_xy.Pixelimage):TextureData {
		// return pixelImage.peoteTexture.toTextureData();
		// return new TextureData( pixelImage.width, pixelImage.height, TextureFormat.RGBA, pixelImage.peoteTexture.toPeotePixels(pixelImage) );
		return new TextureData( pixelImage.width, pixelImage.height, TextureFormat.RGBA, pixelImage.getBytes() );
	}
	#end
	

}