package;
#if sampleBunnyMark
import haxe.Timer;

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Texture;
import lime.graphics.Image;

import peote.view.Element;

class Bunny implements Element
{
	public var x:Float=0;
	public var y:Float=0;
	@posX public var xi:Int=0;
	@posY public var yi:Int=0;
	@sizeX @const public var w:Int=64;
	@sizeY @const public var h:Int=64;
	
	@color @const public var c:Color = 0xffffffff;
	
	public var speedX:Float;
	public var speedY:Float;
}



class BunnyMark 
{
	var addingBunnies:Bool;
	var bunnies:Array<Bunny>;
	var buffer:Buffer<Bunny>;
	var fps:FPS;
	var peoteView:PeoteView;
	var gravity:Float;
	var minX:Int;
	var minY:Int;
	var maxX:Int;
	var maxY:Int;
	
	var isStart:Bool = false;
	
	public function new(window:Window)
	{	
		minX = 0;
		maxX = window.width;
		minY = 0;
		maxY = window.height;
		gravity = 0.5;
		fps = new FPS ();
		bunnies = new Array ();
		
		peoteView = new PeoteView(window.context, window.width, window.height);
		
		buffer = new Buffer<Bunny>(400000);
		
		var display = new Display(0, 0, window.width, window.height, Color.GREEN);
		
		var program = new Program(buffer);
		
		var image = new Image();
		
		var future = Image.loadFromFile("assets/images/wabbit_alpha.png");
		future.onProgress (function (a:Int,b:Int) trace ('loading image $a/$b'));
		future.onError (function (msg:String) trace ("Error: "+msg));
		future.onComplete (function (image:Image) {
			
			var texture = new Texture(image.width, image.height);
			
			texture.setImage(image);
			
			program.setTexture(texture);
			
			display.addProgram(program);    // programm to display
			peoteView.addDisplay(display);  // display to peoteView
			
			var count = #if bunnies Std.parseInt (haxe.macro.Compiler.getDefine ("bunnies")) #else 100 #end;
			for (i in 0...count) {
				addBunny ();
			}
			isStart = true;
			//peoteView.start();	
		});
	}
	
	private function addBunny():Void
	{
		var bunny = new Bunny();
		bunny.x = 0;
		bunny.y = 0;
		bunny.speedX = Math.random () * 5;
		bunny.speedY = (Math.random () * 5) - 2.5;
		bunnies.push (bunny);
		buffer.addElement(bunny);
	}
	
	public function update(deltaTime:Int):Void {
		if (!isStart) return;
		for (bunny in bunnies) {
			
			bunny.x += bunny.speedX;
			bunny.y += bunny.speedY;
			bunny.speedY += gravity;
			
			if (bunny.x > maxX) {
				
				bunny.speedX *= -1;
				bunny.x = maxX;
				
			} else if (bunny.x < minX) {
				
				bunny.speedX *= -1;
				bunny.x = minX;
				
			}
			
			if (bunny.y > maxY) {
				
				bunny.speedY *= -0.8;
				bunny.y = maxY;
				
				if (Math.random () > 0.5) {
					
					bunny.speedY -= 3 + Math.random () * 4;
					
				}
				
			} else if (bunny.y < minY) {
				
				bunny.speedY = 0;
				bunny.y = minY;
				
			}
			bunny.xi = Std.int(bunny.x);
			bunny.yi = Std.int(bunny.y);
			//buffer.updateElement(bunny);
		}
		
		if (addingBunnies) {
			
			for (i in 0...30) {
				
				addBunny ();
				
			}
			
		}
		
		fps.update (deltaTime);
		
		buffer.update();
		
	}

	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		addingBunnies = true;
	}

	public function onMouseUp (x:Float, y:Float, button:MouseButton):Void
	{
		addingBunnies = false;
		trace ('${bunnies.length} bunnies @ ${fps.current} FPS');
	}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.SPACE:isStart = !isStart;
			default:
		}
	}

	public function render()
	{
		peoteView.render();
	}

	public function resize(width:Int, height:Int)
	{
		peoteView.resize(width, height);
	}

}




class FPS {
	
	
	public var current (get, null):Int;
	
	private var totalTime:Int;
	private var times:Array<Float>;
	
	
	public function new () {
		
		totalTime = 0;
		times = new Array ();
		
	}
	
	
	public function update (deltaTime:Int):Void {
		
		totalTime += deltaTime;
		times.push (totalTime);
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_current ():Int {
		
		while (times[0] < totalTime - 1000) {
			
			times.shift ();
			
		}
		
		return times.length;
		
	}
	
	
}

#end