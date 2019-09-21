package peote.ui;

import peote.view.PeoteView;
import peote.view.Display;

import jasper.Expression;
import jasper.Term;
import jasper.Variable;
import jasper.Value;
import jasper.Constraint;
import jasper.Solver;
import jasper.Strength;

/*import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Printer;
*/

class LayoutSolver
{
	var editableLayoutVars:Array<Variable>;
	var layoutsToUpdate:Array<Layout>;
	var constraints:Array<Constraint>;
	
	var solver:Solver;
	
	public function new(editableLayoutVars:Array<Variable>=null, layoutsToUpdate:Array<Layout>, constraints:Array<Constraint>=null) 
	{
		this.editableLayoutVars = editableLayoutVars;
		this.constraints = constraints;
		this.layoutsToUpdate = layoutsToUpdate;
		this.constraints = constraints;
				
		solver = new Solver();
		
		if (editableLayoutVars != null)
			for (editableLayoutVar in editableLayoutVars) {
				solver.addEditVariable(editableLayoutVar, Strength.MEDIUM);
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
		if (editableLayoutVars != null)
			for (i in 0...values.length) {
				solver.suggestValue(editableLayoutVars[i], values[i]);
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
		for (layout in layoutsToUpdate) layout.update(); 
	}

	// TODO: to deliver a new Layout from a more easy notation like:
	/*	Layout.create(
			peoteView.width, peoteView.height, // editable Vars that is in change... see "suggest()"
			hbox(b1, vbox(b2,b3), b4),
			(b1.width <= 600) | MEDIUM,
			(b1.width >= 200) | medium
		);
	*/	
	/*	public static macro function create(expr:Expr):Expr 
		{
			var e = new Printer().printExpr(expr);
			// TODO: expression parsing 
			return Context.parse(code, Context.currentPos());
		}
	*/
}


class LayoutView 
{
	public var x:Value;
	public var y:Value;	
	public var width:Variable;
	public var height:Variable;	
	
	public var centerX:Expression;
	public var centerY:Expression;

	public var left:Value;
	public var top:Value;
	public var right:Expression;
	public var bottom:Expression;

	var addToConstraints:Layout->Array<Constraint>->Void = function(parentLayout:Layout, constraints:Array<Constraint>) {};
	var update:Void->Void;

	public function new() 
	{
		x = 0;
		y = 0;
		left = 0;
		top = 0;
		
		width  = new Variable();
		height = new Variable();		

		centerX = new Expression([new Term(width) / 2.0]);
		centerY = new Expression([new Term(height) / 2.0]);

		right = new Expression([new Term(width)]);
		bottom  = new Expression([new Term(height)]);
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
	
	var addToConstraints:Layout->Array<Constraint>->Void = function(parentLayout:Layout, constraints:Array<Constraint>) {};
	var update:Void->Void;
	
	public function new()
	{
		x = new Variable();
		y = new Variable();
		width  = new Variable();
		height = new Variable();
		
		centerX = new Term(x) + (new Term(width) / 2.0);
		centerY = new Term(y) + (new Term(height) / 2.0);
		
		left = new Expression([new Term(x)]);
		top  = new Expression([new Term(y)]);
		right  = new Term(x) + new Term(width);
		bottom = new Term(y) + new Term(height);
		
	}
	
}

@:forward
abstract Layout(_Layout_) to _Layout_ {
    public function new()
    {
        this = new _Layout_();
    }
		
/*	@:from static public function fromPeoteView(v:PeoteView) {
		return v.layout;
	}
*/	
	@:from static public function fromDisplay(d:Display) {
		return d.layout;
	}
	
	@:from static public function fromUIElement(e:UIElement) {
		return e.layout;
	}
}