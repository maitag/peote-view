package peote.view;


@:allow(peote.view.Program)
interface BufferInterface
{
	@:allow(peote.view.Display) private var _gl: peote.view.PeoteGL;
	@:allow(peote.view.Display) private function createGLBuffer():Void;
	@:allow(peote.view.Display) private function deleteGLBuffer():Void;
	@:allow(peote.view.Display) private function updateGLBuffer():Void;
	
	private function getVertexShader():String;
	private function getFragmentShader():String;
	private function getTextureIdentifiers():Array<String>;
	private function getColorIdentifiers():Array<String>;
	private function getDefaultTextureColors():haxe.ds.StringMap<peote.view.Color>;
	private function getDefaultColorFormula():String;
	private function hasAlpha():Bool;
	private function hasZindex():Bool;
	
	private function bindAttribLocations(gl: peote.view.PeoteGL, glProgram:lime.graphics.opengl.GLProgram):Void;
	
	private function render(peoteView:peote.view.PeoteView, display:peote.view.Display, program:peote.view.Program):Void;
}