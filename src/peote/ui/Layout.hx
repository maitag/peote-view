package peote.ui;

import utils.NestedArray;

import peote.view.PeoteView;
import peote.view.Display;

import jasper.Expression;
import jasper.Term;
import jasper.Variable;
import jasper.Constraint;
import jasper.Strength;


abstract Align(Int) from Int to Int {
	public static inline var center:Int = 1;
	public static inline var left:Int = 2;
	public static inline var right:Int = 3;
	public static inline var top:Int = 4;
	public static inline var bottom:Int = 5;
	
	public static inline var topLeft:Int = 6;
	public static inline var topRight:Int = 7;
	public static inline var bottomLeft:Int = 8;
	public static inline var bottomRight:Int = 9;
	
	public static inline var leftTop:Int = 6;
	public static inline var rightTop:Int = 7;
	public static inline var leftBottom:Int = 8;
	public static inline var rightBottom:Int = 9;
}


@:allow(peote.ui)
class Size {
	var _size:Null<Int>;
	var _percent:Null<Float>;
	var _min:Null<Int>;
	var _max:Null<Int>;
	
	var size:Variable;
	
	inline function new(pixel:Null<Int>, percent:Null<Float>, min:Null<Int>, max:Null<Int>) {
		size = new Variable();
	}
	
	public static inline function px(pixel:Int, min:Null<Int> = null, max:Null<Int> = null):Size {
		return new Size(pixel, null, min, max);
	}
	public static inline function percent(percent:Float, min:Null<Int> = null, max:Null<Int> = null):Size {
		return new Size(null, percent, min, max);
	}
	public static inline function min(min:Int):Size {
		return new Size(null, null, min, null);
	}
	public static inline function max(max:Int):Size {
		return new Size(null, null, null, max);
	}	
	
}

// ---------- Size helpers

@:forwardStatics
abstract Width(Size) from Size to Size {
	@:from public static inline function fromInt(i:Int):Width return Size.px(i);
}

@:forwardStatics
abstract Height(Size) from Size to Size {
	@:from public static inline  function fromInt(i:Int):Height return Size.px(i);
}

@:forwardStatics
abstract HSpace(Size) from Size to Size {
	@:from public static inline  function fromInt(i:Int):HSpace return Size.px(i);
}

@:forwardStatics
abstract VSpace(Size) from Size to Size {
	@:from public static inline  function fromInt(i:Int):VSpace return Size.px(i);
}


// ----------------- Layout -------------------

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