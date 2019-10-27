package peote.ui;

import utils.NestedArray;

import peote.view.PeoteView;
import peote.view.Display;

import jasper.Expression;
import jasper.Term;
import jasper.Variable;
import jasper.Constraint;
import jasper.Strength;


@:allow(peote.ui, peote.view)
class _Layout_
{
	public var x(default,null):Variable;
	public var y(default,null):Variable;	
	public var width(get, never):Variable;
	public var height(get, never):Variable;	
	public inline function get_width():Variable return hSize.size;
	public inline function get_height():Variable return vSize.size;
	
	public var hSize:Width;
	public var vSize:Height;
	
	public var hSpace:HSpace;
	public var lSpace:LSpace;	
	public var rSpace:RSpace;
	public var vSpace:VSpace;	
	public var tSpace:TSpace;
	public var bSpace:BSpace;	
	
		
	public var centerX:Expression;
	public var centerY:Expression;

	//public var width(default,null):Expression;
	//public var height(default,null):Expression;
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

    public function new(hSize:Width, vSize:Height, hSpace:HSpace, lSpace:LSpace, rSpace:RSpace, vSpace:VSpace, tSpace:TSpace, bSpace:BSpace)
	{
		x = new Variable();
		y = new Variable();
		if (hSize == null) this.hSize = Width.min(0) else this.hSize = hSize;
		if (vSize == null) this.vSize = Height.min(0) else this.vSize = vSize;
		
		this.hSpace = hSpace;
		this.lSpace = lSpace;
		this.rSpace = rSpace;
		this.vSpace = vSpace;
		this.tSpace = tSpace;
		this.bSpace = bSpace;
		setHAlias();
		setVAlias();
	}
	
	public function setHAlias() {
		if (hSpace != null && lSpace != null) left = new Term(x) - lSpace.size - hSpace.size;
		else if (hSpace != null) left = new Term(x) - hSpace.size;
		else if (lSpace != null) left = new Term(x) - lSpace.size;
		else left = new Expression([new Term(x)]);
		
		if (hSpace != null && rSpace != null) right = new Term(x) + width + rSpace.size + hSpace.size;
		else if (hSpace != null) right = new Term(x) + width + hSpace.size;
		else if (rSpace != null) right = new Term(x) + width + rSpace.size;
		else right = new Term(x) + width;
		
		centerX = new Term(x) + (width / 2.0);
	}
	
	public function setVAlias() {
		if (vSpace != null && tSpace != null) top = new Term(y) - tSpace.size - vSpace.size;
		else if (vSpace != null) top = new Term(y) - vSpace.size;
		else if (tSpace != null) top = new Term(y) - tSpace.size;
		else top = new Expression([new Term(y)]);
		
		if (vSpace != null && bSpace != null) bottom = new Term(y) + height + bSpace.size + vSpace.size;
		else if (vSpace != null) bottom = new Term(y) + height + vSpace.size;
		else if (bSpace != null) bottom = new Term(y) + height + bSpace.size;
		else bottom = new Term(y) + height;
		
		centerY = new Term(y) + (height / 2.0);
	}
	
	public function addHSizeConstraints(constraints:NestedArray<Constraint>, strength:Strength)
	{
		hSize.addLimitConstraints(constraints, strength);
	}
	
	public function addVSizeConstraints(constraints:NestedArray<Constraint>, strength:Strength)
	{
		vSize.addLimitConstraints(constraints, strength);
	}
	
	public function addHSpaceConstraints(constraints:NestedArray<Constraint>, innerStrength:Strength, outerStrength:Strength)
	{
		if (lSpace != null) lSpace.addLimitConstraints(constraints, innerStrength);
		if (rSpace != null) rSpace.addLimitConstraints(constraints, innerStrength);
		if (hSpace != null) hSpace.addLimitConstraints(constraints, outerStrength);
	}
	
	public function addVSpaceConstraints(constraints:NestedArray<Constraint>, innerStrength:Strength, outerStrength:Strength)
	{
		if (tSpace != null) tSpace.addLimitConstraints(constraints, innerStrength);
		if (bSpace != null) bSpace.addLimitConstraints(constraints, innerStrength);
		if (vSpace != null) vSpace.addLimitConstraints(constraints, outerStrength);
	}
	
	public function hasMaxWidth():Bool {
		if (hSize._max == null) return false;
		if (lSpace != null) {if (lSpace._max == null) return false;}
		if (rSpace != null) {if (rSpace._max == null) return false;}
		if (hSpace != null) {if (hSpace._max == null) return false;}
		return true;
	}
	public function hasMinWidth():Bool {
		if (hSize._min != null) return true;
		if (lSpace != null) {if (lSpace._max != null) return true;}
		if (rSpace != null) {if (rSpace._max != null) return true;}
		if (hSpace != null) {if (hSpace._max != null) return true;}
		return false;
	}
	
}


