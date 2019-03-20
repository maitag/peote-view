package peote.ui;

import peote.ui.skin.Skin;

// main class for all ui-widgets

typedef UIEventParams = Int->Int->Void;

@:enum abstract UIEventMove(Int) from Int to Int {

	public static inline var mouseOver:Int = 1;
	public static inline var mouseOut :Int = 2;
}
@:enum abstract UIEventClick(Int) from Int to Int {

	public static inline var mouseDown :Int = 1;
	public static inline var mouseUp   :Int = 2;
	public static inline var mouseClick:Int = 3;
}

@:allow(peote.ui)
class UIElement
{
	var uiDisplay:UIDisplay = null;
	var skin:Skin = null;
	
	public var x:Int;
	public var y:Int;
	public var w:Int;
	public var h:Int;
	
	var mouseOver :UIEventParams;
	var mouseOut  :UIEventParams;
	
	var mouseDown :UIEventParams;
	var mouseUp   :UIEventParams;
	var mouseClick:UIEventParams; var hasMouseClick:Bool = false;
	
	var hasMoveEvent :Int = 0;
	var hasClickEvent:Int = 0;
	
	function noOperation(x:Int, y:Int):Void {
		trace("--NOP--");
	}
	
	inline function rebindMouseClick(newBinding:UIEventParams, isNull:Bool):Void {
		if ( !isNull ) {
			mouseClick = newBinding;
			if ( !hasMouseClick ) {
			//if ( Reflect.compareMethods(mouseClick, noOperation) ) {
				// TODO: add the pickable if not already there
				trace("add the pickable");
				hasMouseClick = true;
			}
		}
		else {
			mouseClick = noOperation;
			if ( !hasMouseClick ) {
			//if ( !Reflect.compareMethods(mouseClick, noOperation) ) {
				// TODO: remove the pickable if no more need by other eventhandlers
				trace("remove the pickable");
				hasMouseClick = false;
			}
		}
	}
	
	
	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int, skin:Skin=null) 
	{
		x = xPosition;
		y = yPosition;
		w = width;
		h = height;
		
		this.skin = skin;
		
		mouseOver  = noOperation;
		mouseOut   = noOperation;
		
		mouseDown  = noOperation;
		mouseUp    = noOperation;
		mouseClick = noOperation;
	}
	
	public function onAddToDisplay(uiDisplay:UIDisplay) {
		
		this.uiDisplay = uiDisplay;
		
	}
	
		
	public function addPickableClick() {
		
	}
	
	public function removePickableClick() {
		
	}
	
	public function addPickableOver() {
		
	}
	
	public function removePickableOver() {
		
	}
	
}