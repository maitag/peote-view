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
import peote.view.Element;

class Elem implements Element
{
	@posX public var x:Int=0; // signed 2 bytes integer
	@posY public var y:Int=0; // signed 2 bytes integer
	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	@color public var c:Color = 0xff0000ff; // same like @color("color")
	@color("shift") public var c1:Color = 0xff0000ff;
	// TODO: make more colors available for program.colorFormula
	// @color("shift") var shiftColor:Color;
		
	//@texUnit() public var unit:Int;  // unit for all other Layers (max 255)
	@texUnit("base") public var unitColor:Int=0;  //  unit for "color" Layers only
	@texUnit("alpha","mask") public var unitAlphaMask:Int;  //  unit for "alpha" and "mask" Layers

	// what texture-slot to use
	@texSlot("base") public var slot:Int;  // unsigned 2 bytes integer

	// manual texture coordinates inside a slot (or inside all slots if no slot available)
	@texX("base") public var tx:Int;
	@texY("base") public var ty:Int;
	//@texW("color") public var tw:Int=512;
	//@texH("color") public var th:Int=512;
	

	// tiles the slot or manual texture-coordinate into sub-slots
	@texTile() public var tile:Int;  // unsigned 2 bytes integer
	@texTile("base", "mask") public var tileColor:Int;  // unsigned 2 bytes integer


	//TODO: let the texture shift inside slot/texCoords/tile area
	//@texOffsetX("color") public var txOffset:Int;
	//@texOffsetY("color") public var tyOffset:Int;
	
	//TODO:generate
	static inline var TEXTURE_LAYER:String = "base,alpha,mask";
	static inline var COLOR_LAYER:String = "shift";
	public var colorFormula:String = "alpha * (c0 * base+shift)"; // default will be a color-vektor
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100, c:Int=0xFF0000FF )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.c = c;
	}


}

class MultiTextures
{
	var peoteView:PeoteView;
	var element:Elem;
	var buffer:Buffer<Elem>;
	var display:Display;
	var program:Program;
	
	var texture0:Texture;
	var texture1:Texture;
	var texture2:Texture;
	
	public function new(window:Window)
	{
		try {
			peoteView = new PeoteView(window.context, window.width, window.height);
			display   = new Display(10,10, window.width-20, window.height-20, Color.GREEN);
			peoteView.addDisplay(display);  // display to peoteView
			
			buffer  = new Buffer<Elem>(100);
			program = new Program(buffer);
			element  = new Elem(0,0, 512, 512);
			buffer.addElement(element);     // element to buffer
			display.addProgram(program);    // programm to display
			
			texture0 = new Texture(512, 512);
			texture1 = new Texture(512, 512);
			texture2 = new Texture(512, 512);
			
			program.setTextures([texture0, texture1, texture2], Elem.TEXTURE_BASE, false);
			program.setTextures([texture0, texture1], Elem.TEXTURE_ALPHA, false);
			program.setTextures([texture1], Elem.TEXTURE_MASK, false);
			program.setTextures([texture2], Elem.TEXTURE_CUSTOM_0 + 1, false);
			
			// c is default color
			// texture-layer colors: t0 - ElementSimple.TEXTURE_BASE, t1 - ElementSimple.TEXTURE_ALPHA ...
			program.colorFormula = 'c0 * t${Elem.TEXTURE_BASE}';
			// TODO: better go with String-Identifiers: "color * (shift+base) * alpha"
						
			program.updateTextures(); // updates gl-textures and also rebuilds the shadercode
			
			
			loadImage(texture0, "assets/images/peote_tiles.png");
			loadImage(texture1, "assets/images/peote_tiles_bunnys.png");
			loadImage(texture2, "assets/images/peote_font_green.png");
			
		}
		catch (msg:String) {trace("ERROR", msg); }
		// ---------------------------------------------------------------		
	}
	
	public function loadImage(texture:Texture, filename:String):Void {
		trace('load image $filename');
		var future = Image.loadFromFile(filename);
		future.onProgress (function (a:Int,b:Int) trace ('...loading image $a/$b'));
		future.onError (function (msg:String) trace ("Error: "+msg));
		future.onComplete (function (image:Image) {
			trace('loading $filename complete');
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