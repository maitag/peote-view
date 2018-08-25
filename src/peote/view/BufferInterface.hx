package peote.view;


@:allow(peote.view.Program)
interface BufferInterface
{
	@:allow(peote.view.Display) private var _gl: peote.view.PeoteGL;
	@:allow(peote.view.Display) private function createGLBuffer():Void;
	@:allow(peote.view.Display) private function updateGLBuffer():Void;
	
	private function getVertexShader():String;
	private function getFragmentShader():String;
	
	private function bindAttribLocations(gl: peote.view.PeoteGL, glProgram:lime.graphics.opengl.GLProgram):Void;
	
	private function render(peoteView:PeoteView, display:Display, program:Program):Void;
}