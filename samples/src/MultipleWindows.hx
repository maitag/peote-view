package;

import haxe.Timer;

import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.MouseButton;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Window;
import lime.graphics.Image;

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
	
	@texTile var tile:Int = 1;
	
	@color public var c:Color = 0xff0000ff;
	
	var OPTIONS = { alpha:true };
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=10, height:Int=10, c:Int=0xFF0000FF )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.c = c;
	}
}

class MultipleWindows extends Application
{	
	var peoteView_1:PeoteView;
	var display_1  :Display;
	var program_1  :Program;
	var buffer_1   :Buffer<Elem>;
	var texture_1  :Texture;
	
	var peoteView_2:PeoteView;
	var display_2  :Display;
	var program_2  :Program;
	var buffer_2   :Buffer<Elem>;
	var texture_2  :Texture;
	
	var peoteView_3:PeoteView;
	var display_3  :Display;
	var program_3  :Program;
	var buffer_3   :Buffer<Elem>;
	
	public function new() {	super(); }
	
	public override function onWindowCreate():Void {
		
		window.context.attributes.background = 1;
		
		peoteView_1 = new PeoteView(window);
		display_1   = new Display(10, 10, window.width - 20, window.height - 20, Color.GREEN);
		buffer_1    = new Buffer<Elem>(100);
		program_1   = new Program(buffer_1);
		/*texture_1   = new Texture(512, 512); texture_1.tilesX = texture_1.tilesY = 16;
		program_1.setTexture(texture_1, "custom");
		loadImage(texture_1, "assets/images/peote_tiles.png");
		*/
		display_1.addProgram(program_1);
		peoteView_1.addDisplay(display_1);
		
		window.onMouseDown.add (onMouseDown_1.bind (window));
		window.onKeyDown.add   (onKeyDown_.bind (window));
		
		
		Timer.delay( function() {
			createWindow_2();
		}, 1000);
		
		Timer.delay( function() {
			createwindow_3();
		}, 2000);
		
	}
	
	private function createWindow_2():Void
	{
		#if desktop
		var attributes = {	title: "Window_2", x:0, y:0, width: 600, height: 800, resizable:true,
		                    context: { background: 2 }  };
		var window = createWindow(attributes);
		#end
		
		peoteView_2 = new PeoteView(window);
		display_2   = new Display(10, 10, window.width - 20, window.height - 20, Color.BLUE);
		buffer_2    = new Buffer<Elem>(100);
		program_2   = new Program(buffer_2);
		/*texture_2   = new Texture(512, 512); texture_2.tilesX = texture_2.tilesY = 16;
		program_2.setTexture(texture_2, "custom");
		loadImage(texture_2, "assets/images/peote_tiles_bunnys.png");
		*/
		display_2.addProgram(program_2);
		peoteView_2.addDisplay(display_2);
		
		#if desktop
		window.onMouseDown.add (onMouseDown_2.bind(window));
		window.onKeyDown.add   (onKeyDown_.bind   (window));
		#end
	}
	
	private function createwindow_3():Void
	{
		#if desktop
		var attributes = {	title: "window_3", x:0, y:0, width: 800, height: 580, resizable:true,
		                    context: { background: 3 }  };
		var window = createWindow(attributes);
		#end
		
		peoteView_3 = new PeoteView(window);
		display_3   = new Display(10, 10, window.width - 20, window.height - 20, Color.YELLOW);
		buffer_3    = new Buffer<Elem>(100);
		program_3   = new Program(buffer_3);
		display_3.addProgram(program_3);
		peoteView_3.addDisplay(display_3);
		
		#if desktop
		window.onMouseDown.add (onMouseDown_3.bind(window));
		window.onKeyDown.add   (onKeyDown_.bind   (window));
		#end
	}
	
	// load image into texture
	public function loadImage(texture:Texture, filename:String):Void
	{
		trace('load image $filename');
		var future = Image.loadFromFile(filename);
		future.onProgress (function (a:Int,b:Int) trace ('...loading image $a/$b'));
		future.onError (function (msg:String) trace ("Error: "+msg));
		future.onComplete (function (image:Image) {
			trace('loading $filename complete');
			texture.setImage(image);
		});		
	}
	
	
	// ------------------------------------------------------------	
	// ----------- spawn new element on mouse down ----------------
	// ------------------------------------------------------------	
	var elem_1:Int = 0;
	private function onMouseDown_1 (window:Window, x:Float, y:Float, button:MouseButton):Void
	{
		trace("onMouseDown_1:", window.context.attributes.background); 
		buffer_1.addElement(new Elem(10 + 12 * elem_1++, 10));
	}
	
	var elem_2:Int = 0;
	private function onMouseDown_2 (window:Window, x:Float, y:Float, button:MouseButton):Void
	{	
		trace("onMouseDown_2:", window.context.attributes.background);
		buffer_2.addElement(new Elem(5, 5 + 12 * elem_2++));
	}
	
	var elem_3:Int = 0;
	private function onMouseDown_3 (window:Window, x:Float, y:Float, button:MouseButton):Void
	{	
		trace("onMouseDown_3:", window.context.attributes.background);
		buffer_3.addElement(new Elem(10 + 12 * elem_3++, 10));
	}
	
	// ------------------------------------------------------------	
	// ---------------------  keyboardhandler ---------------------
	// ------------------------------------------------------------	
	private function onKeyDown_ (window:Window, keyCode:KeyCode, modifier:KeyModifier):Void
	{
		try
		switch (keyCode) {
			case KeyCode.F:
				window.fullscreen = !window.fullscreen;
			case KeyCode.D:                                  // switching displays
				if (peoteView_1.hasDisplay(display_1))
				{
					peoteView_1.removeDisplay(display_1);
					peoteView_2.addDisplay(display_1);
					peoteView_2.removeDisplay(display_2);
					peoteView_1.addDisplay(display_2);
				} else {
					peoteView_2.removeDisplay(display_1);
					peoteView_1.addDisplay(display_1);
					peoteView_1.removeDisplay(display_2);
					peoteView_2.addDisplay(display_2);
				}
			case KeyCode.P:                                  // switching programs
				if (display_1.hasProgram(program_1))
				{	
					display_1.removeProgram(program_1);
					display_2.addProgram(program_1);
					//display_2.removeProgram(program_2);
					//display_1.addProgram(program_2);
				} else {
					display_2.removeProgram(program_1);
					display_1.addProgram(program_1);
					//display_1.removeProgram(program_2);
					//display_2.addProgram(program_2);
				}
			case KeyCode.NUMBER_1:
				Timer.delay( function() {
					buffer_1.addElement(new Elem(10 + 12 * elem_1++, 10));
				}, 100);
			case KeyCode.NUMBER_2:
				Timer.delay( function() {
					buffer_2.addElement(new Elem(5, 5 + 12 * elem_2++));
				}, 200);
			case KeyCode.NUMBER_3:
				Timer.delay( function() {
					buffer_3.addElement(new Elem(10 + 12 * elem_3++, 10));
				}, 300);
			default:
		}
		catch (msg:String) {trace("ERROR", msg); }
	}
	
	
	
}
