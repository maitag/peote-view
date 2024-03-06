package peote.view.intern;

class IntUtil 
{
	
	public inline static var MAX_BITSIZE:Int = 16;
	
	// --------------- macro optimization -------------------
	
	public static macro function nextPowerOfTwo(i:haxe.macro.Expr, maxBitsize:Int = MAX_BITSIZE) {
		return macro {
			((
				if (($i:UInt) < 3) $i;
				else {
					var bitsize = IntUtil._bitsize(($i:UInt) - 1, $v{maxBitsize >> 1}, $v{maxBitsize >> 1});
					if (bitsize >= $v{maxBitsize})
						throw("Error calculating nextPowerOfTwo: reaching maxBitSize of " + $v{maxBitsize});
					1 << bitsize;
				}
			):UInt);
		}
	}
	
	public static macro function bitsize(i:haxe.macro.Expr, maxBitsize:Int = MAX_BITSIZE) {
		maxBitsize = maxBitsize >> 1;
		return macro (($i:UInt) < 3) ? ($i:UInt) : IntUtil._bitsize(($i:UInt), $v{maxBitsize}, $v{maxBitsize});
	}
	
	// how to make "private"? (no access from bitsize and _bitsize itself!)
	public static macro function _bitsize(i:haxe.macro.Expr, n:Int, delta:Int) {
		if (delta == 0)
			return macro throw('Error calculating intBitLength: ' + $i + ' has more bits than maxBitSize of ' + $v{MAX_BITSIZE});
		else {
			delta = delta >> 1;
			return macro {
				if ( ($i >> $v{n}) == 1 ) $v{n + 1};
				else if ( ($i >> $v{n}) < 1 ) IntUtil._bitsize($i, $v{n - delta}, $v{delta});
				else IntUtil._bitsize($i, $v{n + delta}, $v{delta});
			}
		}
	}	
	
	
	
	// --------------- no macro optimization -----------------------
	
	/*
	public static function nextPowerOfTwo(i:UInt, maxBitsize:Int = MAX_BITSIZE):UInt {
		if (i < 3) return i;
		else {
			var bitsize = _bitsize(i - 1, maxBitsize >> 1, maxBitsize >> 1);
			if (bitsize >= maxBitsize)
				throw('Error calculating nextPowerOfTwo: reaching maxBitSize of $maxBitsize');
			return 1 << bitsize;
		}
	}
	
	public static function bitsize(i:UInt, maxBitsize:Int = MAX_BITSIZE):Int {
		if (i < 3) return i;
		else {
			maxBitsize = maxBitsize >> 1;
			return _bitsize(i, maxBitsize, maxBitsize);
		}
	}
	
	
    static inline function _bitsize(i:UInt, n:Int, delta:Int):Int {
		if ((i >> n) == 1) return n + 1;
		else {
			delta = delta >> 1;
			if (delta == 0) throw('Error calculating intBitLength: $i has more bits than maxBitSize');
			else {
				if ( (i >> n) < 1 ) return _bitsize(i, n - delta, delta);
				else return _bitsize(i, n + delta, delta);
			}
		}
    }	
	
	*/
}
