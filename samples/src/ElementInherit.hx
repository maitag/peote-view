package;

import haxe.CallStack;
import haxe.Timer;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.MouseButton;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;

import peote.view.Element;

class ElementParent implements Element
{
	@posX public var x:Int=0;
	@posY public var y:Int=0;
	@sizeX @anim public var w:Int;
	@sizeY public var h:Int;
}

class ElementOldChild extends ElementParent
{
	var name = "child";
}

class ElementChild extends ElementOldChild
{
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100 )
	{
		super();
		trace("NEW ElementChild", name);
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		// super(); Take care, super here use defaults of its vars 
	}
}


class ElementInherit extends Application
{
	var element:ElementChild;
	var buffer:Buffer<ElementChild>;
	
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
		var peoteView = new PeoteView(window);
		
		buffer = new Buffer<ElementChild>(100);

		var display = new Display(10,10, window.width-20, window.height-20, Color.GREEN);
		var program = new Program(buffer);
		
		peoteView.addDisplay(display);  // display to peoteView
		display.addProgram(program);    // programm to display
	
		element = new ElementChild(10, 10);
		buffer.addElement(element);     // element to buffer
		
		peoteView.start();
		
		var element1  = new ElementChild(10, 150);
		element1.anim(100, 200);
		element1.time(peoteView.time, 3.0);
		buffer.addElement(element1);     // element to buffer
		
		Timer.delay( function() {
			element1.x += 100;
			buffer.updateElement(element1);
		} , 1000);
				
	}
	
	// ----------- Lime events ------------------

	override function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		element.x += 100;
		buffer.updateElement(element);
	}

}