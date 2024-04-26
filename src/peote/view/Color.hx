package peote.view;

import peote.view.intern.Util;

/**
	Represents a color value what is stored inside a 32 bit integer.  
	The supported format is `RGBA`, so it uses one `Byte` per `red`, `green`, `blue` and `alpha` channel into order.
**/
abstract Color(Int) from Int to Int from UInt to UInt
{
	// colorchannels by Integer

	/**Red color component from 0 to 255**/
	public var r(get,set):Int;
	/**Green color component from 0 to 255**/
	public var g(get,set):Int;
	/**Blue color component from 0 to 255**/
	public var b(get,set):Int;
	/**Alpha component from 0 (full transparent) to 255 (opaque)**/
	public var a(get,set):Int;
	
	/**Get or set only the color channels into RGB byteorder**/
	public var rgb(get,set):Int;
	/**Get or set the color into ARGB byteorder**/
	public var argb(get,set):Int;
	
	/**Red color component from 0 to 255**/
	public var red(get,set):Int;
	/**Green color component from 0 to 255**/
	public var green(get,set):Int;
	/**Blue color component from 0 to 255**/
	public var blue(get,set):Int;
	/**Alpha component from 0 (full transparent) to 255 (opaque)**/
	public var alpha(get,set):Int;
	/**Luminance from 0 to 255, get: (r+g+b)/3, set: each color will set to this value**/
	public var luminance(get,set):Int;

	// colorchannels by Float

	/**Red color component from 0.0 to 1.0**/
	public var rF(get,set):Float;
	/**Green color component from 0.0 to 1.0**/
	public var gF(get,set):Float;
	/**Blue color component from 0.0 to 1.0**/
	public var bF(get,set):Float;
	/**Alpha component from 0.0 (full transparent) to 1.0 (opaque)**/
	public var aF(get,set):Float;

	/**Red color component from 0.0 to 1.0**/
	public var redF(get,set):Float;
	/**Green color component from 0.0 to 1.0**/
	public var greenF(get,set):Float;
	/**Blue color component from 0.0 to 1.0**/
	public var blueF(get,set):Float;
	/**Alpha component from 0.0 (full transparent) to 1.0 (opaque)**/
	public var alphaF(get,set):Float;
	/**Luminance from 0.0 to 1.0, get: (r+g+b)/3, set: each color will set to this value**/
	public var luminanceF(get,set):Float;

	// getter Integer
	inline function get_r() return (this >> 24) & 0xff;
	inline function get_g() return (this >> 16) & 0xff;
	inline function get_b() return (this >>  8) & 0xff;
	inline function get_a() return  this & 0xff;
	
	inline function get_rgb () return  this >> 8;
	inline function get_argb() return (this >> 8) | (a << 24);
	
	inline function get_red  () return get_r();
	inline function get_green() return get_g();
	inline function get_blue () return get_b();
	inline function get_alpha() return get_a();
	inline function get_luminance() return Math.round((r + g + b)/3);

	// getter Float
	inline function get_rF() return get_r() / 0xff;
	inline function get_gF() return get_g() / 0xff;
	inline function get_bF() return get_b() / 0xff;
	inline function get_aF() return get_a() / 0xff;

	inline function get_redF  () return get_rF();
	inline function get_greenF() return get_gF();
	inline function get_blueF () return get_bF();
	inline function get_alphaF() return get_aF();
	inline function get_luminanceF() return (rF + gF + bF)/3;

	// setter Integer
	inline function set_r(r:Int) { this = (this & 0x00ffffff) | (r<<24); return r; }
	inline function set_g(g:Int) { this = (this & 0xff00ffff) | (g<<16); return g; }
	inline function set_b(b:Int) { this = (this & 0xffff00ff) | (b<<8 ); return b; }
	inline function set_a(a:Int) { this = (this & 0xffffff00) | a; return a; }
	
	inline function set_rgb (rgb:Int)  { this = ( rgb << 8) | a; return rgb; }
	inline function set_argb(argb:Int) { this = (argb << 8) | (argb >> 24); return argb; }
	
	inline function set_red  (r:Int) return set_r(r);
	inline function set_green(g:Int) return set_g(g);
	inline function set_blue (b:Int) return set_b(b);
	inline function set_alpha(a:Int) return set_a(a);	
	inline function set_luminance(lum:Int) { setRGB(lum, lum, lum); return lum; }

	// setter Float
	inline function set_rF(r:Float) return set_r( Std.int(r * 0xff) );
	inline function set_gF(g:Float) return set_g( Std.int(g * 0xff) );
	inline function set_bF(b:Float) return set_b( Std.int(b * 0xff) );
	inline function set_aF(a:Float) return set_a( Std.int(a * 0xff) );

	inline function set_redF  (r:Float) return set_rF(r);
	inline function set_greenF(g:Float) return set_gF(g);
	inline function set_blueF (b:Float) return set_bF(b);
	inline function set_alphaF(a:Float) return set_aF(a);
	inline function set_luminanceF(lum:Float) { setFloatRGB(lum, lum, lum); return lum; }

	// ---------------------------------------------------------------
	// --------------------- Helper functions ------------------------
	// ---------------------------------------------------------------

	// set multiple color channels by integer values and return the resulting color

	/**
		Set multiple components by integers (0 to 255) and return the resulting color.
		@param a alpha
		@param r red
		@param g green
		@param b blue
	**/
	public inline function setARGB(a:Int, r:Int, g:Int, b:Int):Color return this = ARGB(a, r, g, b);

	/**
		Set multiple components by integers (0 to 255) and return the resulting color.
		@param r red
		@param g green
		@param b blue
		@param a alpha
	**/
	public inline function setRGBA(r:Int, g:Int, b:Int, a:Int):Color return this = RGBA(r, g, b, a);

	/**
		Set multiple components by integers (0 to 255) and return the resulting color.
		@param r red
		@param g green
		@param b blue
	**/
	public inline function setRGB(r:Int, g:Int, b:Int):Color return this = (this & 0x000000ff)|(r<<24)|(g<<16)|(b<<8);

	/**
		Set multiple components by integers (0 to 255) and return the resulting color.
		@param lum luminance
		@param a alpha
	**/
	public inline function setLuminanceAlpha(lum:Int, a:Int):Color return setRGBA(lum, lum, lum, a);


	// set single color channels by Integer value and also return the resulting color

	/**
		Set red color by integer (0 to 255) and return the resulting color.
		@param r red
	**/
	public inline function setRed(r:Int):Color return this = (this & 0x00ffffff)|(r<<24);

	/**
		Set green color by integer (0 to 255) and return the resulting color.
		@param g green
	**/
	public inline function setGreen(g:Int):Color return this = (this & 0xff00ffff)|(g<<16);

	/**
		Set blue color by integer (0 to 255) and return the resulting color.
		@param b blue
	**/
	public inline function setBlue(b:Int):Color return this = (this & 0xffff00ff)|(b<<8);

	/**
		Set alpha by integer (0 to 255) and return the resulting color.
		@param a alpha
	**/
	public inline function setAlpha(a:Int):Color return this = (this & 0xffffff00)|a;

	/**
		Set luminance by integer (0 to 255) and return the resulting color.
		@param lum luminance
	**/
	public inline function setLuminance(lum:Int):Color return setRGB(lum, lum, lum);


	// set multiple color channels by float values and return the resulting color

	/**
		Set multiple components by float values (0.0 to 1.0) and return the resulting color.
		@param a alpha
		@param r red
		@param g green
		@param b blue
	**/
	public inline function setFloatARGB(a:Float, r:Float, g:Float, b:Float):Color return this = FloatARGB(a, r, g, b);

	/**
		Set multiple components by float values (0.0 to 1.0) and return the resulting color.
		@param r red
		@param g green
		@param b blue
		@param a alpha
	**/
	public inline function setFloatRGBA(r:Float, g:Float, b:Float, a:Float):Color return this = FloatRGBA(r, g, b, a);

	/**
		Set multiple components by float values (0.0 to 1.0) and return the resulting color.
		@param r red
		@param g green
		@param b blue
	**/
	public inline function setFloatRGB(r:Float, g:Float, b:Float):Color return this = (this & 0x000000ff)|(Std.int(r*0xFF)<<24)|(Std.int(g*0xFF)<<16)|(Std.int(b*0xFF)<<8);

	/**
		Set multiple components by float values (0.0 to 1.0) and return the resulting color.
		@param lum luminance
		@param a alpha
	**/
	public inline function setFloatLuminanceAlpha(lum:Float, a:Float):Color return setFloatRGBA(lum, lum, lum, a);


	// set single color channels by float value and returns the resulting color

	/**
		Set red color by float value (0.0 to 1.0) and return the resulting color.
		@param r red
	**/
	public inline function setFloatRed(r:Float):Color return this = (this & 0x00ffffff) | (Std.int(r*0xFF)<<24);

	/**
		Set green color by float value (0.0 to 1.0) and return the resulting color.
		@param g green
	**/
	public inline function setFloatGreen(g:Float):Color return this = (this & 0xff00ffff) | (Std.int(g*0xFF)<<16);

	/**
		Set blue color by float value (0.0 to 1.0) and return the resulting color.
		@param b blue
	**/
	public inline function setFloatBlue(b:Float):Color return this = (this & 0xffff00ff) | (Std.int(b*0xFF)<<8);

	/**
		Set alpha by float value (0.0 to 1.0) and return the resulting color.
		@param a alpha
	**/
	public inline function setFloatAlpha(a:Float):Color return this = (this & 0xffffff00) | Std.int(a*0xFF);

	/**
		Set luminance by float value (0.0 to 1.0) and return the resulting color.
		@param lum luminance
	**/
	public inline function setFloatLuminance(lum:Float):Color return setFloatRGB(lum, lum, lum);


	// ---------------------------------------------------------------
	// ------------ static functions to create new Colors ------------
	// ---------------------------------------------------------------

	// create multiple color channels by Integer values

	/**
		Create a new color by integers (0 to 255).
		@param a alpha
		@param r red
		@param g green
		@param b blue
	**/
	public static inline function ARGB(a:Int, r:Int, g:Int, b:Int):Color return (a<<24)|(r<<16)|(g<<8)|b;

	/**
		Create a new color by integers (0 to 255).
		@param r red
		@param g green
		@param b blue
		@param a alpha
	**/
	public static inline function RGBA(r:Int, g:Int, b:Int, a:Int):Color return (r<<24)|(g<<16)|(b<<8)|a;

	/**
		Create a new color by integers (0 to 255).
		@param r red
		@param g green
		@param b blue
	**/
	public static inline function RGB(r:Int, g:Int, b:Int):Color return (r<<24)|(g<<16)|(b<<8)|0xff;

	static inline function RG(r:Int, g:Int):Color return (r<<24)|(g<<16)|0xff;


	/**
		Create a new color by integers (0 to 255).
		@param lum luminance
		@param a alpha
	**/
	public static inline function LuminanceAlpha(lum:Int, a:Int):Color return RGBA(lum, lum, lum, a);


	// create single color channel by Integer value (other channels will be zero and alpha to full, so no transparency)

	/**
		Create a new color by set the red value as integer (0 to 255).
		@param r red
	**/
	public static inline function Red(r:Int):Color return (r<<24)|0xff;

	/**
		Create a new color by set the green value as integer (0 to 255).
		@param g green
	**/
	public static inline function Green(g:Int):Color return (g<<16)|0xff;

	/**
		Create a new color by set the blue value as integer (0 to 255).
		@param b blue
	**/
	public static inline function Blue(b:Int):Color return (b<<8)|0xff;

	/**
		Create a new color by set the alpha value as integer (0 to 255).
		@param a alpha
	**/
	public static inline function Alpha(a:Int):Color return a;

	/**
		Create a new color by set the luminance value as integer (0 to 255).
		@param lum luminance
	**/
	public static inline function Luminance(lum:Int):Color return RGB(lum, lum, lum);


	// create multiple color channels by Float values

	/**
		Create a new color by float values (0.0 to 1.0).
		@param a alpha
		@param r red
		@param g green
		@param b blue
	**/
	public static inline function FloatARGB(a:Float, r:Float, g:Float, b:Float):Color return (Std.int(a*0xFF)<<24)|(Std.int(r*0xFF)<<16)|(Std.int(g*0xFF)<<8)|Std.int(b*0xFF);

	/**
		Create a new color by float values (0.0 to 1.0).
		@param r red
		@param g green
		@param b blue
		@param a alpha
	**/
	public static inline function FloatRGBA(r:Float, g:Float, b:Float, a:Float):Color return (Std.int(r*0xFF)<<24)|(Std.int(g*0xFF)<<16)|(Std.int(b*0xFF)<<8)|Std.int(a*0xFF);

	/**
		Create a new color by float values (0.0 to 1.0).
		@param r red
		@param g green
		@param b blue
	**/
	public static inline function FloatRGB(r:Float, g:Float, b:Float):Color return (Std.int(r*0xFF)<<24)|(Std.int(g*0xFF)<<16)|(Std.int(b*0xFF)<<8)|0xff;

	/**
		Create a new color by float values (0.0 to 1.0).
		@param lum luminance
		@param a alpha
	**/
	public static inline function FloatLuminanceAlpha(lum:Float, a:Float):Color return FloatRGBA(lum, lum, lum, a);


	// create single color channel by Float value (other channels will be zero and alpha to full, so no transparency)

	/**
		Create a new color by set the red value as float (0.0 to 1.0).
		@param r red
	**/
	public static inline function FloatRed(r:Float):Color return (Std.int(r*0xFF)<<24)|0xff;

	/**
		Create a new color by set the green value as float (0.0 to 1.0).
		@param g green
	**/
	public static inline function FloatGreen(g:Float):Color return (Std.int(g*0xFF)<<16)|0xff;

	/**
		Create a new color by set the blue value as float (0.0 to 1.0).
		@param b blue
	**/
	public static inline function FloatBlue(b:Float):Color return (Std.int(b*0xFF)<<8)|0xff;

	/**
		Create a new color by set the alpha value as float (0.0 to 1.0).
		@param a alpha
	**/
	public static inline function FloatAlpha(a:Float):Color return Std.int(a*0xFF);

	/**
		Create a new color by set the luminance value as float (0.0 to 1.0).
		@param lum luminance
	**/
	public static inline function FloatLuminance(lum:Float):Color return FloatRGB(lum, lum, lum);


	// -------- create random colors ----------

	/**
		Create a random color.
		@param alpha to set a value for alpha (by default it is also randomized)
	**/
	public static inline function random(?alpha:Null<Int>):Color {
		return
			if (alpha == null) 
				(Std.int(Math.random()*256) << 24) | Std.random(0x1000000);
			else
				(Std.int(Math.random()*256) << 24) | (Std.random(0x10000) << 8) | alpha;
	}

	/**
		Set the color to a random value.
		@param alpha to set a value for alpha (by default it is also randomized)
	**/
	public inline function randomize(?alpha:Null<Int>) {
		this = random(alpha);
	}

	/**
		To create a string where the color is defined as `vec4(...)` to use inside of glsl-code.
	**/
	public inline function toGLSL():String {
		return 'vec4(${Util.toFloatString(r/255)}, ${Util.toFloatString(g/255)}, ${Util.toFloatString(b/255)}, ${Util.toFloatString(a/255)})';
	}


	public static inline var BLACK:Color = 0x000000ff;
	public static inline var WHITE:Color = 0xffffffff;

	public static inline var RED :Color = 0xff0000ff;
	public static inline var RED1:Color = 0x3f0000ff;
	public static inline var RED2:Color = 0x7f0000ff;
	public static inline var RED3:Color = 0xbf0000ff;

	public static inline var GREEN:Color  = 0x00ff00ff;
	public static inline var GREEN1:Color = 0x003f00ff;
	public static inline var GREEN2:Color = 0x007f00ff;
	public static inline var GREEN3:Color = 0x00bf00ff;

	public static inline var BLUE :Color = 0x0000ffff;
	public static inline var BLUE1:Color = 0x00003fff;
	public static inline var BLUE2:Color = 0x00007fff;
	public static inline var BLUE3:Color = 0x0000bfff;

	public static inline var YELLOW :Color = 0xffff00ff;
	public static inline var MAGENTA:Color = 0xff00ffff;
	public static inline var CYAN   :Color = 0x00ffffff;

	public static inline var GREY1:Color = 0x222222ff;
	public static inline var GREY2:Color = 0x444444ff;
	public static inline var GREY3:Color = 0x666666ff;
	public static inline var GREY4:Color = 0x888888ff;
	public static inline var GREY5:Color = 0xaaaaaaff;
	public static inline var GREY6:Color = 0xccccccff;
	public static inline var GREY7:Color = 0xeeeeeeff;

	public static inline var GOLD:Color = 0xffd700ff;
	public static inline var ORANGE:Color = 0xffa500ff;
	public static inline var LIME:Color = 0xccff00ff; // https://en.wikipedia.org/wiki/Lime_(color)
}