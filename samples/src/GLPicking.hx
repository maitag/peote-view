package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.graphics.Image;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Element;
import peote.view.Texture;

import utils.Loader;

class Elem implements Element
{
	@posX public var x:Int=0; // signed 2 bytes integer
	@posY public var y:Int=0; // signed 2 bytes integer
	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	@color public var color:Color = 0xff0000ff;
		
	@zIndex public var z:Int = 0;	
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100, color:Int=0xff0000ff )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.color = color;
	}
	
	var OPTIONS = { picking:true, texRepeatX:true };
}



class GLPicking extends Application
{
	var peoteView:PeoteView;

	var element = new Array<Elem>();
	
	var buffer:Buffer<Elem>;
	var display:Display;
	var program:Program;
	
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
		
		display = new Display(0, 0,  window.width, window.height);
		
		peoteView.zoom = 1.0;
		peoteView.xOffset = 0;
		peoteView.yOffset = 0;
		
		peoteView.addDisplay(display);
		
		buffer = new Buffer<Elem>(0xffff);
		
		element[0] = new Elem(-100,   0, 512, 512, Color.RED);
		element[1] = new Elem( 100, 200, 512, 512, Color.YELLOW);
		element[2] = new Elem( 330, 100, 512, 512, Color.GREEN);
		element[3] = new Elem( 480, 300, 512, 512, Color.MAGENTA);
		
		element[0].z =  Elem.MAX_ZINDEX;
		element[1].z =  Elem.MAX_ZINDEX - 1;
		element[2].z = -Elem.MAX_ZINDEX + 1;
		element[3].z = -Elem.MAX_ZINDEX;
		
		buffer.addElement(element[0]);
		buffer.addElement(element[1]);
		buffer.addElement(element[2]);
		buffer.addElement(element[3]);
		
		for (i in 4...0xffff) {
			var size = Std.int(4 + Math.random()*10);
			element[i] = new Elem( Std.int(Math.random()*650), Std.int(Math.random()*window.height), size, size, Color.random());
			element[i].z = Std.int(Math.random()*Elem.MAX_ZINDEX);
			buffer.addElement(element[i]);
		}
		
		program = new Program(buffer);
		
		// to disable alpha-discard:
		// program.discardAtAlpha(null);
		
		display.addProgram(program);
		
		Loader.image("assets/images/wabbit_alpha.png", true, function (image:Image)
		{
			trace("loading complete");
			var texture = new Texture(26, 37);
			texture.setImage(image);
			program.setTexture(texture, "custom");
		});
	}
	
	// ----------- Lime events ------------------
	
	override function onMouseDown(x:Float, y:Float, button:MouseButton):Void
	{
		var pickedElement = peoteView.getElementAt(x, y, display, program);
		trace(pickedElement);
		if (pickedElement >= 0) {
			var elem = buffer.getElement(pickedElement);
			elem.color = Color.random();
			elem.color.alpha = 255;
			buffer.updateElement(elem);		
		}
		
		var pickedElements = peoteView.getAllElementsAt(x, y, display, program);
		trace(pickedElements);
		//if (pickedElement != null) pickedElement.y += 100;
	}
	
	override function onKeyDown(keyCode:KeyCode, modifier:KeyModifier):Void
	{
		var steps = 10;
		var esteps = 10;
		switch (keyCode) {
			case KeyCode.LEFT:
					if (modifier.ctrlKey) {element[0].x-=esteps; buffer.updateElement(element[0]);}
					else if (modifier.shiftKey) display.xOffset-=steps;
					else peoteView.xOffset-=steps;
			case KeyCode.RIGHT:
					if (modifier.ctrlKey) {element[0].x+=esteps; buffer.updateElement(element[0]);}
					else if (modifier.shiftKey) display.xOffset+=steps;
					else peoteView.xOffset+=steps;
			case KeyCode.UP:
					if (modifier.ctrlKey) {element[0].y-=esteps; buffer.updateElement(element[0]);}
					else if (modifier.shiftKey) display.yOffset-=steps;
					else peoteView.yOffset-=steps;
			case KeyCode.DOWN:
					if (modifier.ctrlKey) {element[0].y+=esteps; buffer.updateElement(element[0]);}
					else if (modifier.shiftKey) display.yOffset+=steps;
					else peoteView.yOffset+=steps;
			case KeyCode.NUMPAD_PLUS:
					if (modifier.shiftKey) display.zoom+=0.25;
					else peoteView.zoom+=0.25;
			case KeyCode.NUMPAD_MINUS:
					if (modifier.shiftKey) display.zoom-=0.25;
					else peoteView.zoom-=0.25;
			default:
		}
		
	}
	
}