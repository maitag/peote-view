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

import elements.ElementSimple;

class TextureSimple
{
	var peoteView:PeoteView;
	var element:ElementSimple;
	var buffer:Buffer<ElementSimple>;
	var display:Display;
	var program:Program;
	var texture:Texture;
	
	public function new(window:Window)
	{	
		peoteView = new PeoteView(window.context, window.width, window.height);
		display   = new Display(10,10, window.width-20, window.height-20, Color.GREEN);
		peoteView.addDisplay(display);  // display to peoteView
		
		buffer  = new Buffer<ElementSimple>(100);
		program = new Program(buffer);
		
		texture = new Texture(512, 512);
		//program.setTextureLayer(0, [texture]);
		
		display.addProgram(program);    // programm to display

		element  = new ElementSimple(10, 10);
		buffer.addElement(element);     // element to buffer
		
		var future = Image.loadFromFile("assets/images/peote_tiles.png");
		future.onProgress (function (a:Int,b:Int) trace ('loading image $a/$b'));
		future.onError (function (msg:String) trace ("Error: "+msg));
		future.onComplete (function (image:Image) {
			trace("loading complete");
			
			//texture = new Texture(image.width, image.height);
			texture.setImage(image);
			
			program.setTexture(texture, "custom");
			program.updateTextures();
			
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
				else program.addTexture(texture, "custom");
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