package;
#if sampleShaderInjection
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


// --------------------------------------------------- fragment color-spectrum
/*class Elem0 implements Element
{
	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	static public var buffer:Buffer<Elem0>;
	static public var program:Program;

	static public function init(display:Display) {
		buffer = new Buffer<Elem0>(100);
		program = new Program(Elem0.buffer);
		program.injectIntoFragmentShader(
		"
			vec3 hsb2rgb( vec3 c )
			{
				vec3 rgb = clamp( abs( mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0 );
				rgb = rgb * rgb * (3.0 - 2.0 * rgb);
				return (1.0 - c.z) * mix( vec3(1.0), rgb, c.y);
			}
		");
		program.setColorFormula('vec4( hsb2rgb( vec3(vTexCoord.x, 1.0, vTexCoord.y) ), 1.0 )');
		display.addProgram(program);
	}
	
	public function new(positionX:Int=0, positionY:Int=0) {
		this.x = positionX;	this.y = positionY;	buffer.addElement(this);
	}	
}


// --------------------------------------------------- fragment rounded border
class Elem1 implements Element
{
	@color public var borderColor:Color = 0x550000ff; // using propertyname "borderColor" as identifier for setColorFormula()
	@color("bgcolor") public var color:Color=0xffff00ff; // using different identifier "bgcolor" for setColorFormula()
	
	@custom @varying public var borderRadius:Float=25.0; // using propertyname as identifier for setColorFormula()
	@custom("borderSize") @varying public var bSize:Float=10.0;// using different identifier "borderSize" for setColorFormula()
	
	@posX public var x:Int=0;
	@posY public var y:Int=0;	
	@sizeX @varying public var w:Int=100;
	@sizeY @varying public var h:Int=100;
	
	static public var buffer:Buffer<Elem1>;
	static public var program:Program;

	static public function init(display:Display) {
		buffer = new Buffer<Elem1>(100);
		program = new Program(Elem1.buffer);
		program.injectIntoFragmentShader(
		"
			float roundedBox (vec2 pos, vec2 size, float padding, float radius)
			{
				radius -= padding;
				pos = (pos - 0.5) * size;
				size = 0.5 * size - vec2(radius, radius) - vec2(padding, padding);
				float d = length(max(abs(pos), size) - size) - radius;
				return smoothstep( 0.0, 1.0,  d );
			}
			
			float roundedBorder (vec2 pos, vec2 size, float thickness, float radius)
			{
				radius -= thickness / 2.0;
				pos = (pos - 0.5) * size;
				size = 0.5 * (size - vec2(thickness, thickness)) - vec2(radius, radius);
				float s = 0.5 / thickness * 2.0;
				float d = length(max(abs(pos), size) - size) - radius;				
				return smoothstep( 0.5+s, 0.5-s, abs(d / thickness)  );
			}
			
			vec4 compose (vec4 c, vec4 borderColor, float borderSize, float borderRadius)
			{
				float radius =  max(borderSize+1.0, min(borderRadius, min(vSize.x, vSize.y) / 2.0));
				c = mix(c, vec4(0.0, 0.0, 0.0, 0.0), roundedBox(vTexCoord, vSize, borderSize, radius));				
				c = mix(c, borderColor, roundedBorder(vTexCoord, vSize, borderSize, radius)); // TODO: vSize Varyings also via setColorFormula()
				return c;
			}
		");
		
		program.setColorFormula('compose(bgcolor, borderColor, borderSize, borderRadius)');// parsed by color and custom identifiers
		
		program.alphaEnabled = true;
		display.addProgram(program);
	}
	
	public function new(positionX:Int=0, positionY:Int=0) {
		this.x = positionX;	this.y = positionY;	buffer.addElement(this);
	}	
}

// --------------------------------------------------- simple random noise
class Elem2 implements Element
{
	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	static public var buffer:Buffer<Elem2>;
	static public var program:Program;

	static public function init(display:Display) {
		buffer = new Buffer<Elem2>(100);
		program = new Program(Elem2.buffer);
		program.injectIntoFragmentShader(
		"
			float simpleRandom(vec2 co, float seed){
				return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * seed);
			}		
		");
		program.setColorFormula('vec4( vec3(simpleRandom( floor(vTexCoord*5.0), 734502.92731337 )), 1.0 )');
		display.addProgram(program);
	}
	
	public function new(positionX:Int=0, positionY:Int=0) {
		this.x = positionX;	this.y = positionY;	buffer.addElement(this);
	}	
}
*/

// --------------------------------------------------- custom formula for attributes
class Elem3 implements Element
{
	@posX @formula("x - sin(y*0.1)*20.0") public var x:Int=0;
	@posY @anim("Y","pingpong") public var y:Int=0; // @constStart(0) @constEnd(100)
	
	@sizeX @const @formula("100.0 + sin(y*0.1)*40.0") public var w:Int=100;
	@sizeY @const @formula("45.0+time0*45.0")  public var h:Int = 110;
	
	@rotation @const @formula("(h-45.0)*8.0") var r:Float = 30.0;
	
	@pivotX @const @formula("w/2.0") public var px:Int=50;
	@pivotY @const @formula("h/2.0") public var py:Int=50;
	
	static public var buffer:Buffer<Elem3>;
	static public var program:Program;

	static public function init(display:Display) {
		buffer = new Buffer<Elem3>(100);
		program = new Program(Elem3.buffer);
		program.injectIntoVertexShader(
		"
			float simpleRandom(vec2 co, float seed){
				return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * seed);
			}		
		");
		program.setFormula("posY", "x + 50");
		display.addProgram(program);
	}
	
	public function new(positionX:Int=0, positionY:Int=0) {
		this.x = positionX; //this.xEnd = 100;
		this.y = positionY; this.yEnd = 500;
		this.timeYStart = 0.0; this.timeYDuration = 3.0;
		buffer.addElement(this);
	}	
}

// -------------------------------------------------------------------------------
// -------------------------------------------------------------------------------
// -------------------------------------------------------------------------------

class ShaderInjection
{
	var peoteView:PeoteView;
	var display:Display;
	
	public function new(window:Window)
	{
		try {
			peoteView = new PeoteView(window.context, window.width, window.height);
			display   = new Display(10,10, window.width-20, window.height-20, Color.GREEN);
			peoteView.addDisplay(display);
			
/*			Elem0.init(display); new Elem0(  0, 0);
			Elem1.init(display); new Elem1(110, 0);
			Elem2.init(display); new Elem2(220, 0);	
*/			Elem3.init(display); new Elem3(330, 0);		
		} 
		catch (e:Dynamic) trace("ERROR:", e);
	}
	
	public function onPreloadComplete ():Void {}
	
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		if (!peoteView.isRun) peoteView.start();
		else peoteView.stop();
	}

	public function onMouseMove (x:Float, y:Float):Void {}
	public function onWindowLeave ():Void {}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		/*switch (keyCode) {
			case KeyCode.NUMBER_1:
			case KeyCode.NUMBER_2:
			default:
		}*/
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