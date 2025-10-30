package peote.view.intern;


@:allow(peote.view.Program)
interface BufferInterface
{
	@:allow(peote.view.Display) private var _gl: peote.view.PeoteGL;
	//@:allow(peote.view.Display) private function createGLBuffer():Void;
	//@:allow(peote.view.Display) private function deleteGLBuffer():Void;
	//@:allow(peote.view.Display) private function updateGLBuffer():Void;
	@:allow(peote.view.Display) private function setNewGLContext(newGl:PeoteGL):Void;
	
	private function getVertexShader():String;
	private function getFragmentShader():String;
	private function getTextureIdentifiers():Array<String>;
	private function getColorIdentifiers():Array<String>;
	private function getCustomIdentifiers():Array<String>;
	private function getCustomVaryings():Array<String>;
	private function getDefaultColorFormula():String;
	private function getDefaultFormulaVars():haxe.ds.StringMap<peote.view.Color>;
	
	private function getFormulas():haxe.ds.StringMap<String>;
	private function getAttributes():haxe.ds.StringMap<String>;
	private function getFormulaNames():haxe.ds.StringMap<String>;
	private function getFormulaVaryings():Array<String>;
	private function getFormulaConstants():Array<String>;
	private function getFormulaCustoms():Array<String>;
	
	private function getMaxZindex():Int;
	private function hasBlend():Bool;
	private function hasZindex():Bool;
	private function hasPicking():Bool;
	private function hasTime():Bool;
	private function needFragmentPrecision():Bool;
	
	@:allow(peote.view.PeoteView) private function getElementWithHighestZindex(elementIndices:Array<Int>): Int;
	
	private function bindAttribLocations(gl: peote.view.PeoteGL, glProgram:lime.graphics.opengl.GLProgram):Void;
	
	private function render(peoteView:peote.view.PeoteView, display:peote.view.Display, program:peote.view.Program):Void;
	private function pick(peoteView:peote.view.PeoteView, display:peote.view.Display, program:peote.view.Program, toElement:Int):Void;

	// ------------ public fields what need no Type-params -----------
	public var length(get, never):Int;
	public function update():Void;
	public function clear(clearElementsRefs:Bool = false, notUseElementsLater:Bool = false):Void;
}