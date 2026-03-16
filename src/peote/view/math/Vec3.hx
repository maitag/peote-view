package peote.view.math;

import peote.view.PeoteGL;
import peote.view.PeoteGL.GLUniformLocation;

@:structInit
private class Vec3Impl implements peote.view.Uniform
{
	public var x:Float;
	public var y:Float;
	public var z:Float;
	
	public inline function new (x:Float, y:Float, z:Float) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	inline function glslType():String return "vec3";
	inline function updateGL(gl:PeoteGL, loc:GLUniformLocation) gl.uniform3f(loc, x, y, z);
}

/**
	Vector of three `Float` values `x`, `y` and `z`.
	```
	// constructing
	var a = new Vec3(1, 2, 3.14);
	var b:Vec3 = { x:1, y:2, z:2 };
	var c:Vec3 = [ 1, 2, 3.14 ];
	
	// access values
	trace(a.z); // 3.14
	a.y = 42;

	trace( b.length ); // 3
	```
	`.length` calculates the current vector-length (same by casting the vector to a `Float`).  
	###Operations:
	`+`, `-` between two vectors results in a new `Vec3`, while `*` (dot product) results in a `Float`.  
	`*` and `/` between a `Vec3` and a `Float` results in a new (stretched or compressed) `Vec3`.  
	###Comparing vectors:
	`>`, `<`, `>=`, `<=` results into comparing the lengths of the vectors.  
	`a.isEqual(b)` can be used to compare two vectors `a` and `b` for value-equality.  
**/
@:forward
abstract Vec3(Vec3Impl) from Vec3Impl to Vec3Impl
{
	/**
		Creates a new `Vec3` instance.
		@param x `Float`
		@param y `Float`
		@param z `Float`
	**/
	public inline function new (x:Float, y:Float, z:Float) this = new Vec3Impl(x, y, z);

	public var x(get,set):Float;  function get_x() return this.x; inline function set_x(v) return this.x=v;
	public var y(get,set):Float;  function get_y() return this.y; inline function set_y(v) return this.y=v;
	public var z(get,set):Float;  function get_z() return this.z; inline function set_z(v) return this.z=v;

	/**	Gets the current vector-length **/
	public var length(get, never):Float; inline function get_length():Float return Math.sqrt(x*x + y*y + z*z);

	/** Compare this to another vector of equality.
		@param v `Vec3` **/
	public inline function isEqual(v:Vec3):Bool return x==v.x && y==v.y && z==v.z;

	/**	A new vector instance with the same values. **/
	public var copy(get, never):Vec3; inline function get_copy():Vec3 return new Vec3(x, y, z);

	/**	Copyes the values of another inside this vector and returns its reference. **/
	public inline function copyFrom(v:Vec3):Vec3 { x=v.x; y=v.y; z=v.z; return this; };
	/**	Negates the values of this vector and returns its reference. **/
	public inline function negate():Vec3 { x=-x; y=-y; z=-z; return this; }
	/**	Normalizes the values of this vector and returns its reference. **/
	public inline function normalize():Vec3 { var m=length; x=x/m; y=y/m; z=z/m; return this; }


	// operate directly on the vector values and returns its reference.

	/** Calculates the cross product.
		@param v `Vec3` **/
	public inline function crossProduct(v:Vec3):Vec3 return new Vec3(y*v.z - z*v.y, z*v.x - x*v.z, x*v.y - y*v.x);

	/** Adds the values of another vector to this vector. **/
	public inline function add(v:Vec3):Vec3 { x+=v.x; y+=v.y; z+=v.z; return this; }
	/** Subtracts the values of another vector from this vector. **/
	public inline function subtract(v:Vec3):Vec3 { x-=v.x; y-=v.y; z-=v.z; return this; }
	/** Multiplicates the values of this vector by a `Float` **/
	public inline function mul(f:Float):Vec3 { x*=f; y*=f; z*=f; return this; }
	/** Divides the values of this vector by a `Float` **/
	public inline function div(f:Float):Vec3 { x/=f; y/=f; z/=f; return this; }

	
	//  --------------- operator overloading -----------------

	// adding and subtracting two vectors-> returns Vec3
	@:op(A + B) inline function _add(v:Vec3):Vec3 return new Vec3(x+v.x, y+v.y, z+v.z);
	@:op(A - B) inline function _subtract(v:Vec3):Vec3 return new Vec3(x-v.x, y-v.y, z-v.z);
	
	@:commutative // multiply and divide a vector by a float -> returns Vec3
	@:op(A * B) inline function _mul(f:Float):Vec3 return new Vec3(x*f, y*f, z*f);
	@:op(A / B) inline function _div(f:Float):Vec3 return new Vec3(x/f, y/f, z/f);

	// dot product: multiply two vectors -> returns Float
	@:op(A * B) inline function dotProduct(v:Vec3):Float return x*v.x + y*v.y + z*v.z;
		
	// comparing vector to floats or vice versa (using vector length)
	@:op(A <  B) static inline function l_vf (v:Vec3, f:Float):Bool return v.length < f;
	@:op(A <  B) static inline function l_fv (f:Float, v:Vec3):Bool return f < v.length;
	@:op(A >  B) static inline function g_vf (v:Vec3, f:Float):Bool return v.length > f;
	@:op(A >  B) static inline function g_fv (f:Float, v:Vec3):Bool return f > v.length;
	@:op(A <= B) static inline function lt_vf(v:Vec3, f:Float):Bool return v.length <= f;
	@:op(A <= B) static inline function lt_fv(f:Float, v:Vec3):Bool return f <= v.length;
	@:op(A >= B) static inline function gt_vf(v:Vec3, f:Float):Bool return v.length >= f;
	@:op(A >= B) static inline function gt_fv(f:Float, v:Vec3):Bool return f >= v.length;


	@:to inline function toString():String return '[${x}, ${y}, ${z}]';
	@:to inline function toFloat():Float return length;

	@:from static inline function fromFloatArray(a:Array<Float>):Vec3 {
		if (a.length != 3) throw("Error, wrong number of arguments.");
		return new Vec3(a[0], a[1], a[2]);
	}
	
	@:from static inline function fromIntArray(a:Array<Int>):Vec3 {
		if (a.length != 3) throw("Error, wrong number of arguments.");
		return new Vec3(a[0], a[1], a[2]);
	}

}
