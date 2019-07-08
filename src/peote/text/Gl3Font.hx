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

	var rangeMapping = new Vector<{unit:Int, slot:Int, fontData:Gl3FontData}>(20); // TODO: is ( 0x1000 * 20) the greatest charcode for unicode ?
	
	var ranges = new Array<{min:Int, max:Int}>();
	var imageNames = new Array<String>();
	
	var textureCache:TextureCache;
	
	public var isKerning(default,null):Bool;
	
	var rParseFolder = new EReg("/*$", "gm");
	
	public function new(fontPath:String, isKerning:Bool=true) 
	{
		path = rParseFolder.replace(fontPath, '');
		this.isKerning = isKerning;
		
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
		trace("load font-data");
		var gl3FontData = new Array<Gl3FontData>();
		
		var progressSumA:Array<Int> = [for(i in 0...imageNames.length) 0];
		var progressSumB:Array<Int> = [for (i in 0...imageNames.length) 0];
		
		Loader.bytesArray(
			imageNames.map(function (v) return '$path/$v.dat'),
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
					trace(' loading G3Font-Data progress ' + Std.int(loaded / size * 100) + "%" , ' ($loaded / $size)');
				}
			},
			function(index:Int, bytes:Bytes) { // after .dat is loaded
				//trace('File number $index loaded completely.');
				gl3FontData[index] = new Gl3FontData(bytes, ranges[index].min, ranges[index].max, isKerning);
		
			},
			function(bytes:Array<Bytes>) { // after all .dat is loaded
				trace(' --- all font-data loaded ---');
				loadImages(gl3FontData);
			}
		);
	}
	
	public function loadImages(gl3FontData:Array<Gl3FontData>)
	{		
		trace("load images");
			
		var progressSumA = [for(i in 0...imageNames.length) 0];
		var progressSumB = [for (i in 0...imageNames.length) 0];
		
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
			function(index:Int, image:Image) { // after every image is loaded
				//trace('File number $index loaded completely.');
				var p = textureCache.addImage(image);
				trace( '${image.width}x${image.height}', "texture-unit:" + p.unit, "texture-slot" + p.slot);
				
				// recalc texture-coords
				var gl3font = gl3FontData[index];
				for (charcode in gl3font.rangeMin...gl3font.rangeMax+1) {
					var m = gl3font.getMetric(charcode);
					if (m != null) {
						m.u *= textureCache.textures[p.unit].width;
						m.v *= textureCache.textures[p.unit].height;
						m.w *= textureCache.textures[p.unit].width;
						m.h *= textureCache.textures[p.unit].height;
						gl3font.setMetric(charcode, m);
					}
				}
				// sort ranges into rangeMapping
				var range = ranges[index];
				for (i in Std.int(range.min / 0x1000)...Std.int(range.max / 0x1000)+1) {
					rangeMapping.set(i, {unit:p.unit, slot:p.slot, fontData:gl3font});
				}
				
		
			},
			function(images:Array<Image>) { // after all images is loaded
				trace(' --- all images loaded ---');
			}
		);
		
	}
	
	
	
}