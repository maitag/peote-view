package peote.view.math;

import peote.view.PeoteGL;
import peote.view.PeoteGL.GLUniformLocation;

@:structInit
private class Vec4Impl implements peote.view.Uniform
{
	public var x:Float;
	public var y:Float;
	public var z:Float;
	public var w:Float;
	
	public inline function new (x:Float, y:Float, z:Float, w:Float) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	inline function glslType():String return "vec4";
	inline function updateGL(gl:PeoteGL, loc:GLUniformLocation) gl.uniform4f(loc, x, y, z, w);
}

/**
	Vector of four `Float` values `x`, `y`, `z` and `w`.
	```
	// constructing
	var a = new Vec4(1, 2, 3.0, 3.14);
	var b:Vec4 = { x:2, y:4, z:5, w:6 };
	var c:Vec4 = [ 1, 2, 3.0, 3.14 ];
	
	// access values
	trace(a.w); // 3.14
	a.y = 42;

	trace( b.length ); // 9
	```
	`.length` calculates the current vector-length (same by casting the vector to a `Float`).  
	###Operations:
	`+`, `-` between two vectors results in a new `Vec4`, while `*` (dot product) results in a `Float`.  
	`*` and `/` between a `Vec4` and a `Float` results in a new (stretched or compressed) `Vec4`.  
	###Comparing vectors:
	`>`, `<`, `>=`, `<=` results into comparing the lengths of the vectors.  
	`a.isEqual(b)` can be used to compare two vectors `a` and `b` for value-equality.  
**/
@:forward
abstract Vec4(Vec4Impl) from Vec4Impl to Vec4Impl
{
	/**
		Creates a new `Vec4` instance.
		@param x `Float`
		@param y `Float`
		@param z `Float`
		@param w `Float`
	**/
	public inline function new (x:Float, y:Float, z:Float, w:Float) this = new Vec4Impl(x, y, z, w);

	public var x(get,set):Float;  function get_x() return this.x; inline function set_x(v) return this.x=v;
	public var y(get,set):Float;  function get_y() return this.y; inline function set_y(v) return this.y=v;
	public var z(get,set):Float;  function get_z() return this.z; inline function set_z(v) return this.z=v;
	public var w(get,set):Float;  function get_w() return this.w; inline function set_w(v) return this.w=v;

	/**	Gets the current vector-length **/
	public var length(get, never):Float; inline function get_length():Float return Math.sqrt(x*x + y*y + z*z + w*w);

	/** Compare this to another vector of equality.
		@param v `Vec4` **/
	public inline function isEqual(v:Vec4):Bool return x==v.x && y==v.y && z==v.z && w==v.w;

	/**	A new vector instance with the same values. **/
	public var copy(get, never):Vec4; inline function get_copy():Vec4 return new Vec4(x, y, z, w);

	/**	Copyes the values of another inside this vector and returns its reference. **/
	public inline function copyFrom(v:Vec4):Vec4 { x=v.x; y=v.y; z=v.z; w=v.w; return this; };
	/**	Negates the values of this vector and returns its reference. **/
	public inline function negate():Vec4 { x=-x; y=-y; z=-z; w=-w; return this; }
	/**	Normalizes the values of this vector and returns its reference. **/
	public inline function normalize():Vec4 { var m=length; x=x/m; y=y/m; z=z/m; w=w/m; return this; }


	// operate directly on the vector values and returns its reference.

	/** Adds the values of another vector to this vector. **/
	public inline function add(v:Vec4):Vec4 { x+=v.x; y+=v.y; z+=v.z; w+=v.w; return this; }
	/** Subtracts the values of another vector from this vector. **/
	public inline function subtract(v:Vec4):Vec4 { x-=v.x; y-=v.y; z-=v.z; w-=v.w; return this; }
	/** Multiplicates the values of this vector by a `Float` **/
	public inline function mul(f:Float):Vec4 { x*=f; y*=f; z*=f; w*=f; return this; }
	/** Divides the values of this vector by a `Float` **/
	public inline function div(f:Float):Vec4 { x/=f; y/=f; z/=f; w/=f; return this; }

	
	//  --------------- operator overloading -----------------

	// adding and subtracting two vectors-> returns Vec4
	@:op(A + B) inline function _add(v:Vec4):Vec4 return new Vec4(x+v.x, y+v.y, z+v.z, w+v.w);
	@:op(A - B) inline function _subtract(v:Vec4):Vec4 return new Vec4(x-v.x, y-v.y, z-v.z, w-v.w);
	
	@:commutative // multiply and divide a vector by a float -> returns Vec4
	@:op(A * B) inline function _mul(f:Float):Vec4 return new Vec4(x*f, y*f, z*f, w*f);
	@:op(A / B) inline function _div(f:Float):Vec4 return new Vec4(x/f, y/f, z/f, w/f);

	// dot product: multiply two vectors -> returns Float
	@:op(A * B) inline function dotProduct(v:Vec4):Float return x*v.x + y*v.y + z*v.z + w*v.w;
		
	// comparing vector to floats or vice versa (using vector length)
	@:op(A <  B) static inline function l_vf (v:Vec4, f:Float):Bool return v.length < f;
	@:op(A <  B) static inline function l_fv (f:Float, v:Vec4):Bool return f < v.length;
	@:op(A >  B) static inline function g_vf (v:Vec4, f:Float):Bool return v.length > f;
	@:op(A >  B) static inline function g_fv (f:Float, v:Vec4):Bool return f > v.length;
	@:op(A <= B) static inline function lt_vf(v:Vec4, f:Float):Bool return v.length <= f;
	@:op(A <= B) static inline function lt_fv(f:Float, v:Vec4):Bool return f <= v.length;
	@:op(A >= B) static inline function gt_vf(v:Vec4, f:Float):Bool return v.length >= f;
	@:op(A >= B) static inline function gt_fv(f:Float, v:Vec4):Bool return f >= v.length;


	@:to inline function toString():String return '[${x}, ${y}, ${z}, ${w}]';
	@:to inline function toFloat():Float return length;

	@:from static inline function fromFloatArray(a:Array<Float>):Vec4 {
		if (a.length != 4) throw("Error, wrong number of arguments.");
		return new Vec4(a[0], a[1], a[2], a[3]);
	}
	
	@:from static inline function fromIntArray(a:Array<Int>):Vec4 {
		if (a.length != 4) throw("Error, wrong number of arguments.");
		return new Vec4(a[0], a[1], a[2], a[3]);
	}

}
