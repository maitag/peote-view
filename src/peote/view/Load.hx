package peote.view;

import lime.graphics.Image;
import lime.utils.Bytes;

/**
	The `Load` class provides a set of static methods to load text, images or bytes `async` by using [Lime Futures](https://lime.openfl.org/api/lime/app/Future.html).
	Data can be loaded from the `filesystem` (by specify a filename e.g. "assets/..."") or also via `http/https` protocol (by specify an url adress).
**/
class Load
{
	/**
		A string what have to set to the adress of a [Cors-Server](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) to load data from different web domains as where it is hosted (only for html5-target).
	**/
	public static var corsServer:String = "";

	static function onProgressDebug(a:Int, b:Int, name:String) {
		trace ('...loading $a/$b of "$name"');
	}

	static function onErrorDebug(msg:String) {
		trace ('Error - $msg');
	}

	static function onCompleteDebug(name:String) {
		trace ('Loading complete "$name"');
	}


	/**
		Loads a single lime [Image](https://lime.openfl.org/api/lime/graphics/Image.html) and calls `onLoad` afterwards.
		@param name filename or url
		@param debug (optional and `false` by default) to trace debug messages for loading, progress and errors
		@param onProgress callback for the progress handler (param: already loaded and total amount of bytes)
		@param onLoad callback if loading is complete (param: image)
		@param onError callback if an error occurs (param: error message)
	**/
	public static function image( name:String, debug=false, ?onProgress:Int->Int->Void, ?onLoad:Image->Void, ?onError:String->Void):Void {
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
	
	/**
		Loads multiple lime [Images](https://lime.openfl.org/api/lime/graphics/Image.html) into parallel. Calls `onLoad` after each and `onLoadAll` after all are completely loaded.
		@param name Array of filenames or urls
		@param debug (optional, `false` by default), to trace debug messages for loading, progress and errors
		@param onProgress callback for the progress handler per image (param: image number, already loaded and total amount of bytes)
		@param onProgressOverall callback for the progress handler for all images together (param: already loaded and total amount of bytes)
		@param onLoad callback after each single image is loaded (param: image number and the image itself)
		@param onLoadAll callback if all images are completely loaded (param: array of loaded images)
		@param onError callback if an error occurs (param: image number and error message)
	**/
	public static function imageArray( names:Array<String>, debug=false, ?onProgress:Int->Int->Int->Void, ?onProgressOverall:Int->Int->Void, ?onLoad:Int->Image->Void, ?onLoadAll:Array<Image>->Void, ?onError:Int->String->Void):Void {
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
				(onLoad == null && onLoadAll == null) ? null : function(image:Image) {
					if (onLoad != null) onLoad(i, image);
					if (onLoadAll != null) {
						images[i] = image;
						if (--loaded == 0) onLoadAll(images);
					}
				},
				(onError == null) ? null : function(msg:String) onError(i, msg)
			);
		}
	}

	
	/**
		Loads single [Bytes](https://lime.openfl.org/api/lime/utils/Bytes.html) and calls `onLoad` afterwards.
		@param name filename or url
		@param debug (optional and `false` by default) to trace debug messages for loading, progress and errors
		@param onProgress callback for the progress handler (param: already loaded and total amount)
		@param onLoad callback if loading is complete (param: `bytes`)
		@param onError callback if an error occurs (param: error message)
	**/
	public static function bytes( name:String, debug=false, ?onProgress:Int->Int->Void, ?onLoad:Bytes->Void, ?onError:String->Void):Void {
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
	
	/**
		Loads multiple [Bytes](https://lime.openfl.org/api/lime/utils/Bytes.html) into parallel. Calls `onLoad` after each and `onLoadAll` after all are completely loaded.
		@param name Array of filenames or urls
		@param debug (optional, `false` by default), to trace debug messages for loading, progress and errors
		@param onProgress callback for the progress handler per bytes (param: bytes number, already loaded and total amount)
		@param onProgressOverall callback for the progress handler for all bytes together (param: already loaded and total amount)
		@param onLoad callback after each single bytes is loaded (param: bytes number and the bytes itself)
		@param onLoadAll callback if the data of all bytes are completely loaded (param: array of loaded bytes)
		@param onError callback if an error occurs (param: bytes number and error message)
	**/
	public static function bytesArray( names:Array<String>, debug=false, ?onProgress:Int->Int->Int->Void, ?onProgressOverall:Int->Int->Void, ?onLoad:Int->Bytes->Void, ?onLoadAll:Array<Bytes>->Void, ?onError:Int->String->Void):Void {
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
				(onLoad == null && onLoadAll == null) ? null : function(bytes:Bytes) {
					if (onLoad != null) onLoad(i, bytes);
					if (onLoadAll != null) {
						allBytes[i] = bytes;
						if (--loaded == 0) onLoadAll(allBytes);
					}
				},
				(onError == null) ? null : function(msg:String) onError(i, msg)
			);
		}
	}

	
	/**
		Loads a single `text` into a String and calls `onLoad` afterwards.
		@param name filename or url
		@param debug (optional and `false` by default) to trace debug messages for loading, progress and errors
		@param onProgress callback for the progress handler (param: already loaded and total amount)
		@param onLoad callback if loading is complete (param: `text` as a String)
		@param onError callback if an error occurs (param: error message)
	**/
	public static function text( name:String, debug=false, ?onProgress:Int->Int->Void, ?onLoad:String->Void, ?onError:String->Void):Void {
		bytes( name, debug, onProgress, (onLoad == null) ? null : function(bytes:Bytes) onLoad(bytes.toString()), onError );
	}

	/**
		Loads multiple `text` as Strings into parallel. Calls `onLoad` after each and `onLoadAll` after all are completely loaded.
		@param name Array of filenames or urls
		@param debug (optional, `false` by default), to trace debug messages for loading, progress and errors
		@param onProgress callback for the progress handler per text (param: text number, already loaded and total amount)
		@param onProgressOverall callback for the progress handler for all texts together (param: already loaded and total amount)
		@param onLoad callback after each single text is loaded (param: text number and the text itself)
		@param onLoadAll callback if the data of all texts are completely loaded (param: array of loaded texts)
		@param onError callback if an error occurs (param: text number and error message)
	**/
	public static function textArray( names:Array<String>, debug=false, ?onProgress:Int->Int->Int->Void, ?onProgressOverall:Int->Int->Void, ?onLoad:Int->String->Void, ?onLoadAll:Array<String>->Void, ?onError:Int->String->Void):Void {
		bytesArray( names, debug, onProgress, onProgressOverall, 
			(onLoad == null) ? null : function(i:Int, bytes:Bytes) onLoad(i, bytes.toString()),
			(onLoadAll == null) ? null : function(bytesArray:Array<Bytes>) onLoadAll( [for (bytes in bytesArray) bytes.toString()] ),
			onError
		);
	}

}