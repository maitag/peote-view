package;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import peote.view.*;

class FramebufferChain extends Application {
	var peoteView:PeoteView;
	var element:Elem;
	var display:Display;
	var program:Program;
	var frameBuffers:Map<String, Framebuffer>=[];

	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try
					startSample(window)
				catch (_)
					trace(CallStack.toString(CallStack.exceptionStack()), _);
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	public function startSample(window:Window) {
		peoteView = new PeoteView(window);
		peoteView.start();

		var w = window.width;
		var h = window.height;

		frameBuffers = [
			"back" => new Framebuffer(peoteView, w, h),
			"fore" => new Framebuffer(peoteView, w, h),
		];

		display = new Display(0, 0, w, h);
		peoteView.addDisplay(display);

		var buffer = new Buffer<ViewElement>(1);
		program = new Program(buffer);

		program.setTexture(frameBuffers["back"].texture, "back", true);
		program.setTexture(frameBuffers["fore"].texture, "fore", true);
		program.setColorFormula("back + fore");

		program.alphaEnabled = true;
		program.discardAtAlpha(null);
		display.addProgram(program);

		var view = new ViewElement(0, 0, w, h);
		buffer.addElement(view);

		frameBuffers["back"].addElement(new Elem(50, 300, 100, 100, Color.RED));
		frameBuffers["fore"].addElement(new Elem(100, 350, 100, 100, Color.GREEN));
		
	}

	// ----------- Lime events ------------------

	override function onPreloadComplete():Void {}

	override function onMouseDown(x:Float, y:Float, button:MouseButton):Void {}

	override function onMouseMove(x:Float, y:Float):Void {}

	override function onMouseUp(x:Float, y:Float, button:MouseButton):Void {}

	var addedNewFb = false;
	override function onKeyDown(keyCode:KeyCode, modifier:KeyModifier):Void {
		if (!addedNewFb && keyCode == RETURN){
			addedNewFb = true;
			
			frameBuffers["over"] = new Framebuffer(peoteView, window.width, window.height);
			
			program.setTexture(frameBuffers["over"].texture, "over");
			program.setColorFormula("back + fore + over");
			
			frameBuffers["over"].addElement(new Elem(150, 400, 100, 100, Color.BLUE));
			
		}
	}

}


class Elem implements Element {
	@posX public var x:Int = 0;
	@posY public var y:Int = 0;

	@sizeX public var w:Int = 100;
	@sizeY public var h:Int = 100;

	@color public var c:Color = 0xff0000ff;

	public function new(positionX:Int = 0, positionY:Int = 0, width:Int = 100, height:Int = 100, color:Color) {
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.c = color;
	}
}


class ViewElement implements Element {
	@posX var x:Int = 0;
	@posY var y:Int = 0;

	@sizeX var w:Int;
	@sizeY var h:Int;



	public function new(positionX:Int = 0, positionY:Int = 0, width:Int, height:Int) {
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
	}
}


class Framebuffer {
	public var texture(default, null):Texture;
	public var buffer(default, null):Buffer<Elem>;
	public var program(default, null):Program;

	var display:Display;

	public function new(peoteView:PeoteView, width:Int, height:Int) {
		display = new Display(0, 0, width, height);
		buffer = new Buffer<Elem>(16, 16, true);
		program = new Program(buffer);
		program.alphaEnabled = true;
		program.discardAtAlpha(null);
		display.addProgram(program);
		
		texture = new Texture(width, height);
		peoteView.addFramebufferDisplay(display);
		display.setFramebuffer(texture, peoteView);

	}
	
	
	public function enable() {
		display.renderFramebufferEnabled = true;
	}

	public function disable() {
		display.renderFramebufferEnabled = false;
	}

	public function addElement(elem:Elem) {
		buffer.addElement(elem);
	}

	public function update() {
		buffer.update();
	}
}