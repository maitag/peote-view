package;
#if sampleBunnyMarkGPU

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
	
	//@posX @anim("X","pingpong") @formula("xStart+(uResolution.x-w-xStart)*time0") public var x:Int;
	//@posY @anim("Y","pingpong") @formula("yStart+(uResolution.y-h-yStart)*time1*time1") public var y:Int;
	@posX @constStart(0) @constEnd(800) @anim("X","pingpong") @formula("xStart+(xEnd-w-xStart)*time0") public var x:Int;
	@posY @constStart(0) @constEnd(600) @anim("Y","pingpong") @formula("yStart+(yEnd-h-yStart)*time1*time1") public var y:Int;
	//@posX @constStart(0) @constEnd(800) @anim("X","pingpong") @formula("xStart+(uResolution.x-w-xStart)*time0") public var x:Int;
	//@posY @constStart(0) @constEnd(600) @anim("Y","pingpong") @formula("yStart+(uResolution.y-h-yStart)*time1*time1") public var y:Int;
	
	public function new(x:Int, y:Int, currTime:Float) {
		//this.x = x;
		//this.y = y;
		this.timeX(currTime, 4+Math.random()*15);
		//this.animX();
		this.timeY(currTime, 0.5+Math.random()*2);
		//this.animY(0, 563);
	}
}



class BunnyMarkGPU
{
	var peoteView:PeoteView;
	var buffer:Buffer<Bunny>;
	var fps:FPS;
	
	var addingBunnies:Bool;
	var bunnyCount:Int = 100;
	
	var bunnies:Int = 0;
	
	var isStart:Bool = false;
	
	public function new(window:Window)
	{	
		fps = new FPS ();
		
		peoteView = new PeoteView(window.context, window.width, window.height);
		
		#if bunnies 
		bunnyCount = Std.parseInt (haxe.macro.Compiler.getDefine ("bunnies"));
		//bunnyCount *= 5;
		#end
		//trace("Bunnies:", bunnyCount);
		
		buffer = new Buffer<Bunny>(bunnyCount+65536, 65536); // automatic grow buffersize about 4096
		
		//var display = new Display(0, 0, window.width, window.height, Color.GREEN);
		var display = new Display(0, 0, 800, 600, Color.GREEN);
		
		var program = new Program(buffer);
		
		Loader.image ("assets/images/wabbit_alpha.png", true, function (image:Image) {			
			var texture = new Texture(image.width, image.height);
			
			texture.setImage(image);
			
			program.addTexture(texture, "custom");
					
			//program.setVertexFloatPrecision("low");
			//program.setFragmentFloatPrecision("low");
						
			display.addProgram(program);    // programm to display
			peoteView.addDisplay(display);  // display to peoteView
			
			for (i in 0...bunnyCount) {
				addBunny (0,0);
			}
			isStart = true;
			peoteView.start();
		});
	}
		
	private function addBunny(x:Int, y:Int):Void
	{
		var bunny = new Bunny(x, y, peoteView.time);
		buffer.addElement(bunny);
		bunnies++;
	}
	
	public function update(deltaTime:Int):Void {
		if (!isStart) return;
		if (addingBunnies)
		{			
			for (i in 0...200)
				addBunny (0,0);		
		}
		
		fps.update (deltaTime);
	}

	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		addingBunnies = true;
	}

	public function onMouseUp (x:Float, y:Float, button:MouseButton):Void
	{
		addingBunnies = false;
		trace ('$bunnies bunnies @ ${fps.current} FPS');
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