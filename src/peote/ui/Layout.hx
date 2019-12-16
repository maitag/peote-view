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
	
	var addChildConstraints:NestedArray<Constraint>->InnerLimit =
	function(constraints:NestedArray<Constraint>):InnerLimit {return {width:0,height:0}};
	
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
	
	public function addHConstraints(constraints:NestedArray<Constraint>, sizeVars:SizeVars, strength:Strength):SizeVars {
		sizeVars = hSize.addConstraints(constraints, sizeVars, strength);
		constraints.push( (width == hSize.middle.size) | strength );
		return sizeVars;
	}
	
	public function addVConstraints(constraints:NestedArray<Constraint>, sizeVars:SizeVars, strength:Strength):SizeVars {
		sizeVars = vSize.addConstraints(constraints, sizeVars, strength);
		constraints.push( (height == vSize.middle.size) | strength );
		return sizeVars;
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
		else if (sizeLimit== null) return limit._min + (new Term(sizeSpan) * limit._weight);
		else if (sizeSpan == null) return limit._min + (new Term(sizeLimit) * (limit._max - limit._min));
		else return limit._min + (new Term(sizeLimit) * (limit._max - limit._min)) + (new Term(sizeSpan) * limit._weight);
	}
	
	public var sizeLimit:Null<Variable> = null;
	public var sizeSpan:Null<Variable> = null;
	
	public function new(limit:Limit) {
		this.limit = limit;
	}
	
	public function addConstraints(constraints:NestedArray<Constraint>, sizeVars:SizeVars, strength:Strength):SizeVars
	{
		if (!limit.const) {
			if (sizeVars.sLimit == null) {
				sizeVars.sLimit = new Variable();
				constraints.push( (sizeVars.sLimit >= 0) | strength );
			}
			sizeLimit = sizeVars.sLimit;
		}
		
		if (limit.span) {
			if (sizeVars.sSpan == null) {
				sizeVars.sSpan = new Variable();
				constraints.push( (sizeVars.sSpan >= 0) | strength );
			}
			sizeSpan = sizeVars.sSpan;
		}
		return sizeVars;
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
		else if (first== null) return middle.size + last.size;
		else if (last == null) return first.size + middle.size;
		else return first.size + middle.size + last.size;
	}
	
	public function new(limitMiddle:Limit, limitFirst:Limit = null, limitLast:Limit = null) {
		middle = new Size( (limitMiddle != null) ? limitMiddle : Limit.min() );
		if (limitFirst != null) first = new Size(limitFirst);
		if (limitLast  != null) last  = new Size(limitLast);
	}
	
	public function addConstraints(constraints:NestedArray<Constraint>, sizeVars:SizeVars, strength:Strength):SizeVars {
		trace("middle.addConstraints");
		sizeVars = middle.addConstraints(constraints, sizeVars, strength);
		trace("first.addConstraints");
		if (first != null) sizeVars = first.addConstraints(constraints, sizeVars, strength);
		trace("last.addConstraints");
		if (last != null) sizeVars = last.addConstraints(constraints, sizeVars, strength);
		return sizeVars;
	}
	
	public function getMin():Int {
		var min:Int = middle.limit._min;
		if (first != null) min += first.limit._min;
		if (last  != null) min += last.limit._min;
		return min;
	}
	
	public function hasSpan():Bool {
		if (middle.limit.span) return true;
		if (first != null) if (first.limit.span) return true;
		if (last  != null) if (last.limit.span) return true;
		return false;
	}
	
	public function getLimitMax():Int {
		var limitMax:Int = (middle.limit._max != null) ? middle.limit._max : middle.limit._min;
		if (first != null) limitMax += (first.limit._max != null) ? first.limit._max : first.limit._min;
		if (last  != null) limitMax += (last.limit._max  != null) ? last.limit._max : last.limit._min;
		return limitMax;
	}
	
	public function getSumWeight():Float {
		var sumWeight:Float = (middle.sizeSpan != null) ? middle.limit._weight : 0.0;
		if (first != null) if (first.sizeSpan != null) sumWeight += first.limit._weight;
		if (last  != null) if (last.sizeSpan  != null) sumWeight += last.limit._weight;
		return sumWeight;
	}
}

@:allow(peote.ui)
class Limit {
	var const = true;
	var span  = true;
	
	var _min:Int = 0;
	var _max:Null<Int>;
	var _weight:Float = 1.0;
	
	inline function new(min:Null<Int> = null, max:Null<Int> = null, weight:Null<Float> = null, span = true) {
		if (min != null && max != null) {
			if (min > max) {
				_min = max;
				_max = min;
			} else {
				_min = min;
				_max = max;
				const = false;
			}
		}
		else if (min != null) _min = min;
		else _max = max;
		if (weight != null) _weight = weight;
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

