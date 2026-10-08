package peote.view.intern;

/**
	Static helper to generate glsl easing functions as a String.  
	Can be used inside `Program.setEaseFormula` e.g. like this: `Ease.In(SINE)`, `Ease.Out(QUAD)` or `Ease.InOut(CIRC, EXPO, 0.4)`.
**/
enum abstract Ease(Int) {
	var HERMITE;
	var SINE;
	var QUAD;
	var CUBIC;
	var QUART;
	var QUINT;
	var EXPO;
	var CIRC;
	var BACK;
	var ELASTIC;
	var BOUNCE;

	static inline function hermiteIn(t:String):String  return 'smoothstep(0.0, 1.0, $t*0.5)*2.0';
	static inline function hermiteOut(t:String):String return 'smoothstep(0.0, 1.0, 0.5+$t*0.5)*2.0-1.0';
	static inline var hermiteInOut = 'smoothstep(0.0, 1.0, t)'; // <- optimized

	static inline var PI = "3.14159265359";
	static inline function sineIn(t:String):String  return '1.0-cos(($t*$PI)/2.0)';
	static inline function sineOut(t:String):String return 'sin(($t*$PI)/2.0)';

	static inline function quadIn(t:String):String  return '$t*$t';
	static inline function quadOut(t:String):String return '1.0-(1.0-$t)*(1.0-$t)';

	static inline function cubicIn(t:String):String  return '$t*$t*$t';
	static inline function cubicOut(t:String):String return '1.0-pow(1.0-$t,3.0)';

	static inline function quartIn(t:String):String  return '$t*$t*$t*$t';
	static inline function quartOut(t:String):String return '1.0-pow(1.0-$t,4.0)';

	static inline function quintIn(t:String):String  return '$t*$t*$t*$t*$t';
	static inline function quintOut(t:String):String return '1.0-pow(1.0-$t,5.0)';

	static inline function expoIn(t:String):String  return '($t==0.0) ? 0.0 : pow(2.0,10.0* $t-10.0)';
	static inline function expoOut(t:String):String return '($t==1.0) ? 1.0 : 1.0-pow(2.0,-10.0*$t)';

	// static inline function circIn(t:String):String  return '1.0-sqrt(1.0-pow($t,2.0))';
	// static inline function circOut(t:String):String return 'sqrt(1.0-pow($t-1.0,2.0))';
	static inline function circIn(t:String):String  return '1.0-sqrt(1.0-pow(clamp($t,0.0,1.0),2.0))';
	static inline function circOut(t:String):String return 'sqrt(1.0-pow(clamp($t,0.0,1.0)-1.0,2.0))';

	static inline var C1 = "3.14159265359";
	static inline function backIn(t:String):String  return '($C1+1.0)*$t*$t*$t-$C1*$t*$t';
	static inline function backOut(t:String):String return '1.0+($C1+1.0)*pow($t-1.0,3.0)+$C1*pow($t-1.0,2.0)';

	static inline var PIPI = "6.28318530717";
	static inline function elasticIn(t:String):String  return 'clamp($t,0.0,1.0)*step(1.0,$t)+step(0.0,$t)*step($t,1.0)*(-pow(2.0,10.0*$t-10.0)*sin(($t*10.0-10.75)*($PIPI/3.0)))';
	static inline function elasticOut(t:String):String return 'clamp($t,0.0,1.0)*step(1.0,$t)+step(0.0,$t)*step($t,1.0)*(pow(2.0,-10.0*$t)*sin(($t*10.0-0.75)*($PIPI/3.0))+1.0)';
	
	static inline var PI35 = "10.9955742875";
	static inline function bounceIn(t:String):String  return 'step(1.0,$t)+step(0.0,$t)*step($t,1.0)*(pow(2.0,6.0*$t-6.0)*abs(cos((1.0-$t)*$PI35)))';
	static inline function bounceOut(t:String):String return 'step(1.0,$t)+step(0.0,$t)*step($t,1.0)*(1.0-pow(2.0,-6.0*$t)*abs(cos($t*$PI35)))';

	static inline function get(ease:Ease, i:Bool=true):String->String {
		return switch(ease) {
			case HERMITE:  i ? hermiteIn : hermiteOut;
			case SINE:  i ? sineIn : sineOut;
			case QUAD:  i ? quadIn : quadOut;
			case CUBIC: i ? cubicIn : cubicOut;
			case QUART: i ? quartIn : quartOut;
			case QUINT: i ? quintIn : quintOut;
			case EXPO:  i ? expoIn : expoOut;
			case CIRC:  i ? circIn : circOut;
			case BACK:  i ? backIn : backOut;
			case ELASTIC:  i ? elasticIn : elasticOut;
			case BOUNCE:  i ? bounceIn : bounceOut;
		}
	}

	static inline function scale(f:String->String, s:String):String {
		return "(" + f('t/$s') + ')*$s';
	} 

	static inline function scaleShift(f:String->String, s:String, shift:String):String {
		return "(" + f('(t-$shift)/$s') + ')*$s+$shift';
	} 

	// ------------------------------------------------------------------------

	/**
		Returns a String of an glsl ease-in function.
		@param ease easing function e.g. SINE, QUAD, etc.
	**/
	public static inline function In(ease:Ease):String return get(ease)("t");

	/**
		Returns a String of an glsl ease-out function.
		@param ease easing function e.g. SINE, QUAD, etc.
	**/
		public static inline function Out(ease:Ease):String return get(ease, false)("t");

	/**
		Returns a String of an glsl ease-in and ease-out function.
		@param easeIn  ease-in function e.g. SINE, QUAD, etc.
		@param easeOut ease-out function (optional, by default it is using same as easeIn here)
		@param switchAt a float value (default `0.5`) between `0.0`(full ease-out) and `1.0`(full ease-in) indicating the time at which the function switches between ease-in and ease-out
	**/
	public static inline function InOut(easeIn:Ease, ?easeOut:Ease, ?switchAt:Float):String {
		if (switchAt!=null) {
			// if (switchAt <= 0.0 || switchAt >= 1.0) throw('Error: switchAt parameter have to be greater then 0.0 and smaller then 1.0');
			var s = Util.toFloatString(switchAt);
			return 'mix(${ scaleShift(get((easeOut!=null) ? easeOut : easeIn, false), Util.toFloatString(1.0-switchAt), s) },${ scale(get(easeIn), s) },step(t, $s))';
		}
		else {
			if (easeIn == HERMITE && (easeOut == null || easeOut == HERMITE)) return hermiteInOut;
			return 'mix(${ scaleShift(get((easeOut!=null) ? easeOut : easeIn, false), "0.5", "0.5") },${ scale(get(easeIn), "0.5") },step(t, 0.5))';
		}
	}

	// here all again by annother parameter to let it ease in/out or inbetween to no-easing(linear) in addition
	/*
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
	*/
}