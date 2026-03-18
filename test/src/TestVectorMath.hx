package;

import peote.view.math.*;

class TestVectorMath extends lime.app.Application
{
	public function new() {
		super();
		testVec2();
	}
	
	public function testVec2() 
	{
		var a:Vec2 = { x:1, y:1 }; // because of @:structInit
		var b:Vec2 = new Vec2( 2, 1 ); // this also works to initialize
		var c:Vec2 = new Vec2( 1, 2 );
		var d:Vec2 = [1, 1.5]; // cast from array

		trace(d.add(a).mul(2));

		// var x = a.copy.normalize();
		// trace( x.negate() );
		// trace(a);
		// x.copyFrom(a); trace(x);
		
		trace('$a + $b = ${a + b}');
		trace('$a - $b = ${a - b}');
		trace('$a * $b = ${a * b}');
		
		trace('$b * 2.0 = ${b * 2.0}');
		trace('2.0 * $b = ${2.0 * b}');
		trace('$b / 2.0 = ${b / 2.0}');
		
		trace('$a.length = ${a.length}');
		
		// into Float-context it allways gives vector-length
		trace('($a : Float) = ${ (a:Float) }');
		
		// into greater and lesser comparing it using the vector-lengths
		trace('( $a < $b ) = ${ a < b }');
		trace('( $a < 1.4 ) = ${ a < 1.4 }');
		trace('( 1.4 < $a ) = ${ 1.4 < a }');
		
		// into equal test of 2 vectors it is checking referenzes
		trace('( $c == $d ) = ${ c == d }');
		var e = d;
		trace('( $e == $d ) = ${ e == d }');
		
		// even if this is different variables, this checks the vector-values
		trace('$c.isEqual( $d ) = ${ c.isEqual(d) }');
		
		trace('( $b.length == $c.length ) = ${ b.length == c.length }');
		
		trace('( $b == $c.length ) = ${ b == c.length }');
		trace('( $b.length == $c ) = ${ b.length == c }');	
	}

}
