package peote.text;

import peote.view.Color;

@:allow(peote.text)
class FontConfig
{
	@:optional @:default(false) public var packed(default, null):Bool;
	@:optional @:default(false) public var distancefield(default, null):Bool;
	
	@:optional @:default(null) public var kerning(default, null):Null<Bool>;
	
	@:optional @:default(16) public var width(default, null):Float;
	@:optional @:default(16) public var height(default, null):Float;
	
	@:optional @:default(0xffffffff) public var color(default, null):Color;

	@:optional @:default(16) var tilesX(default, null):Int;
	@:optional @:default(16) var tilesY(default, null):Int;
	
	@:optional @:default(0) var paddingRight(default, null):Int;
	@:optional @:default(0) var paddingLeft(default, null):Int;
	@:optional @:default(0) var paddingTop(default, null):Int;
	@:optional @:default(0) var paddingBottom(default, null):Int;
		
	@:optional @:default(0x1000) var rangeSplitSize(default, null):Int;

	var ranges:Array<{
		image:String,                 // image name for glyph-textureatlas
		?data:String,                 // image name for glyph-textureatlas
		slot:{width:Int, height:Int}, // texture-slot size (all with same width and height can be used inside one texture)
		range:Range      // unicode range of glyphes into that image
	}>;
	
	public function new() {
		// TODO
	}
}