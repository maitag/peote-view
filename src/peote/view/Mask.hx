package peote.view;

@:enum abstract Mask(Int) from Int to Int  
{
	public static inline var OFF  :Int = 0;
	public static inline var USE  :Int = 1;
	public static inline var DRAW :Int = 2;
}