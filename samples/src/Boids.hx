package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.graphics.Image;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Texture;

import peote.view.Element;
import utils.Loader;
import utils.Vec2;


class Boid implements Element
{
	@sizeX @const public var w:Int = 13;
	@sizeY @const public var h:Int = 32;
	
	@posX public var x:Float; // using 32 bit Float for glBuffer
	@posY public var y:Float;
	
	@rotation public var rot:Float;

	public var speed:Vec2;

	public var pos(get, set):Vec2;
	inline function get_pos():Vec2 return {x:x, y:y};
	inline function set_pos(v:Vec2) { x = v.x; y = v.y; return v; }
	
	public function new(pos:Vec2, ?speed:Vec2) {
		set_pos(pos);
		if (speed != null)
			this.speed = speed;
		else
			this.speed = new Vec2(0.0, 0.0); // default speed
	}
}


class Boids extends Application
{
	var peoteView:PeoteView;
	var display:Display;
	var buffer:Buffer<Boid>;
	var program:Program;
	
	var fps:FPS;

	var isStart = false;
	var addingBoids = false;


	// boid simulation parameters:
	var boids = new Array<Boid>();
	var boidCount:Int = 100;

	var minPos = new Vec2(0.0, 0.0);
	var maxPos:Vec2;

	var attraction:Float = 0.01; // strength of pull towards centre of mass
	var privateSpace:Float = 100; // amount of space the boids try to get in between them
	var velocityMatching:Float = 0.125;//0.04; // pull in flight direction of other boids
	var speedLimitation:Float = 50; // limit the speed of the boids
	var pullToCentre:Float = 0.00005; // pull towards centre
	var repulsion:Float = 0.1; // strength at which boids try to not collide
	var visionRange:Float = 700;
	var scaling:Float = 0.01; // scale everything down


	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	public function startSample(window:Window)
	{
		// Vec2.test(); // test the Vec2 helper
		
		fps = new FPS ();
		
		maxPos = new Vec2(window.width, window.height);
		
		peoteView = new PeoteView(window); // at now this should stay first ( to initialize PeoteGL from gl-context! )
        display = new Display(0, 0, window.width, window.height, Color.GREEN);

		Loader.image ("assets/images/boid.png", true, onImageLoad);
	}

    private function onImageLoad(image:Image)
	{
        var texture = new Texture(image.width, image.height);
        texture.setImage(image);

        buffer = new Buffer<Boid>(boidCount, 4096); // automatic grow buffersize about 4096
		program = new Program(buffer); //Sprite buffer
        program.addTexture(texture, "custom"); //Sets image for the sprites
        //program.setVertexFloatPrecision("low");
        //program.setFragmentFloatPrecision("low");

        display.addProgram(program);    // program to display
        peoteView.addDisplay(display);  // display to peoteView
		
		
 		// scale everything
		attraction = attraction * scaling;
		velocityMatching = velocityMatching * scaling;
		repulsion = repulsion * scaling;

		initializeBoids(); 
		display.zoom = 0.3;
		isStart = true;
    }
	

	private function initializeBoids():Void
	{
		var alpha:Float;
		var distance:Float;
		for (i in 0...boidCount)
		{
			alpha = boidCount / (i + 1.0) * 2.0 * Math.PI + Math.random() * 0.5 - 0.25;
			distance = 400 + Math.random() * 800;
			
			var boid = new Boid({
				x: distance * Math.sin(alpha) + maxPos.x / 2,
				y: distance * Math.cos(alpha) + maxPos.y / 2
			},
			{
				x: Math.sin(alpha) * 5,
				y: Math.cos(alpha) * 5
			});
			
			boids.push(boid);
			buffer.addElement(boid);
		}
	}
		
	private function addBoid():Void
	{
		var boid = new Boid({
			x: Math.random() * maxPos.x * 4 - maxPos.x * 2,
			y: Math.random() * maxPos.y * 4 - maxPos.y * 2	
		});
		
		boids.push(boid);
		buffer.addElement(boid);
	}
	
	//1. move to perceived centre of mass
	private inline function rule1(boid:Boid):Vec2
	{
		var a1 = new Vec2(0.0, 0.0);
		var nVic:Float=0;
		
		for (boid2 in boids)
		{
			if (boid != boid2 && (boid.pos - boid2.pos).length() < visionRange)
			{
				a1 = a1 + boid2.pos;
				nVic++;
			}
		}
		if (nVic != 0){a1 = a1 / nVic;}
		return(a1);
	}

