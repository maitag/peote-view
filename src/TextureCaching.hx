package;
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
	
	@texSlot var slot:Int = 0;
		
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100)
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
	}
}

class TextureCaching
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
		
		element  = new Elem(0, 0);
		buffer.addElement(element);     // element to buffer
		
		Loader.imageFromFile ("assets/images/peote_tiles.png", true, function (image:Image) {
			texture = new Texture(image.width, image.height);
			texture.setImage(image,0);
			texture.setImage(image.clone(),1); // TODO: throw Error if same image inside multi slot
			
			//program.autoUpdateTextures = false;
			program.setTexture(texture, "custom");
			//program.updateTextures();

			//program.setActiveTextureGlIndex(texture, 2);// only after update

			display.addProgram(program);    // programm to display

			
			element.w = image.width;
			element.h = image.height;
			buffer.updateElement(element);			
		});
				
		// ---------------------------------------------------------------
	}
	public function onPreloadComplete ():Void {
		//trace("preload complete");
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
			case KeyCode.NUMBER_1: // todo: create another element with image 1
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