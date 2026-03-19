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

#if js
import js.lib.Uint32Array;
abstract MT_List(Uint32Array) {
	public inline function new(length:Int) this = new Uint32Array(length);
	public inline function get(i:Int):UInt return this[i];
	public inline function set(i:Int, v:UInt) this[i] = v;
}
#else
import haxe.ds.Vector;
@:forward(get, set) abstract MT_List(Vector<UInt>) {
	public inline function new(length:Int) this = new Vector(length);
}
#end

class Random {
	public static inline var N:Int = 624;
	public static inline var M:Int = 397;
	public static inline var MATRIX_A:  UInt = 0x9908b0df;
	public static inline var UPPER_MASK:UInt = 0x80000000;
	public static inline var LOWER_MASK:UInt = 0x7fffffff;
	public static inline var FF_MASK:   UInt = 0xffffffff;
	public static inline var MULT:      UInt = 1812433253;
	public static inline var TEMPER_1:  UInt = 0x9d2c5680;
	public static inline var TEMPER_2:  UInt = 0xefc60000;
	public static inline var AH_MASK:   UInt = 0xffff0000;
	public static inline var AL_MASK:   UInt = 0x0000ffff;
	
	static inline function mag01(y) return (y & 1 == 0) ? 0 : MATRIX_A;

	public static inline var DEFAULT_SEED:UInt = 5489;

	public static var instance(default,null) = new Random();

	// public var mt(default,null): Array<UInt>;
	public var mt(default,null):MT_List;
	public var mti(default,null):Int = 0; // mt index

	public function new( ?seed:UInt ) {
		// mt = new Array<UInt>();
		mt = new MT_List(N);
		// for ( i in 0...N ) mt[i] = 0;
		// init( seed == null ? Std.int( haxe.Timer.stamp()) : seed );
		init( seed == null ? (Std.int(Math.random()*256) << 24) | Std.random(0x1000000) : seed );
	}
/*
	public function init( s: UInt ) {
		#if js
		mt[0] = s >>> 0;
		#else
		mt[0] = s & FF_MASK;
		#end
		for ( j in 1...N ) {
			var s = (mt[j-1] ^ (mt[j-1] >> 30));
			#if js
			mt[j] = ((((((s & AH_MASK) >>> 16) * MULT) << 16) + (s & AL_MASK) * MULT) + j) >>> 0;
			#else
			mt[j] = (MULT * s + j) & FF_MASK;
			#end
		}
		mti = N;
	}

	public function randomUInt(): UInt {
		var mt = this.mt;
		var y: UInt;

		if ( mti >= N ) { 		// generate N words at one time
			if ( mti == N+1 )   // if init() has not been called
				init( DEFAULT_SEED ); // a default initial seed is used

			for ( kk in 0...N-M ) {
				y = ( mt[kk] & UPPER_MASK ) | ( mt[kk+1] & LOWER_MASK );
				mt[kk] = mt[kk+M] ^ (y >> 1) ^ mag01(y);
			}
			for ( kk in N-M...N-1 ) {
				y = ( mt[kk] & UPPER_MASK ) | ( mt[kk+1] & LOWER_MASK );
				mt[kk] = mt[kk+(M-N)] ^ (y >> 1) ^ mag01(y);
			}
			y = ( mt[N-1] & UPPER_MASK ) | ( mt[0] & LOWER_MASK );
			mt[N-1] = mt[M-1] ^ (y >> 1) ^ mag01(y);

			mti = 0;
		}
  
		y = mt[mti++];

		// Tempering
		y ^= (y >> 11);
		y ^= (y << 7) & TEMPER_1;
		y ^= (y << 15) & TEMPER_2;
		y ^= (y >> 18);

		return y;
	}
*/
	public function init( seed: UInt ) {
		#if js
		var m:UInt = seed >>> 0;
		#else
		var m:UInt = seed & FF_MASK;
		#end

		var s:UInt = (m ^ (m >> 30));
		mt.set(0, m);
		
		for ( j in 1...N )
		{
			#if js
			m = ((((((s & AH_MASK) >>> 16) * MULT) << 16) + (s & AL_MASK) * MULT) + j) >>> 0;
			#else
			m = (MULT * s + j) & FF_MASK;
			#end

			s = (m ^ (m >> 30));			
			mt.set(j, m);
		}
		mti = N;
	}


	public function randomUInt():UInt {
		var y:UInt;

		if ( mti >= N ) // generate N words at one time
		{	
			// if init() has not been called
			if ( mti == N+1 ) init( DEFAULT_SEED ); // a default initial seed is used <- TODO

			for ( kk in 0...N-M ) {
				y = ( mt.get(kk) & UPPER_MASK ) | ( mt.get(kk+1) & LOWER_MASK );
				mt.set(kk, mt.get(kk+M) ^ (y >> 1) ^ mag01(y));
			}

			for ( kk in N-M...N-1 ) {
				y = ( mt.get(kk) & UPPER_MASK ) | ( mt.get(kk+1) & LOWER_MASK );
				mt.set( kk, mt.get(kk+(M-N)) ^ (y >> 1) ^ mag01(y) );
			}

			y = ( mt.get(N-1) & UPPER_MASK ) | ( mt.get(0) & LOWER_MASK );
			mt.set( N-1, mt.get(M-1) ^ (y >> 1) ^ mag01(y) );

			mti = 0;
		}
  
		y = mt.get(mti++);

		/* Tempering */
		y ^= (y >> 11);
		y ^= (y << 7) & TEMPER_1;
		y ^= (y << 15) & TEMPER_2;
		y ^= (y >> 18);

		return y;
	}

	public inline function random(limit:Int):UInt {
		return randomUInt() % limit;
	}

	public inline function randomInt():Int {
		// var x: Int = randomUInt();
		// return x;
		return randomUInt();
	}

	public inline function randomFloat():Float {
		/*
		var a = randomUInt() >> 5;
		var b = randomUInt() >> 6;
		var a_: Float = a;
		var b_: Float = b;
		return (a_ * 67108864.0 + b_) * (1.0 / 9007199254740992.0);
		*/
		return ((randomUInt() >> 5) * 67108864.0 + (randomUInt() >> 6)) / 9007199254740992.0;
	}

	public inline function randomFloat32(): Float {
		/*
		var a = randomUInt();
		var a_: Float = a;
		return a_ / 4294967296.0;
		*/
		return randomUInt() / 4294967296.0;
	}
}
