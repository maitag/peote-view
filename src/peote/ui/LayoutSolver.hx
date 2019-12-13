package peote.ui;

import utils.NestedArray;
import jasper.Variable;
import jasper.Solver;
import jasper.Constraint;
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
			solver.addEditVariable(rootLayout.width, Strength.create( 0, 900, 0));
			solver.addEditVariable(rootLayout.height, Strength.create( 0, 900, 0));
		}

		if (editableLayoutVars != null) {
			for (editableLayoutVar in editableLayoutVars) {
				solver.addEditVariable(editableLayoutVar, Strength.create( 0, 900, 0));
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
			rootLayout.updateChilds();
		}
		if (layoutsToUpdate != null) {
			for (layout in layoutsToUpdate) layout.update();
		}		
	}

}

