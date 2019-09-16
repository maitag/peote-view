package peote.ui;

import jasper.Expression;
import jasper.Term;
import jasper.Variable;
import jasper.Value;

class Layout
{
	
}


class LayoutViewVars 
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

class LayoutVars 
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