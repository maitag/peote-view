package peote.ui;

class Button extends UIElement
{

	public var label:String = null;
	

	public var onMouseClick(default, set):UIDisplay->Button->Int->Int->Void;
	
	inline function set_onMouseClick(f:UIDisplay->Button->Int->Int->Void):UIDisplay->Button->Int->Int->Void {
		rebindMouseClick( f.bind(uiDisplay, this), f == null);
		return onMouseClick = f;
	}
	
	
	
	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int) 
	{
		super(xPosition, yPosition, width, height);
		
		// here defining for what events a Button needs over/click pickables
		
		// what graphics (skin) a Button needs is defined here
		
	}
	
	
	public function test() {
		mouseClick(10, 20);
	}
	
}