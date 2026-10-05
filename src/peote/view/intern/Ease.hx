package peote.view.intern;

enum abstract Ease(Int) {
	var SINE;
	var QUAD;
	var CUBIC;
	var QUART;
	var EXPO;
	var CIRC;
	var BACK;

	static inline var PI = "3.14159265359";
	static inline function sineIn(t:String):String  return '1.0 - cos(($t * $PI) / 2.0)';
	static inline function sineOut(t:String):String return 'sin(($t * $PI) / 2.0)';

	static inline function quadIn(t:String):String  return '$t * $t';
	static inline function quadOut(t:String):String return '1.0 - (1.0 - $t) * (1.0 - $t)';

	static inline function cubicIn(t:String):String  return '$t * $t * $t';
	static inline function cubicOut(t:String):String return '1.0 - pow(1.0 - $t, 3.0)';

	static inline function quartIn(t:String):String  return '$t * $t * $t * $t * $t';
	static inline function quartOut(t:String):String return '1.0 - pow(1.0 - $t, 5.0)';

	static inline function expoIn(t:String):String  return '($t == 0.0) ? 0.0 : pow(2.0, 10.0 * $t - 10.0)';
	static inline function expoOut(t:String):String return '($t == 1.0) ? 1.0 : 1.0 - pow(2.0, -10.0 * $t)';

	// static inline function circIn(t:String):String  return '1.0 - sqrt(1.0 - pow($t, 2.0))';
	// static inline function circOut(t:String):String return 'sqrt(1.0 - pow($t - 1.0, 2.0))';
	static inline function circIn(t:String):String  return '1.0 - sqrt(1.0 - pow(clamp($t,0.0,1.0), 2.0))';
	static inline function circOut(t:String):String return 'sqrt(1.0 - pow(clamp($t,0.0,1.0) - 1.0, 2.0))';

	static inline var C1 = "3.14159265359";
	static inline function backIn(t:String):String  return '($C1 + 1.0) * $t * $t * $t - $C1 * $t * $t';
	static inline function backOut(t:String):String return '1.0 + ($C1 + 1.0) * pow($t - 1.0, 3.0) + $C1 * pow($t - 1.0, 2.0)';

	static function get(ease:Ease, i=true):String->String {
		return switch(ease) {
			case SINE:  i ? sineIn : sineOut;
			case QUAD:  i ? quadIn : quadOut;
			case CUBIC: i ? cubicIn : cubicOut;
			case QUART: i ? quartIn : quartOut;
			case EXPO:  i ? expoIn : expoOut;
			case CIRC:  i ? circIn : circOut;
			case BACK:  i ? backIn : backOut;
		}
	}

	static inline function scale(f:String->String, s:String):String {
		return "(" + f('t/$s') + ')*$s';
	} 

	static inline function scaleShift(f:String->String, s:String, shift:String):String {
		return "(" + f('(t-$shift)/$s') + ')*$s+$shift';
	} 

	// ----------------------------------------

	public static function In(ease:Ease, s:Float = 1.0):String {
		var sIn = Util.toFloatString(s);
		if (s >= 1.0) return get(ease)("t");
		else return 'mix(t,${ scale(get(ease), sIn) }, step(t,$sIn))';
	}

	public static function Out(ease:Ease, s:Float = 1.0):String {
		var sOut0 = Util.toFloatString(s);
		var sOut1 = Util.toFloatString(1.0-s);
		if (s >= 1.0) return get(ease, false)("t");
		else return 'mix(${ scaleShift(get(ease, false), sOut0, sOut1) },t,step(t,$sOut1))';
	}

	public static function InOut(easeIn:Ease, ?scaleIn:Float, ?easeOut:Ease, ?scaleOut:Float):String {
		if (easeOut==null) easeOut = easeIn;
		if (scaleIn!=null && scaleOut!=null) {
			// if (scaleIn + scaleOut > 1.0) throw('Error: scaleIn + scaleOut have to be <= 1.0');
			var sIn = Util.toFloatString(scaleIn);
			var sOut0 = Util.toFloatString(scaleOut);
			var sOut1 = Util.toFloatString(1.0-scaleOut);
			return return 'mix(mix(${ scaleShift(get(easeOut, false), sOut0, sOut1) },t,step(t,$sOut1)),${ scale(get(easeIn), sIn) },step(t,$sIn))';
		}
		else if (scaleIn!=null) {
			var sIn = Util.toFloatString(scaleIn);
			var sOut0 = Util.toFloatString(1.0-scaleIn);
			var sOut1 = Util.toFloatString(scaleIn);
			return 'mix(${ scaleShift(get(easeOut, false), sOut0, sOut1) },${ scale(get(easeIn), sIn) },step(t, $sIn))';
		}
		else if (scaleOut!=null) {
			var sIn = Util.toFloatString(1.0-scaleOut);
			var sOut0 = Util.toFloatString(scaleOut);
			var sOut1 = Util.toFloatString(1.0-scaleOut);
			return 'mix(${ scaleShift(get(easeOut, false), sOut0, sOut1) },${ scale(get(easeIn), sIn) },step(t, $sIn))';
		}
		else return 'mix(${ scaleShift(get(easeOut, false), "0.5", "0.5") },${ scale(get(easeIn), "0.5") },step(t,0.5))';
	}

}