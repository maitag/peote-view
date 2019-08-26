package peote.text;

class FontConfig
{
	public static var NO_PACKING = 0;
	public static var GL3_PACKING = 1;
	
	@:optional @:default(0) public var packing:Int;	
	@:optional @:default(false) public var distancefield:Bool;
	
	@:optional @:default(false) public var kerning:Bool;
	@:optional @:default(16) public var width:Int;
	@:optional @:default(16) public var height:Int;
	@:optional @:default("0xffffffff") public var color:String;
	
	@:optional @:default("0x1000") public var rangeSizeSplitting:String;

	public var ranges:Array<{
		image:String,                 // image name for glyph-textureatlas
		slot:{width:Int, height:Int}, // texture-slot size (all with same width and height can be used inside one texture)
		range:{min:String, max:String}// unicode range of glyphes into that image
	}>;
	
	public function new() {
		// TODO
	}
}