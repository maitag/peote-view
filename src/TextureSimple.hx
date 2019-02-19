package;
#if sampleTextureSimple
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
	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	@texSlot var slot:Int = 0;
	
	//@color public var c:Color = 0xff0000ff;
		
	//@zIndex public var z:Int = 0;	
	
	// manual texture coordinates inside a slot (or inside all slots if no slot available)
	@texX public var tx:Int=32;
	@texY public var ty:Int=0;
	@texW() public var tw:Int=256;
	@texH() public var th:Int=64;
	
	//let the texture shift/resize inside slot/texCoords/tile area of Element
	@texPosX public var txOffset:Int = 10;
	@texPosY public var tyOffset:Int = 10;
	@texSizeX public var twOffset:Int = 256;
	@texSizeY public var thOffset:Int = 16;
	
	var OPTIONS = { texRepeatX:true, texRepeatY:true, alpha:true };
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100, c:Int=0xFF0000FF )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		//this.c = c;
	}


}

class TextureSimple
{
	var peoteView:PeoteView;
	var element:Elem;
	var buffer:Buffer<Elem>;
	var display:Display;
	var program:Program;
	var texture:Texture;
	
	public function new(window:Window)
	{	
		peoteView = new PeoteView(window.context, window.width, window.height);
		display   = new Display(10,10, window.width-20, window.height-20, Color.GREEN);
		peoteView.addDisplay(display);  // display to peoteView
		
		buffer  = new Buffer<Elem>(100);
		program = new Program(buffer);
		
		texture = new Texture(512, 512, 2);
		
		element  = new Elem(0, 0);
		buffer.addElement(element);     // element to buffer
		
		var future = Image.loadFromFile("assets/images/peote_tiles.png");
		future.onProgress (function (a:Int,b:Int) trace ('loading image $a/$b'));
		future.onError (function (msg:String) trace ("Error: "+msg));
		future.onComplete (function (image:Image) {
			trace("loading complete");
			
			//texture = new Texture(image.width, image.height);
			texture.setImage(image,0);
			texture.setImage(image.clone(),1); // TODO: throw Error if same image inside multi slot
			
			//program.autoUpdateTextures = false;
			program.setTexture(texture, "custom");
			//program.updateTextures();
			program.discardAtAlpha(0.1);
			//program.alphaEnabled = true;
			//program.setActiveTextureGlIndex(texture, 2);// only after update

			display.addProgram(program);    // programm to display

			
			element.w = image.width;
			element.h = image.height;
			buffer.updateElement(element);
			
		});
				
		// ---------------------------------------------------------------
	}
	public function onPreloadComplete ():Void {
		// sync loading did not work with html5!
		// texture.setImage(Assets.getImage("assets/images/wabbit_alpha.png"));
	}
	
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		display.zoom *= 2;	
	}

	public function onMouseMove (x:Float, y:Float):Void {}
	public function onWindowLeave ():Void {}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.L:
				if (program.hasTexture(texture, "custom")) program.removeAllTexture("custom");
				else {
					program.setMultiTexture([texture], "custom");
					program.setActiveTextureGlIndex(texture, 3);
				}
			case KeyCode.T:
				if (program.hasTexture(texture)) program.removeTexture(texture, "custom");
				else program.setTexture(texture, "custom");
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