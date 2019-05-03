package peote.view.utils;

import peote.view.PeoteGL.Image;
import peote.view.Texture;

class TextureCache 
{

	static var textureMap:Map<String,TextureSlot>; // image filenames to textures
	static var imageSizes:Array <{imageWidth:Int, imageHeight:Int}>;
	
	public function new(imageSizes:Array<{imageWidth:Int, imageHeight:Int}>, maxTextureSize:Int = 4096) 
	{
		
	}
	
	// looks if there is already a texture with that image
	// returns the texture and slot
	public function addImage(filename:String, image:Image):TextureSlot 
	{
		var texSlot = textureMap.get(filename);
		if (texSlot == null) {
			// look for free texture + slot
			
			// immer die texture auswaehlen die am besten passt von der slot-size
			
			// create texture - falls es nirgendwo passt dann neue texture erzeugen
			
			
			textSlot = {texture:null, slot:23};
		}
		return texSlot;
	}
	
}

typedef TextureSlot = {
	texture:Texture,
	slot:Int,
	users:Int // how much is using this texture
}