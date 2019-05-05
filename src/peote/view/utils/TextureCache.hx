package peote.view.utils;

import peote.view.PeoteGL.Image;
import peote.view.Program;
import peote.view.Texture;

class TextureCache 
{

	static var textureMap:Map<Image,TextureImageProp>; // image filenames to textures
	static var imageSizes:Array <{imageWidth:Int, imageHeight:Int}>;
	
	public function new(imageSizes:Array<{imageWidth:Int, imageHeight:Int, maxSlots:Int}>, maxTextureSize:Int = 4096) 
	{
		// TODO
	}
	
	// looks if there is already a texture with that image
	// creates a new texture on demand and returns it
	// returns the texture and slot
	public function addImage(image:Image):TextureImageProp
	{
		var prop = textureMap.get(image);
		if (prop == null) {
			// look for free texture + slot
			
			// immer die texture auswaehlen die am besten passt von der slot-size
			
			// create texture - falls es nirgendwo passt dann neue texture erzeugen
			trace("TODO:", peote.view.utils.TexUtils.optimalTextureSize(40, 250, 256, 512, false));
			
			prop = {texture:null, slot:23, users:0};
		}
		return prop;
	}
	
	// removes image from cache
	// if there are not more users there will be a new free place into TextureCache to use
	public function removeImage(image:Image)
	{
		// TODO
	}
	
	// sets all textures from cache to textures of a Program
	// will need a Element that can select texture-units
	public function setMultiTextures(program:Program)
	{
		// TODO
	}
	
}

typedef TextureImageProp = {
	texture:Texture,
	slot:Int,
	users:Int // how much is using this texture
}