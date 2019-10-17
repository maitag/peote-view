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
		this.layout.addChildConstraints(this.layout, constraints, 500);
		
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

	function addChildConstraints(parentLayout:Layout, constraints:NestedArray<Constraint>, weight:Int):Void
	{
		var weak = Strength.create(0, 0, weight);
		var weak1 = Strength.create(0, 0, weight+10);
		var medium = Strength.create(0, weight, 0);
		var medium1 = Strength.create(0, weight+10, 0);
		var medium2 = Strength.create(0, weight+20, 0);
		var strong = Strength.create(weight, 0, 0);
				
		if (this.childs != null) for (i in 0...this.childs.length)
		{	
			trace("addChildConstraints");
			var child = this.childs[i];
			// ------- horizontal
			
			// TODO: if there is hspace -> allways do with extra-calculated procentual size for both!
			if (child.hSpace != null) 
				if (child.hSpace._percent != null) constraints.push( (child.hSpace.size == child.hSpace._percent*this.layout.width) | weak1 );
			
			if (this.childs[i].widthSize._percent != null)  {
				constraints.push( (child.width == child.widthSize._percent*this.layout.width) | weak );
			}
			else {
				if (child.hSpace == null) constraints.push( (child.width == this.layout.width) | weak );
				else constraints.push( (child.width + child.hSpace.size == this.layout.width) | weak );
			}
			
			if (Align.isLeft(child.align))
			{
				if (child.hSpace == null) constraints.push( (child.x == this.layout.x) | medium );	 // left
				else constraints.push( (child.x == this.layout.x + child.hSpace.size) | medium );
			}
			else if (Align.isRight(child.align))
			{
				if (child.hSpace == null) constraints.push( (child.right == this.layout.right) | medium );  // right
				else constraints.push( (child.right + child.hSpace.size == this.layout.right) | medium );
			}
			else 
			{
				constraints.push( (child.centerX == this.layout.centerX) | medium );  // center
			}
			
			if (child.hSpace == null) constraints.push( (child.width <= this.layout.width) | Strength.create(0, 1000-weight, 0) );			
			else constraints.push( (child.width + child.hSpace.size <= this.layout.width) | Strength.create(0, 1000-weight, 0) );			
			
			child.widthSize.addFlexConstraints(constraints, Strength.create(0, 1000 - weight, 0));
			if (child.hSpace != null) child.hSpace.addFlexConstraints(constraints, Strength.create(0, 1000-weight, 0)); // hspace
			
			
			
			//  ------- vertical
			
			constraints.push( (child.centerY == parentLayout.centerY) | medium );
			//constraints.push( (child.height == parentLayout.height) | medium );
			
			// height constraints
			child.heightSize.addConstraints(constraints, this.layout.heightSize, weight);
			
			
			
			
			// recursive Container
			child.addChildConstraints(child, constraints, weight-100);
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