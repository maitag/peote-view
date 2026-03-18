package;

import peote.view.math.Random;

class TestRandom extends lime.app.Application
{
	public function new() {
		super();
		testInt();
	}
	
	public function testInt()
	{

		var r = new Random(0);
		// Random.makeFromArray([4,5,6,7,8,9,10]);
		for (i in 0...5)
			trace( r.random(10) );
			trace( r.randomUInt() );

	}

}
