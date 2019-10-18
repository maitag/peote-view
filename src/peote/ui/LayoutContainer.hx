package peote.ui;

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

	public function new(layout:Layout = null, width:Width = null, height:Height = null, align:Align = Align.center, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null) 
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
	
	public function getConstraints():NestedArray<Constraint>
	{
		var constraints = new NestedArray<Constraint>();
		
		// recursive Container
		this.layout.addChildConstraints(this.layout, constraints);
		
		// max/min size constraints
		//this.layout.addWidthConstraints(constraints, Strength.create(0, 0, 600, 1.0));
		//this.layout.addHeightConstraints(constraints, Strength.create(0, 0, 600, 1.0));
		
		return(constraints);
	}
	
}

// -------------------------------------------------------------------------------------------------
// -----------------------------     Box    --------------------------------------------------------
// -------------------------------------------------------------------------------------------------
@:forward @:forwardStatics abstract Box(LayoutContainer) // from LayoutContainer to LayoutContainer
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
		
		if (this.childs != null) for (i in 0...this.childs.length)
		{	
			trace("addChildConstraints");
			var child = this.childs[i];
			
			// --------------------------------- horizontal ---------------------------------------
			
			if (child.hSpace != null) // ------------- Spacer ---------------
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
				if (this.childs[i].widthSize._percent != null) constraints.push( (child.width == child.widthSize._percent*this.layout.width) | sizeChildStrength );  // SIZECHILD
				else constraints.push( (child.width == this.layout.width) | sizeChildStrength );
				
				if (Align.isLeft(child.align)) constraints.push( (child.x == this.layout.x) | positionStrength );	            // POSITION left 
				else if (Align.isRight(child.align)) constraints.push( (child.right == this.layout.right) | positionStrength ); // POSITION right
				else constraints.push( (child.centerX == this.layout.centerX) | positionStrength );                             // POSITION center
				
				constraints.push( (child.width <= this.layout.width) | outerLimitStrength );   // OUTERLIMIT	
			}
			
			child.widthSize.addLimitConstraints(constraints, childLimitStrength);               // CHILDLIMIT
			
			
			
			// --------------------------------- vertical ---------------------------------------
			// TODO
			
			constraints.push( (child.centerY == parentLayout.centerY) | positionStrength );
			//constraints.push( (child.height == parentLayout.height) | medium );
			
			// height constraints
			child.heightSize.addConstraints(constraints, this.layout.heightSize, positionWeight);
			
			
			
			// ------------------------- recursive childs --------------------------
			child.addChildConstraints(child, constraints, sizeSpaceWeight, sizeChildWeight, positionWeight, outerLimitWeight, spaceLimitWeight , childLimitWeight);
			
		}
				
	}
	
}


// -------------------------------------------------------------------------------------------------
// -----------------------------   HShelf   --------------------------------------------------------
// -------------------------------------------------------------------------------------------------

/*@:forward @:forwardStatics abstract HShelf(LayoutContainer) from LayoutContainer to LayoutContainer
{
	public inline function new(layout:Layout = null, width:Width = null, height:Height = null, align:Align = Align.center, hSpace:HSpace = null, vSpace:VSpace = null, childs:Array<Layout> = null) 
	{
		this = new LayoutContainer(layout, width, height, align, hSpace, vSpace, childs) ;
		this.layout.addChildConstraints = addChildConstraints;
	}
	
	@:to public function toNestedArray():NestedArray<Constraint> return(this.getConstraints());
	@:to public function toNestedArrayItem():NestedArrayItem<Constraint> return(this.getConstraints().toArray());	
	@:to public function toLayout():Layout return(this.layout);

	function addChildConstraints(parentLayout:Layout, constraints:NestedArray<Constraint>, weight:Float = 1.0)
	{
		var weak = Strength.create(0, 0, 1, weight);
		var weak5 = Strength.create(0, 0, 500, weight);
		var medium = Strength.create(0, 1, 0, weight);
		
		if (this.childs != null)
			for (i in 0...this.childs.length)
			{	
				// horizontal
				if (i == 0)  // first
					constraints.push( (this.childs[i].left == this.layout.left) | medium );
				else
					constraints.push( (this.childs[i].left == this.childs[i-1].right + 10) | medium );
				
				if (i == this.childs.length - 1) {  // last
					constraints.push( (this.childs[i].right == this.layout.right) | medium);
				}
				else {
					// force same width
					for (j in (i + 1)...this.childs.length) {
						constraints.push( (this.childs[i].width == this.childs[j].width) | weak);
					}
				}
				
				//this.childs[i].widthSize.addConstraints(constraints, this.layout.widthSize, weight);
				
				// vertical
				constraints.push( (this.childs[i].top == this.layout.top) | medium );
				
				constraints.push( (this.childs[i].bottom == this.layout.bottom) | weak );
				
				//if (childs.length == 1)
					//constraints.push( (childs[i].bottom == parentLayout.bottom) | weak9 );
				//else if (childs[i].heightSize == null )
					//constraints.push( (childs[i].bottom == parentLayout.bottom) | weak3 );
				//else
					//constraints.push( (childs[i].bottom == parentLayout.bottom) | Strength.create(0, 0, 100+i*10, weight));
				
					
				// recursive Container
				this.childs[i].addChildConstraints(this.childs[i], constraints, weight+0.05);

			}
				
	}
	
}*/