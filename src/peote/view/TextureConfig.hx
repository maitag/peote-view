package peote.view;


@:structInit
class TextureConfig
{
	// Tile-Resolution for all slots (if the Element have @tile):
	public var tilesX:Int = 1;
	public var tilesY:Int = 1;

	// maximum available Texture-Size (for optimal texturesize-calculation for slotsX/Y tiling )
	public var maxTextureSize:Int = 16384;

	// Textureformat (int/float and what colorchannels)
	public var format:TextureFormat = TextureFormat.RGBA;


	// ---- Texture-Filtering -----

	// smooth Interpolation between Pixels
	public var smoothExpand:Bool = false; // while pixels are expanding (zoom in)
	public var smoothShrink:Bool = false; // while pixels are shrinking (zoom out)

	public var mipmap:Bool = false; // enable to generate mipmap levels

	// smooth Interpolation between mipmap levels (if mipmapping is enabled)
	public var smoothMipmap:Bool = false;
}
