package peote.view;

typedef GLTexture         = lime.graphics.opengl.GLTexture;
typedef GLFramebuffer     = lime.graphics.opengl.GLFramebuffer;                    
typedef GLProgram         = lime.graphics.opengl.GLProgram;
typedef GLShader          = lime.graphics.opengl.GLShader;
typedef GLUniformLocation = lime.graphics.opengl.GLUniformLocation;
typedef GLBuffer          = lime.graphics.opengl.GLBuffer;

typedef BytePointer = lime.utils.BytePointer;
typedef DataPointer = lime.utils.DataPointer;

/*
#if html5
	#if peoteview_es3
		typedef LimeGLRenderContext = lime.graphics.WebGL2RenderContext;
	#elseif peoteview_es2
		typedef LimeGLRenderContext = lime.graphics.WebGLRenderContext;
	#else
		typedef LimeGLRenderContext = lime.graphics.OpenGLRenderContext; // Dynamic
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
*/
typedef LimeGLRenderContext = lime.graphics.OpenGLRenderContext;

@:forward()
abstract PeoteGL(LimeGLRenderContext) from LimeGLRenderContext to LimeGLRenderContext {
#if html5
	public inline function bufferData (target:Int, size:Int, srcData:DataPointer, usage:Int):Void {
		var a = srcData.toUInt8Array();
		//trace("bufferData",srcData,a);
		this.bufferData (target, a, usage);
	}
	
	public inline function bufferSubData (target:Int, offset:Int, size:Int, srcData:DataPointer):Void {
		//var a = srcData.toBufferOrBufferView(size);
		var a = srcData.toUInt8Array(size);
		//trace("bufferSubData",srcData,a);
		this.bufferSubData (target, offset, a);
	}
	
#else
/*
	#if peoteview_es2
		public inline function getShaderParameter (shader:GLShader, name:Int):Dynamic {
			return this.getShaderi (shader, name);
		}
		
		public inline function getProgramParameter (program:GLProgram, name:Int):Dynamic {
			return this.getProgrami (program, name);
		}
	#end
*/
#end
}
