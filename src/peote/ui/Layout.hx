package peote.ui;

import utils.NestedArray;

import peote.view.PeoteView;
import peote.view.Display;

import jasper.Expression;
import jasper.Term;
import jasper.Variable;
import jasper.Constraint;
import jasper.Strength;

@:allow(peote.ui)
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
	
	static function isLeft(align:Align):Bool return (align == left || align == topLeft || align == bottomLeft);
	static function isRight(align:Align):Bool return (align == right || align == topRight || align == bottomRight);

}


@:allow(peote.ui)
class Size {
	var _percent:Null<Float>;
	var _min:Null<Int>;
	var _max:Null<Int>;
	
	public var size:Variable;
	
	inline function new(percent:Null<Float>, min:Null<Int>, max:Null<Int>) {
		_percent = percent;
		_min = min;
		_max = max;
		size = new Variable();
	}
	
	public static inline function px(pixel:Int):Size return new Size(null, pixel,pixel);
	public static inline function percent(percent:Float, min:Null<Int> = null, max:Null<Int> = null):Size return new Size(percent, min, max);
	public static inline function min(min:Int):Size return new Size(null, min, null);
	public static inline function max(max:Int):Size return new Size(null, null, max);
	public static inline function flex(min:Int, max:Int):Size return new Size(null, min, max);
	
	// TODO: dummy
	public function addConstraints(constraints:NestedArray<Constraint>, parentSize:Size, weight:Int)
	{
		//var weak = Strength.create(0, 0, weight);
		//var weak1 = Strength.create(0, 0, weight+10);		
		var medium = Strength.create(0, weight, 0);
		var medium1 = Strength.create(0, weight+10, 0);
		var medium2 = Strength.create(0, weight+20, 0);
		var medium3 = Strength.create(0, weight+30, 0);

		if (_percent != null) {
			constraints.push( (size == _percent*parentSize.size) | medium1 );
		}
		else {
			constraints.push( (size == parentSize.size) | medium1 );
		}
		
		if (_min != null)
			constraints.push( (size >= _min) | medium3 );
		else
			constraints.push( (size >= 0) | medium3 );
		
		if (_max != null)
			constraints.push( (size <= _max) | medium3 );
	}
	
	public function addLimitConstraints(constraints:NestedArray<Constraint>, strength:Strength)
	{
		if (_min != null && _max != null && _min >= _max )
			constraints.push( (size == _min) | strength );
		else
		{
			if (_min != null)
				constraints.push( (size >= _min) | strength );
			else
				constraints.push( (size >= 0) | strength );
			
			if (_max != null)
				constraints.push( (size <= _max) | strength );
		}
	}
	
}

// ---------- Size helpers

@:forward @:forwardStatics
abstract Width(Size) from Size to Size {
	public inline function new(width:Int) this = Size.px(width);
	@:from public static inline function fromInt(i:Int):Width return Size.px(i);
	public static inline function px(pixel:Int):Width return new Size(null, pixel,pixel);
	public static inline function percent(percent:Float, min:Null<Int> = null, max:Null<Int> = null):Width return new Size(percent, min, max);
	public static inline function min(min:Int):Width return new Size(null, min, null);
	public static inline function max(max:Int):Width return new Size(null, null, max);
	public static inline function flex(min:Int, max:Int):Width return new Size(null, min, max);
	// TODO: ratio to Height
}

@:forward @:forwardStatics
abstract Height(Size) from Size to Size {
	public inline function new(height:Int) this = Size.px(height);
	@:from public static inline function fromInt(i:Int):Height return Size.px(i);
	public static inline function px(pixel:Int):Height return new Size(null, pixel,pixel);
	public static inline function percent(percent:Float, min:Null<Int> = null, max:Null<Int> = null):Height return new Size(percent, min, max);
	public static inline function min(min:Int):Height return new Size(null, min, null);
	public static inline function max(max:Int):Height return new Size(null, null, max);
	public static inline function flex(min:Int, max:Int):Height return new Size(null, min, max);
	// TODO: ratio to Width
}

@:forward @:forwardStatics
abstract HSpace(Size) from Size to Size {
	public inline function new(width:Int) this = Size.px(width);
	@:from public static inline  function fromInt(i:Int):HSpace return Size.px(i);
	public static inline function px(pixel:Int):HSpace return new Size(null, pixel,pixel);
	public static inline function percent(percent:Float, min:Null<Int> = null, max:Null<Int> = null):HSpace return new Size(percent, min, max);
	public static inline function min(min:Int):HSpace return new Size(null, min, null);
	public static inline function max(max:Int):HSpace return new Size(null, null, max);
	public static inline function flex(min:Int, max:Int):HSpace return new Size(null, min, max);
}

