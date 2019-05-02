package peote.text;

import peote.view.PeoteGL.Image;
import haxe.io.Bytes;
import peote.view.Texture;

class Font 
{

	public var filename:String;
	
	var texture:Texture;
	
	
	public function new(filename:String, isKerning:Bool) 
	{
		// load the font
		
	}
	
	
	public function loadFont(font:String, isKerning:Bool, onLoad:Gl3FontData->Image->Bool->Void)
	{
		bytesFromFile(font+".dat", function(bytes:Bytes) {
			var gl3font = new Gl3FontData(bytes, isKerning); // TODO: use a Future here to calculate while loading image!
			imageFromFile(font+".png", function(image:Image) {
				onLoad(gl3font, image, isKerning);
			});
		});						
	}
	
	
	public function imageFromFile(filename:String, onLoad:Image->Void):Void {
		trace('load image $filename');
		var future = Image.loadFromFile(filename);
		future.onProgress (function (a:Int,b:Int) trace ('...loading image $a/$b'));
		future.onError (function (msg:String) trace ("Error: "+msg));
		future.onComplete (function (image:Image) {
			trace('loading $filename complete');
			onLoad(image);
		});		
	}
	
	public function bytesFromFile(filename:String, onLoad:Bytes->Void):Void {
		var future = lime.utils.Bytes.loadFromFile(filename);
		future.onProgress (function (a:Int,b:Int) trace ('loading bytes $a/$b'));
		future.onError (function (msg:String) trace ("Error: "+msg));
		future.onComplete (function (bytes:Bytes) {
			trace("loading bytes complete");
			onLoad(bytes);
		});
	}	
	
}