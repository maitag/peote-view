package peote.view;

import peote.view.intern.Util;

abstract Color(Int) from Int to Int from UInt to UInt
{
	public var r(get,set):Int;
	public var g(get,set):Int;
	public var b(get,set):Int;
	public var a(get, set):Int;
	
	public var rgb(get,set):Int;
	public var argb(get,set):Int;
	
	public var red(get,set):Int;
	public var green(get,set):Int;
	public var blue(get,set):Int;
	public var alpha(get,set):Int;

	public var luminance(get,set):Int;

	// getter
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

	// setter
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
	
	inline function get_luminance() return Math.round((r+g+b)/3);
	inline function set_luminance(lum:Int) { setRGB(lum, lum, lum); return lum; }

	// set multiple color channels by Integer values and also returns it
	public inline function setARGB (a:Int, r:Int, g:Int, b:Int):Color return this = ARGB(a, r, g, b);
	public inline function setRGBA (r:Int, g:Int, b:Int, a:Int):Color return this = RGBA(r, g, b, a);
	public inline function setRGB  (r:Int, g:Int, b:Int):Color return this = (this & 0x000000ff)|(r<<24)|(g<<16)|(b<<8);
	public inline function setLuminanceAlpha(lum:Int, a:Int):Color return setRGBA(lum, lum, lum, a);
	// set single color channels by Integer value and also returns it
	public inline function setRed  (r:Int):Color return this = (this & 0x00ffffff)|(r<<24);
	public inline function setGreen(g:Int):Color return this = (this & 0xff00ffff)|(g<<16);
	public inline function setBlue (b:Int):Color return this = (this & 0xffff00ff)|(b<<8);
	public inline function setAlpha(a:Int):Color return this = (this & 0xffffff00)|a;
	public inline function setLuminance(lum:Int):Color return setRGB(lum, lum, lum);
	
	// set multiple color channels by Float values and also returns it
	public inline function setFloatARGB (a:Float, r:Float, g:Float, b:Float):Color return this = FloatARGB(a, r, g, b);
	public inline function setFloatRGBA (r:Float, g:Float, b:Float, a:Float):Color return this = FloatRGBA(r, g, b, a);
	public inline function setFloatRGB  (r:Float, g:Float, b:Float):Color return this = (this & 0x000000ff)|(Std.int(r*0xFF)<<24)|(Std.int(g*0xFF)<<16)|(Std.int(b*0xFF)<<8);
	public inline function setFloatLuminanceAlpha(lum:Float, a:Float):Color return setFloatRGBA(lum, lum, lum, a);
	// set single color channels by Float value and also returns it
	public inline function setFloatRed  (r:Float):Color return this = (this & 0x00ffffff) | (Std.int(r*0xFF)<<24);
	public inline function setFloatGreen(g:Float):Color return this = (this & 0xff00ffff) | (Std.int(g*0xFF)<<16);
	public inline function setFloatBlue (b:Float):Color return this = (this & 0xffff00ff) | (Std.int(b*0xFF)<<8);
	public inline function setFloatAlpha(a:Float):Color return this = (this & 0xffffff00) | Std.int(a*0xFF);
	public inline function setFloatLuminance(lum:Float):Color return setFloatRGB(lum, lum, lum);
	

	// ------------ static functions to create new Colors ------------

	// create multiple color channels by Integer values
	public static inline function ARGB (a:Int, r:Int, g:Int, b:Int):Color return (a<<24)|(r<<16)|(g<<8)|b;
	public static inline function RGBA (r:Int, g:Int, b:Int, a:Int):Color return (r<<24)|(g<<16)|(b<<8)|a;
	public static inline function RGB  (r:Int, g:Int, b:Int):Color return (r<<24)|(g<<16)|(b<<8)|0xff;
	static inline function RG (r:Int, g:Int):Color return (r<<24)|(g<<16)|0xff;
	public static inline function LuminanceAlpha(lum:Int, a:Int):Color return RGBA(lum, lum, lum, a);
	// create single color channel by Integer value
	public static inline function Red  (r:Int):Color return (r<<24)|0xff;
	public static inline function Green(g:Int):Color return (g<<16)|0xff;
	public static inline function Blue (b:Int):Color return (b<<8)|0xff;
	public static inline function Alpha(a:Int):Color return a;
	public static inline function Luminance(lum:Int):Color return RGB(lum, lum, lum);


	// create multiple color channels by Float values
	public static inline function FloatARGB (a:Float, r:Float, g:Float, b:Float):Color return (Std.int(a*0xFF)<<24)|(Std.int(r*0xFF)<<16)|(Std.int(g*0xFF)<<8)|Std.int(b*0xFF);
	public static inline function FloatRGBA (r:Float, g:Float, b:Float, a:Float):Color return (Std.int(r*0xFF)<<24)|(Std.int(g*0xFF)<<16)|(Std.int(b*0xFF)<<8)|Std.int(a*0xFF);
	public static inline function FloatRGB  (r:Float, g:Float, b:Float):Color return (Std.int(r*0xFF)<<24)|(Std.int(g*0xFF)<<16)|(Std.int(b*0xFF)<<8)|0xff;
	public static inline function FloatLuminanceAlpha(lum:Float, a:Float):Color return FloatRGBA(lum, lum, lum, a);
	// create single color channel by Float value
	public static inline function FloatRed  (r:Float):Color return (Std.int(r*0xFF)<<24)|0xff;
	public static inline function FloatGreen(g:Float):Color return (Std.int(g*0xFF)<<16)|0xff;
	public static inline function FloatBlue (b:Float):Color return (Std.int(b*0xFF)<<8)|0xff;
	public static inline function FloatAlpha(a:Float):Color return Std.int(a*0xFF);
	public static inline function FloatLuminance(lum:Float):Color return FloatRGB(lum, lum, lum);


	// random colors
	public static inline function random():Color {
		return (Std.int(Math.random()*256) << 24) | Std.random(0x1000000);
	}
	
	public inline function randomize() {
		this = random();
	}

	public inline function toGLSL():String {
	//public inline function toGLSL(swizzle:String = ""):String {
		
		//TODO: swizzle out to other kind of vector
		
		return 'vec4(${Util.toFloatString(r/255)}, ${Util.toFloatString(g/255)},' + 
		           ' ${Util.toFloatString(b/255)}, ${Util.toFloatString(a/255)})';
	}
	
	                   // TODO: Int to Color ?
	public static inline var BLACK   :Color = 0x000000ff;
    public static inline var RED     :Color = 0xff0000ff;
    public static inline var GREEN   :Color = 0x00ff00ff;
    public static inline var YELLOW  :Color = 0xffff00ff;
    public static inline var BLUE    :Color = 0x0000ffff;
    public static inline var LIME    :Color = 0xccff00ff; // https://en.wikipedia.org/wiki/Lime_(color)
    public static inline var MAGENTA :Color = 0xff00ffff;
    public static inline var CYAN    :Color = 0x00ffffff;
    public static inline var WHITE   :Color = 0xffffffff;
    public static inline var GREY1   :Color = 0x222222ff;
    public static inline var GREY2   :Color = 0x444444ff;
    public static inline var GREY3   :Color = 0x666666ff;
    public static inline var GREY4   :Color = 0x888888ff;
    public static inline var GREY5   :Color = 0xaaaaaaff;
    public static inline var GREY6   :Color = 0xccccccff;
    public static inline var GREY7   :Color = 0xeeeeeeff;
}