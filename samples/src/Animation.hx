package;

import haxe.Timer;
import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.MouseButton;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Element;

class Elem implements Element
{
	// Position in pixel (relative to upper left corner of Display)
	@posX @set("PosSize") //@time("Position") @anim("Position") //@constStart(0) //@constEnd(100)
	public var x;
	
	@posY @set("PosSize") @anim("Position", "pingpong") //@constStart(0) //@constEnd(100) 
	public var y:Int;
	
	// Size in pixel
	@sizeX @set("PosSize") @time("SizePivot") @anim("Size") //@constStart(300) //@constEnd(400) 
	public var w=100;
	
	@sizeY @set("PosSize") @time("SizePivot") @anim("Size") //@constEnd(200)
	public var h:Int=100;
	
	// Color (RGBA)
	@color @anim("Color") @time("Position") // @constStart(0xFF112200) @constEnd(0x0000FE00) 
	public var c:Color; // use same Time as in @poxY
	
	// Rotation around pivot point
	@rotation @anim("Rotation")
	public var r:Float;
	
	// pivot x (rotation offset)
	@pivotX @set("Pivot") @anim("Pivot") @time("SizePivot") 
	public var px:Int = 0;

	// pivot y (rotation offset)
	@pivotY @set("Pivot") @anim("Pivot") @time("SizePivot") 
	public var py:Int = 0;
	
	// z-index
	@zIndex @const(1) // max 0x3FFFFFFF , min -0xC0000000
	public var z:Int = 0;
}


class Animation extends Application
{
	var peoteView:PeoteView;
	var element:Elem;
	var buffer:Buffer<Elem>;
	
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
		peoteView = new PeoteView(window);
		
		buffer = new Buffer<Elem>(100);
		
		var display   = new Display(10,10, window.width-20, window.height-20); display.color = Color.GREEN;
		var program   = new Program(buffer);
		
		peoteView.addDisplay(display);  // display to peoteView
		display.addProgram(program);    // programm to display
	
		element  = new Elem();
		buffer.addElement(element);     // element to buffer
		
		// --------------------------
		
		peoteView.start();
		
		element.setPosSize(50, 0, 50, 50);
		
		element.animPosition(50, 400);
		element.animColor(Color.RED, 0x0000FF00);
		element.timePosition(0.0, 6.0);
		
		element.setPivot(25, 25);
		
		element.animRotation(0, 45);
		element.timeRotation(0.5, 1.5);
		
		buffer.updateElement(element);
			
		Timer.delay(function()
		{
			element.animSize(50, 50, 100, 100);
			element.animPivot(25, 25, 50, 50);
			element.timeSizePivot(peoteView.time , 1);
			
			element.animRotation(45, -90);
			element.timeRotation(peoteView.time, 1.0);

			buffer.updateElement(element);
		}, 3000);
		
	}
	
	// ----------- Lime events ------------------
	
	override function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		element.x += 100;
		element.cStart.randomize();
		element.cEnd.randomize();
		buffer.updateElement(element);
	}
	
}