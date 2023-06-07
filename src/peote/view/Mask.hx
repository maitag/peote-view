package peote.view;

#if (haxe_ver >= 4.0) enum #else @:enum#end
abstract Mask(Int) from Int to Int  
{
	public static inline var OFF  :Int = 0;
	public static inline var USE  :Int = 1;
	public static inline var DRAW :Int = 2;
}