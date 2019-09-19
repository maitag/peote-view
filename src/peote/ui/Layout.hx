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
	var uiDisplays:Array<Display>;
	var uiElements:Array<UIElement>;
	var constraints:Array<Constraint>;
	
	var solver:Solver;
	
	public function new(editableLayoutVars:Array<Variable>=null, uiDisplays:Array<Display>=null, uiElements:Array<UIElement>=null, constraints:Array<Constraint>=null) 
	{
		this.editableLayoutVars = editableLayoutVars;
		this.constraints = constraints;
		this.uiDisplays = uiDisplays;
		this.uiElements = uiElements;
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
		
		if (uiDisplays != null)
			for (uiDisplay in uiDisplays) {
				if (Std.int(uiDisplay.layout.x.m_value) != uiDisplay.x) uiDisplay.x = Std.int(uiDisplay.layout.x.m_value);
				if (Std.int(uiDisplay.layout.y.m_value) != uiDisplay.y) uiDisplay.y = Std.int(uiDisplay.layout.y.m_value);
				uiDisplay.width = Std.int(uiDisplay.layout.width.m_value);
				uiDisplay.height = Std.int(uiDisplay.layout.height.m_value);
			}

		if (uiElements != null)
			for (uiElement in uiElements) {
				if (uiElement.x != Std.int(uiElement.layout.x.m_value) - uiElement.uiDisplay.x ||
					uiElement.y != Std.int(uiElement.layout.y.m_value) - uiElement.uiDisplay.y || 
					uiElement.width != Std.int(uiElement.layout.width.m_value) ||
					uiElement.height != Std.int(uiElement.layout.height.m_value))
				{
					uiElement.x = Std.int(uiElement.layout.x.m_value) - uiElement.uiDisplay.x;
					uiElement.y = Std.int(uiElement.layout.y.m_value) - uiElement.uiDisplay.y;
					uiElement.width = Std.int(uiElement.layout.width.m_value);
					uiElement.height = Std.int(uiElement.layout.height.m_value);
					uiElement.update();
				}
			}
		
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
	public var x:Value=0;
	public var y:Value=0;
	public var left:Value=0;
	public var top:Value=0;
	
	public var width:Variable;
	public var height:Variable;	
	
	public var right:Expression;
	public var bottom:Expression;
	public var centerX:Expression;
	public var centerY:Expression;

	public function new() 
	{
		width  = new Variable();
		height = new Variable();		
		right = new Expression([new Term(width)]);
		bottom  = new Expression([new Term(height)]);
		centerX = new Expression([new Term(width) / 2.0]);
		centerY = new Expression([new Term(height) / 2.0]);
	}
	
}

class Layout
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