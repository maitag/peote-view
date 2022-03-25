package utils;

@:structInit
private class _Vec2 {
	public var x:Float;
	public var y:Float;
	
	public inline function new ( x:Float, y:Float ) {
		this.x = x;
		this.y = y;
	}

	// vector length
	public inline function length():Float return ( Math.sqrt(x*x + y*y) );	
}

@:forward
abstract Vec2(_Vec2) from _Vec2 to _Vec2 {
	inline public function new(x:Float, y:Float) this = new _Vec2(x, y);
	
	@:to public inline function toString():String return '[${this.x}, ${this.y}]';
	@:to public inline function toFloat():Float return this.length();

	//  --------------- operator overloading -----------------
	
	// adding and subtracting two vectors-> returns Vec2
	@:op(A + B) inline function sum(v:Vec2):Vec2 return { x:this.x + v.x, y: this.y + v.y };	
	@:op(A - B) inline function diff(v:Vec2):Vec2 return { x:this.x - v.x, y: this.y - v.y };	

	// multiply two vectors -> returns Float
	@:op(A * B) inline function mul(v:Vec2):Float return this.x * v.x + this.y * v.y;
	
	// multiply and divide a vector by a float -> returns Vec2
	@:commutative @:op(A * B) inline function mul_f(f:Float):Vec2 return { x: this.x * f, y: this.y * f };	
	@:op(A / B) inline function div_f(f:Float):Vec2 return { x: this.x / f, y: this.y / f };
	
	// comparing vector to floats or vice versa (using vector length)
	@:op(A <  B) static inline function l_vf (v:Vec2, f:Float):Bool return v.length() < f;
	@:op(A <  B) static inline function l_fv (f:Float, v:Vec2):Bool return f < v.length();
	@:op(A >  B) static inline function g_vf (v:Vec2, f:Float):Bool return v.length() > f;
	@:op(A >  B) static inline function g_fv (f:Float, v:Vec2):Bool return f > v.length();
	@:op(A <= B) static inline function lt_vf(v:Vec2, f:Float):Bool return v.length() <= f;
	@:op(A <= B) static inline function lt_fv(f:Float, v:Vec2):Bool return f <= v.length();
	@:op(A >= B) static inline function gt_vf(v:Vec2, f:Float):Bool return v.length() >= f;
	@:op(A >= B) static inline function gt_fv(f:Float, v:Vec2):Bool return f >= v.length();

	// compare the values of two vectors for equality
	public inline function isEqualTo   (v:Vec2):Bool return this.x == v.x && this.y == v.y;
	public inline function isNotEqualTo(v:Vec2):Bool return this.x != v.x || this.y != v.y;
	
	// comparing 2 vectors by it's references
	//@:op(A == B) inline function eq(v:Vec2):Bool return this == v;
	//@:op(A != B) inline function ne(v:Vec2):Bool return this != v;


	// comparing equality of a vector to a float (using vector length again)
	
	// TODO: would give problem if comparing with "null" (tipp by theangryepicbanana: "if it somehow does not work, add @:nullSafety(Strict)" )
	// try -> " @:notNull " first !
	//@:commutative @:op(A == B) inline function eq_f(f:Float):Bool return this.length() == f;	
	//@:commutative @:op(A != B) inline function ne_f(f:Float):Bool return this.length() != f;	
	
	
	// for testing
	static public function test() {
		var a:Vec2 = { x:1, y:1 }; // because of @:structInit
		var b:Vec2 = new Vec2( 2, 1 ); // this also works to initialize
		var c:Vec2 = new Vec2( 1, 2 );
		var d = new Vec2( 1, 2 ); // this also works to initialize
		
		trace('$a + $b = ${a + b}');
		trace('$a - $b = ${a - b}');
		trace('$a * $b = ${a * b}');
		
		trace('$b * 2.0 = ${b * 2.0}');
		trace('2.0 * $b = ${2.0 * b}');
		trace('$b / 2.0 = ${b / 2.0}');
		
		trace('$a.length() = ${a.length()}');
		trace('($a : Float) = ${ (a:Float) }'); // into Float-context it allways gives vector-length
		
		trace('( $a < $b ) = ${ a < b }'); // into greater and lesser comparing it using the vector-lengths
		trace('( $a < 1.4 ) = ${ a < 1.4 }');
		trace('( 1.4 < $a ) = ${ 1.4 < a }');
		
		trace('( $c == $d ) = ${ c == d }'); // into equal test of 2 vectors it is checking referenzes
		var e = d;
		trace('( $e == $d ) = ${ e == d }');
		
		trace('$c.isEqualTo( $d ) = ${ c.isEqualTo(d) }'); // even if this is different variables, the vector-values is true
		
		trace('( $b.length() == $c.length() ) = ${ b.length() == c.length() }');
		
		trace('( $b == $c.length() ) = ${ b == c.length() }');
		trace('( $b.length() == $c ) = ${ b.length() == c }');
	}
}
