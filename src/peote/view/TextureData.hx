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
	
	public function clear(color:Color = 0)
	{
		if ( format.isFloat() ) throw("error, use clearFloat() for FLOAT textureformats");
		var pos:Int = 0;
		switch (format) {
			case FLOAT_RGBA:
				for (i in 0...width * height) bytes.setInt32(pos, color); pos += 4;
			case FLOAT_RGB:
				for (i in 0...width * height) {
					bytes.set(pos++, color.red);
					bytes.set(pos++, color.green);
					bytes.set(pos++, color.blue);
				}
			case FLOAT_RG:
				for (i in 0...width * height) {
					bytes.set(pos++, color.red);
					bytes.set(pos++, color.green);
				}
			default:
				for (i in 0...width * height) bytes.set(pos++, color.red);
		}
	}

	public function clearFloat(red:Float=0.0, green:Float=0.0, blue:Float=0.0, alpha:Float=0.0)
	{
		if ( !format.isFloat() ) throw("error, use clear() for INTEGER textureformats");
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

	public function setPixel(x:Int, y:Int, color:Color)
	{
		if ( format.isFloat() ) throw("error, use setPixelFloat() for FLOAT textureformats");		
		var pos = (y * width + x) * format._bytesPerPixelInt();
		switch (format) {
			case RGBA: bytes.setInt32(pos, color);
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
	
	// optimized variants
	inline public function setPixelRGBA(x:Int, y:Int, color:Color) {
		bytes.setInt32((y * width + x) << 2, color);
	}

	inline public function setPixelRGB(x:Int, y:Int, red:Int, green:Int, blue:Int) {
		var pos = (y * width + x) * 3;
		bytes.set(pos, red); bytes.set(pos+1, green); bytes.set(pos+2, blue);
	}

	inline public function setPixelRG(x:Int, y:Int, red:Int, green:Int) {
		var pos = (y * width + x) << 1;
		bytes.set(pos, red); bytes.set(pos+1, green);
	}

	inline public function setPixelR(x:Int, y:Int, red:Int) {
		bytes.set(y * width + x, red);
	}

	inline public function setPixelFloat(x:Int, y:Int, red:Float, green:Float = 0.0, blue:Float = 0.0, alpha:Float = 0.0)
	{
		if ( !format.isFloat() ) throw("error, use setPixel() for INTEGER textureformats");
		
		var pos:Int = (y * width + x) * format._bytesPerPixelFloat();

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

	// optimized variants
	inline public function setPixelFloatRGBA(x:Int, y:Int, red:Float, green:Float, blue:Float, alpha:Float) {
		var pos:Int = (y * width + x) << 4;
		bytes.setFloat(pos     , red);
		bytes.setFloat(pos + 4 , green);
		bytes.setFloat(pos + 8 , blue);
		bytes.setFloat(pos + 12, alpha);
	}

	inline public function setPixelFloatRGB(x:Int, y:Int, red:Float, green:Float, blue:Float) {
		var pos:Int = (y * width + x) * 12;
		bytes.setFloat(pos     , red);
		bytes.setFloat(pos + 4 , green);
		bytes.setFloat(pos + 8 , blue);
	}

	inline public function setPixelFloatRG(x:Int, y:Int, red:Float, green:Float) {
		var pos:Int = (y * width + x) << 3;
		bytes.setFloat(pos     , red);
		bytes.setFloat(pos + 4 , green);
	}

	inline public function setPixelFloatR(x:Int, y:Int, red:Float) {
		bytes.setFloat((y * width + x) << 2, red);
	}



	// -------------------- constructor -------------------

	public function new(width:Int, height:Int, format:TextureFormat, bytes:Bytes = null)
	{
		this.width = width;
		this.height = height;
		this.format = format;
		
		if (bytes == null) this.bytes = Bytes.alloc(width * height * format.bytesPerPixel() );
		else this.bytes = bytes;
	}
	
}

@:forward
abstract TextureData(TextureDataImpl) to TextureDataImpl 
{
	inline public function new(width:Int, height:Int, format:TextureFormat = TextureFormat.RGBA, bytes:Bytes = null) {
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
	
	@:from
	static public inline function fromLimeImage(image:lime.graphics.Image) {
		return new TextureData(image.width, image.height, TextureFormat.RGBA, image.data.toBytes() );
	}

	//@:to
	//public function toLimeImage() {
		//return ;
	//}
	
}