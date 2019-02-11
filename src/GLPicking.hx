package;
#if sampleGLPicking
import haxe.Timer;

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.utils.Assets;

import peote.view.PeoteGL;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Element;
import peote.view.Texture;

class Elem implements Element
{
	@posX public var x:Int=0; // signed 2 bytes integer
	@posY public var y:Int=0; // signed 2 bytes integer
	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	@color public var color:Color = 0xff0000ff;
		
	@zIndex public var z:Int = 0;	
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100, color:Int=0xff0000ff )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.color = color;
	}
	
	var OPTIONS = { picking:true, texRepeatX:true };

}

class GLPicking 
{
	var peoteView:PeoteView;

	var element = new Array<Elem>();
	
	var buffer:Buffer<Elem>;
	var displayLeft:Display;
	var displayRight:Display; 
	var programLeft:Program;
	var programRight:Program; 
	
	public function new(window:Window)
	{	
		try {
			//peoteView = new PeoteView(window.context, window.width, window.height, Color.GREY1);
			peoteView = new PeoteView(window.context, window.width, window.height, Color.GREEN);
			
			displayLeft  = new Display(0, 0, 280, 280, Color.BLUE);
			displayRight = new Display(300, 0, 280, 280, Color.YELLOW);
			
			peoteView.zoom = 1.0;
			peoteView.xOffset = 0;
			peoteView.yOffset = 0;
			
			peoteView.addDisplay(displayLeft);
			peoteView.addDisplay(displayRight);
			
			buffer   = new Buffer<Elem>(100);

			element[0]  = new Elem(0, 0, 100, 100, Color.RED);
			element[0].z = 2;
			buffer.addElement(element[0]);
			
			element[1]  = new Elem(40, 40, 100, 100, Color.CYAN);
			element[1].z = 1;
			buffer.addElement(element[1]);

			programLeft  = new Program(buffer);
			programRight = new Program(buffer);
			
			displayLeft.addProgram(programLeft);
			displayRight.addProgram(programRight);
			
			var future = Image.loadFromFile("assets/images/wabbit_alpha.png");
			future.onProgress (function (a:Int,b:Int) trace ('loading image $a/$b'));
			future.onError (function (msg:String) trace ("Error: "+msg));
			future.onComplete (function (image:Image) {
				trace("loading complete");
				var texture = new Texture(26, 37);
				texture.setImage(image);
				programLeft.setTexture(texture, "custom");
			});
			
			/*
			var timer = new Timer(60);
			timer.run =  function() {
				element[0].x++; buffer.updateElement(element[0]);
				if (element[0].x > 170) timer.stop();
			};*/
		}
		catch (msg:String) {trace("ERROR", msg); }
		
		
	}
	
	public function onPreloadComplete():Void {
		trace("preload complete");
		// syncload with javascript needs <!assets embed=true> in project.xml!
		/*var texture = new Texture(26, 37);
		texture.setImage(Assets.getImage("assets/images/wabbit_alpha.png"));
		programLeft.setTexture(texture, "custom");*/
	}

	public function onMouseDown(x:Float, y:Float, button:MouseButton):Void
	{
		var pickedElement = peoteView.getElementAt(x, y, displayLeft, programLeft);
		trace(pickedElement);
		if (pickedElement >= 0) {
			var elem = buffer.getElement(pickedElement);
			elem.color = Color.random();
			buffer.updateElement(elem);			
		}
		
		var pickedElements = peoteView.getAllElementsAt(x, y, displayLeft, programLeft);
		trace(pickedElements);
		//if (pickedElement != null) pickedElement.y += 100;
	}
	
	public function onKeyDown(keyCode:KeyCode, modifier:KeyModifier):Void
	{
		var steps = 10;
		var esteps = 10;
		switch (keyCode) {
			case KeyCode.LEFT:
					if (modifier.ctrlKey) {element[0].x-=esteps; buffer.updateElement(element[0]);}
					else if (modifier.shiftKey) displayLeft.xOffset-=steps;
					else if (modifier.altKey) displayRight.xOffset-=steps;
					else peoteView.xOffset-=steps;
			case KeyCode.RIGHT:
					if (modifier.ctrlKey) {element[0].x+=esteps; buffer.updateElement(element[0]);}
					else if (modifier.shiftKey) displayLeft.xOffset+=steps;
					else if (modifier.altKey) displayRight.xOffset+=steps;
					else peoteView.xOffset+=steps;
			case KeyCode.UP:
					if (modifier.ctrlKey) {element[0].y-=esteps; buffer.updateElement(element[0]);}
					else if (modifier.shiftKey) displayLeft.yOffset-=steps;
					else if (modifier.altKey) displayRight.yOffset-=steps;
					else peoteView.yOffset-=steps;
			case KeyCode.DOWN:
					if (modifier.ctrlKey) {element[0].y+=esteps; buffer.updateElement(element[0]);}
					else if (modifier.shiftKey) displayLeft.yOffset+=steps;
					else if (modifier.altKey) displayRight.yOffset+=steps;
					else peoteView.yOffset+=steps;
			case KeyCode.NUMPAD_PLUS:
					if (modifier.shiftKey) displayLeft.zoom+=0.25;
					else if (modifier.altKey) displayRight.zoom+=0.25;
					else peoteView.zoom+=0.25;
			case KeyCode.NUMPAD_MINUS:
					if (modifier.shiftKey) displayLeft.zoom-=0.25;
					else if (modifier.altKey) displayRight.zoom-=0.25;
					else peoteView.zoom-=0.25;
			case KeyCode.Z:
					if (element[0].z == 2) {
						element[0].z = 1;
						element[1].z = 2;
					} else {
						element[0].z = 2;
						element[1].z = 1;
					}
					buffer.update();
			default:
		}
		
	}
	public function onMouseUp (x:Float, y:Float, button:MouseButton):Void {}
	
	public function update(deltaTime:Int):Void {}
	
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