/*			-> 2026 -> optimized and minimalized by semmi ~^ *hugs
			  (^_^)

		Haxe implementation of MT19937 pseudorandom number generator.
		(see authors page http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html)
		Git repository https://github.com/iskolbin/mt
		Written by Ilya Kolbin (iskolbin@gmail.com)

	JavaScript and Python conditional compilation based on
	https://gist.github.com/banksean/300494 by Sean McCullough (banksean@gmail.com)
	see also npm package https://github.com/boo1ean/mersenne-twister


A C-program for MT19937, with initialization improved 2002/1/26.
Coded by Takuji Nishimura and Makoto Matsumoto.
Any feedback is very welcome.
http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
email: m-mat @ math.sci.hiroshima-u.ac.jp (remove space)
license: https://www.math.sci.hiroshima-u.ac.jp/m-mat/MT/MT2002/elicense.html
*/
package peote.view.math;
import haxe.Int32;

#if js
import js.lib.Uint32Array;
private abstract MT_List(Uint32Array) {
	public inline function new(length:Int) this = new Uint32Array(length);
	public inline function get(i:Int):UInt return this[i];
	public inline function set(i:Int, v:UInt) this[i] = v;
}
#else
import haxe.ds.Vector;
@:forward(get, set) private abstract MT_List(Vector<UInt>) {
	public inline function new(length:Int) this = new Vector(length);
}
#end

/** 
	To generate pseudo random numbers by a [Mersenne Twister](https://www.math.sci.hiroshima-u.ac.jp/m-mat/MT/ewhat-is-mt.html).  
	The same seed results in the same sequence of random numbers.
**/
class Random {
	static inline var N:Int = 624;
	static inline var M:Int = 397;
	static inline var MATRIX_A:  UInt = 0x9908b0df;
	static inline var UPPER_MASK:UInt = 0x80000000;
	static inline var LOWER_MASK:UInt = 0x7fffffff;
	static inline var FF_MASK:   UInt = 0xffffffff;
	static inline var MULT:      UInt = 1812433253;
	static inline var TEMPER_1:  UInt = 0x9d2c5680;
	static inline var TEMPER_2:  UInt = 0xefc60000;
	static inline var AH_MASK:   UInt = 0xffff0000;
	static inline var AL_MASK:   UInt = 0x0000ffff;	
	static inline function mag01(r):UInt return (r & 1 == 0) ? 0 : MATRIX_A;

	var mt:MT_List;
	var mti:Int = 0;

	/** Creates a new `Random` instance.
		@param seed (optional) the start-seed for the random sequence. If this value is `null` the seed will be `Std.random()`
	**/
	public function new( ?seed:UInt ) {
		mt = new MT_List(N);
		this.seed(seed);
	}

	/** Sets the seed of this instance to start a new sequence.
		@param seed (optional) the start-seed for the random sequence. If this value is `null` the seed will be `Std.random()`
	**/
		public function seed(?seed:UInt) {
		if (seed == null) seed = (Std.int(Math.random()*256) << 24) | Std.random(0x1000000);

		#if js
		var m:UInt = seed >>> 0;
		#else
		var m:UInt = seed & FF_MASK;
		#end

		var s:UInt = (m ^ (m >> 30));
		mt.set(0, m);
		
		for ( i in 1...N )
		{
			#if js
			m = ((((((s & AH_MASK) >>> 16) * MULT) << 16) + (s & AL_MASK) * MULT) + i) >>> 0;
			#else
			m = (MULT * s + i) & FF_MASK;
			#end

			s = (m ^ (m >> 30));			
			mt.set(i, m);
		}

		mti = N;
	}


