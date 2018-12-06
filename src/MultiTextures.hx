package;
#if sampleMultiTextures
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

class MultiTextures
{
	var peoteView:PeoteView;
	var element:ElementSimple;
	var buffer:Buffer<ElementSimple>;
	var display:Display;
	var program:Program;
	
	var texture0:Texture;
	var texture1:Texture;
	
	public function new(window:Window)
	{	
		peoteView = new PeoteView(window.context, window.width, window.height);
		display   = new Display(10,10, window.width-20, window.height-20, Color.GREEN);
		peoteView.addDisplay(display);  // display to peoteView
		
		buffer  = new Buffer<ElementSimple>(100);
		program = new Program(buffer);
		element  = new ElementSimple(0,0, 256, 256);
		buffer.addElement(element);     // element to buffer
		display.addProgram(program);    // programm to display
		
		texture0 = new Texture(512, 512);
		texture1 = new Texture(512, 512);

		program.setTextureLayer([texture0], ElementSimple.LAYER_COLOR);
		program.setTextureLayer([texture0, texture1], ElementSimple.LAYER_COLOR);
		program.setTextureLayer([texture1], ElementSimple.LAYER_MASK);
		
		loadImage(texture0, "assets/images/peote_tiles.png");
		loadImage(texture1, "assets/images/peote_tiles_bunnys.png");
		
			
		
				
		// ---------------------------------------------------------------		
	}
	
	public function loadImage(texture:Texture, filename:String):Void {
		trace('load image $filename');
		var future = Image.loadFromFile(filename);
		future.onProgress (function (a:Int,b:Int) trace ('...loading image $a/$b'));
		future.onError (function (msg:String) trace ("Error: "+msg));
		future.onComplete (function (image:Image) {
			trace('loading $filename complete');
			//texture = new Texture(image.width, image.height);
			texture.setImage(image);
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
			case KeyCode.U:
				trace("switch texture unit");
				element.unitColor = 1;
			case KeyCode.R:
				trace("replace texture "); // TODO
				//program.replaceTexture(texture0, texture1);
			case KeyCode.NUMBER_1:
				loadImage(texture0, "assets/images/peote_tiles.png");
			case KeyCode.NUMBER_2:
				loadImage(texture1, "assets/images/peote_tiles_bunnys.png");// TODO: BUG after activating new imagebuffer from second texture
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