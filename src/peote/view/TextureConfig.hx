package peote.view;


@:structInit
class TextureConfig
{
	public var format:TextureFormat = TextureFormat.RGBA;

	// maximum available Texture-Size (is need for maxSlots-calculation)
	public var maxTextureSize:Int=16384;


	// Tile-Resolution for all slots (if the Element have @tile):
	public var tileX:Int = 1;
	public var tileY:Int = 1;


	// ---- Texture-Filtering -----

	// smooth Interpolation between Pixels
	public var smoothExpand:Bool = false; // while pixels are expanding (zoom in)
	public var smoothShrink:Bool = false; // while pixels are shrinking (zoom out)

	public var mipmap:Bool = false; // enable to generate mipmap levels

	// smooth Interpolation between mipmap levels (if mipmapping is enabled)
	public var smoothMipmap:Bool = false;

	public function new() {

	}
}
