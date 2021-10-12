package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;

import peote.view.PeoteGL;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Element;
import peote.view.UniformFloat;


// -------- simple procedural sinus wave --------
class SinWave implements Element
{
	//@posX @formula("x+uTime*100.0") public var x:Int;
	@posX public var x:Int;
	@posY public var y:Int;
	
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	
	static public var buffer:Buffer<SinWave>;
	static public var program:Program;

	static public function init(display:Display, uniforms:Array<UniformFloat>) {
		buffer = new Buffer<SinWave>(100);
		program = new Program(SinWave.buffer);
		
		// test whats up if uTime is also used insid vertex shader (same as if using @anim)
		// program.injectIntoVertexShader(true);
		
		program.injectIntoFragmentShader(
			"
				//#define PI 3.14159265359
				#define TWO_PI 6.28318530718

				vec4 sinwave( vec2 texcoord )
				{
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
			",
			true, // to enable uTime uniform
			uniforms // set custom uniforms to use in shader or into Elements @formulas
		);
		
		program.setColorFormula('sinwave(vTexCoord)');
		
		#if (html5)
		// On webgl the default fragmentFloatPrecision is "medium" and shared uniforms
		// between vertex- and fragmentshader have to be the same precision!
		// program.setFragmentFloatPrecision("high");
		#end
		
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
	
	var linesize:UniformFloat;
	
	
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
		
		// init custom uniforms
		linesize = new UniformFloat("linesize", 0.1);
		
		SinWave.init(display, [linesize]); new SinWave(0, 0, 314, 100);
		
		peoteView.start();
	}
	
	// ----------- Lime events ------------------

	override function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		if (!peoteView.isRun) peoteView.start();
		else peoteView.stop();
	}
	
	override function onKeyDown(keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.NUMBER_1:
			default:
		}
		
	}
	
	override function onMouseMove (x:Float, y:Float):Void
	{
		linesize.value = x / window.width;
	}

}
