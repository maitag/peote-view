package peote.view;
import peote.view.utils.Util;

abstract Color(Int) from Int to Int from UInt to UInt
{
	inline function new(rgba:Int) this = rgba;
	
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
	
	// set by Float values
	public inline function setAlpha(a:Float):Color { return (this & 0xffffff00) | Std.int(a*0xFF); }
	
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