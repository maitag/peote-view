package peote.ui;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import peote.view.Color;
import peote.view.Display;
import peote.view.PeoteGL;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
import peote.view.Element;
//import peote.view.Texture;


class Pickable implements Element
{
	public var uiElement:UIElement; 
	
	@posX public var x:Int=0;
	@posY public var y:Int=0;	
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	@zIndex public var z:Int = 0;	
	var OPTIONS = { picking:true };
	
	public function new(uiElement:UIElement, x:Int, y:Int, w:Int, h:Int, z:Int )
	{
		this.uiElement = uiElement;
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.z = z;
	}

}


class UIDisplay extends Display 
{
	var uiElements:Array<UIElement>;
	
	var clickBuffer:Buffer<Pickable>;
	var clickProgram:Program;
	
	var overBuffer:Buffer<Pickable>;
	var overProgram:Program;
	
	var lastOverIndex:Int = -1;
	var lastDownIndex:Int = -1;

	public function new(x:Int, y:Int, width:Int, height:Int, color:Color=0x00000000) 
	{
		super(x, y, width, height, color);
		// elements for mouseDown/Up ----------------------

		clickBuffer = new Buffer<Pickable>(16,8);
		clickProgram = new Program(clickBuffer);
		addProgram(clickProgram);
	
		// elements for mouseOver/Out ----------------------
		overBuffer = new Buffer<Pickable>(16, 8);
		overProgram = new Program(overBuffer);
		addProgram(overProgram);
				
		/*
		var clickable = new Pickable(10, 10, 100, 50, 0);
		clickBuffer.addElement(clickButton);
		*/
	}
	
	public function add(uiElement:UIElement):Void {
		//TODO
		uiElements.push(uiElement);
		uiElement.onAddToDisplay(this);
	}
	
	public function remove(uiElement:UIElement):Void {
		//TODO
		uiElements.push(uiElement);
	}
	
	public function removeAll():Void {
		//TODO
	}
	
	public function update(uiElement:UIElement):Void {
		//TODO
	}
	
	public function updateAll():Void {
		//TODO
	}
	
	
	// ----------------------------------------
	
	
	public function onMouseMove (peoteView:PeoteView, x:Float, y:Float):Void
	{
		try {
			var pickedElement = peoteView.getElementAt(x, y, this, overProgram);
			if (pickedElement != lastOverIndex) {
				if (lastOverIndex >= 0) 
					overBuffer.getElement(lastOverIndex).uiElement.mouseOut( Std.int(x), Std.int(y) );
				if (pickedElement >= 0) 
					overBuffer.getElement(pickedElement).uiElement.mouseOver(  Std.int(x), Std.int(y) );
				lastOverIndex = pickedElement;
			}
		}
		catch (e:Dynamic) trace("ERROR:", e);
		
	}

	public function onWindowLeave ():Void {
		if (lastOverIndex >= 0) {
			overBuffer.getElement(lastOverIndex).uiElement.mouseOut( -1, -1) ;
			lastOverIndex = -1;
		}
		if (lastDownIndex >= 0) { 
			clickBuffer.getElement(lastDownIndex).uiElement.mouseUp( -1, -1 );
			lastDownIndex = -1;			
		}
	}
	
	var lockDown = false;
	public function onMouseDown (peoteView:PeoteView, x:Float, y:Float, button:MouseButton):Void
	{
		try {
			if (!lockDown) 
			{
				lastDownIndex = peoteView.getElementAt( x, y, this, clickProgram ) ;
				if (lastDownIndex >= 0) {
					clickBuffer.getElement(lastDownIndex).uiElement.mouseDown( Std.int(x), Std.int(y) );
					lockDown = true;
				}
			}
			//var pickedElements = peoteView.getAllElementsAt(x, y, display, clickProgram);
			//trace(pickedElements);
			
		}
		catch (e:Dynamic) trace("ERROR:", e);
		
	}
	
	public function onMouseUp (peoteView:PeoteView, x:Float, y:Float, button:MouseButton):Void
	{
		try {
			if (lastDownIndex >= 0) {
				var pickedElement = peoteView.getElementAt(x, y, this, clickProgram);
				clickBuffer.getElement(lastDownIndex).uiElement.mouseUp( Std.int(x), Std.int(y) );
				if (pickedElement == lastDownIndex) {
					clickBuffer.getElement(pickedElement).uiElement.mouseClick( Std.int(x), Std.int(y) );
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
	
}


