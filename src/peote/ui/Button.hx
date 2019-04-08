package peote.ui;
import peote.ui.skin.Skin;
import peote.ui.skin.Style;

class Button extends UIElement
{

	public var label:String = null;
	

	public var onMouseOver(default, set):UIDisplay->Button->Int->Int->Void;
	inline function set_onMouseOver(f:UIDisplay->Button->Int->Int->Void):UIDisplay->Button->Int->Int->Void {
		rebindMouseOver( f.bind(uiDisplay, this), f == null);
		return onMouseOver = f;
	}
	
	public var onMouseOut(default, set):UIDisplay->Button->Int->Int->Void;
	inline function set_onMouseOut(f:UIDisplay->Button->Int->Int->Void):UIDisplay->Button->Int->Int->Void {
		rebindMouseOut( f.bind(uiDisplay, this), f == null);
		return onMouseOut = f;
	}
	
	public var onMouseUp(default, set):UIDisplay->Button->Int->Int->Void;
	inline function set_onMouseUp(f:UIDisplay->Button->Int->Int->Void):UIDisplay->Button->Int->Int->Void {
		rebindMouseUp( f.bind(uiDisplay, this), f == null);
		return onMouseUp = f;
	}
	
	public var onMouseDown(default, set):UIDisplay->Button->Int->Int->Void;
	inline function set_onMouseDown(f:UIDisplay->Button->Int->Int->Void):UIDisplay->Button->Int->Int->Void {
		rebindMouseDown( f.bind(uiDisplay, this), f == null);
		return onMouseDown = f;
	}
	
	public var onMouseClick(default, set):UIDisplay->Button->Int->Int->Void;
	inline function set_onMouseClick(f:UIDisplay->Button->Int->Int->Void):UIDisplay->Button->Int->Int->Void {
		rebindMouseClick( f.bind(uiDisplay, this), f == null);
		return onMouseClick = f;
	}
	
	
	
	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int=0, skin:Skin = null, style:Style = null) 
	{
		super(xPosition, yPosition, width, height, zIndex, skin, style);
		
		// here defining for what events a Button needs over/click pickables
		
		// what graphics (skin) a Button needs is defined here
		
	}
	
	
	public function test() {
		mouseClick(10, 20);
	}
	
}