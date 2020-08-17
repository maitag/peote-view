package utils;

import lime.graphics.Image;
import lime.utils.Bytes;

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
	
	public static inline function imageArray( names:Array<String>, debug=false, ?onProgress:Int->Int->Int->Void, ?onProgressOverall:Int->Int->Void, ?onError:Int->String->Void, ?onLoad:Int->Image->Void, ?onLoadAll:Array<Image>->Void):Void {
		var images = new Array<Image>();
		var loaded:Int = names.length;		
		var progressSumA = new Array<Int>(); // does not need to be initialized (only to avoid compiler-warning)
		var progressSumB = new Array<Int>();
		if (onProgressOverall != null) {
			progressSumA = [for (i in 0...names.length) 0];
			progressSumB = [for (i in 0...names.length) 0];
		}
		for (i in 0...names.length) {
			image( names[i], debug, 
				(onProgress == null && onProgressOverall == null) ? null : function (a:Int, b:Int) {
					if (onProgress != null) onProgress(i, a, b);
					if (onProgressOverall != null) {
						progressSumA[i] = a; progressSumB[i] = b;
						b = 0;
						for (x in progressSumB) {
							if (x == 0) { b = 0; break; }
							b += x;
						}
						if (b > 0) {
							a = 0;
							for (x in progressSumA) a += x;
							onProgressOverall(a, b);
						}
					}
				},
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
		#if html5
		if (corsServer != "" && ~/^https?:\/\//.match(name)) name = "//"+corsServer+"/"+name;
		#end
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

	public static inline function text( name:String, debug=false, ?onProgress:Int->Int->Void, ?onError:String->Void, ?onLoad:String->Void):Void {
		bytes( name, debug, onProgress,
			(onLoad == null && onError == null) ? null : onError,  // helps parametermatching
			(onLoad == null && onError == null) ? null : function(bytes:Bytes) {
				if (onLoad != null && onError != null ) // helps parametermatching
					onLoad(bytes.toString());
				else onError(bytes.toString());
			}
		);
	}
	
	public static inline function bytesArray( names:Array<String>, debug=false, ?onProgress:Int->Int->Int->Void, ?onProgressOverall:Int->Int->Void, ?onError:Int->String->Void, ?onLoad:Int->Bytes->Void, ?onLoadAll:Array<Bytes>->Void):Void {
		var allBytes = new Array<Bytes>();
		var loaded:Int = names.length;
		var progressSumA = new Array<Int>(); // does not need to be initialized (only to avoid compiler-warning)
		var progressSumB = new Array<Int>();
		if (onProgressOverall != null) {
			progressSumA = [for (i in 0...names.length) 0];
			progressSumB = [for (i in 0...names.length) 0];
		}
		for (i in 0...names.length) {
			bytes( names[i], debug, 
				(onProgress == null && onProgressOverall == null) ? null : function (a:Int, b:Int) {
					if (onProgress != null) onProgress(i, a, b);
					if (onProgressOverall != null) {
						progressSumA[i] = a; progressSumB[i] = b;
						b = 0;
						for (x in progressSumB) {
							if (x == 0) { b = 0; break; }
							b += x;
						}
						if (b > 0) {
							a = 0;
							for (x in progressSumA) a += x;
							onProgressOverall(a, b);
						}
					}
				},
				(onError == null) ? null : function(msg:String) onError(i, msg),
				(onLoadAll == null) ? null : function(bytes:Bytes) {
					allBytes[i] = bytes;
					if (onLoad != null) onLoad(i, bytes);
					if (--loaded == 0) onLoadAll(allBytes);
				}
			);
		}
	}
	

}