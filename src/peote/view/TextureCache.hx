package peote.view;

import haxe.ds.ArraySort;

import peote.view.TextureData;
import peote.view.Program;
import peote.view.Texture;
import peote.view.intern.TexUtils;

/**
	Provides a set of `Texture`s and slots to automatically store multiple `TextureData` where it fits best.
**/
class TextureCache 
{
	var textureDataMap = new Map<TextureData, {texSize:Int, unit:Int, slot:Int}>();
	var texSizes = new Array <{
			width:Int, height:Int, slots:Int, freeSlots:Int,
			textures:Array<{unit:Int, freeSlots:Array<Int>}>
		}> ();
	
	/**
		Array what contains all created textures.
	**/
	public var textures = new Array<Texture>();
	
	/**
		Creates a new `TextureCache` instance.
		@param textureTypes defines the width, height, slots amount and texture-type of what have to be available
	**/
	public function new(textureTypes:Array<{width:Int, height:Int, slots:Int, config:TextureConfig}>) 
	{
		// sort sizes
		ArraySort.sort(textureTypes, function(x, y) {
			if (x.width * x.height > y.width * y.height) return 1;
			else if (x.width * x.height < y.width * y.height) return -1;
			else return 0;
		});
		
		for (type in textureTypes) {
			var t = new Array<{unit:Int, freeSlots:Array<Int>}>();
			// create empty textures
			var slots = type.slots;
			while (slots > 0) {
				// how many fit into one texture
				var p = TexUtils.optimalTextureSize(slots, type.width, type.height, type.config.maxTextureSize, type.config.powerOfTwo, false, false);
				var s:Int = p.slotsX * p.slotsY;
				t.push( {unit:textures.length, freeSlots:[for (i in 0...s) s-1-i]} );
				textures.push( new Texture(type.width, type.height, s, type.config) );
				slots -= s;
					
			}
			texSizes.push({
				width: type.width,
				height: type.height,
				freeSlots: type.slots,
				slots: type.slots,
				textures: t
			});
		}
		//trace("textureSizes:", texSizes);
	}

	/**
		Adds a `TextureData` instance into the next free texture/slot where it best fits and does not already exist.  
		Returns the texture `unit` and `slot` number or `null` if it not fits.
	**/
	public function addData(textureData:TextureData):{unit:Int, slot:Int}
	{
		var prop = textureDataMap.get(textureData);
		if (prop == null) {
			// look for free texture + slot
			for (s in texSizes) {
				if (s.width >= textureData.width && s.height >= textureData.height && s.freeSlots>0) { // textureData fits
					for (i in 0...s.textures.length) {
						var t = s.textures[i];
						if (t.freeSlots.length > 0 && textures[t.unit].format == textureData.format) { // texture has free slot and is of same format
							s.freeSlots--;
							var p = {texSize:i, unit:t.unit, slot:t.freeSlots.pop()};
							textureDataMap.set(textureData, p);
							textures[p.unit].setData(textureData, p.slot);
							return {unit:p.unit, slot:p.slot};
						}
					}
				}
			}
			// TODO: Error if no more free texture/slot
			return null;
		} 
		else {
			// textureDataMap.set(textureData, prop);
			// already exists
			return {unit:prop.unit, slot:prop.slot};
		}
	}

	/**
		Removes a `TextureData` instance from the texture cache.  
	**/
	public function removeData(textureData:TextureData)
	{
		var prop = textureDataMap.get(textureData);
		var s = texSizes[prop.texSize];
		s.freeSlots++;
		for (t in s.textures) {
			if (prop.unit == t.unit) {
				t.freeSlots.push(prop.slot);
			}
		}
		textureDataMap.remove(textureData);
	}

	// sets all textures from cache to textures of a Program
	// will need a Element that can select texture-units
	/*
	public function setMultiTextures(program:Program)
	{
		// TODO
	}
	*/
}
