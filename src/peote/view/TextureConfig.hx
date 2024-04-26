package peote.view;

/**
	This struct is to configure the properties of a new `Texture`.
**/
@:structInit
class TextureConfig
{	
	/**
		Maximum width or height for the texture if its size is automatic calculated for multiple slots.  
		Should be set lesser or equal to the maximum available OpenGL texturesize.  
		(Avoid large values if your device have limited floatpoint precision for glsl "modulo")
	**/
	public var maxTextureSize:Int = 16384;

	/**
		How many slots the texture is horizontally divided into. Only applies when the `slots` parameter into `Texture` constructor is `null`.
	**/
	public var slotsX:Int = 1; // how much slots horizontaly

	/**
		How many slots the texture is vertically divided into. Only applies when the `slots` parameter into `Texture` constructor is `null`.
	**/
	public var slotsY:Int = 1; // how much slots verticaly

	/**
		Round the texture width or height up to the next "power of two" number.  
		This should be "true" for mipmapping or older OpenGl devices.
	**/
	public var powerOfTwo:Bool = true;

	/**
		How many tiles each slot is horizontally divided into for tilemapping (if the Element use @tile).
	**/
	public var tilesX:Int = 1;

	/**
		How many tiles each slot is vertically divided into for tilemapping (if the Element use @tile).
	**/
	public var tilesY:Int = 1;
	
	/**
		Specifies the used `TextureFormat`.
	**/
	public var format:TextureFormat = TextureFormat.RGBA;

	/**
		Use smooth filtering if the texture is displayed at a enlarged size.
	**/
	public var smoothExpand:Bool = false;

	/**
		Use smooth filtering if the texture is displayed at a reduced size.
	**/
	public var smoothShrink:Bool = false;

	/**
		If the texture have to generate mipmaps for filtering.
	**/
	public var mipmap:Bool = false; // enable to generate mipmap levels

	/**
		Use smooth interpolation between the mipmap-levels for texture filtering.
	**/
	public var smoothMipmap:Bool = false;
}
