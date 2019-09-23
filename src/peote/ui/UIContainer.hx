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
	
	function addToConstraints(parentLayout:Layout, constraints:Array<Constraint>, weight:Float = 1.0) {}
	
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
	
	override function addToConstraints(parentLayout:Layout, constraints:Array<Constraint>, weight:Float = 1.0)
	{
		// TODO: um zusaetzliche listen der verwendeten displays und ui-elements ergaenzen
		// TODO: die for-schleife auch schon in den UIContainer auslagern
		
		var weak = Strength.create(0, 0, 1, weight);
		var weak1 = Strength.create(0, 0, 500, weight);
		var medium = Strength.create(0, 1, 0, weight);
		//var strong = Strength.create(1, 0, 0, weight);
		//var required = Strength.create(1, 1, 1, weight);		
				
		for (i in 0...childs.length)
		{
			// horizontal
			if (i == 0)  // first
				constraints.push( (childs[i].left == parentLayout.left) | medium );
			else
				constraints.push( (childs[i].left == childs[i-1].right + 10) | medium );
			
			if (i == childs.length - 1) {  // last
				constraints.push( (childs[i].right == parentLayout.right) | weak1);
			}
			else {
				// force same width
				for (j in (i + 1)...childs.length)
					// TODO: if (childs[i].constantWidth)
					constraints.push( (childs[i].width == childs[i+1].width) | weak);
			}
			
			// vertical
			constraints.push( (childs[i].top ==  parentLayout.top) | medium );
			constraints.push( (childs[i].bottom ==  parentLayout.bottom) | medium );
			
			// recursive Container
			childs[i].addToConstraints(childs[i], constraints, weight);
		}
		
		
	}
	
}