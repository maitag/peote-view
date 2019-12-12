package peote.ui;

import utils.NestedArray;

import peote.view.PeoteView;
import peote.view.Display;
import peote.ui.LayoutContainer;

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
	public var width(default,null):Variable;
	public var height(default,null):Variable;	
	
	public var hSize:SizeSpaced;
	public var vSize:SizeSpaced;
			
	public var centerX:Expression;
	public var centerY:Expression;

	public var left(get,never):Expression;
	function get_left():Expression {
		if (hSize.first != null) return new Term(x) - hSize.first.size;
		else return new Expression([new Term(x)]);
	}
	public var right(get,never):Expression;
	function get_right():Expression {
		if (hSize.last != null) return new Term(x) + width + hSize.last.size;
		else return new Term(x) + width;
	}
	public var top(get, never):Expression;
	function get_top():Expression {
		if (vSize.first != null) return new Term(y) - vSize.first.size;
		else return new Expression([new Term(y)]);
	}
	public var bottom(get,never):Expression;
	function get_bottom():Expression {
		if (vSize.last != null) return new Term(y) + height + vSize.last.size;
		else return new Term(y) + height;
	}
	
	var addChildConstraints:Layout->NestedArray<Constraint>->?Int->InnerLimit =
	function(parentLayout:Layout, constraints:NestedArray<Constraint>, ?weight:Int):InnerLimit {return {width:0,height:0}};
	
	var update:Void->Void = function() {};
	var updateChilds:Void->Void = function() {};

    public function new(hSize:SizeSpaced, vSize:SizeSpaced)
	{
		this.hSize = hSize;
		this.vSize = vSize;
		
		x = new Variable();
		y = new Variable();
		width = new Variable();
		height = new Variable();
		
		centerX = new Term(x) + (width / 2.0);
		centerY = new Term(y) + (height / 2.0);
	}
	
	
	public function addHConstraints(constraints:NestedArray<Constraint>, sLimit:Variable, sSpan:Variable, strength:Strength, strengthLow:Strength) {
		constraints.push( (width == hSize.middle.size) | strength );
		hSize.addConstraints(constraints, sLimit, sSpan, strength, strengthLow);
	}
	public function addVConstraints(constraints:NestedArray<Constraint>, sLimit:Variable, sSpan:Variable, strength:Strength, strengthLow:Strength) {
		constraints.push( (height == vSize.middle.size) | strength );
		vSize.addConstraints(constraints, sLimit, sSpan, strength, strengthLow);
	}
	

}


// ----------------- Layout -------------------

