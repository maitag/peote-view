package peote.view;

/**
	Provides the mask values of how a `Program` is using or drawing into the stencil buffer.
**/
#if (haxe_ver >= 4.0) enum #else @:enum#end
abstract Mask(Int) from Int to Int  
{
	public static inline var OFF  :Int = 0;
	public static inline var USE  :Int = 1;
	public static inline var DRAW :Int = 2;
}