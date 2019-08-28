package peote.text;

import peote.view.Color;

class FontConfig
{
	@:optional @:default(false) public var packed:Bool;
	@:optional @:default(false) public var distancefield:Bool;
	
	@:optional public var kerning:Null<Bool>;
	@:optional @:default(16) public var width:Float;
	@:optional @:default(16) public var height:Float;
	
	@:optional @:default(16) public var tilesX:Int;
	@:optional @:default(16) public var tilesY:Int;
	
	@:optional @:default(0xffffffff) public var color:Color;
	
	@:optional @:default(0x1000) public var rangeSplitSize:Int;

	public var ranges:Array<{
		image:String,                 // image name for glyph-textureatlas
		?data:String,                 // image name for glyph-textureatlas
		slot:{width:Int, height:Int}, // texture-slot size (all with same width and height can be used inside one texture)
		range:Range      // unicode range of glyphes into that image
	}>;
	
	public function new() {
		// TODO
	}
}