	private function randomUInt():UInt {
		var r:UInt;

		if ( mti >= N )
		{	
			for ( i in 0...N-M ) {
				r = ( mt.get(i) & UPPER_MASK ) | ( mt.get(i+1) & LOWER_MASK );
				mt.set(i, mt.get(i+M) ^ (r >> 1) ^ mag01(r));
			}
			for ( i in N-M...N-1 ) {
				r = ( mt.get(i) & UPPER_MASK ) | ( mt.get(i+1) & LOWER_MASK );
				mt.set( i, mt.get(i+(M-N)) ^ (r >> 1) ^ mag01(r) );
			}

			r = ( mt.get(N-1) & UPPER_MASK ) | ( mt.get(0) & LOWER_MASK );
			mt.set( N-1, mt.get(M-1) ^ (r >> 1) ^ mag01(r) );

			mti = 0;
		}
  
		r = mt.get(mti++);

		// Tempering
		r ^= (r >> 11);
		r ^= (r << 7) & TEMPER_1;
		r ^= (r << 15) & TEMPER_2;
		r ^= (r >> 18);

		return r;
	}


	// --------------------- UInt --------------------------

	/** Returns a random `UInt` unsigned integer number.
		@param rangeLength if not null the random values will be into the range from 0 to rangeLength (exclusive)
	**/
	public inline function uint(?rangeLength:UInt):UInt {
		if (rangeLength == null) return randomUInt();
		else
			#if neko 
			return haxe.Int64.getLow( (haxe.Int64.fromFloat(randomUInt()) % haxe.Int64.fromFloat(rangeLength))  );
			#else
			return randomUInt() % rangeLength;
			#end
	}

	/** Returns a random `UInt` unsigned integer number whose value is limited by min and max (inclusive).
		@param minValue the minimal random value
		@param maxValue the maximum random value
	**/
	public inline function uintLimit(minValue:UInt, maxValue:UInt):UInt {
		return minValue + ( (maxValue == 0xffffffff && minValue==0) ? uint() : uint(maxValue - minValue) );
	}


	// ----------------------- Int ---------------------------

	/** Returns a random `Int` integer number.
		@param rangeLength if not null the random values will be into the range from 0 to rangeLength (exclusive)
	**/
	public inline function int(?rangeLength:Int):Int {
		if (rangeLength == null) return randomUInt();
		else if (rangeLength < 0) return -(randomUInt() % -rangeLength);
		else return randomUInt() % rangeLength;
	}

	/** Returns a random `Int` integer number whose value is limited by min and max (inclusive).
		@param minValue the minimal random value
		@param maxValue the maximum random value
	**/
	public inline function intLimit(minValue:Int, maxValue:Int):Int {
		#if neko
		return minValue + ( (maxValue == 2147483647 && minValue==-2147483648) ? uint() : uint(maxValue - minValue) );
		#else
		return (minValue:Int32) + ( (maxValue == 2147483647 && minValue==-2147483648) ? uint() : uint(maxValue - minValue) );
		#end
	}


	// ---------------------- Float --------------------------

	/** Returns a random `Float` number.
		@param rangeLength if not null the random values will be into the range from 0 to rangeLength (exclusive)
	**/
	public inline function float(rangeLength:Float = 1.0):Float {
		return  rangeLength * ((randomUInt() >> 5) * 67108864.0 + (randomUInt() >> 6)) / 9007199254740992.0; // 0x20 0000 0000 0000
	}

	/** Returns a random `Float` number whose value is limited by min and max (inclusive).
		@param minValue the minimal random value
		@param maxValue the maximum random value
	**/
	public inline function floatLimit(minValue:Float, maxValue:Float):Float {
		return minValue + (maxValue-minValue) * ((randomUInt() >> 5) * 67108864.0 + (randomUInt() >> 6)) / 9007199254740991.0; // 0x1F FFFF FFFF FFFF
	}


	// -------------------- FloatFast ------------------------

	/** Returns a random `Float` number. This is faster then [`.float()`](#float), but less accurate.
		@param minValue the minimal random value
		@param maxValue the maximum random value
	**/
	public inline function floatFast(rangeLength:Float = 1.0):Float {
		return rangeLength * randomUInt() / 4294967296.0; // 0x1 0000 0000
	}

	/** Returns a random `Float` number whose value is limited by min and max (inclusive). This is faster then [`.floatLimit()`](#floatLimit), but less accurate.
		@param minValue the minimal random value
		@param maxValue the maximum random value
	**/
	public inline function floatFastLimit(minValue:Float, maxValue:Float):Float {
		return minValue + (maxValue-minValue) * randomUInt() / 4294967295.0; // 0x FFFF FFFF
	}

}