@:forward @:forwardStatics
abstract VSpace(Size) from Size to Size {
	public inline function new(width:Int) this = Size.px(width);
	@:from public static inline  function fromInt(i:Int):VSpace return Size.px(i);
	public static inline function px(pixel:Int):VSpace return new Size(null, pixel,pixel);
	public static inline function percent(percent:Float, min:Null<Int> = null, max:Null<Int> = null):VSpace return new Size(percent, min, max);
	public static inline function min(min:Int):VSpace return new Size(null, min, null);
	public static inline function max(max:Int):VSpace return new Size(null, null, max);
	public static inline function flex(min:Int, max:Int):VSpace return new Size(null, min, max);
}


// ----------------- Layout -------------------

@:allow(peote.ui, peote.view)
class _Layout_
{
	public var x(default,null):Variable;
	public var y(default,null):Variable;	
	
	public var widthSize:Width;
	public var heightSize:Height;
	public var align:Align;
	
	public var hSpace:HSpace;
	public var vSpace:VSpace;	
	
	public var width(get, never):Variable;
	public var height(get, never):Variable;	
	public inline function get_width():Variable return widthSize.size;
	public inline function get_height():Variable return heightSize.size;
		
	public var centerX:Expression;
	public var centerY:Expression;

	public var left(default,null):Expression;
	public var top(default, null):Expression;
	public var right(default,null):Expression;
	public var bottom(default,null):Expression;
	
	var addChildConstraints:Layout->NestedArray<Constraint>->?Int->?Int->?Int->?Int->?Int->?Int->Void =
		function(parentLayout:Layout, constraints:NestedArray<Constraint>,	
			?sizeSpaceWeight:Int,
			?sizeChildWeight:Int,
			?positionWeight:Int,
			?outerLimitWeight:Int,
			?spaceLimitWeight:Int,
			?childLimitWeight:Int) {};
	
	var update:Void->Void = function() {};
	var updateChilds:Void->Void = function() {};

	
	public function addHConstraints(constraints:NestedArray<Constraint>, start:Variable, end:Variable, weight:Float)
	{
		var medium1 = Strength.create(0, 100, 0, weight);
		constraints.push( (x == start) | medium1 );
		constraints.push( (right == end) | medium1 );
	}
	public function addVConstraints(constraints:NestedArray<Constraint>, start:Variable, end:Variable, weight:Float)
	{
		var medium1 = Strength.create(0, 100, 0, weight);
		constraints.push( (y == start) | medium1 );
		constraints.push( (bottom == end) | medium1 );
	}
	

	public function new(widthSize:Width, heightSize:Height, align:Align, hSpace:HSpace, vSpace:VSpace)
	{
		x = new Variable();
		y = new Variable();
		if (widthSize == null) this.widthSize = Width.min(0) else this.widthSize = widthSize;
		if (heightSize == null) this.heightSize = Height.min(0) else this.heightSize = heightSize;
		
		this.align = align;
		this.hSpace = hSpace;
		this.vSpace = vSpace;
		
		left = new Expression([new Term(x)]);
		top  = new Expression([new Term(y)]);
		
		setHAlias();
		setVAlias();
	}
	
	public function setHAlias() {
		centerX = new Term(x) + (new Term(width) / 2.0);
		right  = new Term(x) + new Term(width);		
	}
	
	public function setVAlias() {
		centerY = new Term(y) + (new Term(height) / 2.0);
		bottom = new Term(y) + new Term(height);		
	}
	
}


@:forward
abstract Layout(_Layout_) from _Layout_ to _Layout_
{
    public function new(widthSize:Width=null, heightSize:Height=null, align:Align = Align.center, hSpace:HSpace = null, vSpace:VSpace = null)
    {
        this = new _Layout_(widthSize, heightSize, align, hSpace, vSpace);
    }
	
	public inline function set(widthSize:Width=null, heightSize:Height=null, align:Align = null, hSpace:HSpace = null, vSpace:VSpace = null):Layout {
		if (widthSize != null) {
			this.widthSize = widthSize;
			this.setHAlias();
		}
		if (heightSize != null) {
			this.heightSize = heightSize;
			this.setVAlias();
		}
		if (align!=null) this.align = align;
		this.hSpace = hSpace;
		this.vSpace = vSpace;
		return this;
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