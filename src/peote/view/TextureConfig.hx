package peote.view;


@:structInit
class TextureConfig
{
	// if you set a number of "slots" while creating a new Texture, e.g. "new Texture(slotWidth, slotHeight, slots, textureConfig)"
	// it will automatic calculate the texturesize and how to tile it into multiple slots (the Element can chose it by @slot)

	// to finetune this you can set a maximum size for width or height (should be set lesser or equal to the maximum available OpenGL texturesize)
	// (if you are use greater values, take also care that your device is have enough floatprecision for "glsl-modulo"!)
	public var maxTextureSize:Int = 16384;

	// manual Slot-Tiling for texturesize-calculation
	// is only used if the optional "slots"-parameter is "null" while creating a new Texture
	public var slotsX:Int = 1; // how much slots horizontaly
	public var slotsY:Int = 1; // how much slots verticaly


	// allways keep this "true" for mipmapping or to be opengl-backwardcompatible
	// it will use the nearest upper "power of two" number for the whole texturesize
	public var powerOfTwo:Bool = true;



	// Tile-Resolution for all slots (if the Element have @tile):
	public var tilesX:Int = 1;
	public var tilesY:Int = 1;
	


	// ----- Textureformat (int/float and what colorchannels) -----

	public var format:TextureFormat = TextureFormat.RGBA;



	// ---- Texture-Filtering -----

	// smooth Interpolation between Pixels
	public var smoothExpand:Bool = false; // while pixels are expanding (zoom in)
	public var smoothShrink:Bool = false; // while pixels are shrinking (zoom out)

	public var mipmap:Bool = false; // enable to generate mipmap levels

	// smooth Interpolation between mipmap levels (if mipmapping is enabled)
	public var smoothMipmap:Bool = false;
}
