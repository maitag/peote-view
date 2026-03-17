package peote.view.math;

import peote.view.PeoteGL;
import peote.view.PeoteGL.GLUniformLocation;

@:structInit
private class Vec3iImpl implements peote.view.Uniform
{
	public var x:Int;
	public var y:Int;
	public var z:Int;
	
	public inline function new (x:Int, y:Int, z:Int) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	inline function glslType():String return "ivec3";
	inline function updateGL(gl:PeoteGL, loc:GLUniformLocation) gl.uniform3i(loc, x, y, z);
}

/**
	Vector of four `Int` values `x`, `y` and `z`.
	```
	// constructing
	var a = new Vec3i(1, 2, 3);
	var b:Vec3i = { x:1, y:2, z:2 };
	var c:Vec3i = [ 1, 2, 3 ];
	
	// access values
	trace(a.z); // 3
	a.y = 42;

	trace( b.length ); // 3
	```
	`.length` calculates the current vector-length (same by casting the vector to a `Float`).  
	###Operations:
	`+`, `-` between two vectors results in a new `Vec3i`, while `*` (dot product) results in a `Float`.  
	`*` and `/` between a `Vec3i` and a `Float` results in a new (stretched or compressed) `Vec3i`.  
	###Comparing vectors:
	`>`, `<`, `>=`, `<=` results into comparing the lengths of the vectors.  
	`a.isEqual(b)` can be used to compare two vectors `a` and `b` for value-equality.  
**/
@:forward
abstract Vec3i(Vec3iImpl) from Vec3iImpl to Vec3iImpl
{
	/**
		Creates a new `Vec3i` instance.
		@param x `Int`
		@param y `Int`
		@param z `Int`
	**/
	public inline function new (x:Int, y:Int, z:Int) this = new Vec3iImpl(x, y, z);

	public var x(get,set):Int;  function get_x() return this.x; inline function set_x(v) return this.x=v;
	public var y(get,set):Int;  function get_y() return this.y; inline function set_y(v) return this.y=v;
	public var z(get,set):Int;  function get_z() return this.z; inline function set_z(v) return this.z=v;

	/**	Gets the current vector-length **/
	public var length(get, never):Float; inline function get_length():Float return Math.sqrt(x*x + y*y + z*z);

	/** Compare this to another vector of equality.
		@param v `Vec3i` **/
	public inline function isEqual(v:Vec3i):Bool return x==v.x && y==v.y && z==v.z;

	/**	A new vector instance with the same values. **/
	public var copy(get, never):Vec3i; inline function get_copy():Vec3i return new Vec3i(x, y, z);

	/**	Copyes the values of another inside this vector and returns its reference. **/
	public inline function copyFrom(v:Vec3i):Vec3i { x=v.x; y=v.y; z=v.z; return this; };
	/**	Negates the values of this vector and returns its reference. **/
	public inline function negate():Vec3i { x=-x; y=-y; z=-z; return this; }


	// operate directly on the vector values and returns its reference.

	/** Adds the values of another vector to this vector. **/
	public inline function add(v:Vec3i):Vec3i { x+=v.x; y+=v.y; z+=v.z; return this; }
	/** Subtracts the values of another vector from this vector. **/
	public inline function subtract(v:Vec3i):Vec3i { x-=v.x; y-=v.y; z-=v.z; return this; }
	/** Multiplicates the values of this vector by a `Float` **/
	public inline function mul(f:Float):Vec3i { x=Math.round(x*f); y=Math.round(y*f); z=Math.round(z*f); return this; }
	/** Divides the values of this vector by a `Float` **/
	public inline function div(f:Float):Vec3i {  x=Math.round(x/f); y=Math.round(y/f); z=Math.round(z/f); return this; }

	
	//  --------------- operator overloading -----------------

	// adding and subtracting two vectors-> returns Vec3i
	@:op(A + B) inline function _add(v:Vec3i):Vec3i return new Vec3i(x+v.x, y+v.y, z+v.z);
	@:op(A - B) inline function _subtract(v:Vec3i):Vec3i return new Vec3i(x-v.x, y-v.y, z-v.z);
	
	@:commutative // multiply and divide a vector by a float -> returns Vec3i
	@:op(A * B) inline function _mul(f:Float):Vec3i return new Vec3i(Math.round(x*f), Math.round(y*f), Math.round(z*f));
	@:op(A / B) inline function _div(f:Float):Vec3i return new Vec3i(Math.round(x/f), Math.round(y/f), Math.round(z/f));

	// dot product: multiply two vectors -> returns Float
	@:op(A * B) inline function dotProduct(v:Vec3i):Float return x*v.x + y*v.y + z*v.z;
		
	// comparing vector to floats or vice versa (using vector length)
	@:op(A <  B) static inline function l_vf (v:Vec3i, f:Float):Bool return v.length < f;
	@:op(A <  B) static inline function l_fv (f:Float, v:Vec3i):Bool return f < v.length;
	@:op(A >  B) static inline function g_vf (v:Vec3i, f:Float):Bool return v.length > f;
	@:op(A >  B) static inline function g_fv (f:Float, v:Vec3i):Bool return f > v.length;
	@:op(A <= B) static inline function lt_vf(v:Vec3i, f:Float):Bool return v.length <= f;
	@:op(A <= B) static inline function lt_fv(f:Float, v:Vec3i):Bool return f <= v.length;
	@:op(A >= B) static inline function gt_vf(v:Vec3i, f:Float):Bool return v.length >= f;
	@:op(A >= B) static inline function gt_fv(f:Float, v:Vec3i):Bool return f >= v.length;


	@:to inline function toString():String return '[${x}, ${y}, ${z}]';
	@:to inline function toFloat():Float return length;
	
	@:from static inline function fromIntArray(a:Array<Int>):Vec3i {
		if (a.length != 3) throw("Error, wrong number of arguments.");
		return new Vec3i(a[0], a[1], a[2]);
	}

}
