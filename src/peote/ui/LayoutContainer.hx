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

	function new(layout:Layout = null, width:Width = null, height:Height = null, align:Align = Align.center, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null) 
	{
		if (layout == null)
			this.layout = new Layout(width, height, align, hSpace, vSpace);
		else {
			this.layout = layout.set(width, height, align, hSpace, vSpace);
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
	
	function addStartConstraints(start:Variable, outStart:Variable, spStart:Size = null, constraints:NestedArray<Constraint>, outerLimitStrength:Strength):Void
	{		
		if (spStart != null) constraints.push( (start == outStart + spStart.size) | outerLimitStrength ); // OUTERLIMIT
		else constraints.push( (start == outStart) | outerLimitStrength ); // OUTERLIMIT
	}
	
	function addEndConstraints(end:Expression, outEnd:Expression, spEnd:Size = null, constraints:NestedArray<Constraint>, outerLimitStrength:Strength):Void
	{		
		if (spEnd != null) constraints.push( (outEnd == end + spEnd.size) | outerLimitStrength ); // OUTERLIMIT
		else constraints.push( (outEnd == end) | outerLimitStrength ); // OUTERLIMIT
	}
	
	function addPrefConstraints(start:Variable, prefEnd:Expression, spStart:Size = null, spPrefEnd:Size = null, constraints:NestedArray<Constraint>, positionStrength:Strength):Void
	{
		if (spStart != null && spPrefEnd != null) constraints.push( (start == prefEnd + spPrefEnd.size + spStart.size) | positionStrength );
		else if (spStart != null) constraints.push( (start == prefEnd + spStart.size) | positionStrength );
		else if (spPrefEnd != null) constraints.push( (start == prefEnd + spPrefEnd.size) | positionStrength );
		else constraints.push( (start == prefEnd) | positionStrength );
	}
	
	function addLimitConstraints(size:Size, spStart:Size = null, spEnd:Size = null,
		constraints:NestedArray<Constraint>, childLimitStrength:Strength, spaceLimitStrength:Strength):Void
	{		
		size.addLimitConstraints(constraints, childLimitStrength);      // CHILDLIMIT
		if (spStart != null) spStart.addLimitConstraints(constraints, spaceLimitStrength);  // SPACELIMIT
		if (spEnd != null) spEnd.addLimitConstraints(constraints, spaceLimitStrength);      // SPACELIMIT
				
	}
	
	
}

// -------------------------------------------------------------------------------------------------
// -----------------------------     Box    --------------------------------------------------------
// -------------------------------------------------------------------------------------------------
abstract Box(LayoutContainer) // from LayoutContainer to LayoutContainer
{
	public inline function new(layout:Layout = null, width:Width = null, height:Height = null, align:Align = Align.center, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null) 
	{
		this = new LayoutContainer(layout, width, height, align, hSpace, vSpace, childs) ;
		this.layout.addChildConstraints = addChildConstraints;
	}
	// ---------- static helpers
	public static inline function center       (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Box return new Box(layout, width, height, Align.center,      hSpace, vSpace, childs); 
	public static inline function left         (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Box return new Box(layout, width, height, Align.left,        hSpace, vSpace, childs); 
	public static inline function right        (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Box return new Box(layout, width, height, Align.right,       hSpace, vSpace, childs); 
	public static inline function top          (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Box return new Box(layout, width, height, Align.top,         hSpace, vSpace, childs); 
	public static inline function bottom       (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Box return new Box(layout, width, height, Align.bottom,      hSpace, vSpace, childs); 
	public static inline function topLeft      (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Box return new Box(layout, width, height, Align.topLeft,     hSpace, vSpace, childs); 
	public static inline function topRight     (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Box return new Box(layout, width, height, Align.topRight,    hSpace, vSpace, childs); 
	public static inline function bottomLeft   (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Box return new Box(layout, width, height, Align.bottomLeft,  hSpace, vSpace, childs); 
	public static inline function bottomRight  (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Box return new Box(layout, width, height, Align.bottomRight, hSpace, vSpace, childs); 
	public static inline function leftTop      (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Box return new Box(layout, width, height, Align.topLeft,     hSpace, vSpace, childs); 
	public static inline function rightTop     (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Box return new Box(layout, width, height, Align.topRight,    hSpace, vSpace, childs); 
	public static inline function leftBottom   (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Box return new Box(layout, width, height, Align.bottomLeft,  hSpace, vSpace, childs); 
	public static inline function rightBottom  (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Box return new Box(layout, width, height, Align.bottomRight, hSpace, vSpace, childs); 
	
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
		
		if (this.childs != null) for (child in this.childs)
		{	
			trace("Box - addChildConstraints");
			// --------------------------------- horizontal ---------------------------------------
			
			this.addStartConstraints(child.x, this.layout.x, null, constraints, outerLimitStrength);
			this.addEndConstraints(child.right, this.layout.right, null, constraints, outerLimitStrength);
			this.addLimitConstraints(child.widthSize, child.hSpace, null, constraints, childLimitStrength, spaceLimitStrength);
			
/*			if (child.hSpace != null) // ------------- Spacer ---------------
			{
				var childPercent = child.widthSize._percent;
				var spacePercent = child.hSpace._percent;
				
				// normalize procentuals
				if (childPercent != null && spacePercent != null) {
					if (childPercent + spacePercent > 1.0) {
						var n = (childPercent + spacePercent - 1.0) / 2;
						childPercent -= n;
						spacePercent -= n;
					}
				}
				
				if (childPercent != null) constraints.push( (child.width == childPercent * this.layout.width) | sizeChildStrength );     // SIZECHILD
				else constraints.push( (child.hSpace.size + child.width == this.layout.width) | sizeChildStrength ); 
				
				if (spacePercent != null) constraints.push( (child.hSpace.size == spacePercent*this.layout.width ) | sizeSpaceStrength );   // SIZESPACE
				else {
					if (child.hSpace._min != null && child.hSpace._max != null) constraints.push( (child.hSpace.size == child.hSpace._min ) | sizeSpaceStrength );
					else if (child.hSpace._min != null) constraints.push( (child.hSpace.size == child.hSpace._min ) | sizeSpaceStrength );
					else if (child.hSpace._max != null) constraints.push( (child.hSpace.size == 0 ) | sizeSpaceStrength );
					else constraints.push( (child.hSpace.size == 0 ) | sizeSpaceStrength );
				}
				
				if (Align.isLeft(child.align)) constraints.push( (child.x == this.layout.x + child.hSpace.size) | positionStrength );               // POSITION left
				else if (Align.isRight(child.align)) constraints.push( (child.right + child.hSpace.size == this.layout.right) | positionStrength ); // POSITION right
				else constraints.push( (child.centerX == this.layout.centerX) | positionStrength );                                                 // POSITION center
				
				constraints.push( (child.width + child.hSpace.size <= this.layout.width) | outerLimitStrength ); // OUTERLIMIT
				
				child.hSpace.addLimitConstraints(constraints, spaceLimitStrength );                               // SPACELIMIT
			}
			else  // ---------------- no Spacer -------------------
			{
				if (child.widthSize._percent != null) constraints.push( (child.width == child.widthSize._percent*this.layout.width) | sizeChildStrength );  // SIZECHILD
				else constraints.push( (child.width == this.layout.width) | sizeChildStrength );
				
				if (Align.isLeft(child.align)) constraints.push( (child.x == this.layout.x) | positionStrength );	            // POSITION left 
				else if (Align.isRight(child.align)) constraints.push( (child.right == this.layout.right) | positionStrength ); // POSITION right
				else constraints.push( (child.centerX == this.layout.centerX) | positionStrength );                             // POSITION center
				
				constraints.push( (child.width <= this.layout.width) | outerLimitStrength );   // OUTERLIMIT	
			}
			
			child.widthSize.addLimitConstraints(constraints, childLimitStrength);               // CHILDLIMIT
*/			
			
			
			// --------------------------------- vertical ---------------------------------------
			// TODO			
			constraints.push( (child.centerY == parentLayout.centerY) | positionStrength );
			child.heightSize.addConstraints(constraints, this.layout.heightSize, positionWeight);
						
			
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
	public inline function new(layout:Layout = null, width:Width = null, height:Height = null, align:Align = Align.center, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null) 
	{
		this = new LayoutContainer(layout, width, height, align, hSpace, vSpace, childs) ;
		this.layout.addChildConstraints = addChildConstraints;
	}
	// ---------- static helpers
	public static inline function center       (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Shelf return new Shelf(layout, width, height, Align.center,      hSpace, vSpace, childs); 
	public static inline function left         (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Shelf return new Shelf(layout, width, height, Align.left,        hSpace, vSpace, childs); 
	public static inline function right        (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Shelf return new Shelf(layout, width, height, Align.right,       hSpace, vSpace, childs); 
	public static inline function top          (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Shelf return new Shelf(layout, width, height, Align.top,         hSpace, vSpace, childs); 
	public static inline function bottom       (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Shelf return new Shelf(layout, width, height, Align.bottom,      hSpace, vSpace, childs); 
	public static inline function topLeft      (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Shelf return new Shelf(layout, width, height, Align.topLeft,     hSpace, vSpace, childs); 
	public static inline function topRight     (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Shelf return new Shelf(layout, width, height, Align.topRight,    hSpace, vSpace, childs); 
	public static inline function bottomLeft   (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Shelf return new Shelf(layout, width, height, Align.bottomLeft,  hSpace, vSpace, childs); 
	public static inline function bottomRight  (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Shelf return new Shelf(layout, width, height, Align.bottomRight, hSpace, vSpace, childs); 
	public static inline function leftTop      (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Shelf return new Shelf(layout, width, height, Align.topLeft,     hSpace, vSpace, childs); 
	public static inline function rightTop     (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Shelf return new Shelf(layout, width, height, Align.topRight,    hSpace, vSpace, childs); 
	public static inline function leftBottom   (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Shelf return new Shelf(layout, width, height, Align.bottomLeft,  hSpace, vSpace, childs); 
	public static inline function rightBottom  (layout:Layout = null, width:Width = null, height:Height = null, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null):Shelf return new Shelf(layout, width, height, Align.bottomRight, hSpace, vSpace, childs); 
	
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
				if (child.widthSize._percent != null) {
					p.child = child.widthSize._percent;
					sum_percent += p.child;
					anz_percent++;
				}
				else if (child.widthSize._max != null) {
					p.childMax = child.widthSize._max - ((child.widthSize._min == null) ? 0 : child.widthSize._min);
					sum_max += p.childMax;
				}
				else if (child.widthSize._min != null) {
					p.childMin = child.widthSize._min;
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
			
			child.widthSize.addLimitConstraints(constraints, childLimitStrength);               // CHILDLIMIT
			
			
			
			// TODO: vertical
			constraints.push( (this.childs[i].top == this.layout.top) | positionStrength );			
			constraints.push( (this.childs[i].bottom <= this.layout.bottom) | outerLimitStrength );
			// height constraints
			child.heightSize.addConstraints(constraints, this.layout.heightSize, positionWeight);
			
			
				
			// recursive Container
			child.addChildConstraints(child, constraints, sizeSpaceWeight, sizeChildWeight, positionWeight, outerLimitWeight, spaceLimitWeight , childLimitWeight);

		}
				
	}
	
}