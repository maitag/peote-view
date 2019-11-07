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

	function new(layout:Layout, width:Width, height:Height,	lSpace:LSpace, rSpace:RSpace, tSpace:TSpace, bSpace:BSpace, childs:Array<Layout>) 
	{
		if (layout == null)
			this.layout = new Layout(width, height, lSpace, rSpace, tSpace, bSpace);
		else {
			this.layout = layout.set(width, height, lSpace, rSpace, tSpace, bSpace);
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
	
	public function addConstraints(sizes:Array<Size>, parentSize:Size = null, constraints:NestedArray<Constraint>,
		percentStrength:Strength, firstMinStrength:Strength, equalMinStrength:Strength, equalMaxStrength:Strength, minStrength:Strength, maxStrength:Strength=null):Bool
	{
		var greatestMax:Size = null;
		var firstMin:Size = null;
		
		for (size in sizes) if (size != null) {
			if (size._percent == null && size._max != null) {
				if (size._max > size._min) {
					if (greatestMax == null) greatestMax = size;
					else if (size._max - size._min > greatestMax._max - greatestMax._min) greatestMax = size;
					trace("greatestMax", greatestMax._max);
				}
			}
		}
		
		for (size in sizes) if (size != null)
		{
			if (size._percent != null) // percentual size
			{trace("a");
				constraints.push( (size.size == size._percent * parentSize.size) | percentStrength );
				// limit
				if (size._max == null) constraints.push( (size.size >= size._min) | minStrength );
				else {
					if (size._max > size._min) {
						constraints.push( (size.size >= size._min) | minStrength );
						constraints.push( (size.size <= size._max) | maxStrength );
					}
					else constraints.push( (size.size == size._min) | minStrength );
				}
			}
			else if (size._max == null) // variable size
			{trace("b");
				// set to greatest 
				if (firstMin == null)
				{
					if (greatestMax != null) {
						constraints.push( (greatestMax.size - greatestMax._min <= size.size - size._min) | equalMinStrength );
						constraints.push( (size.size == size._min) | firstMinStrength );
					}
					// min limit
					constraints.push( (size.size >= size._min) | minStrength );
					
					firstMin = size;
					
				}
				else 
				{
					constraints.push( (size.size - size._min == firstMin.size - firstMin._min) | equalMinStrength );
				}
			}
			else if (size._max > size._min) // restricted size
			{ //trace("c");
				if (size != greatestMax) { trace("c1");
					constraints.push( ( (size.size - size._min) * (greatestMax._max - greatestMax._min) == (size._max - size._min) * (greatestMax.size - greatestMax._min) ) | equalMaxStrength );
				}
				else { trace("c2");
					// first one gets limit
					constraints.push( (size.size >= size._min) | minStrength );
					constraints.push( (size.size <= size._max) | maxStrength );
				}
			}
			else // fixed size
			{ trace("d");
				constraints.push( (size.size == size._min) | minStrength );	
			}
			
		}
		
		return(firstMin == null);
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

typedef Limit = {
	width:Int, height:Int
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

	function addChildConstraints(parentLayout:Layout, constraints:NestedArray<Constraint>, weight:Int = 0):Limit
	{
		weight++;
		var w = weight * 10;
		var restStrength = Strength.create(0, 300 - w, 0);
		var restStrengthHalf = Strength.create(0, 150 - w, 0);
		
		var equalMinStrength = Strength.create(0, 200 - w, 0); // weight here also splitted ?
		
		var percentStrength = Strength.create(0, 200, 0);
		
		var firstMinStrength = Strength.create(0, 100, 0);
		var equalMaxStrength = Strength.create(0, 200, 0);
		
		var limitStrength = Strength.create(0, 400, 0);
		
		var limit = {width:0, height:0};
		
		var i = 0;
		if (this.childs != null) for (child in this.childs)  // the restStrength weight needs splitted depending on childnumber
		{	
			trace("Box - addChildConstraints");
		//todo:
		//var restStrength = Strength.create(0, 300 - w, 500-i*10);
		//var restStrengthHalf = Strength.create(0, 150 - w, 0);
		i++;
		
			// ------------------------- recursive childs --------------------------
			var innerLimit = child.addChildConstraints(child, constraints, weight);
			
			if (child.hSize._min < innerLimit.width) child.hSize._min = innerLimit.width;
			
			var newLimit = ((child.lSpace != null) ? child.lSpace._min:0) +
			               ((child.hSize  != null) ? child.hSize._min :0) +
			               ((child.rSpace != null) ? child.rSpace._min:0);
			
			if (newLimit > limit.width) limit.width = newLimit;
			
			// --------------------------------- horizontal ---------------------------------------
			var isVariable = this.addConstraints([child.lSpace, child.hSize, child.rSpace], this.layout.hSize, constraints, 
				percentStrength, firstMinStrength, equalMinStrength, equalMaxStrength, limitStrength, limitStrength);
			
			// connect to outer
			var startRestSpace:Size = null;
			var endRestSpace:Size = null;
			if (isVariable) {
				trace(" REST SPACER ");
				var restSpace = Size.min(0);				
				constraints.push( (restSpace.size >= 0) | limitStrength );
				
				if ( (child.lSpace == null && child.rSpace == null) || (child.lSpace != null && child.rSpace != null) ) {
					constraints.push( (restSpace.size == 0) | restStrength ); // <-- shrinking weight !
					startRestSpace = endRestSpace = restSpace; trace("LEFT/RIGHT");
				}
				else if (child.lSpace != null) {
					constraints.push( (restSpace.size == 0) | restStrengthHalf ); // <-- shrinking weight !
					endRestSpace = restSpace; trace("LEFT");
				}
				else if (child.rSpace != null) {
					constraints.push( (restSpace.size == 0) | restStrengthHalf ); // <-- shrinking weight !
					startRestSpace = restSpace; trace("RIGHT");
				}
			}
			this.addStartConstraints(child.left, this.layout.x, startRestSpace, constraints, limitStrength);
			this.addEndConstraints(child.right, this.layout.x + this.layout.width, endRestSpace, constraints, limitStrength);
			
			
			
			// TODO
			// --------------------------------- vertical ---------------------------------------
			// size
			child.addVSizeConstraints(constraints, Strength.MEDIUM);
			child.addVSpaceConstraints(constraints, Strength.MEDIUM, Strength.MEDIUM);
			var restSpace = Size.px(0);
			constraints.push( (restSpace.size == 8) | Strength.MEDIUM );
			this.addStartConstraints(child.top, this.layout.y, restSpace, constraints, Strength.MEDIUM);
			this.addEndConstraints(child.bottom, this.layout.y + this.layout.height, restSpace, constraints, Strength.MEDIUM);
			
			
			
		}
		
		return limit;
	}
	
}


// -------------------------------------------------------------------------------------------------
// -----------------------------   HShelf   --------------------------------------------------------
// -------------------------------------------------------------------------------------------------

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

	function addChildConstraints(parentLayout:Layout, constraints:NestedArray<Constraint>, weight:Int = 0):Limit
	{
		weight++;
			// ------------------------- recursive childs --------------------------
			var limit = {width:0, height:0};
		
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
		
		return limit;
	}
	
}