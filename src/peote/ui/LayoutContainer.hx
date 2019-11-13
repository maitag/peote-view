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
		percentStrength:Strength, equalStrength:Strength, stretchStrength:Strength, limitStrength:Strength):{min:Int, noMax:Bool}
	{
		var greatestMax:Size = null;
		var greatestMin:Size = null;
		var limit:{min:Int, noMax:Bool } = {min:0, noMax:false};
		
		for (size in sizes) if (size != null) {
			if (size._percent == null)
			{
				if (size._max != null)
				{
					if (greatestMax == null) greatestMax = size;
					else if (size._max - size._min > greatestMax._max - greatestMax._min) greatestMax = size;
				}
				else
				{
					limit.noMax = true; // unlimited in size
					if (greatestMin == null) greatestMin = size;
					else if (size._min > greatestMin._min) greatestMin = size;
				}
			}
			limit.min += size._min;
		}

		if (greatestMin != null) trace("greatestMin", greatestMin._min);
		if (greatestMax != null) trace("greatestMax", greatestMax._max);
		
		for (size in sizes) if (size != null)
		{
			if (size._percent != null) // percentual size
			{
				trace("set limit for procentuals");
				// TODO:
				constraints.push( (size.size == size._percent * parentSize.size) | percentStrength );
				// limit
				if (size._max == null) constraints.push( (size.size >= size._min) | limitStrength );
				else {
					if (size._max > size._min) {
						constraints.push( (size.size >= size._min) | limitStrength );
						constraints.push( (size.size <= size._max) | limitStrength );
					}
					else constraints.push( (size.size == size._min) | limitStrength );
				}
			}
			else if (size._max == null) // variable size (only min)
			{
				// set to greatest 
				if (size == greatestMin)
				{	trace("set limit for greatestMin");
					if (greatestMax != null) {
						trace("constrain greatestMin with greatestMax");
						//constraints.push( (greatestMax.size - greatestMax._min <= size.size - size._min) | equalStrength );
						
						// TODO: equal did not work if outer spacer is variable
						constraints.push( (size._min * greatestMax.size == size.size * greatestMax._min) | stretchStrength );
					}
					// only the greatestMin gets the limit
					constraints.push( (size.size >= size._min) | limitStrength );
				}
				else 
				{	trace("constrain other _min sizes with greatestMin");
					//constraints.push( (size.size - size._min == greatestMin.size - greatestMin._min) | equalStrength );
					constraints.push( (size.size * greatestMin._min == size._min * greatestMin.size) | equalStrength );
				}
			}
			else if (size._max > size._min) // limit size
			{
				if (size == greatestMax) 
				{	trace("set limit for greatestMax");
					if (greatestMin == null) { trace("stretch greatestMax to _max");
						constraints.push( (size.size == size._max) | stretchStrength ); // <- STRETCH					
					}
					// only the greatesMax gets the limit
					constraints.push( (size.size >= size._min) | limitStrength );
					constraints.push( (size.size <= size._max) | limitStrength );
				}
				else { trace("constrain other _max sizes with greatestMax");
					constraints.push( ( (size.size - size._min) * (greatestMax._max - greatestMax._min) == (size._max - size._min) * (greatestMax.size - greatestMax._min) ) | equalStrength );
				}
			}
			else // fixed size
			{
				constraints.push( (size.size == size._min) | limitStrength );	
			}
			
		}
		
		return(limit); //returns the min and max limits (max can be null)
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
		
		var percentStrength = Strength.create(0, 200, 0);
		var limitStrength = Strength.create(0, 900, 0);
		//var limitStrength = Strength.create(800 ,0, 0);
		
		var limit = {width:0, height:0};
		
		if (this.childs != null)
		{
			var stretchStrength = Strength.create(0, 0, 500 );

			var equalStrength = Strength.create(0, 800 / this.childs.length, 0 );
			var restStrength  = Strength.create(0, 800 / this.childs.length, 0 );
			
			for (child in this.childs)
			{	
				trace("Box - addChildConstraints");
			
				// ------------------------- recursive childs --------------------------
				var innerLimit = child.addChildConstraints(child, constraints, weight);				
				trace("----");
				// --------------------------------- horizontal ---------------------------------------
				if (child.hSize._min < innerLimit.width) {
					child.hSize._min = innerLimit.width;
					if (child.hSize._max != null) child.hSize._max = Std.int(Math.max(child.hSize._max, child.hSize._min));
				}
				
				var outerLimit = this.addConstraints([child.lSpace, child.hSize, child.rSpace], this.layout.hSize, constraints,
					percentStrength, equalStrength, stretchStrength, limitStrength);
				
				
				if (outerLimit.min > limit.width) limit.width = outerLimit.min;

				// rest-spacer
				var restSpace:Size = null;
				
				if (!outerLimit.noMax) { trace("REST spacer injection");
					restSpace = Size.min(0);
					constraints.push( (restSpace.size >= 0) | limitStrength );
					// TODO: only need if the one of the inner is using the stretching 
					//       from greatestMin to greatestMax or the greatestMaxStretching if it is alone ??? 
					//constraints.push( (restSpace.size == 0) | restStrength );
				}
				
				this.addStartConstraints(child.left, this.layout.x, restSpace, constraints, limitStrength);
				this.addEndConstraints(child.right, this.layout.x + this.layout.width, restSpace, constraints, limitStrength);
				
				
				
				// TODO
				// --------------------------------- vertical ---------------------------------------
				// size
				//child.addVSizeConstraints(constraints, Strength.MEDIUM);
				//child.addVSpaceConstraints(constraints, Strength.MEDIUM, Strength.MEDIUM);
				var restSpace = Size.px(0);
				constraints.push( (restSpace.size == 8) | Strength.MEDIUM );
				this.addStartConstraints(child.top, this.layout.y, restSpace, constraints, Strength.MEDIUM);
				this.addEndConstraints(child.bottom, this.layout.y + this.layout.height, restSpace, constraints, Strength.MEDIUM);
				
				
				
			}
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