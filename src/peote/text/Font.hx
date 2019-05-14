package peote.text;

import peote.view.PeoteGL.Image;
import haxe.io.Bytes;
import peote.view.Texture;
import utils.Loader;
import haxe.Json;

class Font 
{

	public var filename:String;
	
	var texture:Texture;
	
	var rParseFolder = new EReg("/*$", "gm");
	
	public function new(fontFolder:String, isKerning:Bool=true) 
	{
		fontFolder = rParseFolder.replace(fontFolder, '');
		Loader.json(fontFolder+"/config.json", true, function(json:Json) {
			
			var ranges = Reflect.field(json, "ranges");
			for( fn in Reflect.fields(ranges) )
			{
				var range:Array<String> = Reflect.field(ranges, fn);
				trace(fn, Std.parseInt(range[0]), Std.parseInt(range[1]));
			}
			
			trace(json);
		});
			
		// TODO
		
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