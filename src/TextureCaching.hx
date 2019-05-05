package;
import peote.view.utils.TextureCache;
#if sampleTextureCaching

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.graphics.Image;

import utils.Loader;

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
	@texW public var tw:Int=100;
	@texH public var th:Int=100;	
	@texSlot public var slot:Int=0;
		
	public function new(positionX:Int, positionY:Int, width:Int, height:Int, texW:Int, texH:Int, slot:Int)
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.tw = texW;
		this.th = texH;
		this.slot = slot;
	}
}

class TextureCaching
{
	var peoteView:PeoteView;
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
		display.addProgram(program);    // programm to display			
		
		texture = new Texture(512, 512, 4);
		program.setTexture(texture, "custom");
		
		// TODO
		var textureCache = new TextureCache(
			[
				{imageWidth:400, imageHeight:300, maxSlots:10},
				{imageWidth:26, imageHeight:37, maxSlots:1},
			],
			peoteView.gl.getParameter(peoteView.gl.MAX_TEXTURE_SIZE)
		);
		// TODO
		Loader.imagesFromFiles([
			"assets/images/test0.png",
			"assets/images/test1.png",
			"assets/images/test2.png"
			], //true,
			function (images:Array<Image>) {
				for (image in images) {
					var p = textureCache.addImage(image);
					trace(p.slot);
					// TODO
				}
			}
		);
		
		Loader.imageFromFile ("assets/images/test0.png", true, function (image:Image) {
			texture.setImage(image, 0);
			//haxe.Timer.delay( function() { texture.removeImage(image); }, 2000);
			buffer.addElement(new Elem(0, 0, 256, 256, 400, 300, 0));
		});

		Loader.imageFromFile ("assets/images/wabbit_alpha.png", true, function (image:Image) {
			texture.setImage(image,1);
			buffer.addElement(new Elem(256, 0, 256, 256, 26, 37, 1));
		});

		// ---------------------------------------------------------------
	}
	
	public function onPreloadComplete ():Void {}
	
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		display.zoom *= 2;	
	}

	public function onMouseMove (x:Float, y:Float):Void {}
	public function onWindowLeave ():Void {}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.NUMBER_1: // todo: testing here to add/remove images from textureCache
			case KeyCode.NUMBER_2:
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