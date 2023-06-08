package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.graphics.Image;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Texture;
import peote.view.Element;

import utils.Loader;

class Elem implements Element
{
	@posX public var x:Int=0; // signed 2 bytes integer
	@posY public var y:Int=0; // signed 2 bytes integer
	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	@color("tint")   public var tint:Color = 0xffffffff;
		
	// image unit
	@texUnit("image") public var imageUnit:Int;

	// image slot
	@texSlot("image") public var imageSlot:Int;

	// mask tile
	@texTile("mask") public var maskTile:Int;
	
	// for "image" AND "mask" Layers together
	//@texTile("image", "mask") public var maskTile:Int;

	// formula (glsl) to combine colors and textures
	var DEFAULT_COLOR_FORMULA = "vec4( (tint * image).rgb, mask.a )";

	// give texture, texturelayer- or custom-to-use identifiers a default value ( if there is no texture set for )	
	var DEFAULT_FORMULA_VARS = [
		"mask"  => 0x000000ff,
		"image"  => 0x00ff00ff,
	];
	
	var OPTIONS = { blend:true };
		
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100)
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
	}
}

class CombineShaders extends Application
{
	var peoteView:PeoteView;
	var element:Elem;
	var buffer:Buffer<Elem>;
	var display:Display;
	var program:Program;
	
	var textureImage0:Texture;
	var textureImage1:Texture;
	var textureMask:Texture;
	
	var hasBlur = false;
	var hasMask = true;
	
	
	var maskImage:Array<String> = ["assets/images/peote_tiles.png", "assets/images/peote_tiles_bunnys.png"];
	var maskImageNumber:Int = 0;
	
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
		display   = new Display(10, 10, window.width - 20, window.height - 20, Color.GREY1);
		peoteView.addDisplay(display);  // display to peoteView
		
		buffer  = new Buffer<Elem>(100);
		program = new Program(buffer);
		element  = new Elem(0, 0, 400, 300);
		element.maskTile = 1;
		buffer.addElement(element);     // element to buffer
		display.addProgram(program);    // programm to display
		
		textureImage0 = new Texture(400, 300, 2);
		textureImage1 = new Texture(400, 300, 2);
		
		textureMask = new Texture(512, 512);
		textureMask.tilesX = 16;
		textureMask.tilesY = 16;
		
		program.setMultiTexture([textureImage0, textureImage1], Elem.TEXTURE_image, false);
		program.setTexture(textureMask, Elem.TEXTURE_mask, false);
				
		program.updateTextures(); // updates gl-textures and rebuilding shadercode
				
		loadImage(textureImage0, "assets/images/test0.png", 0);
		loadImage(textureImage0, "assets/images/test1.png", 1);
		
		loadImage(textureImage1, "assets/images/test2.png", 0);
		loadImage(textureImage1, "assets/images/test3.png", 1);
		
