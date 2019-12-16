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
	
	function fixLimit(childSize:SizeSpaced, limit:Int) 
	{
		if (childSize.middle.limit._min < limit) {
			childSize.middle.limit._min = limit;
			if (childSize.middle.limit._max != null) childSize.middle.limit._max = Std.int(Math.max(childSize.middle.limit._max, childSize.middle.limit._min));
		}		
	}
	
	function fixSpacer(size:SizeSpaced, childSize:SizeSpaced) 
	{
		if (!childSize.hasSpan()) {
			if ( size.middle.limit.span || childSize.getLimitMax() < ( (size.middle.limit._max != null) ? size.middle.limit._max : size.middle.limit._min) )
			{
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
		
}

// -------------------------------------------------------------------------------------------------
// -----------------------------     Box    --------------------------------------------------------
// -------------------------------------------------------------------------------------------------
abstract Box(LayoutContainer)
{
	public inline function new(layout:Layout = null, width:Width = null, height:Height = null, 
		lSpace:LeftSpace = null, rSpace:RightSpace = null, tSpace:TopSpace = null, bSpace:BottomSpace = null,
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
				// ------------------------- recursive childs --------------------------
				var innerLimit = child.addChildConstraints(constraints);				
				
				// --------------------------------- horizontal ---------------------------------------				
				this.fixLimit(child.hSize, innerLimit.width);
				this.fixSpacer(this.layout.hSize, child.hSize);
				
				if (child.hSize.getMin() > childsLimit.width) childsLimit.width = child.hSize.getMin();
				
				var hSizeVars = child.addHConstraints(constraints, {sLimit:null, sSpan:null}, strength);				
				if (hSizeVars.sSpan != null) constraints.push( (hSizeVars.sSpan == (this.layout.width - child.hSize.getLimitMax()) / child.hSize.getSumWeight() ) | strengthLow );
				
				constraints.push( (child.left == this.layout.x) | strength );
				constraints.push( (child.right == this.layout.x + this.layout.width) | strength );
				
				// --------------------------------- vertical ---------------------------------------
				this.fixLimit(child.vSize, innerLimit.height);
				this.fixSpacer(this.layout.vSize, child.vSize);
				
				if (child.vSize.getMin() > childsLimit.height) childsLimit.height = child.vSize.getMin();
				
				var vSizeVars = child.addVConstraints(constraints, {sLimit:null, sSpan:null}, strength);				
				if (vSizeVars.sSpan != null) constraints.push( (vSizeVars.sSpan == (this.layout.height - child.vSize.getLimitMax()) / child.vSize.getSumWeight() ) | strengthLow );
				
				constraints.push( (child.top == this.layout.y) | strength );
				constraints.push( (child.bottom == this.layout.y + this.layout.height) | strength );				
			}
		}
		return childsLimit;
	}
	
}


// -------------------------------------------------------------------------------------------------
// -----------------------------   HBox   ----------------------------------------------------------
// -------------------------------------------------------------------------------------------------
abstract HBox(LayoutContainer)
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
		var strength = Strength.create(0, 900, 0); // TODO: gloabalstatic
		var strengthLow = Strength.create(0, 0, 900);		
		var childsLimit = {width:0, height:0};

		if (this.childs != null)
		{
			var hSizeVars:SizeVars = {sLimit:null, sSpan:null};
			var hLimitMax:Int = 0;
			var hSumWeight:Float = 0.0;			
			var noChildHasSpan = true;
			
			for (child in this.childs) {
				if (noChildHasSpan && child.hSize.hasSpan()) noChildHasSpan = false;
				hLimitMax += child.hSize.getLimitMax();
			}
			
			if (noChildHasSpan && this.childs.length>0) {
				if ( this.layout.hSize.middle.limit.span || hLimitMax < ( (this.layout.hSize.middle.limit._max != null) ? this.layout.hSize.middle.limit._max : this.layout.hSize.middle.limit._min) )
				{
					if (this.childs[0].hSize.first != null && this.childs[this.childs.length-1].hSize.last != null) {
						this.childs[0].hSize.first.limit.span = true;
						this.childs[this.childs.length-1].hSize.last.limit.span = true;
					}
					else {
						if (this.childs[0].hSize.first == null) this.childs[0].hSize.first = new Size(Limit.min());
						if (this.childs[this.childs.length-1].hSize.last  == null) this.childs[this.childs.length-1].hSize.last = new Size(Limit.min());
					}					
				}					
			}
			
			for (i in 0...this.childs.length)
			{	
				var child = this.childs[i];
				// ------------------------- recursive childs --------------------------
				var innerLimit = child.addChildConstraints(constraints);			
				
				// --------------------------------- horizontal ---------------------------------------				
				this.fixLimit(child.hSize, innerLimit.width);
				
				childsLimit.width += child.hSize.getMin();
				
				hSizeVars = child.addHConstraints(constraints, hSizeVars, strength);
				hSumWeight += child.hSize.getSumWeight();
				
				if (i == 0) constraints.push( (child.left == this.layout.x) | strength ); // first
				else constraints.push( (child.left == this.childs[i-1].right) | strength ); // not first
				if (i == this.childs.length - 1) constraints.push( (child.right == this.layout.x + this.layout.width) | strength ); // last
				
				// --------------------------------- vertical ---------------------------------------
				this.fixLimit(child.vSize, innerLimit.height);
				this.fixSpacer(this.layout.vSize, child.vSize);
				
				if (child.vSize.getMin() > childsLimit.height) childsLimit.height = child.vSize.getMin();
				
				var vSizeVars = child.addVConstraints(constraints, {sLimit:null, sSpan:null}, strength);				
				if (vSizeVars.sSpan != null) constraints.push( (vSizeVars.sSpan == (this.layout.height - child.vSize.getLimitMax()) / child.vSize.getSumWeight() ) | strengthLow );
				
				constraints.push( (child.top == this.layout.y) | strength );
				constraints.push( (child.bottom == this.layout.y + this.layout.height) | strength );
			}
			// -------------------------
			if (hSizeVars.sSpan != null) constraints.push( (hSizeVars.sSpan == (this.layout.width - hLimitMax) / hSumWeight ) | strengthLow );
			
		}		
		return childsLimit;
	}



}