	//2. keep distance to other boids
	private inline function rule2(boid:Boid):Vec2
	{
		var a2 = new Vec2(0.0, 0.0);
		for (boid2 in boids)
		{
			if (boid != boid2)
			{
				if ((boid.pos - boid2.pos).length() < privateSpace)
				{ 
					a2 = a2 - (boid2.pos - boid.pos);
				}
			}
		}
		return(a2);
	}

	//3. match velocity of other adjacent boids
	private inline function rule3(boid:Boid):Vec2
	{
		var a3 = new Vec2(0.0, 0.0);
		var nVic:Float=0;
		for (boid2 in boids)
		{
			if (boid != boid2 && (boid.pos - boid2.pos).length() < visionRange)
			{
				a3 = a3 + boid2.speed;
				nVic++;
			}
		}
		if (nVic != 0){a3 = a3 / nVic;}
		return(a3);
	}

	//4. keep boids inside borders
	private inline function rule4(boid:Boid):Vec2
	{
		var a4 = new Vec2(0.0, 0.0);
		if (boid.pos.x < - maxPos.x || boid.pos.x > 2 * maxPos.x)
		{
			a4.x += -(boid.pos.x - maxPos.x / 2);
		}
		if (boid.pos.y < - maxPos.y || boid.pos.y > 2 * maxPos.y)
		{
			a4.y += -(boid.pos.y - maxPos.y / 2);
		}
		return(a4);
	}

	// ----------- Lime events ------------------

	override function update(deltaTime:Int):Void 
	{
		if (!isStart) return;		

		for (boid in boids) 
		{
			boid.pos += boid.speed;
						
			var a = new Vec2(0.0, 0.0); 

			a += (rule1(boid) - boid.pos)*attraction;

			a += rule2(boid) * repulsion;
			
			a += (rule3(boid) - boid.speed) * velocityMatching;
			
			//accellerate boids to middle of screen // Todo: only if out of borders
			//a -= (boid.pos - maxPos / 2) * pullToCentre;
			a += rule4(boid)*pullToCentre;

			//update velocity
			boid.speed = boid.speed + a;
			
			var speed:Float = boid.speed.length();
			if (speed > speedLimitation)
			{
				boid.speed = boid.speed / speed * speedLimitation;
			}
			
			//update orientation
			boid.rot = Math.atan2(boid.speed.y, boid.speed.x) * 180 / Math.PI + 90;
		}
		
		if (addingBoids)
		{
			for (i in 0...1) addBoid();	
		}
		
		fps.update (deltaTime);
		
		buffer.update();	
	}

	override function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		addingBoids = true;
	}

	override function onMouseUp (x:Float, y:Float, button:MouseButton):Void
	{
		addingBoids = false;
		trace ('${boids.length} boids @ ${fps.current} FPS');
	}
	
	override function onMouseWheel (dx:Float, dy:Float, mode:MouseWheelMode):Void
	{
		if (dy > 0) display.zoom *= 1.1;
		else if (dy < 0) display.zoom *= 0.9;
	}
	
	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.SPACE: isStart = !isStart;
			case KeyCode.LEFT:  display.xOffset += 300 * display.zoom;
			case KeyCode.RIGHT: display.xOffset -= 300 * display.zoom;
			case KeyCode.UP:    display.yOffset += 300 * display.zoom;
			case KeyCode.DOWN:  display.yOffset -= 300 * display.zoom;
			default:
		}
	}
	
	override function onWindowResize (width:Int, height:Int):Void
	{
		display.width = width;
		display.height = height;
		
		maxPos.x = width;
		maxPos.y = height;
	}
	

}


// --------------------------------------------

class FPS
{
	public var current (get, null):Int;
	
	private var totalTime:Int;
	private var times:Array<Float>;
		
	public function new () 
	{
		totalTime = 0;
		times = new Array ();
	}
		
	public function update (deltaTime:Int):Void
	{
		totalTime += deltaTime;
		times.push (totalTime);		
	}
	
	private function get_current ():Int
	{
		while (times[0] < totalTime - 1000)
		{			
			times.shift ();		
		}		
		return times.length;
	}	
}
