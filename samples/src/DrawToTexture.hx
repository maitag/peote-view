package;

import haxe.Timer;
import haxe.CallStack;

import lime.app.Application;
import lime.graphics.RenderContext;
import lime.graphics.ImageBuffer;
import lime.graphics.ImageFileFormat;
import lime.graphics.PixelFormat;
import lime.graphics.Image;
import lime.ui.MouseWheelMode;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.utils.UInt8Array;

import peote.view.PeoteGL;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Texture;
import peote.view.Element;

class ElemCanvas implements Element
{
	@sizeX public var w:Float;	
	@sizeY public var h:Float;
	
	@color public var c:Color = 0xffff00ff;
		
	public function new(w:Float=800, h:Float=600, c:Int=0xFFFF00FF )
	{
		this.w = w;
		this.h = h;
		this.c = c;
	}
}

class ElemPen implements Element
{
	@posX public var x:Float;
	@posY public var y:Float;
		
	@sizeX public var w:Float;	
	@sizeY public var h:Float;
	
	@pivotX @const @formula("w/2.0") public var px:Float;
	@pivotY @const @formula("h/2.0") public var py:Float;
	
	@color public var c:Color = 0xffff00ff;
		
	public function new(x:Float=0, y:Float=0, w:Float=10, h:Float=10, c:Int=0xFFFF00FF )
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.c = c;
	}
}

class DrawToTexture extends Application
{
	var peoteView:PeoteView;

	var textureCanvas:Texture; // texture to draw into
	
	var displayCanvas:Display;
	var bufferCanvas:Buffer<ElemCanvas>;
	var programCanvas:Program;
	var elemCanvas:ElemCanvas;

	var displayPen:Display;
	var bufferPen:Buffer<ElemPen>;
	var programPen:Program;
	var elemPen:ElemPen;
	
	var isDraw = false;
	
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
		
		// ----------- texture to render into ------------------------
		
		textureCanvas = new Texture(800, 600); // 2 Slots
		textureCanvas.clearOnRenderInto = false; // do not clear the texture before rendering into
		
		
		
		// -- display that holds only one element with the texture what is drawed into
		
		displayCanvas = new Display(0, 0, 800, 600, Color.BLUE);
		peoteView.addDisplay(displayCanvas);
		
		bufferCanvas  = new Buffer<ElemCanvas>(1);
		programCanvas = new Program(bufferCanvas);
		
		programCanvas.setTexture(textureCanvas, "renderFrom");
		//programCanvas.setColorFormula('renderFrom');
		programCanvas.alphaEnabled = true;
		programCanvas.discardAtAlpha(null);
		displayCanvas.addProgram(programCanvas);
		
		elemCanvas = new ElemCanvas(800, 600);
		bufferCanvas.addElement(elemCanvas);
		
		
		
		// ------ display to render the pen and into the texture -------------------
		
		displayPen = new Display(0, 0, 800, 600);
		peoteView.addDisplay(displayPen);
		peoteView.addFramebufferDisplay(displayPen); // add also to the hidden RenderList for updating the Framebuffer Textures
		//displayPen.renderFramebufferSkipFrames = 2; // at 1/3 framerate (after render a frame skip 2)
		displayPen.renderFramebufferEnabled = false;
		
		bufferPen  = new Buffer<ElemPen>(100);
		programPen = new Program(bufferPen);
		
		displayPen.addProgram(programPen);
		
		// Pen Element
		elemPen = new ElemPen(100, 100, 10, 10, Color.RED);
		bufferPen.addElement(elemPen);				
		
		displayPen.setFramebuffer(textureCanvas); // texture to render into
		//peoteView.setFramebuffer(displayPen, textureCanvas); // <- alternatively (if displayPen is not added to renderlist or to framebuffer-renderlist!)		
		
		// display.removeFramebuffer(); // to unbind (is need before using this texture into different gl-context!)	
		
		
		// ------------  Render into Texture permanently ---------------
		
		peoteView.start();
	}
	
	// ----------- Lime events ------------------

	override function onMouseMove (x:Float, y:Float):Void
	{
		elemPen.x = x;
		elemPen.y = y;
		bufferPen.updateElement(elemPen);
		
		// draws while hold left-shift key down (diffs on native vs html5 timings!)
		if (isDraw) peoteView.renderToTexture(displayPen);
	}
	
	override function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		// start drawign the hidden Frambuffer-Renderlist while holding mouse down
		displayPen.renderFramebufferEnabled = true;
	}
	
	override function onMouseUp (x:Float, y:Float, button:MouseButton):Void
	{
		// stop drawign the hidden Frambuffer-Renderlist
		displayPen.renderFramebufferEnabled = false;
	}
	
/*	override function onMouseWheel (dx:Float, dy:Float, mode:MouseWheelMode)
	{
		if (dy > 0)	peoteView.zoom += 0.1;
		else if (dy < 0) peoteView.zoom -= 0.1;
	}
*/
	override function onKeyUp (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.LEFT_SHIFT: isDraw = false;
			default:
		}
	}

	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.LEFT_SHIFT: isDraw = true;
			case KeyCode.SPACE:
				
				trace("save image");
				
				// data what holds the rgba-imagedata
				var data = textureCanvas.readPixelsUInt8(0, 0, 800, 600);

				// convert into lime Image
				var imageBuffer = new ImageBuffer(data, 800, 600, 32, PixelFormat.RGBA32);
				imageBuffer.format = RGBA32;
				var image = new Image(imageBuffer);

				// encode image format
				var format = ImageFileFormat.PNG;
				//var format = ImageFileFormat.JPEG;
				//var format = ImageFileFormat.BMP;
				
				var imageData = image.encode(format);
				
				// save into file
				var fileName = "picture." + switch (format) {
					case JPEG:"jpg";
					case BMP:"bmp";
					default: "png";
				};
				
				#if html5
					var arrayBuffer:js.lib.ArrayBuffer = imageData.getData();					
					var blob = new js.html.Blob([arrayBuffer]);
					var url = js.html.URL.createObjectURL(blob);
					var anchor = js.Browser.document.createAnchorElement();
					anchor.href = url;
					anchor.download = fileName;
					anchor.click();				
				#else
					var fileOutput =  sys.io.File.write(fileName, true);
					fileOutput.writeBytes(imageData, 0, imageData.length);
					fileOutput.close();
				#end
				
			default:
		}
	}
	
}
