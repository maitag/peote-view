package;
#if MouseEvents
import haxe.Timer;

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

class Elem implements Element
{
	@posX public var x:Int=0; // signed 2 bytes integer
	@posY public var y:Int=0; // signed 2 bytes integer
	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	@color public var c:Color = 0xff0000ff;
		
	@zIndex public var z:Int = 0;	
	
	var OPTIONS = { picking:true };
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=80, height:Int=80, c:Int=0xFF0000FF )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.c = c;
	}
}

class ClickElem extends Elem
{
	public var onMouseDown:Int->Int->Display->Program->Void = null;
	public var onMouseUp:Int->Int->Display->Program->Void = null;
	public var onMouseClick:Int->Int->Display->Program->Void = null;
}

class OverElem extends Elem
{
	public var onMouseOver:Int->Int->Display->Program->Void = null;
	public var onMouseOut:Int->Int->Display->Program->Void = null;
}

class MouseEvents 
{
	var peoteView:PeoteView;
	var display:Display;
	
	var clickBuffer:Buffer<ClickElem>;
	var clickProgram:Program;
	
	var overBuffer:Buffer<OverElem>;
	var overProgram:Program;
	
	var lastOverIndex:Int = -1;
	var lastDownIndex:Int = -1;
	
	public function new(window:Window)
	{
		try {
			
			peoteView = new PeoteView(window.context, window.width, window.height);
			display = new Display(0, 0, window.width, window.height, Color.GREEN);
			peoteView.addDisplay(display);
			
			
			// elements for mouseDown/Up ----------------------

			clickBuffer = new Buffer<ClickElem>(16,8);
			clickProgram = new Program(clickBuffer);
			display.addProgram(clickProgram);
		
			for (y in 0...3) for (x in 0...16)
			{
				var clickButton = new ClickElem(x*50, y*43, 45, 40);
				clickButton.onMouseDown = buttonDown.bind(clickButton);
				clickButton.onMouseUp = buttonUp.bind(clickButton);
				clickButton.onMouseClick = buttonClick.bind(clickButton);
				clickBuffer.addElement(clickButton);
			}
			
			// elements for mouseOver/Out ----------------------
			overBuffer = new Buffer<OverElem>(1, 8);
			overProgram = new Program(overBuffer);
			display.addProgram(overProgram);
				
			//var overButton = new Array<OverElem>();
			//var i:Int = 0;
			for (y in 0...19) for (x in 0...32)
			{
				/*overButton[i] = new OverElem(x*50, 150+y*50, 50, 50);
				overButton[i].onMouseOver = buttonOver.bind(overButton[i]);
				overButton[i].onMouseOut = buttonOut.bind(overButton[i]);
				overBuffer.addElement(overButton[i]);
				i++;
				*/
				var overButt = new OverElem(x*25, 130+y*25, 25, 25);
				overButt.onMouseOver = buttonOver.bind(overButt);
				overButt.onMouseOut = buttonOut.bind(overButt);
				overBuffer.addElement(overButt);
			}
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}
	
	public function buttonDown(button:ClickElem, x:Int, y:Int, display:Display, program:Program)
	{
		trace("Button down", x - button.x - display.x, y - button.y - display.y);
		button.x -= 4;button.y -= 4;button.w += 8;button.h += 8;
		clickBuffer.updateElement(button);			
	}
	public function buttonUp(button:ClickElem, x:Int, y:Int, display:Display, program:Program)
	{
		trace("Button up", x - button.x - display.x, y - button.y - display.y);
		button.x += 4;button.y += 4;button.w -= 8;button.h -= 8;
		clickBuffer.updateElement(button);			
	}
	public function buttonClick(button:ClickElem, x:Int, y:Int, display:Display, program:Program)
	{
		trace("Button click", x - button.x - display.x, y - button.y - display.y);
		button.c = Color.random();
		button.c.alpha = 255;
		clickBuffer.updateElement(button);			
	}
	
	// --------------------------------------------------
	
	public function buttonOver(button:OverElem, x:Int, y:Int, display:Display, program:Program)
	{
		trace("Button over", x - button.x - display.x, y - button.y - display.y);
		button.x += 2;button.y += 2;button.w -= 4;button.h -= 4;
		button.c = Color.random();
		button.c.alpha = 255;
		overBuffer.updateElement(button);
	}
	public function buttonOut(button:OverElem, x:Int, y:Int, display:Display, program:Program)
	{
		trace("Button out", x - button.x - display.x, y - button.y - display.y);
		button.x -= 2;button.y -= 2;button.w += 4;button.h += 4;
		button.c = Color.random();
		button.c.alpha = 255;
		overBuffer.updateElement(button);
	}
	
	// --------------------------------------------------

	public function onPreloadComplete ():Void { trace("preload complete"); }
		
	public function onMouseMove (x:Float, y:Float):Void
	{
		try {
			var pickedElement = peoteView.getElementAt(x, y, display, overProgram);
			if (pickedElement != lastOverIndex) {
				if (lastOverIndex >= 0) 
					overBuffer.getElement(lastOverIndex).onMouseOut(Std.int(x), Std.int(y), display, overProgram);
				if (pickedElement >= 0) 
					overBuffer.getElement(pickedElement).onMouseOver(Std.int(x), Std.int(y), display, overProgram);
				lastOverIndex = pickedElement;
			}
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}

	public function onWindowLeave ():Void {
		if (lastOverIndex >= 0) {
			overBuffer.getElement(lastOverIndex).onMouseOut( -1, -1, display, overProgram);
			lastOverIndex = -1;
		}
		if (lastDownIndex >= 0) { 
			clickBuffer.getElement(lastDownIndex).onMouseUp( -1, -1, display, clickProgram);
			lastDownIndex = -1;			
		}
	}
	
	var lockDown = false;
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		try {
			if (!lockDown) 
			{
				lastDownIndex = peoteView.getElementAt(x, y, display, clickProgram);
				if (lastDownIndex >= 0) {
					clickBuffer.getElement(lastDownIndex).onMouseDown(Std.int(x), Std.int(y), display, clickProgram);
					lockDown = true;
				}
			}
			//var pickedElements = peoteView.getAllElementsAt(x, y, display, clickProgram);
			//trace(pickedElements);
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}
	
	public function onMouseUp (x:Float, y:Float, button:MouseButton):Void
	{
		try {
			if (lastDownIndex >= 0) {
				var pickedElement = peoteView.getElementAt(x, y, display, clickProgram);
				clickBuffer.getElement(lastDownIndex).onMouseUp(Std.int(x), Std.int(y), display, clickProgram);
				if (pickedElement == lastDownIndex) {
					clickBuffer.getElement(pickedElement).onMouseClick(Std.int(x), Std.int(y), display, clickProgram);
				}
				lastDownIndex = -1;
				lockDown = false;
			}
			
			//var pickedElements = peoteView.getAllElementsAt(x, y, display, clickProgram);
			//trace(pickedElements);
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			//case KeyCode.NUMPAD_PLUS:
			default:
		}
	}
	
	public function onWindowActivate():Void {};
	public function onTextInput (text:String):Void {}

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