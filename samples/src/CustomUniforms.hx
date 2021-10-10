package;

import haxe.CallStack;

import lime.app.Application;
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


// -------- simple procedural sinus wave --------
class SinWave implements Element
{
	@posX public var x:Int;
	@posY public var y:Int;
	
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	static public var buffer:Buffer<SinWave>;
	static public var program:Program;

	static public function init(display:Display) {
		buffer = new Buffer<SinWave>(100);
		program = new Program(SinWave.buffer);
		program.injectIntoFragmentShader(
		"
			uniform float uTime;

			#define PI 3.14159265359
			#define TWO_PI 6.28318530718

			vec4 sinwave( vec2 texcoord )
			{
				float linesize = 0.2;
				
				texcoord.x += uTime;
				texcoord.x *= TWO_PI;
				texcoord.y *= (1.0 + linesize);
				texcoord.y = 1.0 + linesize - 2.0 * texcoord.y;
								
				float intensity = 0.0;
				
				float y = sin(texcoord.x);
				
				if (y > texcoord.y - linesize && y < texcoord.y + linesize)
				{
					intensity = 1.0;
				}
				
				return vec4( intensity, intensity, intensity, intensity );
			}
		");
		
		program.setColorFormula('sinwave(vTexCoord)');
		program.alphaEnabled = true;
		display.addProgram(program);
	}
	
	public function new(x:Int, y:Int, w:Int, h:Int) {
		this.x = x;	this.y = y;	this.w = w;	this.h = h;
		buffer.addElement(this);
	}	
}

// -------------------------------------------------------------------------------
// -------------------------------------------------------------------------------
// -------------------------------------------------------------------------------

class CustomUniforms extends Application
{
	var peoteView:PeoteView;
	
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
		
		var display   = new Display(10,10, window.width-20, window.height-20, Color.GREEN);
		peoteView.addDisplay(display);
		
		SinWave.init(display); new SinWave(0, 0, 314, 100);
		
		peoteView.start();
	}
	
	// ----------- Lime events ------------------

	override function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		if (!peoteView.isRun) peoteView.start();
		else peoteView.stop();
	}

}
