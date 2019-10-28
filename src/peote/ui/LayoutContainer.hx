package peote.ui;

import jasper.Expression;
import jasper.Strength;
import jasper.Constraint;
import jasper.Variable;
import utils.NestedArray;
import peote.ui.Layout;


@:allow(peote.ui)
class LayoutContainer
{
	var layout:Layout;
	var childs:Array<Layout>;

	function new(layout:Layout, width:Width, height:Height,	hSpace:HSpace, lSpace:LSpace, rSpace:RSpace, vSpace:VSpace, tSpace:TSpace, bSpace:BSpace, childs:Array<Layout>) 
	{
		if (layout == null)
			this.layout = new Layout(width, height, hSpace, lSpace, rSpace, vSpace, tSpace, bSpace);
		else {
			this.layout = layout.set(width, height, hSpace, lSpace, rSpace, vSpace, tSpace, bSpace);
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
		this.layout.addChildConstraints(this.layout, constraints);
		
		return(constraints);
	}
	
	function addStartConstraints(start:Expression, outStart:Variable, spStart:Size = null, constraints:NestedArray<Constraint>, outerLimitStrength:Strength):Void
	{		
		if (spStart != null) constraints.push( (start == outStart + spStart.size) | outerLimitStrength ); // OUTERLIMIT
		else constraints.push( (start == outStart) | outerLimitStrength ); // OUTERLIMIT
	}
	
	function addEndConstraints(end:Expression, outEnd:Expression, spEnd:Size = null, constraints:NestedArray<Constraint>, outerLimitStrength:Strength):Void
	{		
		if (spEnd != null) constraints.push( (outEnd == end + spEnd.size) | outerLimitStrength ); // OUTERLIMIT
		else constraints.push( (outEnd == end) | outerLimitStrength ); // OUTERLIMIT
	}
	
	function addPrefConstraints(start:Expression, prefEnd:Expression, spStart:Size = null, spPrefEnd:Size = null, constraints:NestedArray<Constraint>, positionStrength:Strength):Void
	{
		if (spStart != null && spPrefEnd != null) constraints.push( (start == prefEnd + spPrefEnd.size + spStart.size) | positionStrength );
		else if (spStart != null) constraints.push( (start == prefEnd + spStart.size) | positionStrength );
		else if (spPrefEnd != null) constraints.push( (start == prefEnd + spPrefEnd.size) | positionStrength );
		else constraints.push( (start == prefEnd) | positionStrength );
	}

	
}

// -------------------------------------------------------------------------------------------------
// -----------------------------     Box    --------------------------------------------------------
// -------------------------------------------------------------------------------------------------
abstract Box(LayoutContainer) // from LayoutContainer to LayoutContainer
{
	public inline function new(layout:Layout = null, width:Width = null, height:Height = null, 
		hSpace:HorizontalSpace = null, lSpace:LeftSpace = null, rSpace:RightSpace = null,
		vSpace:VerticalSpace = null, tSpace:TopSpace = null, bSpace:BottomSpace = null,
		childs:Array<Layout> = null) 
	{
		this = new LayoutContainer(layout, width, height, hSpace, lSpace, rSpace, vSpace, tSpace, bSpace, childs) ;
		this.layout.addChildConstraints = addChildConstraints;
	}
	
	@:to public function toNestedArray():NestedArray<Constraint> return(this.getConstraints());
	@:to public function toNestedArrayItem():NestedArrayItem<Constraint> return(this.getConstraints().toArray());	
	@:to public function toLayout():Layout return(this.layout);

	function addChildConstraints(parentLayout:Layout, constraints:NestedArray<Constraint>, 
		sizeSpaceWeight:Int  = 900,
		sizeChildWeight:Int  = 900,
		positionWeight:Int   = 100,
		outerLimitWeight:Int = 100,
		spaceLimitWeight:Int = 500,
		childLimitWeight:Int = 500
	):Void
	{
		sizeSpaceWeight  -= 10;
		sizeChildWeight  -= 10;
		
		//positionWeight   += 10;  
		outerLimitWeight += 10;
		spaceLimitWeight += 10;
		childLimitWeight += 10;
		
		var sizeSpaceStrength  = Strength.create(0, 0, sizeSpaceWeight); // weak
		var sizeSpaceStrength1  = Strength.create(0, 0, sizeSpaceWeight+2); // weak
		var sizeSpaceStrength2  = Strength.create(0, 0, sizeSpaceWeight+4); // weak
		var sizeSpaceStrength3  = Strength.create(0, 0, sizeSpaceWeight+6); // weak
		var sizeChildStrength  = Strength.create(0, sizeChildWeight,0 ); // medium
		
		//var positionStrength   = Strength.create( positionWeight,0,  0); // strong
		var outerLimitStrength = Strength.create( 0,outerLimitWeight,0);
		var spaceLimitStrength = Strength.create( 0,spaceLimitWeight,0);
		var childLimitStrength = Strength.create( 0,childLimitWeight,0);
		
		if (this.childs != null) for (child in this.childs)
		{	
			trace("Box - addChildConstraints");
			
			// --------------------------------- horizontal ---------------------------------------
			// size
			child.addHSizeConstraints(constraints, childLimitStrength);
			child.addHSpaceConstraints(constraints, spaceLimitStrength, spaceLimitStrength);

			//constraints.push( (child.width == this.layout.x + this.layout.width) | sizeChildStrength );
			
			if (child.lSpace != null && child.rSpace != null) {
				//if (child.lSpace._max == null && child.lSpace._max == null)
					constraints.push( (child.lSpace.size == child.rSpace.size) | sizeSpaceStrength );
			}

			if (child.lSpace != null) {
				if (child.lSpace._percent != null) {
					
				}
				else {
					if (child.lSpace._min != null && child.lSpace._max != null) constraints.push( (child.lSpace.size == child.lSpace._max) | sizeSpaceStrength1 );
					else if (child.lSpace._min != null) constraints.push( (child.lSpace.size == child.lSpace._min) | sizeSpaceStrength1 );
					else if (child.lSpace._max != null) constraints.push( (child.lSpace.size == child.lSpace._max) | sizeSpaceStrength1 );
				}
			}
			if (child.rSpace != null) {
				if (child.rSpace._percent != null) {
					
				}
				else {
					if (child.rSpace._min != null && child.rSpace._max != null) constraints.push( (child.rSpace.size == child.rSpace._max) | sizeSpaceStrength2 );
					else if (child.rSpace._min != null) constraints.push( (child.rSpace.size == child.rSpace._min) | sizeSpaceStrength2 );
					else if (child.rSpace._max != null) constraints.push( (child.rSpace.size == child.rSpace._max) | sizeSpaceStrength2 );
				}
			}			
			if (child.hSpace != null) {
				if (child.hSpace._percent != null) {
					
				}
				else {
					if (child.hSpace._min != null && child.hSpace._max != null) constraints.push( (child.hSpace.size == child.hSpace._max) | sizeSpaceStrength2 );
					else if (child.hSpace._min != null) constraints.push( (child.hSpace.size == child.hSpace._min) | sizeSpaceStrength2 );
					else if (child.hSpace._max != null) constraints.push( (child.hSpace.size == child.hSpace._max) | sizeSpaceStrength2 );
				}
			}			
			
			// left right
			var startRestSpace:HSpace = null;
			var endRestSpace:HSpace = null;
			if (child.hasMaxWidth()) {
				trace(" REST SPACER ");
				var restSpace = HSpace.min(0);				
				constraints.push( (restSpace.size == 0) | sizeSpaceStrength3 );
				constraints.push( (restSpace.size >= 0) | spaceLimitStrength ); // TODO
				
				if ( (child.lSpace == null && child.rSpace == null) || (child.lSpace != null && child.rSpace != null) ) {
					startRestSpace = endRestSpace = restSpace; trace("LEFT/RIGHT");
				}
				else if (child.lSpace != null) {
					endRestSpace = restSpace; trace("LEFT");
				}
				else if (child.rSpace != null) {
					startRestSpace = restSpace; trace("RIGHT");
				}
			}
			this.addStartConstraints(child.left, this.layout.x, startRestSpace, constraints, outerLimitStrength);
			this.addEndConstraints(child.right, this.layout.x + this.layout.width, endRestSpace, constraints, outerLimitStrength);
			
			
			
			
			// --------------------------------- vertical ---------------------------------------
			// size
			child.addVSizeConstraints(constraints, childLimitStrength);
			child.addVSpaceConstraints(constraints, spaceLimitStrength, spaceLimitStrength);
			
			constraints.push( (child.height == this.layout.y + this.layout.height) | childLimitStrength );

			// top bottom
			this.addStartConstraints(child.top, this.layout.y, null, constraints, outerLimitStrength);
			this.addEndConstraints(child.bottom, this.layout.y + this.layout.height, null, constraints, outerLimitStrength);
			
			
			
			// ------------------------- recursive childs --------------------------
			child.addChildConstraints(child, constraints, sizeSpaceWeight, sizeChildWeight, positionWeight, outerLimitWeight, spaceLimitWeight , childLimitWeight);
			
		}
				
	}
	
}


// -------------------------------------------------------------------------------------------------
// -----------------------------   HShelf   --------------------------------------------------------
// -------------------------------------------------------------------------------------------------

abstract Shelf(LayoutContainer) from LayoutContainer to LayoutContainer
{
	public inline function new(layout:Layout = null, width:Width = null, height:Height = null,
		hSpace:HorizontalSpace = null, lSpace:LeftSpace = null, rSpace:RightSpace = null,
		vSpace:VerticalSpace = null, tSpace:TopSpace = null, bSpace:BottomSpace = null,
		childs:Array<Layout> = null) 
	{
		this = new LayoutContainer(layout, width, height, hSpace, lSpace, rSpace, vSpace, tSpace, bSpace, childs) ;
		this.layout.addChildConstraints = addChildConstraints;
	}
	
	@:to public function toNestedArray():NestedArray<Constraint> return(this.getConstraints());
	@:to public function toNestedArrayItem():NestedArrayItem<Constraint> return(this.getConstraints().toArray());	
	@:to public function toLayout():Layout return(this.layout);

	function addChildConstraints(parentLayout:Layout, constraints:NestedArray<Constraint>, 
		sizeSpaceWeight:Int  = 900, // weak
		sizeChildWeight:Int  = 900, // medium
		positionWeight:Int   = 100, // strong
		outerLimitWeight:Int = 100,
		spaceLimitWeight:Int = 100,
		childLimitWeight:Int = 100
	):Void
	{
		sizeSpaceWeight  -= 10;
		sizeChildWeight  -= 10;
		positionWeight   += 10;  
		outerLimitWeight += 10;
		spaceLimitWeight += 10;
		childLimitWeight += 10;
		
		var sizeSpaceStrength  = Strength.create(0, 0, sizeSpaceWeight); // weak
		var sizeChildStrength  = Strength.create(0, sizeChildWeight,0 ); // medium
		var positionStrength   = Strength.create( positionWeight,0,  0); // strong
		var outerLimitStrength = Strength.create( outerLimitWeight,0, 0);
		var spaceLimitStrength = Strength.create( spaceLimitWeight,0, 0);
		var childLimitStrength = Strength.create( childLimitWeight,0, 0);
		
		// calculate procentual
		var procentuals = new Array<{space:Null<Float>, child:Null<Float>, spaceMax:Null<Int>, childMax:Null<Int>, spaceMin:Int, childMin:Int}>();
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
				if (child.hSpace != null) {
					if (child.hSpace._percent != null) {
						p.space = child.hSpace._percent;
						sum_percent += p.space;
						anz_percent++;
					} 
					else if (child.hSpace._max != null) {
						p.spaceMax = child.hSpace._max - ((child.hSpace._min == null) ? 0 : child.hSpace._min);
						sum_max += p.spaceMax;
					}
					else if (child.hSpace._min != null) {
						p.spaceMin = child.hSpace._min;
						sum_min += p.spaceMin;
					}
				}
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
		
		if (this.childs != null) for (i in 0...this.childs.length)
		{	
			trace("Shelf - addChildConstraints");
			var child = this.childs[i];

			// horizontal -----------
			if (i == 0)  // first
				constraints.push( (child.left == this.layout.left) | positionStrength );
			else
				constraints.push( (child.left == this.childs[i-1].right) | positionStrength );
			
			if (i == this.childs.length - 1) {  // last
				constraints.push( (child.right <= this.layout.right) | outerLimitStrength);
			}
			
			// procentual size
			
			child.hSize.addLimitConstraints(constraints, childLimitStrength);               // CHILDLIMIT
			
			
			
			// TODO: vertical
			constraints.push( (this.childs[i].top == this.layout.top) | positionStrength );			
			constraints.push( (this.childs[i].bottom <= this.layout.bottom) | outerLimitStrength );
			// height constraints
			
			
				
			// recursive Container
			child.addChildConstraints(child, constraints, sizeSpaceWeight, sizeChildWeight, positionWeight, outerLimitWeight, spaceLimitWeight , childLimitWeight);

		}
				
	}
	
}