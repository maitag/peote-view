package peote.view;

#if (haxe_ver >= 4.0) enum #else @:enum#end
abstract TextureFormat(Int) from Int to Int  
{
	// ES 2.0: https://docs.gl/es2/glTexImage2D
	public static inline var LUMINANCE:Int = 0;
	public static inline var ALPHA:Int = 1;
	public static inline var LUMINANCE_ALPHA:Int = 2;

	public static inline var RGBA:Int = 3;
	public static inline var RGB:Int = 4;

	// ES 3.0: https://docs.gl/es3/glTexImage2D
	public static inline var RG:Int = 5;
	public static inline var R:Int = 6;
	
	public static inline var FLOAT_RGBA:Int = 7;
	public static inline var FLOAT_RGB:Int = 8;
	public static inline var FLOAT_RG:Int = 9;
	public static inline var FLOAT_R:Int = 10;


	public inline function isFloat():Bool return (this > 6);

	public inline function intern(gl:PeoteGL):Int {
		return switch(this) {
			case LUMINANCE       : gl.LUMINANCE;
			case ALPHA           : gl.ALPHA;
			case LUMINANCE_ALPHA : gl.LUMINANCE_ALPHA;

			case RGBA : gl.RGBA;
			case RGB  : gl.RGB;

			case RG : gl.RG8;
			case R  : gl.R8;

			case FLOAT_RGBA : gl.RGBA32F;
			case FLOAT_RGB  : gl.RGB32F;
			case FLOAT_RG   : gl.RG32F;
			case FLOAT_R    : gl.R32F;
			
			default: gl.RGBA;
		}
	}

	public inline function format(gl:PeoteGL):Int {
		return switch(this) {
			case LUMINANCE       : gl.LUMINANCE;
			case ALPHA           : gl.ALPHA;
			case LUMINANCE_ALPHA : gl.LUMINANCE_ALPHA;

			case RGBA : gl.RGBA;
			case RGB  : gl.RGB;

			case RG : gl.RG;
			case R  : gl.RED;

			case FLOAT_RGBA : gl.RGBA;
			case FLOAT_RGB  : gl.RGB;
			case FLOAT_RG   : gl.RG;
			case FLOAT_R    : gl.RED;

			default: gl.RGBA;
		}
	}
}
