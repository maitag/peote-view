package;

import haxe.Int32;
import peote.view.math.Random;

class TestRandom extends lime.app.Application
{
	public function new() {
		super();
		test();
	}
	
	public function test()
	{

		// var random = new Random();
		var random = new Random(123);

		for (i in 0...30)
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
			// trace( random.float32(5) );
			
			// trace( random.floatLimit(-10, 10) );		
			// trace( random.float32Limit(2, 3) );
			
		}


	}

}
