package peote.ui;

import utils.NestedArray;
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
		
		layout.addChildConstraints = addChildConstraints;
		layout.updateChilds = updateChilds;
	}
	
	function updateChilds() {
		trace("update childs");
		for (child in childs) {
			child.update();
		}
	}
	
	function addChildConstraints(parentLayout:Layout, constraints:NestedArray<Constraint>, weight:Float = 1.0) {}
	
	public function getConstraints(layout:Layout):NestedArray<Constraint>
	{
		var constraints = new NestedArray<Constraint>();
		
		this.layout.addConstraints(layout, constraints);
		
		layout.updateChilds = this.updateChilds;
		
		return(constraints);
	}
	
	public function getViewConstraints(layout:Layout):NestedArray<Constraint>
	{
		var constraints = new NestedArray<Constraint>();
		
		// set root
		constraints.push( (layout.x == 0) | Strength.REQUIRED);
		constraints.push( (layout.y == 0) | Strength.REQUIRED);
		
		this.layout.addConstraints(layout, constraints, 1.1);
		
		layout.update = this.updateChilds;
		
		return(constraints);
	}
	
		
}

class Hbox extends UIContainer
{
	
	override function addChildConstraints(parentLayout:Layout, constraints:NestedArray<Constraint>, weight:Float = 1.0)
	{
		// TODO: die for-schleife auch schon in den UIContainer auslagern
		
		var weak = Strength.create(0, 0, 1, weight);
		var weak1 = Strength.create(0, 0, 100, weight);
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
				for (j in (i + 1)...childs.length) {
					// TODO: alternative methods
					constraints.push( (childs[i].width == childs[j].width) | weak);
				}
			}
			
			// vertical
			constraints.push( (childs[i].top ==  parentLayout.top) | medium );
			constraints.push( (childs[i].bottom ==  parentLayout.bottom) | weak1 );
			
			// recursive Container
			childs[i].addConstraints(childs[i], constraints, weight+0.05);
		}
		
		
	}
	
}