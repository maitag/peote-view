package peote.view;

/**
	To set up the "depth" functions if a `Program` has `.zIndexEnabled`. 
**/
@:allow(peote.view.PeoteView)
abstract DepthFunc(Int) from Int to Int
{
	public static inline var NEVER        :Int = 0;
	public static inline var LESS         :Int = 1;
	public static inline var LESS_EQUAL   :Int = 2;
	public static inline var GREATER      :Int = 3;
	public static inline var NOTEQUAL     :Int = 4;
	public static inline var GREATER_EQUAL:Int = 5;
	public static inline var ALWAYS       :Int = 6;
	
	function toGL(gl:PeoteGL):Int {
		return switch (this) {
			case NEVER:         gl.NEVER;
			case LESS:          gl.LESS;
			case LESS_EQUAL:    gl.LEQUAL;
			case GREATER:       gl.GREATER;
			case NOTEQUAL:      gl.NOTEQUAL;
			case GREATER_EQUAL: gl.GEQUAL;
			case ALWAYS:        gl.ALWAYS;
			default: throw("Error, wrong gl-depthFunc");
		}
	}
}