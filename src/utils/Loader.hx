package utils;

import haxe.Json;
import lime.graphics.Image;
import lime.utils.Bytes;
import lime.net.HTTPRequest;
import lime.net.HTTPRequestMethod;

class Loader 
{
	public static var corsServer = "";

	static function onProgressDebug(a:Int, b:Int, name:String) {
		trace ('...loading $a/$b of "$name"');
	}

	static function onErrorDebug(msg:String) {
		trace ('Error - $msg');
	}

	static function onCompleteDebug(name:String) {
		trace ('Loading complete "$name"');
	}

	public static inline function image( name:String, debug=false, ?onProgress:Int->Int->Void, ?onError:String->Void, ?onLoad:Image->Void):Void {
		#if html5
		if (corsServer != "" && ~/^https?:\/\//.match(name)) name = "//"+corsServer+"/"+name;
		#end
		var future = Image.loadFromFile(name);		
		if (debug) {
			trace('Start loading image "$name"');
			future.onProgress( function(a:Int, b:Int) onProgressDebug(a, b, name) );
			future.onError( onErrorDebug );
			future.onComplete( function(image:Image) onCompleteDebug(name) );
		}		
		if (onProgress != null) future.onProgress( onProgress );
		if (onError != null) future.onError( onError );
		if (onLoad != null) future.onComplete( onLoad );		
	}
	
	public static inline function imageArray( names:Array<String>, debug=false, ?onProgress:Int->Int->Int->Void, ?onError:Int->String->Void, ?onLoad:Int->Image->Void, ?onLoadAll:Array<Image>->Void):Void {
		var images = new Array<Image>();
		var loaded:Int = names.length;
		for (i in 0...names.length) {
			image( names[i], debug, 
				(onProgress == null) ? null : function (a:Int, b:Int) onProgress(i, a, b),
				(onError == null) ? null : function(msg:String) onError(i, msg),
				(onLoadAll == null) ? null : function(image:Image) {
					images[i] = image;
					if (onLoad != null) onLoad(i, image);
					if (--loaded == 0) onLoadAll(images);
				}
			);
		}
	}
	
	public static inline function bytes( name:String, debug=false, ?onProgress:Int->Int->Void, ?onError:String->Void, ?onLoad:Bytes->Void):Void {
		var future = Bytes.loadFromFile(name);		
		if (debug) {
			trace('Start loading bytes "$name"');
			future.onProgress( function(a:Int, b:Int) onProgressDebug(a, b, name) );
			future.onError( onErrorDebug );
			future.onComplete( function(bytes:Bytes) onCompleteDebug(name) );
		}		
		if (onProgress != null) future.onProgress( onProgress );
		if (onError != null) future.onError( onError );
		if (onLoad != null) future.onComplete( onLoad );		
	}
		
	public static inline function json( name:String, debug=false, ?onProgress:Int->Int->Void, ?onError:String->Void, ?onLoad:Json->Void):Void {
		var future = Bytes.loadFromFile(name);		
		if (debug) {
			trace('Start loading json "$name"');
			future.onProgress( function(a:Int, b:Int) onProgressDebug(a, b, name) );
			future.onError( onErrorDebug );
			future.onComplete( function(bytes:Bytes) onCompleteDebug(name) );
		}		
		if (onProgress != null) future.onProgress( onProgress );
		if (onError != null) future.onError( onError );
		if (onLoad != null) future.onComplete( function(bytes:Bytes) {
			
			var rComments = new EReg("//.*?$", "gm");
			var rEmptylines:EReg = new EReg("([ \t]*\r?\n)+", "g");
			var rStartspaces:EReg = new EReg("^([ \t]*\r?\n)+", "g");
			
			var json:Json;
			
			try {
				json = Json.parse( rStartspaces.replace(rEmptylines.replace(rComments.replace(bytes.toString(), ""), "\n"), ""));
				onLoad(json);
			} catch (msg:Dynamic) trace('Error while parsing json of file "$name"\n   ' + msg);			
		});
		
	}
	
}