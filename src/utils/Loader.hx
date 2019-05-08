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

	public static inline function image( name:String, debug=false, ?onProgress:Int->Int->Void, ?onError:String->Void, onLoad:Image->Void):Void {
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
		future.onComplete( onLoad );		
	}
	
	public static inline function imageArray( names:Array<String>, debug=false, ?onProgress:Int->Int->Void, ?onError:String->Void, ?onLoad:Image->Void, onLoadAll:Array<Image>->Void):Void {
		var images = new Array<Image>();
		var loaded:Int = names.length;
		#if !html5
		var progressSumA:Array<Int> = [for(i in 0...names.length) 0];
		var progressSumB:Array<Int> = [for (i in 0...names.length) 0];
		#end
		for (i in 0...names.length) {
			image( names[i], debug, 
				#if !html5
				function (a:Int, b:Int) {
					progressSumA[i] = a;
					progressSumB[i] = b;
					var bSum = 0;
					for (x in progressSumB) {
						if (x == 0) { bSum = 0; break; }
						bSum += x;
					}
					if (bSum > 0) {
						var aSum = 0;
						for (x in progressSumA) aSum += x;
						onProgress(aSum, bSum);
					}
				},
				#else
				onProgress,
				#end
				onError,
				function(image:Image) {
					images[i] = image;
					#if html5
					onProgress(names.length-loaded+1, names.length);
					#end
					if (onLoad != null) onLoad(image);
					if (--loaded == 0) {
						onLoadAll(images);
						images = null;
					}
				}
			);
		}
	}
	
	public static inline function bytes( name:String, debug=false, ?onProgress:Int->Int->Void, ?onError:String->Void, onLoad:Bytes->Void):Void {
		var future = Bytes.loadFromFile(name);
		
		if (debug) {
			trace('Start loading bytes "$name"');
			future.onProgress( function(a:Int, b:Int) onProgressDebug(a, b, name) );
			future.onError( onErrorDebug );
			future.onComplete( function(bytes:Bytes) onCompleteDebug(name) );
		}
		
		if (onProgress != null) future.onProgress( onProgress );
		if (onError != null) future.onError( onError );
		future.onComplete( onLoad );		
	}
		
	public static inline function json( name:String, debug=false, ?onProgress:Int->Int->Void, ?onError:String->Void, onLoad:Json->Void):Void {
		var future = Bytes.loadFromFile(name);
		
		if (debug) {
			trace('Start loading json "$name"');
			future.onProgress( function(a:Int, b:Int) onProgressDebug(a, b, name) );
			future.onError( onErrorDebug );
			future.onComplete( function(bytes:Bytes) onCompleteDebug(name) );
		}
		
		if (onProgress != null) future.onProgress( onProgress );
		if (onError != null) future.onError( onError );
		future.onComplete( function(bytes:Bytes) {
			
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