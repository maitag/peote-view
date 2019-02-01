package;
#if sampleRenderToTexture
import haxe.Timer;

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.graphics.Image;

import peote.view.PeoteGL;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Texture;
import peote.view.Element;

class Elem implements Element
{
	@posX public var x:Int = 0;	
	@posY public var y:Int = 0;
		
	@sizeX public var w:Int = 100;	
	@sizeY public var h:Int = 100;
	
	@rotation @anim("Rotation", "constant") public var r:Float;
	
	@pivotX @set("Pivot") public var px:Int;
	@pivotY @set("Pivot") public var py:Int;
	
	@texSlot public var slot:Int = 0;
	
	@color public var c:Color = 0xffff00ff;
		
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=64, height:Int=64, c:Int=0xFFFF00FF )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.c = c;
	}


}

class RenderToTexture
{
	var peoteView:PeoteView;
	
	var displayFrom:Display;
	var bufferFrom:Buffer<Elem>;
	var programFrom:Program;
	var elementFrom:Elem;

	var texture:Texture; // texture that will be used from both
	
	var displayTo:Display;
	var bufferTo:Buffer<Elem>;
	var programTo:Program;
	var elementTo:Elem;

	public function new(window:Window)
	{
		try {
		peoteView = new PeoteView(window.context, window.width, window.height);

		// display to renderToTexture:
		displayFrom = new Display(0, 60, 256, 256, Color.GREEN);
		peoteView.addDisplay(displayFrom);
		
		bufferFrom  = new Buffer<Elem>(100);
		programFrom = new Program(bufferFrom);
		displayFrom.addProgram(programFrom);
		
		// rotation Elements
		elementFrom = new Elem(120, 16, 16, 64, Color.RED);
		elementFrom.setPivot(8, 96 + 16);
		elementFrom.animRotation(0, 360);
		elementFrom.timeRotation(0, 1);
		bufferFrom.addElement(elementFrom);
		
		texture = new Texture(256, 256 , 2); // 2 Slots
			
		displayFrom.setFramebuffer(texture);
		//displayFrom.removeFramebuffer(); // need before using this texture with different gl-context!
		
		// --------------------------------------------
		
		// display that is using the Texture the other display is rendering In:
		displayTo = new Display(260, 0, 512, 512, Color.BLUE);
		peoteView.addDisplay(displayTo);
		
		bufferTo  = new Buffer<Elem>(100);
		programTo = new Program(bufferTo);
		programTo.setTexture(texture, "renderFrom");
		programTo.setColorFormula('renderFrom');
		programTo.discardAtAlpha(null);
		displayTo.addProgram(programTo);
		
		peoteView.renderToTexture(displayFrom, 0); // render into slot 0
		
		// element in middle is using texture-slot 1
		var elementTo1 = new Elem(256 - 32, 256 - 32, 64, 64, Color.CYAN);
		elementTo1.slot = 0;
		bufferTo.addElement(elementTo1);
		
		// rotating element is using texture-slot 1
		elementTo = new Elem(256 - 32, 16, 64, 64, Color.CYAN);
		elementTo.slot = 1;
		elementTo.setPivot(32, 256 - 16);
		elementTo.animRotation(0, 360);
		elementTo.timeRotation(0, 8);
		bufferTo.addElement(elementTo);
		
		var timer = new Timer(30);
		timer.run = function() {
			peoteView.renderToTexture(displayFrom, 1); // render into slot 1
		}
		
		
		peoteView.start();
		
		} catch (msg:Dynamic) trace("Error:", msg);
		// ---------------------------------------------------------------
	}
	
	public function onPreloadComplete ():Void {
		// sync loading did not work with html5!
		// texture.setImage(Assets.getImage("assets/images/wabbit_alpha.png"));
	}
	
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		//peoteView.renderToTexture(displayFrom);
	}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.NUMPAD_PLUS:
					if (modifier.shiftKey) peoteView.zoom+=0.01;
					else displayFrom.zoom+=0.1;
			case KeyCode.NUMPAD_MINUS:
					if (modifier.shiftKey) peoteView.zoom-=0.01;
					else displayFrom.zoom -= 0.1;
			case KeyCode.UP: displayFrom.yOffset -= (modifier.shiftKey) ? 8 : 1;
			case KeyCode.DOWN: displayFrom.yOffset += (modifier.shiftKey) ? 8 : 1;
			case KeyCode.RIGHT: displayFrom.xOffset += (modifier.shiftKey) ? 8 : 1;
			case KeyCode.LEFT: displayFrom.xOffset -= (modifier.shiftKey) ? 8 : 1;
			default:
		}
	}

	public function render()
	{
		peoteView.render();
	}
	
	public function update(deltaTime:Int):Void {}
	
	public function onMouseUp (x:Float, y:Float, button:MouseButton):Void {}

	public function resize(width:Int, height:Int)
	{
		peoteView.resize(width, height);
	}

}
#end