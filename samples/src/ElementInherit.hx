package;
#if ElementInherit
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
//import peote.view.Texture;

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
}

class ElementChild extends ElementOldChild
{
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100 )
	{
		super();
		trace("NEW ElementChild");
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		// super(); Take care, super here use defaults of its vars 
	}
}


class ElementInherit 
{
	var peoteView:PeoteView;
	var element:ElementChild;
	var buffer:Buffer<ElementChild>;
	
	public function new(window:Window)
	{	
		peoteView = new PeoteView(window.context, window.width, window.height);
		
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
	
	public function onPreloadComplete ():Void { trace("preload complete"); }
	
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
			element.x += 100;
			buffer.updateElement(element);
	}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			//case KeyCode.:
			default:
		}
	}
	public function update(deltaTime:Int):Void {}
	public function onMouseUp (x:Float, y:Float, button:MouseButton):Void {}
	public function onMouseMove (x:Float, y:Float):Void {}

	public function render()
	{
		peoteView.render();
	}

	public function resize(width:Int, height:Int)
	{
		peoteView.resize(width, height);
	}

}
#end