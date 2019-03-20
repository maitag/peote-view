package peote.ui;

/**
 * ...
 * @author 
 */
class UIContainer extends UIElement
{

	var elements:Array<UIElement>;
	
	public function new(xPosition:Int, yPosition:Int, width:Int, height:Int) 
	{
		super(xPosition, yPosition, width, height);
		
		elements = new Array<UIElement>();
		
	}
	
}