		loadImage(textureMask, maskImage[maskImageNumber]);
		
	}
	
	public function loadImage(texture:Texture, filename:String, slot:Int=0):Void {
		Loader.image(filename, true, function(image:Image) {
			texture.setImage(image, slot);
		});		
	}
	
	// ----------- Lime events ------------------

	override function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		element.x += 100;
		buffer.updateElement(element);		
	}

	override function onKeyUp (keyCode:KeyCode, modifier:KeyModifier):Void
	{	
		switch (keyCode) {
			case KeyCode.NUMBER_1:
				trace("switch imageUnit texture to " + ((element.imageUnit == 0) ? 1 : 0));
				element.imageUnit = (element.imageUnit == 0) ? 1 : 0;
				buffer.updateElement(element);
				
			case KeyCode.NUMBER_2:
				trace("switch imageSlot to " + ((element.imageSlot == 0) ? 1 : 0) );
				element.imageSlot = (element.imageSlot == 0) ? 1 : 0;
				buffer.updateElement(element);
				
			case KeyCode.NUMBER_3:
				trace("next maskTile");
				element.maskTile++;
				buffer.updateElement(element);
				
			case KeyCode.NUMBER_4:
				trace("load next mask image");
				maskImageNumber = (maskImageNumber == 0) ? 1 : 0;
				loadImage(textureMask, maskImage[maskImageNumber]);
				
			case KeyCode.M:
				if (program.hasTexture(textureMask, Elem.TEXTURE_mask)) {
					trace("remove mask texture");
					program.removeTexture(textureMask, Elem.TEXTURE_mask, true);
				}
				else {
					trace("add mask texture");
					program.addTexture(textureMask, Elem.TEXTURE_mask, true);
				}
				
			case KeyCode.I:
				if (program.hasTexture(textureImage0, Elem.TEXTURE_image)) {
					trace("remove image texture unit 0");
					program.removeTexture(textureImage0, Elem.TEXTURE_image, true);
				}
				else {
					trace("add image texture unit 0");
					program.addTexture(textureImage0, Elem.TEXTURE_image, true);
				}
				
			case KeyCode.J:
				if (program.hasTexture(textureImage1, Elem.TEXTURE_image)) {
					trace("remove image texture unit 1");
					program.removeTexture(textureImage1, Elem.TEXTURE_image, true);
				}
				else {
					trace("add image texture unit 1");
					program.addTexture(textureImage1, Elem.TEXTURE_image, true);
				}
				
			// TODO
/*			case KeyCode.R:
				trace("replace texture ");
				program.replaceTexture(texture0, texture1);
*/			
				
			case KeyCode.SPACE:
				
				if (hasMask) {
					trace("remove mask texture from ColorFormula");
					hasMask = false;
					if (hasBlur)
						program.setColorFormula('${Elem.COLOR_tint} * blur(${Elem.TEXTURE_ID_image})');				
					else 
						program.setColorFormula('${Elem.COLOR_tint} * ${Elem.TEXTURE_image}');
				}
				else {
					trace("add mask texture to ColorFormula");
					hasMask = true;
					
					if (hasBlur)
						program.setColorFormula('vec4( (${Elem.COLOR_tint} * blur(${Elem.TEXTURE_ID_image}) ).rgb, ${Elem.TEXTURE_mask}.a )');				
					else 
						program.setColorFormula(); // back to default colorFormula
					
				}
				
			case KeyCode.RETURN:
				
				if (hasBlur) {
					trace("remove blur shader");
					hasBlur = false;
					if (hasMask)
						program.setColorFormula(); // back to default colorFormula
					else 
						program.setColorFormula('${Elem.COLOR_tint} * ${Elem.TEXTURE_image}');
						
					// removes the shadercode-injection
					program.injectIntoFragmentShader();
				}
				else {
					trace("add blur shader");
					hasBlur = true;
					program.injectIntoFragmentShader(
					
					// TODO: generate defaults
					
					"				
						float normpdf(in float x, in float sigma) { return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma; }
						
						vec4 blur( int textureID )
						{
							const int mSize = 11;
							
							const int kSize = (mSize-1)/2;
							float kernel[mSize];
							
							float sigma = 7.0;
							float Z = 0.0;
							
							for (int j = 0; j <= kSize; ++j) kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
							for (int j = 0; j <  mSize; ++j) Z += kernel[j];
							
							vec3 final_colour = vec3(0.0);
							
							for (int i = -kSize; i <= kSize; ++i)
							{
								for (int j = -kSize; j <= kSize; ++j)
								{
									final_colour += kernel[kSize+j] * kernel[kSize+i] *
										getTextureColor(  textureID, vTexCoord + vec2(float(i), float(j)) / getTextureResolution(textureID)  ).rgb;
								}
							}
							
							return vec4(final_colour / (Z * Z), 1.0);
						}			
					"
					,false // no uTime
					,false // not rebuild shader here 
					);
					
					if (hasMask)
						program.setColorFormula('vec4( (${Elem.COLOR_tint} * blur(${Elem.TEXTURE_ID_image}) ).rgb, ${Elem.TEXTURE_mask}.a )');
					else 
						program.setColorFormula('${Elem.COLOR_tint} * blur(${Elem.TEXTURE_ID_image})');
						
				}
				
			default:
		}
	}

}