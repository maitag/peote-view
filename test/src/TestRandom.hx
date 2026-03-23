package;

import haxe.Int32;
import peote.view.math.Rnd;
import peote.view.math.Random;

class TestRandom extends lime.app.Application
{
	public function new() {
		super();
		testRnd(10);
		// testRndLimits();

		// testRandom(10, 12345);
		// testRandomLimits(12345);
	}

	// ----------------------------------------------------------
	// ------------------------- Rnd ----------------------------
	// ----------------------------------------------------------

	public function testRnd(n:Int) { trace("------- testRnd() -------");
		for (i in 0...n)
		{
			trace( StringTools.hex( Rnd.uint(), 8 ) );
			// trace( StringTools.hex( Rnd.uint(0xffffffff), 8 ) );
			
			// trace( StringTools.hex( Rnd.uintLimit(0xa0, 0xaf), 8 ) );
			// trace( StringTools.hex( Rnd.uintLimit(0, 0xffffffff), 8 ) );
			// trace( StringTools.hex( Rnd.uintLimit(0xfffffffa, 0xffffffff), 8 ) );

			// trace( Rnd.int(10) );
			// trace( Rnd.int(-10) );
			// trace( Rnd.int(-2147483648) );
			// trace( " "+ Rnd.int( 2147483647) );
			
			// trace( Rnd.intLimit(-2147483648, 2147483647) );
			// trace( Rnd.intLimit(-2, 3) );
			// trace( Rnd.intLimit(-5, 5) );
			// trace( Rnd.intLimit(-5, -2) );
			// trace( Rnd.intLimit(100, 110) );

			// trace( Rnd.float(2) );
			// trace( Rnd.floatFast(5) );
			
			// trace( Rnd.floatLimit(0, 1) );
			// trace( Rnd.floatLimit(-10, 10) );
			// trace( Rnd.floatLimit(-10, -5) );

			// trace( Rnd.floatFastLimit(0, 1) );
			// trace( Rnd.floatFastLimit(2, 3) );
		}
	}

	public function testRndLimits() { trace("------- testRndLimits() -------");
		while (true)
		{
			if ( Rnd.uint() == 0xffffffff )
			// if ( Rnd.uint(0xffffffff) == 0xfffffffe )
			// if ( Rnd.uint(0x80000000) == 0x7FFFFFFF )
			// if ( Rnd.uintLimit(0, 0xffffffff) == 0xffffffff )
			// if ( Rnd.int(-2147483648) <= -2147400000 )
			// if ( Rnd.int(-2147483648) == -2147483647 )
			// if ( Rnd.int( 2147483647) ==  2147483646 )
			// if ( Rnd.intLimit(-2147483648, 2147483647) <= -2147400000 )
			// if ( Rnd.intLimit(-2147483648, 2147483647) == -2147483648 )
			// if ( Rnd.intLimit(-2147483648, 2147483647) >=  2147400000 )
			// if ( Rnd.intLimit(-2147483648, 2147483647) ==  2147483647 )
			// if ( Rnd.floatLimit( 0.0, 1.0) >  0.99999999 )
			// if ( Rnd.floatLimit( 0.0, 1.0) >=  1.0 ) // <- can take very long time
			// if ( Rnd.floatFastLimit( 0.0, 1.0) >=  1.0 )
			{
				trace("found");
				break;
			}
		}
	}


	// ----------------------------------------------------------
	// ----------------------- Random ---------------------------
	// ----------------------------------------------------------

	public function testRandom(n:Int, ?seed:Int) { trace("------- testRandom() -------");
		var random = new Random(seed);
		for (i in 0...10)
		{
			trace( StringTools.hex( random.uint(), 8 ) );
			// trace( StringTools.hex( random.uint(5), 8 ) );
			// trace( StringTools.hex( random.uint(0xffffffff), 8 ) );
			
			// trace( StringTools.hex( random.uintLimit(0xa0, 0xaf), 8 ) );
			// trace( StringTools.hex( random.uintLimit(0, 0xffffffff), 8 ) );
			// trace( StringTools.hex( random.uintLimit(0xfffffffa, 0xffffffff), 8 ) );


			// trace( random.int(10) );
			// trace( random.int(-10) );
			
			// trace( random.intLimit(-2147483648, 2147483647) );
			// trace( random.intLimit(-2, 3) );
			// trace( random.intLimit(-5, 5) );
			// trace( random.intLimit(-5, -2) );
			// trace( random.intLimit(100, 110) );

			// trace( random.float(2) );
			// trace( random.floatFast(5) );
			
			// trace( random.floatLimit(-10, 10) );		
			// trace( random.floatFastLimit(2, 3) );			
		}
	}

	public function testRandomLimits(?seed:Int) { trace("------- testRandomLimits() -------");
		var random = new Random(seed);
		while (true)
		{
			if ( random.uint() == 0xffffffff )
			// if ( random.uint(0xffffffff) == 0xfffffffe )
			// if ( random.uint(0x80000000) == 0x7FFFFFFF )
			// if ( random.uintLimit(0, 0xffffffff) == 0xffffffff )
			// if ( random.int(-2147483648) <= -2147400000 )
			// if ( random.int(-2147483648) == -2147483647 )
			// if ( random.int( 2147483647) ==  2147483646 )
			// if ( random.intLimit(-2147483648, 2147483647) <= -2147400000 )
			// if ( random.intLimit(-2147483648, 2147483647) == -2147483648 )
			// if ( random.intLimit(-2147483648, 2147483647) >=  2147400000 )
			// if ( random.intLimit(-2147483648, 2147483647) ==  2147483647 )
			// if ( random.floatLimit( 0.0, 1.0) >  0.99999999 )
			// if ( random.floatLimit( 0.0, 1.0) >=  1.0 )
			// if ( random.floatFastLimit( 0.0, 1.0) >  0.999999999 )
			// if ( random.floatFastLimit( 0.0, 1.0) >=  1.0 )
			{
				trace("found");
				break;
			}
		}
	}

}
