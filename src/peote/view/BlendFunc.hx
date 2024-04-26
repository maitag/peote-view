package peote.view;

/**
	The set up the "blend" functions if a `Program` have `.blendEnabled`. 
**/
@:allow(peote.view.Program)
abstract BlendFunc(Int) from Int to Int
{
	public static inline var ADD             :Int = 0;
	public static inline var SUBTRACT        :Int = 1;
	public static inline var REVERSE_SUBTRACT:Int = 2;
	public static inline var MIN             :Int = 3;
	public static inline var MAX             :Int = 4;
	
	function toGL(gl:PeoteGL):Int {
		return switch (this) {
			case ADD: gl.FUNC_ADD;
			case SUBTRACT: gl.FUNC_SUBTRACT;
			case REVERSE_SUBTRACT: gl.FUNC_REVERSE_SUBTRACT;
			case MIN: gl.MIN;
			case MAX: gl.MAX;
			default: throw("Error, wrong gl-blendmode");
		}
	}
	
	static inline function getFunc     (v:Int):BlendFunc return (v >> 16 ) & 0xF;
	static inline function getFuncAlpha(v:Int):BlendFunc return (v >> 20 ) & 0xF;
	
	inline function setFunc     (v:Int):Int return (v & 0xFFF0FFFF) | (this << 16);
	inline function setFuncAlpha(v:Int):Int return (v & 0xFF0FFFFF) | (this << 20);
	
}