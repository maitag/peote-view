package peote.view;

class UniformBufferView 
{

	//var width:Int;
	//var height:Int;

	public var block:Int;
	public var uniformBuffer:lime.graphics.opengl.GLBuffer;
	
	var uniformBytes:haxe.io.Bytes;
	
	public function new(gl:PeoteGL, width:Int, height:Int) 
	{
		uniformBytes = haxe.io.Bytes.alloc(2 * 4);
		uniformBuffer = gl.createBuffer();
		update(gl, width, height);
	}
	
	public function update(gl:PeoteGL, width:Int, height:Int)
	{
		//this.width = width;
		//this.height = height;
		uniformBytes.setFloat(0, width);
		uniformBytes.setFloat(4, height);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferData(gl.UNIFORM_BUFFER, uniformBytes.length, uniformBytes, gl.STATIC_DRAW);
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}
	
	public function bindToProgram(gl:PeoteGL, glProgram:lime.graphics.opengl.GLProgram, name:String, block:Int) {
		this.block = block;
		var index:Int = gl.getUniformBlockIndex(glProgram, name);
		if (index != gl.INVALID_INDEX) {
			trace('has uniform $name, index=$index, block=$block');
			gl.uniformBlockBinding(glProgram, index, block);
		}
	}
	

	
}