// ----------------- Layout -------------------

@:forward abstract Layout(_Layout_) from _Layout_ to _Layout_
{
    public function new(hSize:Width=null, vSize:Height=null, hSpace:HSpace = null, lSpace:LSpace = null, rSpace:RSpace = null, vSpace:VSpace = null, tSpace:TSpace = null, bSpace:BSpace = null)
    {
        this = new _Layout_(hSize, vSize, hSpace, lSpace, rSpace, vSpace, tSpace, bSpace);
    }
	
	public inline function set(hSize:Width = null, vSize:Height = null, hSpace:HSpace = null, lSpace:LSpace = null, rSpace:RSpace = null, vSpace:VSpace = null, tSpace:TSpace = null, bSpace:BSpace = null):Layout
	{
		if (hSize != null) this.hSize = hSize;
		if (vSize != null) this.vSize = vSize;

		this.hSpace = hSpace;
		this.lSpace = lSpace;
		this.rSpace = rSpace;
		this.vSpace = vSpace;
		this.tSpace = tSpace;
		this.bSpace = bSpace;
		
		if (hSize != null || hSpace != null || lSpace != null || rSpace != null) this.setHAlias();
		if (vSize != null || hSpace != null || tSpace != null || bSpace != null) this.setVAlias();
		
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



// ----------------- Size -------------------


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

typedef HorizontalSpace = HSpace;
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

typedef VerticalSpace = VSpace;
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

typedef LeftSpace = LSpace;
@:forward @:forwardStatics
abstract LSpace(Size) from Size to Size {
	public inline function new(width:Int) this = Size.px(width);
	@:from public static inline  function fromInt(i:Int):LSpace return Size.px(i);
	public static inline function px(pixel:Int):LSpace return new Size(null, pixel,pixel);
	public static inline function percent(percent:Float, min:Null<Int> = null, max:Null<Int> = null):LSpace return new Size(percent, min, max);
	public static inline function min(min:Int):LSpace return new Size(null, min, null);
	public static inline function max(max:Int):LSpace return new Size(null, null, max);
	public static inline function flex(min:Int, max:Int):LSpace return new Size(null, min, max);
}

typedef RightSpace = RSpace;
@:forward @:forwardStatics
abstract RSpace(Size) from Size to Size {
	public inline function new(width:Int) this = Size.px(width);
	@:from public static inline  function fromInt(i:Int):RSpace return Size.px(i);
	public static inline function px(pixel:Int):RSpace return new Size(null, pixel,pixel);
	public static inline function percent(percent:Float, min:Null<Int> = null, max:Null<Int> = null):RSpace return new Size(percent, min, max);
	public static inline function min(min:Int):RSpace return new Size(null, min, null);
	public static inline function max(max:Int):RSpace return new Size(null, null, max);
	public static inline function flex(min:Int, max:Int):RSpace return new Size(null, min, max);
}

typedef TopSpace = TSpace;
@:forward @:forwardStatics
abstract TSpace(Size) from Size to Size {
	public inline function new(width:Int) this = Size.px(width);
	@:from public static inline  function fromInt(i:Int):TSpace return Size.px(i);
	public static inline function px(pixel:Int):TSpace return new Size(null, pixel,pixel);
	public static inline function percent(percent:Float, min:Null<Int> = null, max:Null<Int> = null):TSpace return new Size(percent, min, max);
	public static inline function min(min:Int):TSpace return new Size(null, min, null);
	public static inline function max(max:Int):TSpace return new Size(null, null, max);
	public static inline function flex(min:Int, max:Int):TSpace return new Size(null, min, max);
}

typedef BottomSpace = BSpace;
@:forward @:forwardStatics
abstract BSpace(Size) from Size to Size {
	public inline function new(width:Int) this = Size.px(width);
	@:from public static inline  function fromInt(i:Int):BSpace return Size.px(i);
	public static inline function px(pixel:Int):BSpace return new Size(null, pixel,pixel);
	public static inline function percent(percent:Float, min:Null<Int> = null, max:Null<Int> = null):BSpace return new Size(percent, min, max);
	public static inline function min(min:Int):BSpace return new Size(null, min, null);
	public static inline function max(max:Int):BSpace return new Size(null, null, max);
	public static inline function flex(min:Int, max:Int):BSpace return new Size(null, min, max);
}

