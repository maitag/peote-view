package peote.view;

#if html5
typedef LimeGLRenderContext = lime.graphics.WebGLRenderContext;
//typedef LimeGLRenderContext = lime.graphics.WebGL2RenderContext;
#else
typedef LimeGLRenderContext = lime.graphics.OpenGLRenderContext;
//typedef LimeGLRenderContext = lime.graphics.OpenGLES2RenderContext;
//typedef LimeGLRenderContext = lime.graphics.OpenGLES3RenderContext;
#end

@:forward()
abstract PeoteGL(LimeGLRenderContext) from LimeGLRenderContext to LimeGLRenderContext {
#if html5
	public inline function bufferData (target:Int, size:Int, srcData:lime.utils.DataPointer, usage:Int):Void {
		var a = srcData.toUInt8Array();
		trace("bufferData",srcData,a);
		this.bufferData (target, a, usage);
	}
	
	public inline function bufferSubData (target:Int, offset:Int, size:Int, srcData:lime.utils.DataPointer):Void {
		//var a = srcData.toBufferOrBufferView(size);
		var a = srcData.toUInt8Array(size);
		trace("bufferSubData",srcData,a);
		this.bufferSubData (target, offset, a);
	}
#end

}
