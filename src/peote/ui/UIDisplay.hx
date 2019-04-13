package peote.ui;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import peote.ui.skin.Skin;
import peote.view.Color;
import peote.view.Display;
import peote.view.PeoteGL;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
//import peote.view.Texture;


@:allow(peote.ui)
class UIDisplay extends Display 
{
	var uiElements:Array<UIElement>;
	
	var overBuffer:Buffer<Pickable>;
	var overProgram:Program;
	
	var clickBuffer:Buffer<Pickable>;
	var clickProgram:Program;
	
	var lastOverIndex:Int = -1;
	var lastDownIndex:Int = -1;
	
	var skins:Array<Skin>;

	public function new(x:Int, y:Int, width:Int, height:Int, color:Color=0x00000000) 
	{
		super(x, y, width, height, color);
		
		// elements for mouseOver/Out ----------------------
		overBuffer = new Buffer<Pickable>(16, 8); // TODO: fill with constants
		overProgram = new Program(overBuffer);
				
		// elements for mouseDown/Up ----------------------
		clickBuffer = new Buffer<Pickable>(16,8); // TODO: fill with constants
		clickProgram = new Program(clickBuffer);
	
		uiElements = new Array<UIElement>();
		skins = new Array<Skin>();
	}
	
	override private function setNewGLContext(newGl:PeoteGL)
	{
		super.setNewGLContext(newGl);
		overProgram.setNewGLContext(newGl);
		clickProgram.setNewGLContext(newGl);
	}
	
	public function add(uiElement:UIElement):Void {
		//TODO
		uiElements.push(uiElement);
		uiElement.onAddToDisplay(this);
	}
	
	public function remove(uiElement:UIElement):Void {
		//TODO
		uiElements.remove(uiElement);
		uiElement.onRemoveFromDisplay(this);
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
		trace("onWindowLeave");
		if (lastOverIndex >= 0) {
			overBuffer.getElement(lastOverIndex).uiElement.mouseOut( -1, -1) ;
			lastOverIndex = -1;
		}
		if (lastDownIndex >= 0) { 
			clickBuffer.getElement(lastDownIndex).uiElement.mouseUp( -1, -1 );
			lastDownIndex = -1;
			lockDown = false;
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


