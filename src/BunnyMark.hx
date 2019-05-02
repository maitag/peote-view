package;
#if sampleBunnyMark

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.graphics.Image;

import utils.Loader;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Texture;

import peote.view.Element;

class Bunny implements Element
{
	@sizeX @const public var w:Int=26;
	@sizeY @const public var h:Int=37;
	
	@posX public var x:Float; // using 32 bit Float for glBuffer
	@posY public var y:Float;
	/*
	@posX public var xi:Int;  // using 16 bit Integer for glBuffer
	@posY public var yi:Int;
	
	public var x(default, set):Float=0;
	inline function set_x(a):Float {
		xi = Std.int(x);
		return x=a;
	}
	
	public var y(default, set):Float=0;
	inline function set_y(a):Float {
		yi = Std.int(y);
		return y=a;
	}
	*/
	
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
	
	var bunnyCount:Int = 100;
	
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
		
		#if bunnies 
		bunnyCount = Std.parseInt (haxe.macro.Compiler.getDefine ("bunnies"));
		#end
		//trace("Bunnies:", bunnyCount);
		buffer = new Buffer<Bunny>(bunnyCount, 4096); // automatic grow buffersize about 4096
		
		var display = new Display(0, 0, window.width, window.height, Color.GREEN);
		
		var program = new Program(buffer);
		
		Loader.imageFromFile ("assets/images/wabbit_alpha.png", true, function (image:Image) {			
			var texture = new Texture(image.width, image.height);
			
			texture.setImage(image);
			
			program.addTexture(texture, "custom");
					
			//program.setVertexFloatPrecision("low");
			//program.setFragmentFloatPrecision("low");
						
			display.addProgram(program);    // programm to display
			peoteView.addDisplay(display);  // display to peoteView
			
			for (i in 0...bunnyCount) {
				addBunny ();
			}
			isStart = true;
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
	
	public function onMouseMove (x:Float, y:Float):Void {}
	public function onWindowLeave ():Void {}

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
	
	public function onPreloadComplete ():Void { trace("preload complete"); }

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