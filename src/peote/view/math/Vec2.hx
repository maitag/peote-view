package peote.view.math;

import peote.view.PeoteGL;
import peote.view.PeoteGL.GLUniformLocation;

@:structInit
private class Vec2Impl implements peote.view.Uniform
{
	public var x:Float;
	public var y:Float;
	
	public inline function new (x:Float, y:Float) {
		this.x = x;
		this.y = y;
	}

	inline function glslType():String return "vec2";
	inline function updateGL(gl:PeoteGL, loc:GLUniformLocation) gl.uniform2f(loc, x, y);
}

/**
	Vector of two `Float` values `x` and `y`.
	```
	// constructing
	var a = new Vec2(2, 3.14);
	var b:Vec2 = { x:3, y:4 };
	var c:Vec2 = [ 1, 3.14 ];
	
	// access values
	trace(a.y); // 3.14
	a.x = 42;

	trace( b.length ); // 5
	```
	`.length` calculates the current vector-length (same by casting the vector to a `Float`).  
	###Operations:
	`+`, `-` between two vectors results in a new `Vec2`, while `*` (dot product) results in a `Float`.  
	`*` and `/` between a `Vec2` and a `Float` results in a new (stretched or compressed) `Vec2`.  
	###Comparing vectors:
	`>`, `<`, `>=`, `<=` results into comparing the lengths of the vectors.  
	`a.isEqual(b)` can be used to compare two vectors `a` and `b` for value-equality.  
**/
@:forward
abstract Vec2(Vec2Impl) from Vec2Impl to Vec2Impl
{
	/**
		Creates a new `Vec2` instance.
		@param x `Float` 
		@param y `Float` 
	**/
	public inline function new (x:Float, y:Float) this = new Vec2Impl(x, y);

	public var x(get,set):Float;  function get_x() return this.x; inline function set_x(v) return this.x=v;
	public var y(get,set):Float;  function get_y() return this.y; inline function set_y(v) return this.y=v;

	/**	Gets the current vector-length **/
	public var length(get, never):Float; inline function get_length():Float return Math.sqrt(x*x + y*y);

	/** Compare this to another vector of equality.
		@param v `Vec2` **/
	public inline function isEqual(v:Vec2):Bool return x==v.x && y==v.y;

	/**	A new vector instance with the same values. **/
	public var copy(get, never):Vec2; inline function get_copy():Vec2 return new Vec2(x, y);

	/**	Copyes the values of another inside this vector and returns its reference. **/
	public inline function copyFrom(v:Vec2):Vec2 { x=v.x; y=v.y; return this; };
	/**	Negates the values of this vector and returns its reference. **/
	public inline function negate():Vec2 { x=-x; y=-y; return this; }
	/**	Normalizes the values of this vector and returns its reference. **/
	public inline function normalize():Vec2 { var m=length; x=x/m; y=y/m; return this; }

	/**
		Calculates the cross product.
		@param v `Vec3` 
	**/
	// public inline function crossProduct(v:Vec3Impl):Vec3Impl return new Vec3Impl(y*v.z - z*v.y, z*v.x - x*v.z, x*v.y - y*v.x);

	// operate directly on the vector values and returns its reference.

	/** Adds the values of another vector to this vector. **/
	public function add(v:Vec2):Vec2 { x+=v.x; y+=v.y; return this; }
	/** Subtracts the values of another vector from this vector. **/
	public function subtract(v:Vec2):Vec2 { x-=v.x; y-=v.y; return this; }
	/** Multiplicates the values of this vector by a `Float` **/
	public function mul(f:Float):Vec2 { x*=f; y*=f; return this; }
	/** Divides the values of this vector by a `Float` **/
	public function div(f:Float):Vec2 { x/=f; y/=f; return this; }
	
	//  --------------- operator overloading -----------------

	// adding and subtracting two vectors-> returns Vec2
	@:op(A + B) inline function _add (v:Vec2):Vec2 return new Vec2(x+v.x, y+v.y);
	@:op(A - B) inline function _subtract(v:Vec2):Vec2 return new Vec2(x-v.x, y-v.y);
	
	@:commutative // multiply and divide a vector by a float -> returns Vec2
	@:op(A * B) inline function _mul(f:Float):Vec2 return new Vec2(x*f, y*f);
	@:op(A / B) inline function _div(f:Float):Vec2 return new Vec2(x/f, y/f);

	// dot product: multiply two vectors -> returns Float
	@:op(A * B) inline function dotProduct(v:Vec2):Float return x*v.x + y*v.y;
		
	// comparing vector to floats or vice versa (using vector length)
	@:op(A <  B) static inline function l_vf (v:Vec2, f:Float):Bool return v.length < f;
	@:op(A <  B) static inline function l_fv (f:Float, v:Vec2):Bool return f < v.length;
	@:op(A >  B) static inline function g_vf (v:Vec2, f:Float):Bool return v.length > f;
	@:op(A >  B) static inline function g_fv (f:Float, v:Vec2):Bool return f > v.length;
	@:op(A <= B) static inline function lt_vf(v:Vec2, f:Float):Bool return v.length <= f;
	@:op(A <= B) static inline function lt_fv(f:Float, v:Vec2):Bool return f <= v.length;
	@:op(A >= B) static inline function gt_vf(v:Vec2, f:Float):Bool return v.length >= f;
	@:op(A >= B) static inline function gt_fv(f:Float, v:Vec2):Bool return f >= v.length;


	@:to inline function toString():String return '[${x}, ${y}]';
	@:to inline function toFloat():Float return length;

	@:from static inline function fromFloatArray(a:Array<Float>):Vec2 {
		if (a.length != 2) throw("Error, wrong number of arguments.");
		return new Vec2(a[0], a[1]);
	}
	
	@:from static inline function fromIntArray(a:Array<Int>):Vec2 {
		if (a.length != 2) throw("Error, wrong number of arguments.");
		return new Vec2(a[0], a[1]);
	}

}
