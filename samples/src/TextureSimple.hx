package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.graphics.Image;

import utils.Loader;
//import lime.utils.Assets;

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
	
	//@color public var c:Color = 0xff0000ff;
	
	//@texSlot public var slot:Int = 0;
	
	// manual texture coordinates inside a slot (or inside all slots if no slot available)
	//@texX @anim("Tex","pingpong") @constStart(0) public var tx:Int;
	//@texY public var ty:Int=-11;
	//@texW @const @formula("tw - tx") public var tw:Int=256;
	//@texH @const public var th:Int=256;
	//@texH("B") public var thB:Int=128;
	
	//let the texture shift/resize inside slot/texCoords/tile area of Element
/*	@texPosX public var txOffset:Int = 10;
	@texPosY public var tyOffset:Float = 2.0;
	@texSizeX public var twOffset:Int = 256;
	@texSizeY public var thOffset:Int = 256;
*/	
	var OPTIONS = { texRepeatX:true, texRepeatY:true, alpha:true };
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100, c:Int=0xFF0000FF )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		//this.c = c;
		
		//this.animTex(255);
		//this.timeTex(0, 5);
	}
}

class TextureSimple extends Application
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
		peoteView.addDisplay(display);  // display to peoteView
		
		buffer  = new Buffer<Elem>(100);
		program = new Program(buffer);
		
		texture = new Texture(512, 512, 2);
		
		element  = new Elem(0, 0);
		buffer.addElement(element);     // element to buffer
		
		Loader.image ("assets/images/peote_tiles.png", true, function (image:Image) {
			//texture = new Texture(image.width, image.height);
			texture.setImage(image,0);
			texture.setImage(image.clone(),1); // TODO: throw Error if same image inside multi slot
			
			//program.autoUpdateTextures = false;
			program.setTexture(texture, "custom");
			//program.updateTextures();
			program.discardAtAlpha(0.1);
			//program.alphaEnabled = true;
			//program.setActiveTextureGlIndex(texture, 2);// only after update

			//program.setFormula("ty", "10.0");
			//program.setFormula("th", "512.0");
			
			display.addProgram(program);    // programm to display

			
			element.w = 512;// image.width;
			element.h = 512;// image.height;
			buffer.updateElement(element);
			
			peoteView.start();
		});
	}
	
	// ----------- Lime events ------------------

	override function onPreloadComplete ():Void {
		/*
		trace("preload complete");
		// sync loading for HTML5 only works with embed=true for assets inside project.xml !
		texture = new Texture(512, 512, 2);
		texture.setImage(Assets.getImage("assets/images/peote_tiles.png"));
		program.setTexture(texture, "custom");
		*/
	}
	
	override function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		display.zoom *= 2;	
	}

	override function onMouseMove (x:Float, y:Float):Void {}
	override function onMouseUp (x:Float, y:Float, button:MouseButton):Void {}

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
