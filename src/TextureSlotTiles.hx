package;
#if sampleTextureSlotTiles
import haxe.Timer;

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
	
	// unit (index of texture-array while set a TextureLayer)
	@texUnit() public var unit:Int;

	// what texture-slot to use
	@texSlot  @anim("Slot")
	public var slot:Int;  // unsigned 2 bytes integer
	
	// tiles the slot or manual texture-coordinate into sub-slots
	@texTile() @anim("Tile")
	public var tile:Int;  // unsigned 2 bytes integer

	var OPTIONS = { alpha:true };
	
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
	var element0:Elem;
	var element1:Elem;
	var element2:Elem;
	var buffer:Buffer<Elem>;
	var display:Display;
	var program:Program;
	var texture0:Texture;
	var texture1:Texture;
	
	public function new(window:Window)
	{	
		try {
			peoteView = new PeoteView(window.context, window.width, window.height);
			display   = new Display(10,10, window.width-20, window.height-20, Color.BLUE);
			peoteView.addDisplay(display);  // display to peoteView
			
			buffer  = new Buffer<Elem>(100);
			program = new Program(buffer);
			
			display.addProgram(program);    // programm to display

			texture0 = new Texture(400, 300, 4);

			loadImage(texture0, "assets/images/test0.png", 0);
			loadImage(texture0, "assets/images/test1.png", 1);
			loadImage(texture0, "assets/images/test2.png", 2);
			loadImage(texture0, "assets/images/test3.png", 3);
			
			program.discardAtAlpha(0.3, false);
			program.addTexture(texture0, "custom", false);
			//program.updateTextures();
			
			element0  = new Elem(0, 0, 200, 150);
			element0.slot = 0;
			buffer.addElement(element0);     // element to buffer
			
			texture1 = new Texture(512, 512, 3);
			texture1.tilesX = texture1.tilesY = 16;
			
			loadImage(texture1, "assets/images/peote_font_green.png", 0);
			loadImage(texture1, "assets/images/peote_tiles.png", 1);
			loadImage(texture1, "assets/images/peote_tiles_bunnys.png", 2);
			
			program.addTexture(texture1, "custom");
			program.updateTextures();
			
			element1  = new Elem(0, 150, 200, 200);
			element1.unit = 1;
			element1.slot = 0;
			element1.tile = 1;
			buffer.addElement(element1);     // element to buffer
			
			// Animated Slot and Tile
			element2  = new Elem(0, 350, 200, 200);
			element2.unit = 1;
			
			var timePerSlot = 10;
			for (i in 0...3)
				Timer.delay(function() {
					trace("Slot " + i);
					element2.animTile(0, (i == 3-1) ? 31 : 32);
					element2.timeTile(i*timePerSlot, timePerSlot);
					buffer.updateElement(element2);
				}, i*timePerSlot*1000);
			
			element2.animSlot(0, 2);
			element2.timeSlot(0, timePerSlot*2);
			
			buffer.addElement(element2);     // element to buffer
			peoteView.start();
		}
		catch (msg:String) {trace("ERROR", msg); }
	
				
		// ---------------------------------------------------------------
	}
	
	public function loadImage(texture:Texture, filename:String, slot:Int=0):Void {
		Loader.image(filename, true, function(image:Image) {
			texture.setImage(image, slot);
		});		
	}
	
	public function onPreloadComplete ():Void { trace("preload complete"); }

	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		element0.x += 100;
		buffer.updateElement(element0);		
	}

	public function onMouseMove (x:Float, y:Float):Void {}
	public function onWindowLeave ():Void {}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		//trace(Type.typeof(keyCode), Type.typeof(KeyCode.NUMBER_1));
		// This did not work on NEKO if there are more then 5 switch-cases!!!
		//switch (keyCode) {
		// neko needs Std.int(keyCode) !!!
		switch (Std.int(keyCode)) {
			case KeyCode.NUMBER_1: element0.slot = (element0.slotStart !=0 ) ? element0.slotStart-1 : 3 ; buffer.updateElement(element0);
			case KeyCode.NUMBER_2: element0.slot = (element0.slotStart+1) % 4; buffer.updateElement(element0);
			case KeyCode.NUMBER_3: element1.slot = (element1.slotStart !=0 ) ? element1.slotStart-1 : 2 ; buffer.updateElement(element1);
			case KeyCode.NUMBER_4: element1.slot = (element1.slotStart+1) % 3; buffer.updateElement(element1);
			case KeyCode.NUMBER_5: element1.tile = (element1.tileStart !=0 ) ? element1.tileStart-1 : 31 ; buffer.updateElement(element1);
			case KeyCode.NUMBER_6: element1.tile = (element1.tileStart+1) % 32; buffer.updateElement(element1);
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