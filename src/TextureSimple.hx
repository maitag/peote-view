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
	@posX public var x:Int=0; // signed 2 bytes integer
	@posY public var y:Int=0; // signed 2 bytes integer
	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	@texSlot var slot:Int = 1;
	
	@color public var c:Color = 0xff0000ff;
		
	@zIndex public var z:Int = 0;	
	
	//TODO: let the texture shift inside slot/texCoords/tile area
	@texOffsetX @texRepeat public var txOffset:Int;
	@texOffsetY public var tyOffset:Int;
	@texOffsetW public var twOffset:Int;
	@texOffsetH public var thOffset:Int;

	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100, c:Int=0xFF0000FF )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.c = c;
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
		//program.setTextureLayer(0, [texture]);
		
		display.addProgram(program);    // programm to display

		element  = new Elem(10, 10);
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
			
			program.setActiveTextureGlIndex(texture, 2);// only after update

			
			element.w = image.width;
			element.h = image.height;
			buffer.updateElement(element);
			//program.replaceTexture(texture, texture1);
		});
				
		// ---------------------------------------------------------------
		//peoteView.render();
		
	}
	public function loadImage(texture:Texture, filename:String, slot:Int=0):Void {
		trace('load image $filename');
		var future = Image.loadFromFile(filename);
		future.onProgress (function (a:Int,b:Int) trace ('...loading image $a/$b'));
		future.onError (function (msg:String) trace ("Error: "+msg));
		future.onComplete (function (image:Image) {
			trace('loading $filename complete');
			texture.setImage(image, slot);
		});		
	}
	
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		element.x += 100;
		buffer.updateElement(element);		
	}

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