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
import peote.view.utils.Util;
import peote.view.Element;

import peote.ui.Gl3Font;

#if isInt
class Elem implements Element { // signed 2 bytes integer
	@posX public var x:Int; 
	@posY public var y:Int;
	
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	@texX public var tx:Int;
	@texY public var ty:Int;
	@texW public var tw:Int;
	@texH public var th:Int;
	
	@color("COL") public var c:Color;	
	public function new(positionX:Int=0, positionY:Int=0, c:Int=0xddddddff ) {
		this.x = positionX;
		this.y = positionY;
		this.c = c;
	}
}
#else
class Elem implements Element { // 4 bytes float
	@posX public var x:Float; 
	@posY public var y:Float;
	
	@sizeX public var w:Float;
	@sizeY public var h:Float;
	
	@texX public var tx:Float;
	@texY public var ty:Float;
	@texW public var tw:Float;
	@texH public var th:Float;

	@color("COL") public var c:Color;
	public function new(positionX:Float=0, positionY:Float=0, c:Int=0xddddddff ) {
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
	var timer:Timer;
	
	public function new(window:Window)
	{
		try{	
			peoteView = new PeoteView(window.context, window.width, window.height);
			display   = new Display(10,10, window.width-20, window.height-20, Color.GREY1);
			peoteView.addDisplay(display);  // display to peoteView
			
			buffer  = new Buffer<Elem>(10000);
			program = new Program(buffer);
			
			
			//loadFont("assets/gl3fonts/DejavuSans", true,
			
			// no kerning (much faster then to convert fontdata!) for the u n i glyphes
			loadFont("assets/gl3fonts/unifont/unifont_0000-0fff", false, 
			//loadFont("assets/gl3fonts/unifont/unifont_1000-1fff", false,
			//loadFont("assets/gl3fonts/unifont/unifont_3000-3fff", false,
				function(gl3font:Gl3Font, image:Image, isKerning:Bool)
				{
					var texture = new Texture(image.width, image.height, 1, 4, false, 1, 1);
					texture.setImage(image);
					program.setTexture(texture, "TEX");
					display.addProgram(program);    // programm to display
					
					var bold = Util.toFloatString(0.48);
					var sharp = Util.toFloatString(0.5);
					program.setColorFormula('COL * smoothstep( $bold - $sharp * fwidth(TEX.r), $bold + $sharp * fwidth(TEX.r), TEX.r)');
					
					// for unifont + INT is this best readable (but good not scalable and not not for all letters!!!) at fixed scale 16 ( or 32.. etc)
					//program.setColorFormula('COL * smoothstep( 0.5, 0.5, TEX.r)');
					
					renderTextLine(	100, 4, 16, gl3font, image.width, image.height, isKerning,
						"Unifont Test with peote-view and gl3font"
					);
					renderTextLine(	100, 30, 16, gl3font, image.width, image.height, isKerning,
						" -> move the display with cursorkeys (more speed with shift)"
					);
					renderTextLine(	100, 50, 16, gl3font, image.width, image.height, isKerning,
						" -> zoom the display with numpad +- (shift is zooming the view)"
					);
					
					var i:Int = 0;
					var l:Int = 90;
					var c:Int = 0;
					var s = new haxe.Utf8();
					for (char in gl3font.idmap)
					{
						s.addChar( char );
						//s.addChar( char + 0x1000);
						//s.addChar( char + 0x3000);
						i++; c++;
						if (i > 100) {
							//trace("charnumber:",c,"line:",l);
							renderTextLine( 30, l, 16, gl3font, image.width, image.height, isKerning, s.toString());
							i = 0; s = new haxe.Utf8(); l += 26;
						}
					}
					
				}
			);
			
			
			timer = new Timer(40); zoomIn();
			
			
		} catch (e:Dynamic) trace("ERROR:", e);
		// ---------------------------------------------------------------
	}

	public function loadFont(font:String, isKerning:Bool, onLoad:Gl3Font->Image->Bool->Void)
	{
		bytesFromFile(font+".dat", function(bytes:Bytes) {
			var gl3font = new Gl3Font(bytes, isKerning); // TODO: use a Future here to calculate while loading image!
			imageFromFile(font+".png", function(image:Image) {
				onLoad(gl3font, image, isKerning);
			});
		});						
	}
	
	public function renderTextLine(x:Float, y:Float, scale:Float, gl3font:Gl3Font, imgWidth:Int, imgHeight:Int, isKerning:Bool, text:String)
	{
		var penX:Float = x;
		var penY:Float = y;
		
		var prev_id:Int = -1;
		
		try{
			haxe.Utf8.iter(text, function(charcode)
			{
				//trace("charcode", charcode);
				var id:Null<Int> = gl3font.idmap.get(charcode);
				
				if (id != null)
				{
					#if isInt
					if (isKerning && prev_id != -1) { // KERNING
						penX += Math.ceil(gl3font.kerning[prev_id][id] * scale);
						//trace("kerning to left letter: " + Math.round(gl3font.kerning[prev_id][id]* scale) );
					}
					prev_id = id;
					
					//trace(charcode, "h:"+gl3font.metrics[id].height, "t:"+gl3font.metrics[id].top );
					element  = new Elem(
						Math.floor((penX + gl3font.metrics[id].left * scale )),
						Math.floor((penY + ( gl3font.height - gl3font.metrics[id].top ) * scale ))
					);
					
					penX += Math.ceil(gl3font.metrics[id].advance * scale);

					element.w  = Math.ceil( gl3font.metrics[id].width  * scale );
					element.h  = Math.ceil( gl3font.metrics[id].height * scale );
					element.tx = Math.floor(gl3font.metrics[id].u * imgWidth );
					element.ty = Math.floor(gl3font.metrics[id].v * imgHeight);
					element.tw = Math.floor(1+gl3font.metrics[id].w * imgWidth );
					element.th = Math.floor(1+gl3font.metrics[id].h * imgHeight);
					#else
					if (isKerning && prev_id != -1) { // KERNING
						penX += gl3font.kerning[prev_id][id] * scale;
						//trace("kerning to left letter: " + Math.round(gl3font.kerning[prev_id][id]* scale) );
					}
					prev_id = id;
					
					//trace(charcode, "h:"+gl3font.metrics[id].height, "t:"+gl3font.metrics[id].top );
					element  = new Elem(
						penX + gl3font.metrics[id].left * scale,
						penY + ( gl3font.height - gl3font.metrics[id].top ) * scale
					);
					
					penX += gl3font.metrics[id].advance * scale;

					element.w  = gl3font.metrics[id].width  * scale;
					element.h  = gl3font.metrics[id].height * scale;
					element.tx = gl3font.metrics[id].u * imgWidth;
					element.ty = gl3font.metrics[id].v * imgHeight;
					element.tw = gl3font.metrics[id].w * imgWidth;
					element.th = gl3font.metrics[id].h * imgHeight;
					#end
					buffer.addElement(element);     // element to buffer
				}
			});
		} catch (e:Dynamic) trace("ERR", e); // <-- problem with utf8 and neko breaks haxe.Utf8.iter()
	}
	
	public function imageFromFile(filename:String, onLoad:Image->Void):Void {
		trace('load image $filename');
		var future = Image.loadFromFile(filename);
		future.onProgress (function (a:Int,b:Int) trace ('...loading image $a/$b'));
		future.onError (function (msg:String) trace ("Error: "+msg));
		future.onComplete (function (image:Image) {
			trace('loading $filename complete');
			onLoad(image);
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
	
	var isZooming:Bool = false;
	public function zoomIn() {
		var fz:Float = 1.0;		
		timer.run = function() {
			if (isZooming) {
				if (fz < 10.0) fz *= 1.01; else zoomOut();
				display.zoom = fz;
			}
		}
	}
	
	public function zoomOut() {
		var fz:Float = 10.0;
		timer.run = function() {
			if (isZooming) {
				if (fz > 1.0) fz /= 1.01; else zoomIn();
				display.zoom = fz;
			}
		}
	}
	
	public function onPreloadComplete ():Void {
		// sync loading did not work with html5!
		// texture.setImage(Assets.getImage("assets/images/wabbit_alpha.png"));
	}
	
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		isZooming = ! isZooming;
	}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{	
		switch (keyCode) {
			case KeyCode.NUMPAD_PLUS:
					if (modifier.shiftKey) peoteView.zoom+=0.01;
					else display.zoom+=0.1;
			case KeyCode.NUMPAD_MINUS:
					if (modifier.shiftKey) peoteView.zoom-=0.01;
					else display.zoom -= 0.1;
			case KeyCode.UP: display.yOffset -= (modifier.shiftKey) ? 8 : 1;
			case KeyCode.DOWN: display.yOffset += (modifier.shiftKey) ? 8 : 1;
			case KeyCode.RIGHT: display.xOffset += (modifier.shiftKey) ? 8 : 1;
			case KeyCode.LEFT: display.xOffset -= (modifier.shiftKey) ? 8 : 1;
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
		display.width  = width - 20;
		display.height = height - 20;
	}

}
#end