package peote.view.utils;
import peote.view.PeoteGL;

@:allow(peote.view.Program)
abstract BlendMode(Int) from Int to Int
{
	public static inline var ZERO                    :Int = 0;
	public static inline var ONE                     :Int = 1;
	public static inline var SRC_COLOR               :Int = 2;
	public static inline var ONE_MINUS_SRC_COLOR     :Int = 3;
	public static inline var DST_COLOR               :Int = 4;
	public static inline var ONE_MINUS_DST_COLOR     :Int = 5;
	public static inline var SRC_ALPHA               :Int = 6;
	public static inline var ONE_MINUS_SRC_ALPHA     :Int = 7;
	public static inline var DST_ALPHA               :Int = 8;
	public static inline var ONE_MINUS_DST_ALPHA     :Int = 9;
	public static inline var SRC_ALPHA_SATURATE      :Int = 10;
	public static inline var CONSTANT_COLOR          :Int = 11;
	public static inline var ONE_MINUS_CONSTANT_COLOR:Int = 12;
	public static inline var CONSTANT_ALPHA          :Int = 13;
	public static inline var ONE_MINUS_CONSTANT_ALPHA:Int = 14;
	
	public function toGL(gl:PeoteGL):Int {
		return switch (this) {
			case ZERO: gl.ZERO;
			case ONE: gl.ONE;
			case SRC_COLOR: gl.SRC_COLOR;
			case ONE_MINUS_SRC_COLOR: gl.ONE_MINUS_SRC_COLOR;
			case DST_COLOR: gl.DST_COLOR;
			case ONE_MINUS_DST_COLOR: gl.ONE_MINUS_DST_COLOR;
			case SRC_ALPHA: gl.SRC_ALPHA;
			case ONE_MINUS_SRC_ALPHA: gl.ONE_MINUS_SRC_ALPHA;
			case DST_ALPHA: gl.DST_ALPHA;
			case ONE_MINUS_DST_ALPHA: gl.ONE_MINUS_DST_ALPHA;
			case SRC_ALPHA_SATURATE: gl.SRC_ALPHA_SATURATE;
			case CONSTANT_COLOR: gl.CONSTANT_COLOR;
			case ONE_MINUS_CONSTANT_COLOR: gl.ONE_MINUS_CONSTANT_COLOR;
			case CONSTANT_ALPHA: gl.CONSTANT_ALPHA;
			case ONE_MINUS_CONSTANT_ALPHA: gl.ONE_MINUS_CONSTANT_ALPHA;
			default: throw("Error, wrong gl-blendmode");
		}
	}
	
	static inline function getSrc      (v:Int):BlendMode return  v        & 0xF;
	static inline function getDest     (v:Int):BlendMode return (v >> 4 ) & 0xF;
	static inline function getSrcAlpha (v:Int):BlendMode return (v >> 8 ) & 0xF;
	static inline function getDestAlpha(v:Int):BlendMode return (v >> 12) & 0xF;
	
	inline function setSrc      (v:Int):Int return (v & 0xFFFFFFF0) | this;
	inline function setDest     (v:Int):Int return (v & 0xFFFFF0FF) | (this << 4 );
	inline function setSrcAlpha (v:Int):Int return (v & 0xFFFF0FFF) | (this << 8 );
	inline function setDestAlpha(v:Int):Int return (v & 0xFFF0FFFF) | (this << 12);
	
}