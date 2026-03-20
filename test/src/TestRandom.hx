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

		var random = new Random();
		// var random = new Random(123);

		for (i in 0...30)
		{
			trace( StringTools.hex( random.uint(), 8 ) );
			// trace( StringTools.hex( random.uint(5), 8 ) );
			// trace( StringTools.hex( random.uint(0xffffffff), 8 ) );
			
			// trace( StringTools.hex( random.limitUInt(0xa0, 0xaf), 8 ) );
			// trace( StringTools.hex( random.limitUInt(0, 0xffffffff), 8 ) );
			// trace( StringTools.hex( random.limitUInt(0xfffffffa, 0xffffffff), 8 ) );


			// trace( random.int(10) );
			// trace( random.int(-10) );
			
			// trace( random.limitInt(-2147483648, 2147483647) );
			// trace( random.limitInt(-2, 3) );
			// trace( random.limitInt(-5, 5) );
			// trace( random.limitInt(-5, -2) );
			// trace( random.limitInt(100, 110) );

			// trace( random.float(2) );
			// trace( random.floatLow(5) );
			
			// trace( random.limitFloat(-10, 10) );		
			// trace( random.limitFloatLow(2, 3) );
			
		}


	}

}
