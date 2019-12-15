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
		var innerLimit = this.layout.addChildConstraints(constraints);
		trace(innerLimit.width);
		constraints.push( (this.layout.width >= innerLimit.width) | Strength.create(0,900,0) );
		constraints.push( (this.layout.height >= innerLimit.height) | Strength.create(0,900,0) );
		
		return(constraints);
	}
	
	// TODO
	function autoLimitAndSpacer(size:SizeSpaced, childSize:SizeSpaced, limit:Int) 
	{
		if (childSize.middle.limit._min < limit) {
			childSize.middle.limit._min = limit;
			if (childSize.middle.limit._max != null) 
				childSize.middle.limit._max = Std.int(Math.max(childSize.middle.limit._max, childSize.middle.limit._min));
		}
		
		if (!childSize.hasSpan()) {
			if ( size.middle.limit.span || 
				 childSize.getLimitMax() < ( (size.middle.limit._max != null) ? size.middle.limit._max : size.middle.limit._min) )
			{
				trace(" -----  add span  ------ ");
				if (childSize.first != null && childSize.last != null) {
					childSize.first.limit.span = true;
					childSize.last.limit.span = true;
				}
				else {
					if (childSize.first == null) childSize.first = new Size(Limit.min());
					if (childSize.last  == null) childSize.last = new Size(Limit.min());
				}
				
			}					
		}		
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

	function addChildConstraints(constraints:NestedArray<Constraint>):InnerLimit
	{	
		var strength = Strength.create(0, 900, 0); // TODO: gloabalstatic
		var strengthLow = Strength.create(0, 0, 900);
		
		var childsLimit = {width:0, height:0};
		
		if (this.childs != null)
		{
			for (child in this.childs)
			{	
				trace("Box - addChildConstraints");
			
				// ------------------------- recursive childs --------------------------
				var innerLimit = child.addChildConstraints(constraints);				
				trace("----");
				
				// --------------------------------- horizontal ---------------------------------------				
				this.autoLimitAndSpacer(this.layout.hSize, child.hSize, innerLimit.width);
				
				if (child.hSize.getMin() > childsLimit.width) childsLimit.width = child.hSize.getMin();
				
				var sizeVars:SizeVars = {sLimit:null, sSpan:null};				
				sizeVars = child.addHConstraints(constraints, sizeVars, strength);				
				if (sizeVars.sSpan != null) {
					trace("child.hSize.getLimitMax()", child.hSize.getLimitMax());
					constraints.push( (sizeVars.sSpan == (this.layout.width - child.hSize.getLimitMax()) / child.hSize.getSumWeight() ) | strengthLow );
				}
				
				constraints.push( (child.left == this.layout.x) | strength );
				constraints.push( (child.right == this.layout.x + this.layout.width) | strength );
				
				// --------------------------------- vertical ---------------------------------------
				this.autoLimitAndSpacer(this.layout.vSize, child.vSize, innerLimit.height);
				
				if (child.vSize.getMin() > childsLimit.height) childsLimit.height = child.vSize.getMin();
				
				var sizeVars:SizeVars = {sLimit:null, sSpan:null};				
				sizeVars = child.addVConstraints(constraints, sizeVars, strength);				
				if (sizeVars.sSpan != null) {
					trace("child.vSize.getLimitMax()", child.vSize.getLimitMax());
					constraints.push( (sizeVars.sSpan == (this.layout.height - child.vSize.getLimitMax()) / child.vSize.getSumWeight() ) | strengthLow );
				}
				
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

	function addChildConstraints(constraints:NestedArray<Constraint>):InnerLimit
	{
		// ------------------------- recursive childs --------------------------
		var childsLimit = {width:0, height:0};
		

		if (this.childs != null) for (i in 0...this.childs.length)
		{	
			trace("Shelf - addChildConstraints");
			//var child = this.childs[i];

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