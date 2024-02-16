package peote.view.intern;

import peote.view.PeoteGL.GLBuffer;

class UniformBufferDisplay
{
	var xOffestBufferPointer: GLBufferPointer;
	var yOffestBufferPointer: GLBufferPointer;
	var xZoomBufferPointer: GLBufferPointer;
	var yZoomBufferPointer: GLBufferPointer;
	
	public static inline var block:Int = 1;
	public var uniformBuffer:GLBuffer;
	
	var uniformBytes:BufferBytes;
	

	public function new() 
	{
		//uniformBytes = Bytes.alloc(3 * 4);
		uniformBytes = BufferBytes.alloc(2 * 4*4);  // alignment to vec4 (2 values)
		xOffestBufferPointer  = new GLBufferPointer(uniformBytes, 0);
		yOffestBufferPointer  = new GLBufferPointer(uniformBytes, 4);
		xZoomBufferPointer    = new GLBufferPointer(uniformBytes, 8);
		yZoomBufferPointer    = new GLBufferPointer(uniformBytes, 12);
	}
	
	public inline function updateXOffset(gl:PeoteGL, xo:Float) {
		if (gl != null) {
			uniformBytes.setFloat(0, xo);
			gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
			gl.bufferSubData(gl.UNIFORM_BUFFER, 0, 4, xOffestBufferPointer );
			gl.bindBuffer(gl.UNIFORM_BUFFER, null);
		}
	}

	public inline function updateYOffset(gl:PeoteGL, yo:Float) {
		if (gl != null) {
			uniformBytes.setFloat(4, yo);
			gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
			gl.bufferSubData(gl.UNIFORM_BUFFER, 4, 4, yOffestBufferPointer );
			gl.bindBuffer(gl.UNIFORM_BUFFER, null);
		}
	}

	public inline function updateZoom(gl:PeoteGL, xz:Float, yz:Float) {
		uniformBytes.setFloat(8,  xz);
		uniformBytes.setFloat(12, yz);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 8, 8, xZoomBufferPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}
	
	public inline function updateXZoom(gl:PeoteGL, xz:Float) {
		uniformBytes.setFloat(8, xz);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 8, 4, xZoomBufferPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}
	
	public inline function updateYZoom(gl:PeoteGL, yz:Float) {
		uniformBytes.setFloat(12, yz);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 12, 4, yZoomBufferPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}

	public function createGLBuffer(gl:PeoteGL, xOffest:Float, yOffest:Float, xz:Float, yz:Float)
	{
		uniformBuffer = gl.createBuffer();
		uniformBytes.setFloat(0,  xOffest);
		uniformBytes.setFloat(4,  yOffest);
		uniformBytes.setFloat(8,  xz);
		uniformBytes.setFloat(12, yz);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferData(gl.UNIFORM_BUFFER, uniformBytes.length, new GLBufferPointer(uniformBytes), gl.STATIC_DRAW);
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}
	
	public function deleteGLBuffer(gl:PeoteGL)
	{
		gl.deleteBuffer(uniformBuffer);
	}
	
}