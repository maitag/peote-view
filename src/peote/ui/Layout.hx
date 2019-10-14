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
	
	public var size:Variable;
	
	inline function new(pixel:Null<Int>, percent:Null<Float>, min:Null<Int>, max:Null<Int>) {
		_size = pixel;
		_percent = percent;
		_min = min;
		_max = max;
		
		if (_min == _max && _min != null) {
			_size = _min;
			_percent = _min = _max = null;
		}
		
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
	
	public function addConstraints(constraints:NestedArray<Constraint>, parentSize:Size, weight:Float)
	{
		//var weak = Strength.create(0, 0, 1, weight);
		//var weak1 = Strength.create(0, 0, 100, weight);		
		var medium = Strength.create(0, 1, 0, weight);
		var medium1 = Strength.create(0, 100, 0, weight);
		var medium2 = Strength.create(0, 200, 0, weight);
		var medium3 = Strength.create(0, 300, 0, weight);

		if (_size != null) {
			constraints.push( (size == _size) | medium1 ); // TODO: separate min/max handling here
			constraints.push( (size <= parentSize.size) | medium2 );
		}
		else if (_percent != null) {
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
	
}

// ---------- Size helpers

@:forward @:forwardStatics
abstract Width(Size) from Size to Size {
	public inline function new(width:Int) this = Size.px(width);
	@:from public static inline function fromInt(i:Int):Width return Size.px(i);
}

@:forward @:forwardStatics
abstract Height(Size) from Size to Size {
	public inline function new(height:Int) this = Size.px(height);
	@:from public static inline function fromInt(i:Int):Height return Size.px(i);
}

@:forwardStatics
abstract HSpace(Size) from Size to Size {
	public inline function new(width:Int) this = Size.px(width);
	@:from public static inline  function fromInt(i:Int):HSpace return Size.px(i);
}

@:forwardStatics
abstract VSpace(Size) from Size to Size {
	public inline function new(width:Int) this = Size.px(width);
	@:from public static inline  function fromInt(i:Int):VSpace return Size.px(i);
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
	
	var addChildConstraints:Layout->NestedArray<Constraint>->?Float->Void = function(parentLayout:Layout, constraints:NestedArray<Constraint>, weight:Float = 1.0) {};
	
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