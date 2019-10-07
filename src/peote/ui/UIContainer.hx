package peote.ui;

import utils.NestedArray;
import peote.ui.skin.Skin;
import peote.ui.skin.Style;

import jasper.Constraint;
import jasper.Strength;


class UIContainer extends UIElement
{
	static inline var ALIGN_LEFT:Int = 1;
	static inline var ALIGN_BOTTOM:Int = 2;
	//static inline var FIT_WIDTH:Int = 4;
	//static inline var FIT_HEIGHT:Int = 8;
	
	var options:Int = 0;
		
	var childs:Array<Layout>;
	
	public function new(xPosition:Int = 0, yPosition:Int = 0, width:Int = 100, height:Int = 100, zIndex:Int = 0, skin:Skin = null, style:Style = null,
		childs:Array<Layout>, options:Int=0) 
	{
		super(xPosition, yPosition, width, height, zIndex, skin, style);
		
		this.childs = childs;
		
		layout.addChildConstraints = addChildConstraints;
		layout.updateChilds = updateChilds;
	}
	
	function updateChilds() {
		//trace("update childs");
		for (child in childs) {
			child.update();
		}
	}
	
	function addChildConstraints(parentLayout:Layout, constraints:NestedArray<Constraint>, weight:Float = 1.0)
	{}

	
	public function getConstraints(layout:Layout):NestedArray<Constraint>
	{
		var constraints = new NestedArray<Constraint>();
		
		// recursive Container
		this.layout.addChildConstraints(layout, constraints, 1.0);
		
		// max/min size constraints
		this.layout.addWidthConstraints(constraints, Strength.create(0, 0, 600, 1.0));
		this.layout.addHeightConstraints(constraints, Strength.create(0, 0, 600, 1.0));
		
		
		layout.updateChilds = this.updateChilds;
		
		return(constraints);
	}
	
	public function getViewConstraints(layout:Layout):NestedArray<Constraint>
	{
		var constraints = new NestedArray<Constraint>();
		
		// set root
		constraints.push( (layout.x == 0) | Strength.REQUIRED);
		constraints.push( (layout.y == 0) | Strength.REQUIRED);
		
		// recursive Container
		this.layout.addChildConstraints(layout, constraints, 1.1);
		
		layout.update = this.updateChilds;
		
		return(constraints);
	}
	
		
}

// -------------------- HBox ------------------------------------------

class Hbox extends UIContainer
{
	
	override function addChildConstraints(parentLayout:Layout, constraints:NestedArray<Constraint>, weight:Float = 1.0)
	{
		// TODO: refactoring
		
		var weak = Strength.create(0, 0, 1, weight);
		var weak1 = Strength.create(0, 0, 100, weight);
		var weak2 = Strength.create(0, 0, 200, weight);
		var weak3 = Strength.create(0, 0, 300, weight);
		var weak4 = Strength.create(0, 0, 400, weight);
		var weak5 = Strength.create(0, 0, 500, weight);
		var weak6 = Strength.create(0, 0, 600, weight);
		var weak7 = Strength.create(0, 0, 700, weight);
		var weak8 = Strength.create(0, 0, 800, weight);
		var weak9 = Strength.create(0, 0, 900, weight);
		
		var medium = Strength.create(0, 1, 0, weight);
		var medium1 = Strength.create(0, 100, 0, weight);
		//var medium1 = Strength.create(0, 500, 0, weight);
		//var strong = Strength.create(1, 0, 0, weight);
		//var required = Strength.create(1, 1, 1, weight);		
		
		// TODO: not smaller than all childs-minWidth together
		// TODO: not greater that all childs-maxWidth together (only if there is no one with maxWidth==-1)
/*		// get max height
		var minChildHeight:Int = 0;
		var maxChildHeight:Int = -1;
		for (child in childs) {
			if (child.minHeight < minChildHeight) minChildHeight = child.minHeight;
			if (child.maxHeight > maxChildHeight) maxChildHeight = child.maxHeight;
		}
		//parentLayout.minHeight = minChildHeight;
		//parentLayout.maxHeight = maxChildHeight;
*/		
		for (i in 0...childs.length)
		{	
			// horizontal
			if (i == 0)  // first
				constraints.push( (childs[i].left == parentLayout.left) | medium );
			else
				constraints.push( (childs[i].left == childs[i-1].right + 10) | medium );
			
			if (i == childs.length - 1) {  // last
				constraints.push( (childs[i].right == parentLayout.right) | weak5);
			}
			else {
				// force same width
				for (j in (i + 1)...childs.length) {
					// TODO: better trying to force maxWidth for every child here
					constraints.push( (childs[i].width == childs[j].width) | weak);
				}
			}
			
			// vertical
			constraints.push( (childs[i].top == parentLayout.top) | medium );
			
			if (childs.length == 1)
				//constraints.push( (childs[i].bottom == parentLayout.bottom) | weak9 );
				constraints.push( (childs[i].bottom == parentLayout.bottom) | Strength.create(0, 0, 900, weight) );
			else if (childs[i].maxHeight == -1 )
				//constraints.push( (childs[i].bottom == parentLayout.bottom) | weak3 );
				constraints.push( (childs[i].bottom == parentLayout.bottom) | Strength.create(0, 0, 300, weight) );
			else
				constraints.push( (childs[i].bottom == parentLayout.bottom) | Strength.create(0, 0, 100+i*10, weight));

			
				
			// recursive Container
			childs[i].addChildConstraints(childs[i], constraints, weight+0.05);

			// max/min size constraints
			childs[i].addWidthConstraints(constraints, weak6);
			childs[i].addHeightConstraints(constraints, weak6);
		}
		
		
	}
	
}