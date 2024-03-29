package peote.view;

import haxe.ds.ArraySort;

import peote.view.TextureData;
import peote.view.Program;
import peote.view.Texture;
import peote.view.intern.TexUtils;

class TextureCache 
{
	var imageMap = new Map<TextureData, {texSize:Int, unit:Int, slot:Int}>();
	var texSizes = new Array <{
			width:Int, height:Int, slots:Int, freeSlots:Int,
			textures:Array<{unit:Int, freeSlots:Array<Int>}>
		}> ();
		
	public var textures = new Array<Texture>();
	
	public function new(imageSizes:Array<{width:Int, height:Int, slots:Int, config:TextureConfig}>) 
	{
		// sort sizes
		ArraySort.sort(imageSizes, function(x, y) {
			if (x.width * x.height > y.width * y.height) return 1;
			else if (x.width * x.height < y.width * y.height) return -1;
			else return 0;
		});
		
		for (size in imageSizes) {
			var t = new Array<{unit:Int, freeSlots:Array<Int>}>();
			// create empty textures
			var slots = size.slots;
			while (slots > 0) {
				// how many fit into one texture
				var p = TexUtils.optimalTextureSize(slots, size.width, size.height, size.config.maxTextureSize, size.config.powerOfTwo, false, false);
				var s:Int = p.slotsX * p.slotsY;
				t.push( {unit:textures.length, freeSlots:[for (i in 0...s) s-1-i]} );
				textures.push( new Texture(size.width, size.height, s, size.config) );
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
		//trace("textureSizes:", texSizes);
	}
	
	// if there is not already a textureslot with that image
	// it puts the image into next free texture and slot where it best fits
	// returns the texture-unit (index of textures-array) and slot
	public function addImage(image:TextureData):{unit:Int, slot:Int}
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
							textures[p.unit].setData(image, p.slot);
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

	public function addImages(images:Array<TextureData>):Void
	{
		for (image in images) addImage(image);
	}

	// removes image from cache
	public function removeImage(image:TextureData)
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
