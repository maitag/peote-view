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

		var random = new Random(3);
		
		for (i in 0...55) {
			// trace( random.randomFloat());
			// trace( random.random(10) );
			trace( random.randomUInt() );
			// trace( random.randomInt() );
		}
	}

}
