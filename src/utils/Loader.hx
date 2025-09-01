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


	public static function image( name:String, debug=false, ?onProgress:Int->Int->Void, ?onError:String->Void, ?onLoad:Image->Void):Void {
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
	
	public static function imageArray( names:Array<String>, debug=false, ?onProgress:Int->Int->Int->Void, ?onProgressOverall:Int->Int->Void, ?onError:Int->String->Void, ?onLoad:Int->Image->Void, ?onLoadAll:Array<Image>->Void):Void {
		var images:Array<Image> = (onLoadAll == null) ? null : new Array<Image>();
		var loaded:Int = names.length;
		var progressSumA:Array<Int> = null;
		var progressSumB:Array<Int> = null;
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
				(onLoad == null && onLoadAll == null) ? null : function(image:Image) {
					if (onLoad != null) onLoad(i, image);
					if (onLoadAll != null) {
						images[i] = image;
						if (--loaded == 0) onLoadAll(images);
					}
				}
			);
		}
	}

	
	public static function bytes( name:String, debug=false, ?onProgress:Int->Int->Void, ?onError:String->Void, ?onLoad:Bytes->Void):Void {
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
	
	public static function bytesArray( names:Array<String>, debug=false, ?onProgress:Int->Int->Int->Void, ?onProgressOverall:Int->Int->Void, ?onError:Int->String->Void, ?onLoad:Int->Bytes->Void, ?onLoadAll:Array<Bytes>->Void):Void {
		var allBytes:Array<Bytes> = (onLoadAll == null) ? null : new Array<Bytes>();
		var loaded:Int = names.length;
		var progressSumA:Array<Int> = null;
		var progressSumB:Array<Int> = null;
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
				(onLoad == null && onLoadAll == null) ? null : function(bytes:Bytes) {
					if (onLoad != null) onLoad(i, bytes);
					if (onLoadAll != null) {
						allBytes[i] = bytes;
						if (--loaded == 0) onLoadAll(allBytes);
					}
				}
			);
		}
	}

	
	public static function text( name:String, debug=false, ?onProgress:Int->Int->Void, ?onLoad:String->Void, ?onError:String->Void):Void {
		bytes( name, debug, onProgress, onError, (onLoad == null) ? null : function(bytes:Bytes) onLoad(bytes.toString()) );
	}

	public static function textArray( names:Array<String>, debug=false, ?onProgress:Int->Int->Int->Void, ?onProgressOverall:Int->Int->Void, ?onLoad:Int->String->Void, ?onLoadAll:Array<String>->Void, ?onError:Int->String->Void):Void {
		bytesArray( names, debug, onProgress, onProgressOverall, onError, 
			(onLoad == null) ? null : function(i:Int, bytes:Bytes) onLoad(i, bytes.toString()),
			(onLoadAll == null) ? null : function(bytesArray:Array<Bytes>) onLoadAll( [for (bytes in bytesArray) bytes.toString()] )
		);
	}

}