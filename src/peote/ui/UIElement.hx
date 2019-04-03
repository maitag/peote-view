package peote.ui;

import peote.ui.skin.Skin;
import peote.view.Color;

// main class for all ui-widgets

typedef UIEventParams = Int->Int->Void;

@:enum abstract UIEventOver(Int) from Int to Int {

	public static inline var mouseOver:Int = 1;
	public static inline var mouseOut :Int = 2;
}
@:enum abstract UIEventClick(Int) from Int to Int {

	public static inline var mouseDown :Int = 1;
	public static inline var mouseUp   :Int = 2;
	public static inline var mouseClick:Int = 4;
}

@:allow(peote.ui)
class UIElement
{
	var uiDisplay:UIDisplay = null;
	var skin:Skin = null;
	
	var skinElement:Dynamic = null; // TODO: extend Element & Buffer with @buffIndex !
	var pickableOver:Pickable = null;
	var pickableClick:Pickable = null;
	
	public var x:Int;
	public var y:Int;
	public var w:Int;
	public var h:Int;
	public var z:Int;
	public var color:Null<Color> = null;
	
	var mouseOver :UIEventParams;
	var mouseOut  :UIEventParams;
	var hasOverEvent :Int = 0;
	
	var mouseUp   :UIEventParams;
	var mouseDown :UIEventParams;
	var mouseClick:UIEventParams;
	var hasClickEvent:Int = 0;
	
	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int, zIndex:Int, skin:Skin=null) 
	{
		x = xPosition;
		y = yPosition;
		w = width;
		h = height;
		z = zIndex;
		
		this.skin = skin;
		
		mouseOver  = noOperation;
		mouseOut   = noOperation;
		
		mouseDown  = noOperation;
		mouseUp    = noOperation;
		mouseClick = noOperation;
	}
		
	private function noOperation(x:Int, y:Int):Void {
		//trace("--NOP--");
	}
	
	// Event-Bindings
	
	private function rebindMouseOver(newBinding:UIEventParams, isNull:Bool):Void {
		if ( !isNull ) {
			mouseOver = newBinding;
			if ( hasOverEvent == 0 ) addPickableOver();
			hasOverEvent |= UIEventOver.mouseOver;
		}
		else {
			hasOverEvent &= ~UIEventOver.mouseOver;
			if ( hasOverEvent == 0 ) removePickableOver();
			mouseOver = noOperation;
		}
	}

	private function rebindMouseOut(newBinding:UIEventParams, isNull:Bool):Void {
		if ( !isNull ) {
			mouseOut = newBinding;
			if ( hasOverEvent == 0 ) addPickableOver();
			hasOverEvent |= UIEventOver.mouseOut;
		}
		else {
			hasOverEvent &= ~UIEventOver.mouseOut;
			if ( hasOverEvent == 0 ) removePickableOver();
			mouseOut = noOperation;
		}
	}

	// -----------------

	private function rebindMouseUp(newBinding:UIEventParams, isNull:Bool):Void {
		if ( !isNull ) {
			mouseUp = newBinding;
			if ( hasClickEvent == 0 ) addPickableClick();
			hasClickEvent |= UIEventClick.mouseUp;
		}
		else {
			hasClickEvent &= ~UIEventClick.mouseUp;
			if ( hasClickEvent == 0 ) removePickableClick();
			mouseUp = noOperation;
		}
	}
	
	private function rebindMouseDown(newBinding:UIEventParams, isNull:Bool):Void {
		if ( !isNull ) {
			mouseDown = newBinding;
			if ( hasClickEvent == 0 ) addPickableClick();
			hasClickEvent |= UIEventClick.mouseDown;
		}
		else {
			hasClickEvent &= ~UIEventClick.mouseDown;
			if ( hasClickEvent == 0 ) removePickableClick();
			mouseDown = noOperation;
		}
	}
	
	private function rebindMouseClick(newBinding:UIEventParams, isNull:Bool):Void {
		if ( !isNull ) {
			mouseClick = newBinding;
			if ( hasClickEvent == 0 ) addPickableClick();
			hasClickEvent |= UIEventClick.mouseClick;
		}
		else {
			hasClickEvent &= ~UIEventClick.mouseClick;
			if ( hasClickEvent == 0 ) removePickableClick();
			mouseClick = noOperation;
		}
	}
	
	// -----------------
	
	public function onAddToDisplay(uiDisplay:UIDisplay)
	{
		this.uiDisplay = uiDisplay;
		
		if (skin != null) skin.addElement(uiDisplay, this);
		if ( hasOverEvent  != 0 ) addPickableOver();	
		if ( hasClickEvent != 0 ) addPickableClick();
	}
	
	public function onRemoveFromDisplay(uiDisplay:UIDisplay)
	{		
		if (uiDisplay != this.uiDisplay) throw('Error, $this is not inside uiDisplay: $uiDisplay');
		
		if (skin != null) skin.removeElement(uiDisplay, this);
		if ( hasOverEvent  != 0 ) removePickableOver();
		if ( hasClickEvent != 0 ) removePickableClick();
		
		uiDisplay = null;
	}
	
	// -----------------
		
	public function addPickableOver()
	{
		trace("addPickableOver");
		if (pickableOver==null) pickableOver = new Pickable(this, x, y, w, h, z);
		if (uiDisplay!=null) uiDisplay.overBuffer.addElement( pickableOver );
	}
	
	public function removePickableOver()
	{
		trace("removePickableOver");
		if (uiDisplay!=null) uiDisplay.overBuffer.removeElement( pickableOver );  //pickableOver=null
	}
	
	public function addPickableClick()
	{
		trace("addPickableClick");
		if (pickableClick==null) pickableClick = new Pickable(this, x, y, w, h, z);
		if (uiDisplay!=null) uiDisplay.clickBuffer.addElement( pickableClick );
	}
	
	public function removePickableClick()
	{
		trace("removePickableClick");
		if (uiDisplay!=null) uiDisplay.clickBuffer.removeElement( pickableClick ); //pickableClick=null
	}
	
	
}