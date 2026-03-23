package peote.view.math;
import haxe.Int32;

/** 
	A set of static helper functions to get random numbers.  
	All functions except one wraps around haxes [`Std.random()`](https://api.haxe.org/Std.html#random).  
	The [`.float()`](#float) function uses [`Math.random()`](https://api.haxe.org/Math.html#random).
**/
class Rnd {

	// ----------------------- UInt ---------------------------

	private static inline function _random2():UInt return (Std.random(0x10000) << 16) | Std.random(0x10000);

	/** Returns a random `UInt` unsigned integer number. By default, `rangeLength` is set to `null`, which results in values from `0` to inclusive `0xFFFFFFFF`.
		@param rangeLength random values will be into the range from 0 to rangeLength (exclusive)
	**/
	public static inline function uint(?rangeLength:UInt):UInt {
		if (rangeLength == null) return _random2();
		#if js
		else if (rangeLength & 0x80000000 == 0) return Std.random(rangeLength); // uppest bit not set
		#else
		else if (rangeLength & 0xC0000000 == 0) return Std.random(rangeLength); // uppest 2 bits not set
		#end
		else
			#if neko 
			return haxe.Int64.getLow( (haxe.Int64.fromFloat(uint()) % haxe.Int64.fromFloat(rangeLength))  );
			#else
			return _random2() % rangeLength;
			#end
	}

	/** Returns a random `UInt` unsigned integer number whose value is limited by min and max (inclusive).
		@param minValue the minimal random value
		@param maxValue the maximum random value
	**/
	public static inline function uintLimit(minValue:UInt, maxValue:UInt):UInt {
		return minValue + ( (maxValue == 0xffffffff && minValue==0) ? uint() : uint(maxValue - minValue + 1) );
	}


	// ----------------------- Int ---------------------------

	/** Returns a random `Int` integer number. By default, `rangeLength` is set to `null`, which results in values from `-2147483648` to inclusive `2147483647`.
		@param rangeLength random values will be into the range from 0 to rangeLength (exclusive)
	**/
	public static inline function int(?rangeLength:Int):Int {
		if (rangeLength == null) return uint();
		else if (rangeLength < 0) return -uint(-(rangeLength+1))-1;
		else return uint(rangeLength);
	}

	/** Returns a random `Int` integer number whose value is limited by min and max (inclusive).
		@param minValue the minimal random value
		@param maxValue the maximum random value
	**/
	public static inline function intLimit(minValue:Int, maxValue:Int):Int {
		#if neko
		return minValue + ( (maxValue == 2147483647 && minValue==-2147483648) ? uint() : uint(maxValue - minValue + 1) );
		#else
		return (minValue:Int32) + ( (maxValue == 2147483647 && minValue==-2147483648) ? uint() : uint(maxValue - minValue + 1) );
		#end
	}


	// ---------------------- Float --------------------------

	/** Returns a random `Float` number. (using `Math.random * rangeLength`)
		@param rangeLength if not null the random values will be into the range from 0 to rangeLength (exclusive)
	**/
	public static inline function float(rangeLength:Float = 1.0):Float {
		return Math.random() * rangeLength;
	}

	/** Returns a random `Float` number whose value is limited by min and max (inclusive).
		@param minValue the minimal random value
		@param maxValue the maximum random value
	**/
	public static inline function floatLimit(minValue:Float, maxValue:Float):Float {
		return minValue + (maxValue-minValue) * ( Std.random(0x8000000) * 67108864.0 + Std.random(0x4000000) ) / 9007199254740991.0; // 0x1F FFFF FFFF FFFF
	}

	
	// -------------------- Fast Float ------------------------

	private static inline function _fast() {
		#if (js || neko)
		return Math.random();
		#else
		return Std.random(0x3FFFFFFF) / 1073741823.0; // 0x3FFF FFFF
		#end
	}

	/** Returns a random `Float` number. This can be faster then [`.float()`](#float), but is less accurate.
		@param minValue the minimal random value
		@param maxValue the maximum random value
	**/
	public static inline function fast(rangeLength:Float = 1.0):Float {
		return rangeLength * _fast();
	}

	private static inline function _fastLimit() {
		#if js
		return Std.random(0x7FFFFFFF) / 2147483646.0; // 0x7FFF FFFE
		#else
		return Std.random(0x3FFFFFFF) / 1073741822.0; // 0x3FFF FFFE
		#end
	}

	/** Returns a random `Float` number whose value is limited by min and max (inclusive). This can be faster then [`.floatLimit()`](#floatLimit), but is less accurate.
		@param minValue the minimal random value
		@param maxValue the maximum random value
	**/
	public static inline function fastLimit(minValue:Float, maxValue:Float):Float {
		return minValue + (maxValue-minValue) * _fastLimit(); 
	}


}
