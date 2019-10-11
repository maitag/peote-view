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
			this.layout = new Layout();
		else this.layout = layout;
		
		this.childs = childs;
		layout.updateChilds = updateChilds;	
		
	}
		
	function updateChilds() {
		trace("update childs", childs.length);
		for (child in childs) {
			child.update();
			child.updateChilds();
		}
	}
	//function addChildConstraints(parentLayout:Layout, constraints:NestedArray<Constraint>, weight:Float = 1.0)
	//{}
	
	public function getConstraints():NestedArray<Constraint>
	{
		var constraints = new NestedArray<Constraint>();
		
		// recursive Container
		this.layout.addChildConstraints(this.layout, constraints, 1.0);
		
		// max/min size constraints
		//this.layout.addWidthConstraints(constraints, Strength.create(0, 0, 600, 1.0));
		//this.layout.addHeightConstraints(constraints, Strength.create(0, 0, 600, 1.0));
		
		return(constraints);
	}
	
}

// -------------------------------------------------------------------------------------------------
// -----------------------------     Box    --------------------------------------------------------
// -------------------------------------------------------------------------------------------------
@:forward @:forwardStatics abstract Box(LayoutContainer) //from LayoutContainer to LayoutContainer
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

	function addChildConstraints(parentLayout:Layout, constraints:NestedArray<Constraint>, weight:Float = 1.0):Void
	{
		trace("addChildConstraints");
		var weak = Strength.create(0, 0, 1, weight);
		var medium = Strength.create(0, 1, 0, weight);
		
		if (this.childs != null)
			for (i in 0...this.childs.length)
			{	
				// horizontal
				constraints.push( (this.childs[i].centerX == parentLayout.centerX) | medium );
				constraints.push( (this.childs[i].width == parentLayout.width-20) | medium );
				// vertical
				constraints.push( (this.childs[i].centerY == parentLayout.centerY) | medium );
				constraints.push( (this.childs[i].height == parentLayout.height-20) | medium );
				
				// recursive Container
				this.childs[i].addChildConstraints(this.childs[i], constraints, weight+0.05);
			}
				
	}
	
}


// -------------------------------------------------------------------------------------------------
// -----------------------------   HShelf   --------------------------------------------------------
// -------------------------------------------------------------------------------------------------

/*@:forward abstract HShelf(LayoutContainer) from LayoutContainer to LayoutContainer
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
					constraints.push( (this.childs[i].left == parentLayout.left) | medium );
				else
					constraints.push( (this.childs[i].left == this.childs[i-1].right + 10) | medium );
				
				if (i == this.childs.length - 1) {  // last
					constraints.push( (this.childs[i].right == parentLayout.right) | weak5);
				}
				else {
					// force same width
					for (j in (i + 1)...this.childs.length) {
						constraints.push( (this.childs[i].width == this.childs[j].width) | weak);
					}
				}
				
				// vertical
				constraints.push( (this.childs[i].top == parentLayout.top) | medium );
				
				constraints.push( (this.childs[i].bottom == parentLayout.bottom) | weak );
				
					
				// recursive Container
				this.childs[i].addChildConstraints(this.childs[i], constraints, weight+0.05);

			}
				
	}
	
}*/