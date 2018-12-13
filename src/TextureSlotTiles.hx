package;
#if sampleTextureSlotTiles
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
	
	// what texture-slot to use
	@texSlot public var slot:Int;  // unsigned 2 bytes integer

	// manual texture coordinates inside a slot (or inside all slots if no slot available)
	//@texX public var tx:Int;
	//@texY public var ty:Int;
	//@texW public var tw:Int=512;
	//@texH public var th:Int=512;
	
	// tiles the slot or manual texture-coordinate into sub-slots
	@texTile() public var tile:Int;  // unsigned 2 bytes integer

	//TODO: let the texture shift inside slot/texCoords/tile area
	//@texOffsetX("color") public var txOffset:Int;
	//@texOffsetY("color") public var tyOffset:Int;
	
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100 )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
	}


}
class TextureSlotTiles
{
	var peoteView:PeoteView;
	var element:Elem;
	var buffer:Buffer<Elem>;
	var display:Display;
	var program:Program;
	var texture:Texture;
	
	public function new(window:Window)
	{	
		try {
			peoteView = new PeoteView(window.context, window.width, window.height);
			display   = new Display(10,10, window.width-20, window.height-20, Color.GREEN);
			peoteView.addDisplay(display);  // display to peoteView
			
			buffer  = new Buffer<Elem>(100);
			program = new Program(buffer);
			
			display.addProgram(program);    // programm to display

			texture = new Texture(400, 300, 10);

			loadImage(texture, "assets/images/test0.png", 0);
			loadImage(texture, "assets/images/test1.png", 1);
			loadImage(texture, "assets/images/test2.png", 2);
			loadImage(texture, "assets/images/test3.png", 3);
			
			program.colorFormula = 't${Elem.LAYER_CUSTOM_0}';
			program.addTexture(texture);
			program.updateTextures();
			
			element  = new Elem(0, 0, 200, 150);
			buffer.addElement(element);     // element to buffer
			
		}
		catch (msg:String) {trace("ERROR", msg); }
	
				
		// ---------------------------------------------------------------
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
			case KeyCode.NUMBER_0: element.slot = 0; buffer.updateElement(element);
			case KeyCode.NUMBER_1: element.slot = 1; buffer.updateElement(element);
			case KeyCode.NUMBER_2: element.slot = 2; buffer.updateElement(element);
			case KeyCode.NUMBER_3: element.slot = 3; buffer.updateElement(element);
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