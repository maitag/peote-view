package peote.ui;

import peote.ui.skin.Skin;
import peote.ui.skin.Style;

import jasper.Constraint;
import jasper.Strength;


class UIContainer extends UIElement
{
	var childs:Array<Layout>;
	
	public function new(xPosition:Int = 0, yPosition:Int = 0, width:Int = 100, height:Int = 100, zIndex:Int = 0, skin:Skin = null, style:Style = null,
		childs:Array<Layout>) 
	{
		super(xPosition, yPosition, width, height, zIndex, skin, style);
		
		this.childs = childs;
		
		layout.addToConstraints = addToConstraints;
	}
	
	function addToConstraints(parentLayout:Layout, constraints:Array<Constraint>) {	
	}
	
	public function getConstraints(layout:Layout):Array<Constraint> {
		var constraints = new Array<Constraint>();
		layout.addToConstraints(layout, constraints);
		return(constraints);
	}
		
}

class Hbox extends UIContainer
{
	
/*	public function new(xPosition:Int = 0, yPosition:Int = 0, width:Int = 100, height:Int = 100, zIndex:Int = 0, skin:Skin = null, style:Style = null, 
		uiElementsChilds:Array<UIElement>) 
	{
		super(xPosition, yPosition, width, height, zIndex, skin, style, uiElementsChilds);
		
		layout.addToConstraints = function(parentLayout:Layout, constraints:Array<Constraint>)
*/		
	override function addToConstraints(parentLayout:Layout, constraints:Array<Constraint>)
		{
			for (i in 0...childs.length)
			{
				// horizontal
				if (i==0) constraints.push( childs[i].left == parentLayout.left ); // first
				else constraints.push( childs[i].left == childs[i-1].right + 10 );
				
				if (i==childs.length-1) constraints.push( childs[i].right == parentLayout.right);  // last
				
				// vertical
				constraints.push( (childs[i].top ==  parentLayout.top) | Strength.MEDIUM );
				constraints.push( (childs[i].bottom ==  parentLayout.bottom) | Strength.MEDIUM );
				
				// recursive Container
				childs[i].addToConstraints(layout, constraints);
			}
			
		}
		
		
		
	//}
	
}