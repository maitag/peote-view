package peote.view;

import haxe.io.Bytes;
import haxe.io.UInt8Array;
import haxe.io.Float32Array;

@:enum
abstract ImageType(Int) {
  var UINT = 0;   //for gl.UNSIGNED_BYTE
  var FLOAT = 1; //for gl.FLOAT
}

// TODO:
/*                 bytes per pixel
                 FLOAT   UNSIGNED_BYTE
RGBA              16         4
RGB               12         3
LUMINANCE_ALPHA   8          2
LUMINANCE         4          1
ALPHA             4          1
*/	
private class ImageImpl
{
	
	public var width:Int = 0;
	public var height:Int = 0;
	
	public var slot(default, null):Int = 0;
	
	//public var data:Bytes = null;
	public var dataUInt8:UInt8Array = null;
	public var dataFloat:Float32Array = null;
	
	public function new(width:Int, height:Int, type:ImageType = ImageType.UINT, data:UInt8Array = null)
	{
		this.width = width;
		this.height = height;
		
		if (data == null)
			dataUInt8 = new UInt8Array(width * height);
		else dataUInt8 = data;
	}
	
}

@:forward
abstract Image(ImageImpl) to ImageImpl 
{
	inline public function new(width:Int, height:Int, type:ImageType = ImageType.UINT, data:UInt8Array = null) {
		this = new ImageImpl(width, height, type, data);
	}
	
	
	@:from
	static public function fromLimeImage(image:lime.graphics.Image) {
		return new Image(image.width, image.height, ImageType.UINT,
			UInt8Array.fromBytes( image.data.toBytes() )
		);
	}

	//@:to
	//public function toLimeImage() {
		//return ;
	//}
	
}