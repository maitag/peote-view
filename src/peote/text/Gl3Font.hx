package peote.text;

import haxe.ds.Vector;
import peote.view.PeoteGL.Image;
import haxe.io.Bytes;
import peote.view.utils.TextureCache;
import utils.Loader;
import haxe.Json;

class Gl3Font 
{
	var path:String;

	var rangeMapping = new Vector<{unit:Int, slot:Int, fontData:Gl3FontData}>(16*20); // TODO: is (16 * 0x100 * 20) the greatest charcode for unicode ?
	
	var ranges = new Array<{min:Int, max:Int}>();
	var imageNames = new Array<String>();
	
	var textureCache:TextureCache;
	
	var rParseFolder = new EReg("/*$", "gm");
	
	public function new(fontFolder:String, isKerning:Bool=true) 
	{
		
		path = rParseFolder.replace(fontFolder, '');
		
		Loader.json(path+"/config.json", true, function(json:Json) {
			
			//trace(json);
			var _ranges = Reflect.field(json, "ranges");
			for( fn in Reflect.fields(_ranges) )
			{
				var r:Array<String> = Reflect.field(_ranges, fn);
				trace('$fn: ${Std.parseInt(r[0])} - ${Std.parseInt(r[1])}');
				ranges.push({min:Std.parseInt(r[0]), max:Std.parseInt(r[1])});
				imageNames.push(fn);
			}
			
			textureCache = new TextureCache(
				[
					{width:2048, height:2048, slots:ranges.length},
				],
				4096*4 //peoteView.gl.getParameter(peoteView.gl.MAX_TEXTURE_SIZE)
			);
		
			load(); // TODO: do manual with callback
		});
	}

	public function load() // TODO 
	{		
		var progressSumA:Array<Int> = [for(i in 0...19) 0];
		var progressSumB:Array<Int> = [for (i in 0...19) 0];
		
		trace("load images and font-data");
		Loader.imageArray(
			imageNames.map(function (v) return '$path/$v.png'),
			true,
			function(index:Int, loaded:Int, size:Int) {
				//trace(' File number $index progress ' + Std.int(loaded / size * 100) + "%" , ' ($loaded / $size)');
				progressSumA[index] = loaded;
				progressSumB[index] = size;
				size = 0;
				for (x in progressSumB) {
					if (x == 0) { size = 0; break; }
					size += x;
				}
				if (size > 0) {
					loaded = 0;
					for (x in progressSumA) loaded += x;
					trace(' loading G3Font-Images progress ' + Std.int(loaded / size * 100) + "%" , ' ($loaded / $size)');
				}
			},
			function(index:Int, image:Image) { // after every single image is loaded
				//trace('File number $index loaded completely.');
				var p = textureCache.addImage(image);
				trace( '${image.width}x${image.height}', "texture-unit:" + p.unit, "texture-slot" + p.slot);
				
				// load font-data -> TODO: load all at first
				Loader.bytes('$path/${imageNames[index]}.dat', true, function(bytes:Bytes) {
					var gl3FontData = new Gl3FontData(bytes, true); // TODO: KERNING on/off
					
					// sort ranges into rangeMapping
					var range = ranges[index];
					for (i in Std.int(range.min / 0x100)...Std.int(range.max / 0x100)) {
						rangeMapping.set(i, {unit:p.unit, slot:p.slot, fontData:gl3FontData});
					}
					
				});						
				
		
			},
			function(images:Array<Image>) { // after all images is loaded
				trace(' --- all images loaded ---');
			}
		);
		
	}
	
	
	function loadFont(font:String, isKerning:Bool, onLoad:Gl3FontData->Image->Bool->Void)
	{
		Loader.bytes(font+".dat", true, function(bytes:Bytes) {
			var gl3font = new Gl3FontData(bytes, isKerning);
			Loader.image(font+".png", true, function(image:Image) {
				onLoad(gl3font, image, isKerning);
			});
		});						
	}
	
	
	
}