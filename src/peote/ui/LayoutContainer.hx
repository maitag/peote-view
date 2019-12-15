package peote.ui;

import jasper.Strength;
import jasper.Constraint;
import jasper.Variable;
import utils.NestedArray;
import peote.ui.Layout;

typedef InnerLimit = { width:Int, height:Int }
typedef SizeVars = { sLimit:Null<Variable>, sSpan:Null<Variable> }

@:allow(peote.ui)
class LayoutContainer
{
	var layout:Layout;
	var childs:Array<Layout>;

	function new(layout:Layout, width:Width, height:Height,	lSpace:LSpace, rSpace:RSpace, tSpace:TSpace, bSpace:BSpace, childs:Array<Layout>) 
	{
		if (layout == null)
			this.layout = new Layout(width, height, lSpace, rSpace, tSpace, bSpace);
		else {
			layout.hSize = new SizeSpaced(width, lSpace, rSpace);
			layout.vSize = new SizeSpaced(height, tSpace, bSpace);
			this.layout = layout;
		}
		
		this.childs = childs;
		layout.updateChilds = updateChilds;			
	}
		
	function updateChilds() {
		if (this.childs != null) for (child in childs) {
			child.update();
			child.updateChilds();
		}
	}
	
	function getConstraints():NestedArray<Constraint>
	{
		var constraints = new NestedArray<Constraint>();
		
		// recursive Container
		var innerLimit = this.layout.addChildConstraints(this.layout, constraints);
		trace(innerLimit.width);
		constraints.push( (this.layout.width >= innerLimit.width) | Strength.create(0,900,0) );
		constraints.push( (this.layout.height >= innerLimit.height) | Strength.create(0,900,0) );
		
		return(constraints);
	}
	
/*	function addPrefConstraints(start:Expression, prefEnd:Expression, spStart:Size = null, spPrefEnd:Size = null, constraints:NestedArray<Constraint>, positionStrength:Strength):Void
	{
		if (spStart != null && spPrefEnd != null) constraints.push( (start == prefEnd + spPrefEnd.size + spStart.size) | positionStrength );
		else if (spStart != null) constraints.push( (start == prefEnd + spStart.size) | positionStrength );
		else if (spPrefEnd != null) constraints.push( (start == prefEnd + spPrefEnd.size) | positionStrength );
		else constraints.push( (start == prefEnd) | positionStrength );
	}
*/
	
}

