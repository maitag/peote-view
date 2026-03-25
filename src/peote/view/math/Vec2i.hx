package peote.view.math;

import peote.view.PeoteGL;
import peote.view.PeoteGL.GLUniformLocation;

@:structInit
private class Vec2iImpl implements peote.view.Uniform
{
	public var x:Int;
	public var y:Int;
	
	public inline function new (x:Int, y:Int) {
		this.x = x;
		this.y = y;
	}

	inline function glslType():String return "ivec2";
	inline function updateGL(gl:PeoteGL, loc:GLUniformLocation) gl.uniform2i(loc, x, y);
}

/**
	Vector of two `Int` values `x` and `y`.
	```
	// constructing
	var a = new Vec2i(1, 2);
	var b:Vec2i = { x:3, y:4};
	var c:Vec2i = [ 1, 2 ];
	
	// access values
	trace(a.x); // 1
	a.y = 42;

	trace( b.length ); // 9
	```
	`.length` calculates the current vector-length (same by casting the vector to a `Float`).  
	###Operations:
	`+`, `-` between two vectors results in a new `Vec2i`, while `*` (dot product) results in a `Float`.  
	`*` and `/` between a `Vec2i` and a `Float` results in a new (stretched or compressed) `Vec2i`.  
	###Comparing vectors:
	`>`, `<`, `>=`, `<=` results into comparing the lengths of the vectors.  
	`a.isEqual(b)` can be used to compare two vectors `a` and `b` for value-equality.  
**/
@:forward
abstract Vec2i(Vec2iImpl) from Vec2iImpl to Vec2iImpl
{
	/**
		Creates a new `Vec2i` instance.
		@param x `Int`
		@param y `Int`
	**/
	public inline function new (x:Int, y:Int) this = new Vec2iImpl(x, y);

	public var x(get,set):Int;  function get_x() return this.x; inline function set_x(v) return this.x=v;
	public var y(get,set):Int;  function get_y() return this.y; inline function set_y(v) return this.y=v;

	/**	Gets the current vector-length **/
	public var length(get, never):Float; inline function get_length():Float return Math.sqrt(x*x + y*y);

	/** Compare this to another vector of equality.
		@param v `Vec2i` **/
	public inline function isEqual(v:Vec2i):Bool return x==v.x && y==v.y;

	/**	A new vector instance with the same values. **/
	public var copy(get, never):Vec2i; inline function get_copy():Vec2i return new Vec2i(x, y);

	/**	Copyes the values of another inside this vector and returns its reference. **/
	public inline function copyFrom(v:Vec2i):Vec2i { x=v.x; y=v.y; return this; };
	/**	Negates the values of this vector and returns its reference. **/
	public inline function negate():Vec2i { x=-x; y=-y; return this; }


	// operate directly on the vector values and returns its reference.

	/** Adds the values of another vector to this vector. **/
	public inline function add(v:Vec2i):Vec2i { x+=v.x; y+=v.y; return this; }
	/** Subtracts the values of another vector from this vector. **/
	public inline function subtract(v:Vec2i):Vec2i { x-=v.x; y-=v.y; return this; }
	/** Multiplicates the values of this vector by a `Float` **/
	public inline function mul(f:Float):Vec2i { x=Math.round(x*f); y=Math.round(y*f); return this; }
	/** Divides the values of this vector by a `Float` **/
	public inline function div(f:Float):Vec2i {  x=Math.round(x/f); y=Math.round(y/f); return this; }

	
	//  --------------- operator overloading -----------------

	// adding and subtracting two vectors-> returns Vec2i
	@:op(A + B) inline function _add(v:Vec2i):Vec2i return new Vec2i(x+v.x, y+v.y);
	@:op(A - B) inline function _subtract(v:Vec2i):Vec2i return new Vec2i(x-v.x, y-v.y);
	
	@:commutative // multiply and divide a vector by a float -> returns Vec2i
	@:op(A * B) inline function _mul(f:Float):Vec2i return new Vec2i(Math.round(x*f), Math.round(y*f));
	@:op(A / B) inline function _div(f:Float):Vec2i return new Vec2i(Math.round(x/f), Math.round(y/f));

	// dot product: multiply two vectors -> returns Float
	@:op(A * B) inline function dotProduct(v:Vec2i):Float return x*v.x + y*v.y;
		
	// comparing vector to floats or vice versa (using vector length)
	@:op(A <  B) static inline function l_vf (v:Vec2i, f:Float):Bool return v.length < f;
	@:op(A <  B) static inline function l_fv (f:Float, v:Vec2i):Bool return f < v.length;
	@:op(A >  B) static inline function g_vf (v:Vec2i, f:Float):Bool return v.length > f;
	@:op(A >  B) static inline function g_fv (f:Float, v:Vec2i):Bool return f > v.length;
	@:op(A <= B) static inline function lt_vf(v:Vec2i, f:Float):Bool return v.length <= f;
	@:op(A <= B) static inline function lt_fv(f:Float, v:Vec2i):Bool return f <= v.length;
	@:op(A >= B) static inline function gt_vf(v:Vec2i, f:Float):Bool return v.length >= f;
	@:op(A >= B) static inline function gt_fv(f:Float, v:Vec2i):Bool return f >= v.length;


	@:to inline function toString():String return '[${x}, ${y}]';
	@:to inline function toFloat():Float return length;
	
	@:from static inline function fromIntArray(a:Array<Int>):Vec2i {
		if (a.length != 2) throw("Error, wrong number of arguments.");
		return new Vec2i(a[0], a[1]);
	}

}
