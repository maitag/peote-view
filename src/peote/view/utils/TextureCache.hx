package peote.view.utils;

import peote.view.PeoteGL.Image;
import peote.view.Program;
import peote.view.Texture;

class TextureCache 
{
	// TODO: alle Texturen erzeugen um es direkt fuer multitextures zu benutzen (units bestimmen)
	var imageMap = new Map<Image, {texSize:Int, unit:Int, slot:Int}>();
	var texSizes = new Array <{
			width:Int, height:Int, slots:Int, freeSlots:Int,
			textures:Array<{unit:Int, freeSlots:Array<Int>}>
		}> ();
		
	var textures = new Array<Texture>();
	
	public function new(imageSizes:Array<{width:Int, height:Int, slots:Int}>, maxTextureSize:Int = 4096) 
	{
		for (size in imageSizes) { // TODO: sort sizes
			var t = new Array<{unit:Int, freeSlots:Array<Int>}>();
			// create empty textures
			var slots = size.slots;
			while (slots > 0) {
				// how many fit into one texture
				var s = peote.view.utils.TexUtils.optimalTextureSize(slots, size.width, size.height, maxTextureSize, false).imageSlots;
				t.push( {unit:textures.length, freeSlots:[for (i in 0...s) i]} );
				textures.push( new Texture(size.width, size.height, s) ); // TODO: mipmaps ...
				slots -= s;
			}
			texSizes.push({
				width: size.width,
				height: size.height,
				freeSlots: size.slots,
				slots: size.slots,
				textures: t
			});
		}
		trace("textureSizes:", texSizes);
	}
	
	// looks if there is already a texture with that image
	// creates a new texture on demand
	// returns the texture and slot
	public function addImage(image:Image):{unit:Int, slot:Int}
	{
		var prop = imageMap.get(image);
		if (prop == null) {
			// look for free texture + slot
			for (s in texSizes) {
				if (s.width >= image.width && s.height >= image.height && s.freeSlots>0) { // image fits
					for (i in 0...s.textures.length) {
						var t = s.textures[i];
						if (t.freeSlots.length > 0) { // texture has free slot
							s.freeSlots--;
							var p = {texSize:i, unit:t.unit, slot:t.freeSlots.pop()};
							imageMap.set(image, p);
							return {unit:p.unit, slot:p.slot};
						}
					}
				}
			}
			// TODO: Error if no more free texture/slot
			return {unit:-1, slot:-1};
		} 
		else {
			imageMap.set(image, prop);
			return {unit:prop.unit, slot:prop.slot};
		}
	}
	
	// removes image from cache
	public function removeImage(image:Image)
	{
		var prop = imageMap.get(image);
		var s = texSizes[prop.texSize];
		s.freeSlots++;
		for (t in s.textures) {
			if (prop.unit == t.unit) {
				t.freeSlots.push(prop.slot);
			}
		}
		imageMap.remove(image);
	}
	
	// sets all textures from cache to textures of a Program
	// will need a Element that can select texture-units
	public function setMultiTextures(program:Program)
	{
		// TODO
	}
	
}