@:forward abstract Layout(_Layout_) from _Layout_ to _Layout_
{
    public function new(width:Width=null, height:Height=null, lSpace:LSpace = null, rSpace:RSpace = null, tSpace:TSpace = null, bSpace:BSpace = null)
    {
        this = new _Layout_(new SizeSpaced(width, lSpace, rSpace), new SizeSpaced(height, tSpace, bSpace));
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
class Size
{
	public var limit:Limit;
	
	public var size(get, never):Expression;
	public function get_size():Expression {
		if (sizeLimit == null && sizeSpan == null) return new Expression([], limit._min); // CHECK!
		else if (sizeLimit!= null) return limit._min + new Term(sizeLimit) * (limit._max - limit._min);
		else if (sizeSpan != null) return limit._min + new Term(sizeSpan) * limit._weight;
		else return limit._min + new Term(sizeLimit) * (limit._max - limit._min) + new Term(sizeSpan) * limit._weight;
	}
	
	public var sizeLimit:Variable = null;
	public var sizeSpan:Variable = null;
	
	public function new(limit:Limit) {
		this.limit = limit;
	}
	
	public function addConstraints(constraints:NestedArray<Constraint>, sLimit:Variable, sSpan:Variable, strength:Strength, strengthLow:Strength) {
		// constant
		if (limit.const) {
			//constraints.push( (sizeLimit == limit._min) | strength ); // need this?
		}
		else {
			if (sLimit == null) {
				sLimit = new Variable();
				constraints.push( (sLimit >= 0) | strength );
				//constraints.push( (sLimit <= 1) | strength ); // need this?
			}
			sizeLimit = sLimit;
			//constraints.push( (sizeLimit >= limit._min) | strength );
			//constraints.push( (sizeLimit <= limit._max) | strength );
		}
		
		if (limit.span) {
			if (sSpan == null) {
				sSpan = new Variable();
				constraints.push( (sSpan >= 0) | strength );
			}
			sizeLimit = sLimit;
			//constraints.push( (sizeSpan == parentSpan * limit.weight) | strengthLow );
		}
		
	}
	
}

class SizeSpaced 
{
	public var middle:Size;
	public var first:Size = null;
	public var last:Size  = null;
	
	public var size(get, never):Expression;
	inline function get_size():Expression {
		if (first==null && last==null) return middle.size;
		else if (first!= null) return first.size + middle.size;
		else if (last != null) return middle.size + last.size;
		else return first.size + middle.size + last.size;
	}
	
	public function new(limitMiddle:Limit, limitFirst:Limit = null, limitLast:Limit = null) {
		middle = new Size(limitMiddle);
		if (limitFirst != null) first = new Size(limitFirst);
		if (limitLast  != null) last  = new Size(limitLast);
	}
	
	public function addConstraints(constraints:NestedArray<Constraint>, sLimit:Variable, sSpan:Variable, strength:Strength, strengthLow:Strength) {
		middle.addConstraints(constraints, sLimit, sSpan, strength, strengthLow);
		if (first != null) first.addConstraints(constraints, sLimit, sSpan, strength, strengthLow);
		if (last != null) last.addConstraints(constraints, sLimit, sSpan, strength, strengthLow);
	}
	
	public function getMin():Int {
		var min:Int = middle.limit._min;
		if (first != null) min += first.limit._min;
		if (last != null) min += last.limit._min;
		return min;
	}
	public function getLimitMax():Int {
		var limitMax:Int = (middle.limit._max != null) ? middle.limit._max : middle.limit._min;
		if (first != null) limitMax += (first.limit._max != null) ? first.limit._max : first.limit._min;
		if (last != null) limitMax += (last.limit._max != null) ? last.limit._max : last.limit._min;
		return limitMax;
	}
}

@:allow(peote.ui)
class Limit {
	var const = true;
	var span  = true;
	
	var _min:Int = 0;
	var _max:Null<Int>;
	var _weight:Null<Float>;
	
	inline function new(min:Null<Int> = null, max:Null<Int> = null, weight:Null<Float> = null, span = true) {
		if (min != null && max != null) {
			if (min > max) {
				_min = max;
				_max = min;
				const = false;
			} else {
				_min = min;
				_max = max;
			}
		}
		else if (min != null) _min = min;
		else _max = max;
		_weight = weight;
		this.span = span;
	}
	public static inline function is (min:Null<Int> = null, max:Null<Int> = null):Limit return new Limit(min, max, false);
	public static inline function min(min:Null<Int> = null, max:Null<Int> = null, weight:Null<Float> = null):Limit return new Limit(min, max, weight);
}

@:forward @:forwardStatics
abstract Width(Limit) from Limit to Limit {
	public inline function new(width:Int) this = Limit.is(width);
	@:from public static inline function fromInt(i:Int):Width return Limit.is(i);
	public static inline function is (min:Null<Int> = null, max:Null<Int> = null):Width return new Limit(min, max, false);
	public static inline function min(min:Null<Int> = null, max:Null<Int> = null, weight:Null<Float> = null):Width return new Limit(min, max, weight);
	// TODO: ratio to Height?
}

@:forward @:forwardStatics
abstract Height(Limit) from Limit to Limit {
	public inline function new(height:Int) this = Limit.is(height);
	@:from public static inline function fromInt(i:Int):Height return Limit.is(i);
	public static inline function is (min:Null<Int> = null, max:Null<Int> = null):Height return new Limit(min, max, false);
	public static inline function min(min:Null<Int> = null, max:Null<Int> = null, weight:Null<Float> = null):Height return new Limit(min, max, weight);
	// TODO: ratio to Width
}

typedef LeftSpace = LSpace;
@:forward @:forwardStatics
abstract LSpace(Limit) from Limit to Limit {
	public inline function new(width:Int) this = Limit.is(width);
	@:from public static inline  function fromInt(i:Int):LSpace return Limit.is(i);
	public static inline function is (min:Null<Int> = null, max:Null<Int> = null):LSpace return new Limit(min, max, false);
	public static inline function min(min:Null<Int> = null, max:Null<Int> = null, weight:Null<Float> = null):LSpace return new Limit(min, max, weight);
}

typedef RightSpace = RSpace;
@:forward @:forwardStatics
abstract RSpace(Limit) from Limit to Limit {
	public inline function new(width:Int) this = Limit.is(width);
	@:from public static inline  function fromInt(i:Int):RSpace return Limit.is(i);
	public static inline function is (min:Null<Int> = null, max:Null<Int> = null):RSpace return new Limit(min, max, false);
	public static inline function min(min:Null<Int> = null, max:Null<Int> = null, weight:Null<Float> = null):RSpace return new Limit(min, max, weight);
}

typedef TopSpace = TSpace;
@:forward @:forwardStatics
abstract TSpace(Limit) from Limit to Limit {
	public inline function new(height:Int) this = Limit.is(height);
	@:from public static inline  function fromInt(i:Int):TSpace return Limit.is(i);
	public static inline function is (min:Null<Int> = null, max:Null<Int> = null):TSpace return new Limit(min, max, false);
	public static inline function min(min:Null<Int> = null, max:Null<Int> = null, weight:Null<Float> = null):TSpace return new Limit(min, max, weight);
}

typedef BottomSpace = BSpace;
@:forward @:forwardStatics
abstract BSpace(Limit) from Limit to Limit {
	public inline function new(height:Int) this = Limit.is(height);
	@:from public static inline  function fromInt(i:Int):BSpace return Limit.is(i);
	public static inline function is (min:Null<Int> = null, max:Null<Int> = null):BSpace return new Limit(min, max, false);
	public static inline function min(min:Null<Int> = null, max:Null<Int> = null, weight:Null<Float> = null):BSpace return new Limit(min, max, weight);
}

