package peote.view;

import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;

#if html5
	#if peoteview_es3
		typedef LimeGLRenderContext = lime.graphics.WebGL2RenderContext;
	#elseif peoteview_es2
		typedef LimeGLRenderContext = lime.graphics.WebGLRenderContext;
	#end
#else
	#if peoteview_es3
		typedef LimeGLRenderContext = lime.graphics.OpenGLES3RenderContext;
	#elseif peoteview_es2
		typedef LimeGLRenderContext = lime.graphics.OpenGLES2RenderContext;
	#else
		typedef LimeGLRenderContext = lime.graphics.OpenGLRenderContext;
	#end
#end

@:forward()
abstract PeoteGL(LimeGLRenderContext) from LimeGLRenderContext to LimeGLRenderContext {
#if html5
	public inline function bufferData (target:Int, size:Int, srcData:lime.utils.DataPointer, usage:Int):Void {
		var a = srcData.toUInt8Array();
		//trace("bufferData",srcData,a);
		this.bufferData (target, a, usage);
	}
	
	public inline function bufferSubData (target:Int, offset:Int, size:Int, srcData:lime.utils.DataPointer):Void {
		//var a = srcData.toBufferOrBufferView(size);
		var a = srcData.toUInt8Array(size);
		//trace("bufferSubData",srcData,a);
		this.bufferSubData (target, offset, a);
	}

	
#else

	#if peoteview_es2
	
	public inline function getShaderParameter (shader:GLShader, pname:Int):Dynamic {
		return this.getShaderi (shader, pname);
	}
	
	public inline function getProgramParameter (program:GLProgram, pname:Int):Dynamic {
		return this.getProgrami (program, pname);
	}
	
	#end

#end

}
