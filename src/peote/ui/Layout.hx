package peote.ui;

import utils.NestedArray;
import peote.view.PeoteView;
import peote.view.Display;

import jasper.Expression;
import jasper.Term;
import jasper.Variable;
import jasper.Constraint;
import jasper.Solver;
import jasper.Strength;

class LayoutSolver
{
	var rootLayout:Layout;
	var editableLayoutVars:Array<Variable>;
	var layoutsToUpdate:Array<Layout>;
	var constraints:Array<Constraint>;
	
	var solver:Solver;
	
	public function new(rootLayout:Layout=null, editableLayoutVars:Array<Variable>=null, layoutsToUpdate:Array<Layout>=null, constraints:NestedArray<Constraint>=null) 
	{
		this.rootLayout = rootLayout;
		this.editableLayoutVars = editableLayoutVars;
		this.layoutsToUpdate = layoutsToUpdate;
		this.constraints = constraints;
				
		solver = new Solver();
		
		if (rootLayout == null && editableLayoutVars == null) throw("Error: needs at least a rootLayout if no editableLayoutVars specified");

		if (rootLayout != null) {
			solver.addEditVariable(rootLayout.width, Strength.STRONG);
			solver.addEditVariable(rootLayout.height, Strength.STRONG);
		}

		if (editableLayoutVars != null) {
			for (editableLayoutVar in editableLayoutVars) {
				solver.addEditVariable(editableLayoutVar, Strength.STRONG);
			}
		}
		
		if (constraints != null) addConstraints(constraints);
	}
	
	public inline function addConstraints(constraints:Array<Constraint>):LayoutSolver
	{
		for (constraint in constraints) {
			solver.addConstraint(constraint);
		}
		return this;
	}
	
	public inline function addConstraint(constraint:Constraint):LayoutSolver
	{
		solver.addConstraint(constraint);
		return this;
	}
	
	public inline function removeConstraint(constraint:Constraint):LayoutSolver
	{
		solver.removeConstraint(constraint);
		return this;
	}
	
	public inline function suggestValues(values:Array<Int>):LayoutSolver
	{
		var start:Int = 0;
		if (rootLayout != null) {
			solver.suggestValue(rootLayout.width, values[0]);
			solver.suggestValue(rootLayout.height, values[1]);
			start = 2;
		}
		if (editableLayoutVars != null) {
			for (i in start...values.length) {
				solver.suggestValue(editableLayoutVars[i], values[i]);
			}
		}
		return this;
	}
	
	public inline function suggest(layoutVar: Variable, value:Int):LayoutSolver
	{
		solver.suggestValue(layoutVar, value);
		return this;
	}
	
	public inline function update()
	{
        solver.updateVariables();
		if (rootLayout != null) {
			rootLayout.update();
		}
		if (layoutsToUpdate != null) {
			for (layout in layoutsToUpdate) layout.update();
		}		
	}

}


@:allow(peote.ui, peote.view)
class _Layout_
{
	public var x:Variable;
	public var y:Variable;	
	public var width:Variable;
	public var height:Variable;	
	
	public var centerX:Expression;
	public var centerY:Expression;

	public var left:Expression;
	public var top:Expression;
	public var right:Expression;
	public var bottom:Expression;
	

	public function addWidthConstraints(constraints:NestedArray<Constraint>, strength:Strength) 
	{
		// restrict width
		if (minWidth == maxWidth)
			constraints.push( (width == maxWidth) | strength );
		else {
			constraints.push( (width >= minWidth) | strength );
			if (maxWidth > -1) constraints.push( (width <= maxWidth) | strength );
		}
	}
	public function addHeightConstraints(constraints:NestedArray<Constraint>, strength:Strength)
	{
		// restrict height
		if (minHeight == maxHeight)
			constraints.push( (height == maxHeight) | strength );
		else {
			constraints.push( (height >= minHeight) | strength );
			if (maxHeight > -1) constraints.push( (height <= maxHeight) | strength );
		}
	}

	var addChildConstraints:Layout->NestedArray<Constraint>->?Float->Void = function(parentLayout:Layout, constraints:NestedArray<Constraint>, weight:Float = 1.0) {};
	
	var update:Void->Void = function() {};
	var updateChilds:Void->Void = function() {};
	
	public function new()
	{
		x = new Variable();
		y = new Variable();
		width = new Variable();
		height = new Variable();
		
		centerX = new Term(x) + (new Term(width) / 2.0);
		centerY = new Term(y) + (new Term(height) / 2.0);
		
		left = new Expression([new Term(x)]);
		top  = new Expression([new Term(y)]);
		right  = new Term(x) + new Term(width);
		bottom = new Term(y) + new Term(height);		
	}
	
	// for constraints to restrict size
	public var minWidth = 0;
	public var maxWidth = -1;

	public var minHeight = 0;
	public var maxHeight = -1;
	
	public function minSize(minWidth:Int = 0, minHeight:Int = 0) {
		this.minWidth = Std.int(Math.max(0, minWidth));
		this.minHeight = Std.int(Math.max(0, minHeight));
		if (maxWidth > -1 && maxWidth < this.minWidth) maxWidth = minWidth;
		if (maxHeight > -1 && maxHeight < this.minHeight) maxHeight = minHeight;
	}
	public function maxSize(maxWidth:Null<Int> = null, maxHeight:Null<Int> = null) {
		if (maxWidth == null) this.maxWidth = -1;
		else {
			this.maxWidth = maxWidth;
			if (minWidth > maxWidth) minWidth = maxWidth;
		}
		if (maxHeight == null) this.maxHeight = -1;
		else {
			this.maxHeight = maxHeight;
			if (minHeight > maxHeight) minHeight = maxHeight;
		}
	}
	
}

@:forward
abstract Layout(_Layout_) to _Layout_
{
    public function new()
    {
        this = new _Layout_();
    }
		
	@:from static public function fromPeoteView(v:PeoteView) {
		return v.layout;
	}
	
	@:from static public function fromDisplay(d:Display) {
		return d.layout;
	}
	
	@:from static public function fromUIElement(e:UIElement) {
		return e.layout;
	}
}