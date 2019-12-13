package peote.ui;

import jasper.Expression;
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
		this = new LayoutContainer(layout, width, height, lSpace, rSpace, tSpace, bSpace, childs) ;
		this.layout.addChildConstraints = addChildConstraints;
	}
	
	@:to public function toNestedArray():NestedArray<Constraint> return(this.getConstraints());
	@:to public function toNestedArrayItem():NestedArrayItem<Constraint> return(this.getConstraints().toArray());	
	@:to public function toLayout():Layout return(this.layout);

	function addChildConstraints(parentLayout:Layout, constraints:NestedArray<Constraint>, weight:Int = 0):InnerLimit
	{
		weight++;
		var w = weight * 10;
		
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
				
				// TODO: add span left or right or both sides if not fit
				
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

// TODO: only Stack and Shelf 
// (shelf is horizontally aligned [but vertically splitted;])

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
		weight++;
			// ------------------------- recursive childs --------------------------
			var childsLimit = {width:0, height:0};
		
		// calculate procentual
/*		var procentuals = new Array<{space:Null<Float>, child:Null<Float>, spaceMax:Null<Int>, childMax:Null<Int>, spaceMin:Int, childMin:Int}>();
		var anz_percent:Int = 0;
		var sum_percent:Float = 0.0;
		var anz_min:Int = 0;
		var greatest_min:Int = 0;
		var sum_min:Int = 0;
		var greatest_max:Int = 0;
		var sum_max:Int = 0;
		if (this.childs != null) {
			for (child in this.childs) {
				var p = {space:null, child:null, spaceMax:null, childMax:null, spaceMin:0, childMin:0};
				if (child.hSize._percent != null) {
					p.child = child.hSize._percent;
					sum_percent += p.child;
					anz_percent++;
				}
				else if (child.hSize._max != null) {
					p.childMax = child.hSize._max - ((child.hSize._min == null) ? 0 : child.hSize._min);
					sum_max += p.childMax;
				}
				else if (child.hSize._min != null) {
					p.childMin = child.hSize._min;
					sum_min += p.childMin;
				}
				procentuals.push(p);
			}
			for (p in procentuals) {
				
			}
		}
*/		
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