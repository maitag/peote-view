package peote.view.text;

class Text {

	static inline var POS:Int = 1;
	static inline var TXT:Int = 2;
	static inline var OPT:Int = 4;

	var update:Int = 0;
	
	public var elements:Array<TextElement> = null;

	public var x(default, set):Int = 0;
	inline function set_x(v:Int):Int {update |= POS;return x = v;}

	public var y:Int;
	inline function set_y(v:Int):Int {update |= POS;return y = v;}

	public var text(default, set):String;
	inline function set_text(t:String):String {update |= TXT;return text = t;}


	public var options(default, set):TextOptions = null;
	inline function set_options(o:TextOptions):TextOptions {update |= OPT;return options = o;}

	public var fgColor(get,set):Null<Color>;
	inline function get_fgColor():Null<Color> return options.fgColor;
	inline function set_fgColor(v:Null<Color>):Null<Color> {update |= OPT; return options.fgColor = v;}

	public var bgColor(get,set):Null<Color>;
	inline function get_bgColor():Null<Color> return options.bgColor;
	inline function set_bgColor(v:Null<Color>):Null<Color> {update |= OPT; return options.bgColor = v;}

	public var letterWidth(get,set):Null<Int>;
	inline function get_letterWidth():Null<Int> return options.letterWidth;
	inline function set_letterWidth(v:Null<Int>):Null<Int> {update |= OPT; return options.letterWidth = v;}

	public var letterHeight(get,set):Null<Int>;
	inline function get_letterHeight():Null<Int> return options.letterHeight;
	inline function set_letterHeight(v:Null<Int>):Null<Int> {update |= OPT; return options.letterHeight = v;}

	public var letterSpace(get,set):Null<Int>;
	inline function get_letterSpace():Null<Int> return options.letterSpace;
	inline function set_letterSpace(v:Null<Int>):Null<Int> {update |= OPT; return options.letterSpace = v;}

	public var lineSpace(get,set):Null<Int>;
	inline function get_lineSpace():Null<Int> return options.lineSpace;
	inline function set_lineSpace(v:Null<Int>):Null<Int> {update |= OPT; return options.lineSpace = v;}
	

	public var zIndex(get,set):Null<Int>;
	inline function get_zIndex():Null<Int> return options.zIndex;
	inline function set_zIndex(v:Null<Int>):Null<Int> {update |= POS; return options.zIndex = v;}

	public function new(x:Int, y:Int, text:String, ?textOptions:TextOptions) {
		this.x = x;
		this.y = y;
		this.text = text;
		if (textOptions != null) options = textOptions.copy() else options = {};
	}
}