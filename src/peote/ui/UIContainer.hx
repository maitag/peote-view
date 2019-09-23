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
	
	function addToConstraints(parentLayout:Layout, constraints:Array<Constraint>) {}
	
	public function getConstraints(layout:Layout):Array<Constraint>
	{
		var constraints = new Array<Constraint>();
		this.layout.addToConstraints(layout, constraints);
		
		// TODO (for all ui or ui-elements)
		// if () constraints.push( (childs[i].width == childs[i].constantWidth) | Strength.MEDIUM );
		// else {
		//	if () constraints.push( (childs[i].width <= childs[i].maxWidth) | Strength.MEDIUM );
		// 	if () constraints.push( (childs[i].width >= childs[i].minWidth) | Strength.MEDIUM );
		// }		

		return(constraints);
	}
	
	public function getViewConstraints(layout:Layout):Array<Constraint>
	{
		var constraints = new Array<Constraint>();
		
		// set root
		constraints.push( (layout.x == 0) | Strength.REQUIRED);
		constraints.push( (layout.y == 0) | Strength.REQUIRED);
		
		this.layout.addToConstraints(layout, constraints);
		return(constraints);
	}
	
		
}

class Hbox extends UIContainer
{
	
	public function new(xPosition:Int = 0, yPosition:Int = 0, width:Int = 100, height:Int = 100, zIndex:Int = 0, skin:Skin = null, style:Style = null, 
		childs:Array<Layout>) 
	{
		super(xPosition, yPosition, width, height, zIndex, skin, style, childs);
		
		layout.addToConstraints = function(parentLayout:Layout, constraints:Array<Constraint>)
		
	//override function addToConstraints(parentLayout:Layout, constraints:Array<Constraint>)
		{
			// TODO: um zusaetzliche listen der verwendeten displays und ui-elements ergaenzen
			// TODO: die for-schleife auch schon in den UIContainer auslagern
			for (i in 0...childs.length)
			{
				// horizontal
				if (i == 0)  // first
					constraints.push( (childs[i].left == parentLayout.left) | Strength.MEDIUM );
				else
					constraints.push( (childs[i].left == childs[i-1].right + 10) | Strength.MEDIUM );
				
				if (i == childs.length - 1) {  // last
					constraints.push( (childs[i].right == parentLayout.right) | Strength.MEDIUM);
				}
				else {
					// force same width
					for (j in (i + 1)...childs.length)
						// TODO: if (childs[i].constantWidth)
						constraints.push( (childs[i].width == childs[i+1].width) | Strength.WEAK);
				}
				
				// vertical
				constraints.push( (childs[i].top ==  parentLayout.top) | Strength.MEDIUM );
				constraints.push( (childs[i].bottom ==  parentLayout.bottom) | Strength.MEDIUM );
				
				// recursive Container
				childs[i].addToConstraints(layout, constraints);
			}
			
		}
		
		
		
	}
	
}