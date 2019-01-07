package;

#if sampleGLPicking
import haxe.Timer;

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;

import peote.view.PeoteGL;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Element;
//import peote.view.Texture;

class Elem implements Element
{
	@posX public var x:Int=0; // signed 2 bytes integer
	@posY public var y:Int=0; // signed 2 bytes integer
	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	@color public var c:Color = 0xff0000ff;
		
	@zIndex public var z:Int = 0;	
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100, c:Int=0xFF0000FF )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.c = c;
	}
	
	var OPTIONS = { picking:true, texRepeatX:true };

}

class GLPicking 
{
	var peoteView:PeoteView;

	var element:Elem;
	var buffer:Buffer<Elem>;
	var programLeft:Program;
	var programRight:Program; 
	
	public function new(window:Window)
	{	

		peoteView = new PeoteView(window.context, window.width, window.height, Color.GREY1);
		var displayLeft  = new Display(10, 10, 280, 280, Color.BLUE);
		var displayRight = new Display(300, 10, 280, 280, Color.YELLOW);
		
		peoteView.addDisplay(displayLeft);
		peoteView.addDisplay(displayRight);
		
		buffer   = new Buffer<Elem>(100);

		element  = new Elem(20, 20);
		buffer.addElement(element);

		
		programLeft  = new Program(buffer);
		programRight = new Program(buffer);
		
		displayLeft.addProgram(programLeft);
		displayRight.addProgram(programRight);
		
		
		
		var timer = new Timer(60);
		timer.run =  function() {
			element.x++; buffer.updateElement(element);
			if (element.x > 170) timer.stop();
		};
		
		
	}

	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		// TODO
		// TODO
		// TODO
		var pickedElement = buffer.pickElementAt(Std.int(x), Std.int(y), programLeft);
		if (pickedElement != null) pickedElement.y += 100;
	}
	
	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		
	}
	public function update(deltaTime:Int):Void {}
	public function onMouseUp (x:Float, y:Float, button:MouseButton):Void {}
	
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