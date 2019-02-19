package;
import lime.math.Rectangle;
import lime.math.Vector2;

#if sampleDepthBlend
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

import elements.ElementSimple;
import lime.utils.Assets;

class DepthBlend 
{
	var peoteView:PeoteView;

	var activeElement:ElementSimple;
	
	var element1:ElementSimple;
	var element2:ElementSimple;
	var element3:ElementSimple;
	var element4:ElementSimple;
	
	var bufferL:Buffer<ElementSimple>;
	var displayL:Display;
	var programL:Program;
	
	var bufferR:Buffer<ElementSimple>;
	var displayR:Display;
	var programR:Program;
	
	public function new(window:Window)
	{	

		peoteView = new PeoteView(window.context, window.width, window.height);
		
		//var texture = new Texture(26, 37);
		//texture.setImage(Assets.getImage("assets/images/wabbit_alpha.png"));
		
		
		displayL  = new Display(0, 0, 400, 400);
		displayL.color = Color.GREY3;
		bufferL  = new Buffer<ElementSimple>(100);
		programL = new Program(bufferL);
		displayL.addProgram(programL);
		peoteView.addDisplay(displayL);
		
		displayR = new Display(300, 100, 400, 400);
		displayR.color = 0x00FFFF99;
		bufferR  = new Buffer<ElementSimple>(100);
		programR = new Program(bufferR);
		displayR.addProgram(programR);
		peoteView.addDisplay(displayR);
		
		element1 = new ElementSimple(100, 100, 100, 100, 0xFF0000ff); element1.z = ElementSimple.MAX_ZINDEX;
		element2 = new ElementSimple(130, 130, 100, 100, 0x0000ffff); element2.z = ElementSimple.MAX_ZINDEX;
		bufferL.addElement(element1);
		bufferL.addElement(element2);
		
		element3 = new ElementSimple(100, 100, 100, 100, 0x0000FFFF);
		element4 = new ElementSimple(150, 150, 100, 100, 0xFFFF0099);
		bufferR.addElement(element3);
		bufferR.addElement(element4);
		
		activeElement = element1;
	}
	
	public function onPreloadComplete ():Void {  // for HTML5 this needs <assets ...embed="true"> inside project.xml !!!
		trace("preload complete");
		var texture = new Texture(32, 32);
		var image = new Image(null, 0, 0, 32, 32);
		image.copyPixels(Assets.getImage("assets/images/peote_tiles.png"), new Rectangle(128+32, 0, 32, 32), new Vector2(0, 0));
		texture.setImage(image);
		programL.setTexture(texture, "custom");
	}

	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		element2.z -= 1;
		element4.z -= 1;
		bufferL.update(); bufferR.update();
	}
	
	var discardValue = 0.0;
	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.D: 
				discardValue+= 0.1;
				if (discardValue > 1.0) discardValue = 0.0;
				if (discardValue > 0.9) programL.discardAtAlpha(); else programL.discardAtAlpha(discardValue);
			case KeyCode.A: displayR.backgroundAlpha = !displayR.backgroundAlpha;
			case KeyCode.B: displayR.backgroundEnabled = !displayR.backgroundEnabled;
			case KeyCode.X: programL.alphaEnabled = !programL.alphaEnabled;
			case KeyCode.Y: programR.alphaEnabled = !programR.alphaEnabled;
			case KeyCode.C: programL.zIndexEnabled = !programL.zIndexEnabled;
			case KeyCode.V: programR.zIndexEnabled = !programR.zIndexEnabled;
			case KeyCode.Z: displayR.backgroundDepth = !displayR.backgroundDepth;
			case KeyCode.NUMBER_1: activeElement = element1;
			case KeyCode.NUMBER_2: activeElement = element2;
			case KeyCode.NUMBER_3: activeElement = element3;
			case KeyCode.NUMBER_4: activeElement = element4;
			case KeyCode.LEFT:  activeElement.x -= 10;
			case KeyCode.RIGHT: activeElement.x += 10;
			case KeyCode.UP:    activeElement.y -= 10;
			case KeyCode.DOWN:  activeElement.y += 10;
			case KeyCode.NUMPAD_PLUS: activeElement.z += 1; trace(activeElement.z);
			case KeyCode.NUMPAD_MINUS:activeElement.z -= 1; trace(activeElement.z);
			default:
		}
		bufferL.update(); bufferR.update();
	}
	
	public function update(deltaTime:Int):Void {}
	public function onMouseUp (x:Float, y:Float, button:MouseButton):Void {}
	public function onMouseMove (x:Float, y:Float):Void {}
	public function onWindowLeave ():Void {}

	public function render()
	{
		peoteView.render();
	}

	public function resize(width:Int, height:Int)
	{
		peoteView.resize(width, height);
	}

	
}
#end