// -------------------------------------------------------------------------------------------------
// -----------------------------     Box    --------------------------------------------------------
// -------------------------------------------------------------------------------------------------
abstract Box(LayoutContainer) // from LayoutContainer to LayoutContainer
{
	public inline function new(layout:Layout = null, width:Width = null, height:Height = null, 
		lSpace:LeftSpace = null, rSpace:RightSpace = null,
		tSpace:TopSpace = null, bSpace:BottomSpace = null,
		childs:Array<Layout> = null) 
	{
		this = new LayoutContainer(layout, width, height, lSpace, rSpace, tSpace, bSpace, childs);
		this.layout.addChildConstraints = addChildConstraints;
	}
	
	@:to public function toNestedArray():NestedArray<Constraint> return(this.getConstraints());
	@:to public function toNestedArrayItem():NestedArrayItem<Constraint> return(this.getConstraints().toArray());	
	@:to public function toLayout():Layout return(this.layout);

	// TODO: remove parentLayout and weight-param
	function addChildConstraints(parentLayout:Layout, constraints:NestedArray<Constraint>, weight:Int = 0):InnerLimit
	{	
		var strength = Strength.create(0, 900, 0);
		var strengthLow = Strength.create(0, 0, 900);
		
		var childsLimit = {width:0, height:0};
		
		if (this.childs != null)
		{
			for (child in this.childs)
			{	
				trace("Box - addChildConstraints");
			
				// ------------------------- recursive childs --------------------------
				var innerLimit = child.addChildConstraints(child, constraints, weight);				
				trace("----");
				// --------------------------------- horizontal ---------------------------------------
				if (child.hSize.middle.limit._min < innerLimit.width) {
					child.hSize.middle.limit._min = innerLimit.width;
					if (child.hSize.middle.limit._max != null) 
						child.hSize.middle.limit._max = Std.int(Math.max(child.hSize.middle.limit._max, child.hSize.middle.limit._min));
				}
				
				if (child.hSize.getMin() > childsLimit.width) childsLimit.width = child.hSize.getMin();
				
				if (!child.hSize.hasSpan()) {
					if ( this.layout.hSize.middle.limit.span || 
					     child.hSize.getLimitMax() < ( (this.layout.hSize.middle.limit._max != null) ? this.layout.hSize.middle.limit._max : this.layout.hSize.middle.limit._min) )
					{
						trace(" -----  add span  ------ ");
						if (child.hSize.first != null && child.hSize.last != null) {
							child.hSize.first.limit.span = true;
							child.hSize.last.limit.span = true;
						}
						else {
							if (child.hSize.first == null) child.hSize.first = new Size(Limit.min());
							if (child.hSize.last  == null) child.hSize.last = new Size(Limit.min());
						}
						
					}					
				}
				
				var sizeVars:SizeVars = {sLimit:null, sSpan:null};
				
				sizeVars = child.addHConstraints(constraints, sizeVars, strength);
				
				if (sizeVars.sSpan != null) {
					trace("child.hSize.getLimitMax()", child.hSize.getLimitMax());
					constraints.push( (sizeVars.sSpan == (this.layout.width - child.hSize.getLimitMax()) / child.hSize.getSumWeight() ) | strengthLow );
				}
				
				constraints.push( (child.left == this.layout.x) | strength );
				constraints.push( (child.right == this.layout.x + this.layout.width) | strength );
				
				
				// TODO
				// --------------------------------- vertical ---------------------------------------
				constraints.push( (child.top == this.layout.y) | strength );
				constraints.push( (child.bottom == this.layout.y + this.layout.height) | strength );
				
				
			}
		}
		return childsLimit;
	}
	
}


// -------------------------------------------------------------------------------------------------
// -----------------------------   HShelf   --------------------------------------------------------
// -------------------------------------------------------------------------------------------------
// TODO: HBox and VBox
// OR:
// Shelf(left to right) and  Stack(top to bottom)
abstract Shelf(LayoutContainer) from LayoutContainer to LayoutContainer
{
	public inline function new(layout:Layout = null, width:Width = null, height:Height = null,
		lSpace:LeftSpace = null, rSpace:RightSpace = null, tSpace:TopSpace = null, bSpace:BottomSpace = null,
		childs:Array<Layout> = null) 
	{
		this = new LayoutContainer(layout, width, height, lSpace, rSpace, tSpace, bSpace, childs) ;
		this.layout.addChildConstraints = addChildConstraints;
	}
	
	@:to public function toNestedArray():NestedArray<Constraint> return(this.getConstraints());
	@:to public function toNestedArrayItem():NestedArrayItem<Constraint> return(this.getConstraints().toArray());	
	@:to public function toLayout():Layout return(this.layout);

	function addChildConstraints(parentLayout:Layout, constraints:NestedArray<Constraint>, weight:Int = 0):InnerLimit
	{
		// ------------------------- recursive childs --------------------------
		var childsLimit = {width:0, height:0};
		

		if (this.childs != null) for (i in 0...this.childs.length)
		{	
			trace("Shelf - addChildConstraints");
			var child = this.childs[i];

			// horizontal -----------
/*			if (i == 0)  // first
				constraints.push( (child.left == this.layout.left) | positionStrength );
			else
				constraints.push( (child.left == this.childs[i-1].right) | positionStrength );
			
			if (i == this.childs.length - 1) {  // last
				constraints.push( (child.right <= this.layout.right) | outerLimitStrength);
			}
*/			

		}
		
		return childsLimit;
	}



}