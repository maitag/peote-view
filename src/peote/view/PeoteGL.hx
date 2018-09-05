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

	// -------------------------------------------------------------------------------------------------
	// ---------------------------- downcasting the gl render context ----------------------------------

	@:from private static function fromRenderContext (context:lime.graphics.RenderContext):PeoteGL {

		#if html5
		
			#if peoteview_es3
				if (context.webgl2 == null) js.Browser.alert("Sorry, only works on Webbrowsers that supports WEBGL2 (OpenGL-ES3).");
				trace("Force WEBGL2.");
				return cast context.webgl2;
			#elseif peoteview_es2
				if (context.webgl == null) js.Browser.alert("Sorry, only works on Webbrowsers that supports WEBGL1 (OpenGL-ES2).");
				trace("Force WEBGL1.");
				return cast context.webgl;
			#else
				if (context.webgl2 != null) {
					trace("WEBGL2 detected.");
					PeoteView.isUBO = true; PeoteView.isINSTANCED = true;
					return cast context.webgl2;
				}
				else if (context.webgl != null) {
					trace("WEBGL1 detected.");
					return cast context.webgl;
				}
				else {
					js.Browser.alert("Error: missing webgl context");
					return null;
				}
			#end				
			
		#else
			#if peoteview_es3
				if (context.gles3 == null) throw("Sorry, only works with OpenGL-ES3.");
				trace("Force OpenGL-ES3.");
				return cast context.gles3;
			#elseif peoteview_es2
				if (context.gles2 == null) throw("Sorry, only works with OpenGL-ES2.");
				trace("Force OpenGL-ES2.");
				return cast context.gles2;
			#else
				if (context.gles3 != null) {
					trace("OpenGL-ES3 detected.");
					PeoteView.isUBO = true; PeoteView.isINSTANCED = true;
					return cast context.gles3;
				}
				else if (context.gles2 != null) {
					trace("OpenGL-ES2 detected.");
					return cast context.gles2;
				}
				else if (context.gl != null) {
					trace("OpenGL detected.");
					return cast context.gl;
				}
				else throw("Error: missing OpenGL context");
			#end
			
		#end
	}



}
