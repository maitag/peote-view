package utils;

import haxe.Json;
import lime.graphics.Image;
import lime.utils.Bytes;

class Loader 
{

	static function onProgressDebug(a:Int, b:Int, filename:String) {
		trace ('...loading $a/$b of "$filename"');
	}

	static function onErrorDebug(msg:String) {
		trace ('Error - $msg');
	}

	static function onCompleteDebug(filename:String) {
		trace ('Loading complete "$filename"');
	}

	public static inline function imageFromFile( filename:String, debug=false, ?onProgress:Int->Int->Void, ?onError:String->Void, onLoad:Image->Void):Void {
		var future = Image.loadFromFile(filename);
		
		if (debug) {
			trace('Start loading image "$filename"');
			future.onProgress( function(a:Int, b:Int) onProgressDebug(a, b, filename) );
			future.onError( onErrorDebug );
			future.onComplete( function(image:Image) onCompleteDebug(filename) );
		}
		
		if (onProgress != null) future.onProgress( onProgress );
		if (onError != null) future.onError( onError );
		future.onComplete( onLoad );		
	}
	
	public static inline function bytesFromFile( filename:String, debug=false, ?onProgress:Int->Int->Void, ?onError:String->Void, onLoad:Bytes->Void):Void {
		var future = Bytes.loadFromFile(filename);
		
		if (debug) {
			trace('Start loading bytes "$filename"');
			future.onProgress( function(a:Int, b:Int) onProgressDebug(a, b, filename) );
			future.onError( onErrorDebug );
			future.onComplete( function(bytes:Bytes) onCompleteDebug(filename) );
		}
		
		if (onProgress != null) future.onProgress( onProgress );
		if (onError != null) future.onError( onError );
		future.onComplete( onLoad );		
	}
	
	
	public static inline function jsonFromFile( filename:String, debug=false, ?onProgress:Int->Int->Void, ?onError:String->Void, onLoad:Json->Void):Void {
		var future = Bytes.loadFromFile(filename);
		
		if (debug) {
			trace('Start loading json "$filename"');
			future.onProgress( function(a:Int, b:Int) onProgressDebug(a, b, filename) );
			future.onError( onErrorDebug );
			future.onComplete( function(bytes:Bytes) onCompleteDebug(filename) );
		}
		
		if (onProgress != null) future.onProgress( onProgress );
		if (onError != null) future.onError( onError );
		future.onComplete( function(bytes:Bytes) {
			
			var regex = new EReg("//.*?$", "gm");
			//trace(regex.replace( bytes.toString(), "") );
			var json:Json;
			
			try {
				json = Json.parse( regex.replace( bytes.toString(), "") );
				onLoad(json);
			} catch (msg:Dynamic) trace('Error while parsing json of file "$filename"\n   ' + msg);			
		});
		
	}
	
}