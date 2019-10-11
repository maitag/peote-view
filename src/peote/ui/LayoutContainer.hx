package peote.ui;

import jasper.Strength;
import jasper.Constraint;
import jasper.Variable;
import utils.NestedArray;
import peote.ui.Layout;


abstract Align(Int) from Int to Int {
	public static inline var Center:Int = 1;
	public static inline var Left:Int = 2;
	public static inline var Right:Int = 3;
	public static inline var Top:Int = 4;
	public static inline var Bottom:Int = 5;
	
	public static inline var TopLeft:Int = 6;
	public static inline var TopRight:Int = 7;
	public static inline var BottomLeft:Int = 8;
	public static inline var BottomRight:Int = 9;
	
	public static inline var LeftTop:Int = 6;
	public static inline var RightTop:Int = 7;
	public static inline var LeftBottom:Int = 8;
	public static inline var RightBottom:Int = 9;
}



@:allow(peote.ui)
class LayoutContainer
{
	var layout:Layout;
	var childs:Array<Layout>;

	public function new(layout:Layout = null, align:Align = Align.Center, widthOptions:Width = null, heightOptions:Height = null, hSpacer:HSpace = null, vSpacer:VSpace = null, childs:Array<Layout> = null) 
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
@:forward abstract Box(LayoutContainer) from LayoutContainer to LayoutContainer
{
	public inline function new(layout:Layout = null, align:Align = Align.Center, widthOptions:Width = null, heightOptions:Height = null, hSpacer:HSpace = null, vSpacer:VSpace = null, childs:Array<Layout> = null) 
	{
		this = new LayoutContainer(layout, widthOptions, heightOptions, hSpacer, vSpacer, childs) ;
		this.layout.addChildConstraints = addChildConstraints;
	}
	
	@:to public function toNestedArray():NestedArray<Constraint> return(this.getConstraints());
	@:to public function toNestedArrayItem():NestedArrayItem<Constraint> return(this.getConstraints().toArray());	
	@:to public function toLayout():Layout return(this.layout);

	function addChildConstraints(parentLayout:Layout, constraints:NestedArray<Constraint>, weight:Float = 1.0)
	{
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

@:forward abstract HShelf(LayoutContainer) from LayoutContainer to LayoutContainer
{
	public inline function new(layout:Layout = null, align:Align = Align.Center, widthOptions:Width = null, heightOptions:Height = null, hSpacer:HSpace, vSpacer:VSpace, childs:Array<Layout> = null) 
	{
		this = new LayoutContainer(layout, widthOptions, heightOptions, hSpacer, vSpacer, childs) ;
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
	
}