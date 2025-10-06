package peote.view.text;

/**
	A Text-instance represents a continuous text (with line breaks) that can be added to a `TextProgram` to display it.
**/
class Text {

	static inline var POS:Int = 1;
	static inline var TXT:Int = 2;
	static inline var OPT:Int = 4;

	var update:Int = 0;
	
	/**
		Contains the elements (letter glyphes) of the text.
	**/
	public var elements:Array<TextElement> = null;

	/**
		Horizontal position of the top left character
	**/
	public var x(default, set):Int = 0;
	inline function set_x(v:Int):Int {update |= POS;return x = v;}

	/**
		Vertical position of the top left character
	**/
	public var y:Int;
	inline function set_y(v:Int):Int {update |= POS;return y = v;}

	/**
		The String-representation of the text
	**/
	public var text(default, set):String;
	inline function set_text(t:String):String {update |= TXT;return text = t;}

	/**
		The `TextOptions` values to define colors and spacing for the text. If a property is null it is using the value from `TextProgram.defaultOptions`.
	**/
	public var options(default, set):TextOptions = null;
	inline function set_options(o:TextOptions):TextOptions {update |= OPT;return options = o;}

	/** Gets or sets the options.fgColor property **/
	public var fgColor(get,set):Null<Color>;
	inline function get_fgColor():Null<Color> return options.fgColor;
	inline function set_fgColor(v:Null<Color>):Null<Color> {update |= OPT; return options.fgColor = v;}

	/** Gets or sets the options.bgColor property. **/
	public var bgColor(get,set):Null<Color>;
	inline function get_bgColor():Null<Color> return options.bgColor;
	inline function set_bgColor(v:Null<Color>):Null<Color> {update |= OPT; return options.bgColor = v;}

	/** Gets or sets the options.letterWidth property. **/
	public var letterWidth(get,set):Null<Int>;
	inline function get_letterWidth():Null<Int> return options.letterWidth;
	inline function set_letterWidth(v:Null<Int>):Null<Int> {update |= OPT; return options.letterWidth = v;}

	/** Gets or sets the options.letterHeight property. **/
	public var letterHeight(get,set):Null<Int>;
	inline function get_letterHeight():Null<Int> return options.letterHeight;
	inline function set_letterHeight(v:Null<Int>):Null<Int> {update |= OPT; return options.letterHeight = v;}

	/** Gets or sets the options.letterSpace property.**/
	public var letterSpace(get,set):Null<Int>;
	inline function get_letterSpace():Null<Int> return options.letterSpace;
	inline function set_letterSpace(v:Null<Int>):Null<Int> {update |= OPT; return options.letterSpace = v;}

	/** Gets or sets the options.lineSpace property. **/
	public var lineSpace(get,set):Null<Int>;
	inline function get_lineSpace():Null<Int> return options.lineSpace;
	inline function set_lineSpace(v:Null<Int>):Null<Int> {update |= OPT; return options.lineSpace = v;}
	
	/** Gets or sets the options.zIndex property. **/
	public var zIndex(get,set):Null<Int>;
	inline function get_zIndex():Null<Int> return options.zIndex;
	inline function set_zIndex(v:Null<Int>):Null<Int> {update |= POS; return options.zIndex = v;}

	/**
		Creates a new `Text` instance.
		@param x horizontal position of the top left character
		@param y vertical position of the top left character
		@param text the String representation of the text (can contain "\n" linebreaks)
		@param textOptions the `TextOptions`
	**/
	public function new(x:Int, y:Int, text:String, ?textOptions:TextOptions) {
		this.x = x;
		this.y = y;
		this.text = text;
		if (textOptions != null) options = textOptions.copy() else options = {};
	}

}