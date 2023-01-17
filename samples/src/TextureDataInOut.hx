package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
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
	
	@texSlot public var slot:Int = 0;
		
	//var OPTIONS = { texRepeatX:true, texRepeatY:true, alpha:true };
	
	public function new(x:Int=0, y:Int=0, w:Int=100, h:Int=100)
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}
}

class TextureDataInOut extends Application
{
	var peoteView:PeoteView;
	var element:Elem;
	var buffer:Buffer<Elem>;
	var display:Display;
	var program:Program;
	var texture:Texture;
	
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
		display   = new Display(10,10, window.width-20, window.height-20, Color.GREEN);
		peoteView.addDisplay(display);
		
		buffer  = new Buffer<Elem>(100);
		program = new Program(buffer);
		
		texture = new Texture(512, 512, 2);
		
		element  = new Elem();
		buffer.addElement(element);
		
		Loader.image ("assets/images/peote_tiles.png", true, function (image:Image) {
			
			//var img = new peote.view.Image(image.width, image.height);
			
			
			//texture = new Texture(image.width, image.height);
			texture.setImage(image, 0);
			//texture.setImage(image.clone(), 1); // TODO: throw Error if same image inside multi slot
			
			//program.autoUpdateTextures = false;
			program.setTexture(texture, "custom");
			//program.updateTextures();
			
			program.discardAtAlpha(0.1);
			//program.alphaEnabled = true;
			
			//program.setActiveTextureGlIndex(texture, 2);// only after update

			
			display.addProgram(program);    // programm to display

			
			element.w = 512;// image.width;
			element.h = 512;// image.height;
			buffer.updateElement(element);
			
			peoteView.start();
		});
	}
	
	// ----------- Lime events ------------------

	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
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


}
