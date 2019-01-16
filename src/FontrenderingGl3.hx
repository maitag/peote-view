package;
#if sampleFontrenderingGl3
import haxe.Timer;
import haxe.io.Bytes;

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

import peote.ui.Gl3Font;

#if isInt
class Elem implements peote.view.Element { // signed 2 bytes integer
	@posX public var x:Int; 
	@posY public var y:Int;
	
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	@texX() public var tx:Int;
	@texY() public var ty:Int;
	@texW() public var tw:Int;
	@texH() public var th:Int;
	
	@color public var c:Color = 0xffffffff;	
	public function new(positionX:Int=0, positionY:Int=0, c:Int=0xffffffff ) {
		this.x = positionX;
		this.y = positionY;
		this.c = c;
	}
}
#else
class Elem implements peote.view.ElementFloat { // 4 bytes float
	@posX public var x:Float; 
	@posY public var y:Float;
	
	@sizeX public var w:Float;
	@sizeY public var h:Float;
	
	@texX() public var tx:Float;
	@texY() public var ty:Float;
	@texW() public var tw:Float;
	@texH() public var th:Float;

	@color public var c:Color = 0xffffffff;
	public function new(positionX:Float=0, positionY:Float=0, c:Int=0xffffffff ) {
		this.x = positionX;
		this.y = positionY;
		this.c = c;
	}
}
#end

class FontrenderingGl3
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
		display   = new Display(10,10, window.width-20, window.height-20, Color.GREY1);
		peoteView.addDisplay(display);  // display to peoteView
		
		buffer  = new Buffer<Elem>(100);
		program = new Program(buffer);
		
		display.addProgram(program);    // programm to display

		// TODO: snap to every second pixel while animation
		
		loadFont("assets/gl3fonts/unifont/unifont_0000-0fff", false,
		//loadFont("assets/gl3fonts/DejavuSans", true,
			function(texture:Texture, info:Gl3Font, imgWidth:Int, imgHeight:Int, isKerning:Bool)
			{
				program.setTexture(texture, "t");
				var bold = 0.47;
				program.setColorFormula('c0 * smoothstep( $bold - fwidth(t.r), $bold + fwidth(t.r), t.r)');
			
				renderText(	10, 50, 16, info, imgWidth, imgHeight, isKerning,
					"Hello World (yiö) 1.23 a^2 abcdefgHIJKLMNOP XYZ | # _- .,*/"
				);
			}
		);
		// ---------------------------------------------------------------
	}
	
	public function loadFont(font:String, isKerning:Bool, onLoad:Texture->Gl3Font->Int->Int->Bool->Void)
	{
		bytesFromFile(font+".dat", function(bytes:Bytes) {
			var info = new Gl3Font(bytes, isKerning); // TODO: use a Future here to calculate while loading image!
			textureFromImageFile(font+".png", function(texture:Texture, imgWidth:Int, imgHeight:Int) {
				onLoad(texture, info, imgWidth, imgHeight, isKerning);	
			});
		});						
	}
	
	public function renderText(x:Int, y:Int, scale:Float, info:Gl3Font, imgWidth:Int, imgHeight:Int, isKerning:Bool, text:String)
	{
		var penX:Float = x;
		var penY:Float = y;
		
		var prev_id:Int = -1;
		haxe.Utf8.iter(text, function(charcode)
		{
			var id:Null<Int> = info.idmap.get(charcode);
			
			if (id != null)
			{
				#if isInt
				if (isKerning && prev_id != -1) { // KERNING
					penX += Math.ceil(info.kerning[prev_id][id] * scale);
					//trace("kerning to left letter: " + Math.round(info.kerning[prev_id][id]* scale) );
				}
				prev_id = id;
				
				trace(charcode, "h:"+info.metrics[id].height, "t:"+info.metrics[id].top );
				element  = new Elem(
					Math.floor((penX + info.metrics[id].left * scale )),
					Math.floor((penY + ( info.height - info.metrics[id].top ) * scale ))
				);
				
				penX += info.metrics[id].advance * scale;

				element.w  = Math.ceil( info.metrics[id].width  * scale );
				element.h  = Math.ceil( info.metrics[id].height * scale );
				element.tx = Math.floor(info.metrics[id].u * imgWidth );
				element.ty = Math.floor(info.metrics[id].v * imgHeight);
				element.tw = Math.floor(1+info.metrics[id].w * imgWidth );
				element.th = Math.floor(1+info.metrics[id].h * imgHeight);
				#else
				if (isKerning && prev_id != -1) { // KERNING
					penX += info.kerning[prev_id][id] * scale;
					//trace("kerning to left letter: " + Math.round(info.kerning[prev_id][id]* scale) );
				}
				prev_id = id;
				
				//trace(charcode, "h:"+info.metrics[id].height, "t:"+info.metrics[id].top );
				element  = new Elem(
					penX + info.metrics[id].left * scale,
					penY + ( info.height - info.metrics[id].top ) * scale
				);
				
				penX += info.metrics[id].advance * scale;

				element.w  = info.metrics[id].width  * scale;
				element.h  = info.metrics[id].height * scale;
				element.tx = info.metrics[id].u * imgWidth;
				element.ty = info.metrics[id].v * imgHeight;
				element.tw = info.metrics[id].w * imgWidth;
				element.th = info.metrics[id].h * imgHeight;
				#end
				buffer.addElement(element);     // element to buffer
			}
			
		});
	}
	
	public function textureFromImageFile(filename:String, onLoad:Texture->Int->Int->Void):Void {
		trace('load image $filename');
		var future = Image.loadFromFile(filename);
		future.onProgress (function (a:Int,b:Int) trace ('...loading image $a/$b'));
		future.onError (function (msg:String) trace ("Error: "+msg));
		future.onComplete (function (image:Image) {
			trace('loading $filename complete');
			var texture = new Texture(image.width, image.height, 1, 4, false, 1, 1);
			texture.setImage(image);
			onLoad(texture, image.width, image.height);
		});		
	}
	
	public function bytesFromFile(filename:String, onLoad:Bytes->Void):Void {
		var future = lime.utils.Bytes.loadFromFile(filename);
		future.onProgress (function (a:Int,b:Int) trace ('loading bytes $a/$b'));
		future.onError (function (msg:String) trace ("Error: "+msg));
		future.onComplete (function (bytes:Bytes) {
			trace("loading bytes complete");
			onLoad(bytes);
		});
	}
	
	public function onPreloadComplete ():Void {
		// sync loading did not work with html5!
		// texture.setImage(Assets.getImage("assets/images/wabbit_alpha.png"));
	}
	
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		
	}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{	
		switch (keyCode) {
			case KeyCode.NUMPAD_PLUS:
					if (modifier.shiftKey) display.zoom+=0.01;
					else peoteView.zoom+=0.1;
			case KeyCode.NUMPAD_MINUS:
					if (modifier.shiftKey) display.zoom-=0.01;
					else peoteView.zoom -= 0.1;
			case KeyCode.UP: display.yOffset -= (modifier.shiftKey) ? 2 : 1;
			case KeyCode.DOWN: display.yOffset += (modifier.shiftKey) ? 2 : 1;
			case KeyCode.RIGHT: display.xOffset += (modifier.shiftKey) ? 2 : 1;
			case KeyCode.LEFT: display.xOffset -= (modifier.shiftKey) ? 2 : 1;
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