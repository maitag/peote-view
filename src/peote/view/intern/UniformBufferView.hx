package peote.view.intern;

import peote.view.PeoteGL.GLBuffer;

class UniformBufferView 
{

	var resolutionBufferPointer: GLBufferPointer;
	var xOffestBufferPointer: GLBufferPointer;
	var yOffestBufferPointer: GLBufferPointer;
	var xZoomBufferPointer: GLBufferPointer;
	var yZoomBufferPointer: GLBufferPointer;

	public static inline var block:Int = 0;
	public var uniformBuffer:GLBuffer;
	
	var uniformBytes:BufferBytes;
	
	public function new() 
	{
		//uniformBytes = Bytes.alloc(5 * 4);
		uniformBytes = BufferBytes.alloc(3 * 4*4); // alignment to vec4 (3 values)
		//uniformBytes = Bytes.alloc( 256   +    3 * 4*4); // for multiple ranges
		resolutionBufferPointer = new GLBufferPointer(uniformBytes, 0);
		xOffestBufferPointer = new GLBufferPointer(uniformBytes, 8);
		yOffestBufferPointer = new GLBufferPointer(uniformBytes, 12);
		xZoomBufferPointer    = new GLBufferPointer(uniformBytes, 16);
		yZoomBufferPointer    = new GLBufferPointer(uniformBytes, 20);
	}
	
	public inline function updateResolution(gl:PeoteGL, width:Float, height:Float) {
		uniformBytes.setFloat(0, width);
		uniformBytes.setFloat(4, height);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 0, 8, resolutionBufferPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}

	public inline function updateXOffset(gl:PeoteGL, xOffset:Float) {
		uniformBytes.setFloat(8, xOffset);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 8, 4, xOffestBufferPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}
	
	public inline function updateYOffset(gl:PeoteGL, yOffset:Float) {
		uniformBytes.setFloat(12, yOffset);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 12, 4, yOffestBufferPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}

	public inline function updateZoom(gl:PeoteGL, xz:Float, yz:Float) {
		uniformBytes.setFloat(16, xz);
		uniformBytes.setFloat(20, yz);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 16, 8, xZoomBufferPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}
	public inline function updateXZoom(gl:PeoteGL, xz:Float) {
		uniformBytes.setFloat(16, xz);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 16, 4, xZoomBufferPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}
	
	public inline function updateYZoom(gl:PeoteGL, yz:Float) {
		uniformBytes.setFloat(20, yz);
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferSubData(gl.UNIFORM_BUFFER, 20, 4, yZoomBufferPointer );
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}
	
	public function createGLBuffer(gl:PeoteGL, width:Float, height:Float, xOffest:Float, yOffest:Float, xz:Float, yz:Float)
	{
		uniformBuffer = gl.createBuffer();
		uniformBytes.setFloat(0,  width);
		uniformBytes.setFloat(4,  height);
		uniformBytes.setFloat(8,  xOffest);
		uniformBytes.setFloat(12, yOffest);
		uniformBytes.setFloat(16, xz);
		uniformBytes.setFloat(20, yz);
		
		// for multiple ranges, for 256 use gl.getParameter(gl.UNIFORM_BUFFER_OFFSET_ALIGNMENT)
		/*
		uniformBytes.setFloat( 256  +  0,  width);
		uniformBytes.setFloat( 256  +  4,  height);
		uniformBytes.setFloat( 256  +  8,  xOffest);
		uniformBytes.setFloat( 256  +  12, yOffest);
		uniformBytes.setFloat( 256  +  16, xz);
		uniformBytes.setFloat( 256  +  20, yz);
		*/
		
		gl.bindBuffer(gl.UNIFORM_BUFFER, uniformBuffer);
		gl.bufferData(gl.UNIFORM_BUFFER, uniformBytes.length, new GLBufferPointer(uniformBytes), gl.STATIC_DRAW);
		gl.bindBuffer(gl.UNIFORM_BUFFER, null);
	}
	
	public function deleteGLBuffer(gl:PeoteGL)
	{
		gl.deleteBuffer(uniformBuffer);
	}
	
}