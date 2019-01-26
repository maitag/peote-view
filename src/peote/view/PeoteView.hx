package peote.view;

import haxe.Timer;
import haxe.ds.Vector;

import peote.view.utils.Background;
import peote.view.utils.GLTool;
import peote.view.utils.RenderList;
import peote.view.utils.RenderListItem;
import peote.view.utils.TexUtils;

import peote.view.PeoteGL.GLTexture;
import peote.view.PeoteGL.GLFramebuffer;

@:allow(peote.view)
class PeoteView 
{
	public var gl(default, null):PeoteGL;
	
	var width:Int;
	var height:Int;
	public var color(default,set):Color = 0x000000FF;
	inline function set_color(c:Color):Color {
		red   = c.red   / 255.0;			
		green = c.green / 255.0;			
		blue  = c.blue  / 255.0;
		alpha = c.alpha / 255.0;
		return c;
	}
	var red:Float = 0.0;
	var green:Float = 0.0;
	var blue:Float = 0.0;
	var alpha:Float = 1.0;
	
	var glStateAlpha:Bool = false;
	var glStateDepth:Bool = false;
	
	var maxTextureImageUnits:Int;
	var glStateTexture:Vector<GLTexture>;
	public function isTextureStateChange(activeTextureUnit:Int, texture:Texture):Bool {
		if (texture.updated) {
			texture.updated = false;
			// TODO: should it update ALL other textures the program is in use?
			// ..maybe program as param here and then set all glStateTexture of that program ?
			glStateTexture = new Vector<GLTexture>(maxTextureImageUnits); // clear full -> todo: optimize
			glStateTexture.set(activeTextureUnit, texture.glTexture);			
			return true;
		}
		if (glStateTexture.get(activeTextureUnit) != texture.glTexture) {
			glStateTexture.set(activeTextureUnit, texture.glTexture);
			return true;
		} else return false;
	}
	
	private var xz(default, null):Float = 1.0;
	private var yz(default, null):Float = 1.0;
	
	public var zoom(default, set):Float = 1.0;
	public inline function set_zoom(z:Float):Float {
		xz = xZoom * z;
		yz = yZoom * z;
		if (PeoteGL.Version.isUBO) uniformBuffer.updateZoom(gl, xz, yz);
		return zoom = z;
	}
	public var xZoom(default, set):Float = 1.0;
	public inline function set_xZoom(z:Float):Float {
		xz = zoom * z;
		if (PeoteGL.Version.isUBO) uniformBuffer.updateXZoom(gl, xz);
		return xZoom = z;
	}
	public var yZoom(default, set):Float = 1.0;
	public inline function set_yZoom(z:Float):Float {
		yz = zoom * z;
		if (PeoteGL.Version.isUBO) uniformBuffer.updateYZoom(gl, yz);
		return yZoom = z;
	}
	public var xOffset(default, set):Float = 0;
	public inline function set_xOffset(xo:Float):Float {
		if (PeoteGL.Version.isUBO) uniformBuffer.updateXOffset(gl, xo);//TODO:->float
		return xOffset = xo;
	}
	public var yOffset(default, set):Float = 0;
	public inline function set_yOffset(yo:Float):Float {
		if (PeoteGL.Version.isUBO) uniformBuffer.updateYOffset(gl, yo);
		return yOffset = yo;
	}
	
	var displayList:RenderList<Display>;
	
	var background:Background;
	
	var uniformBuffer:UniformBufferView;
	
	var isRun:Bool = false;
	var startTime:Float = 0;
	var stopTime:Float = 0;
	var speed:Float = 1.0;
	public var time(get,set):Float;
	public inline function get_time():Float
	{
		return ((isRun) ? Timer.stamp() - startTime : stopTime)*speed;
	}
	public inline function set_time(t:Float):Float
	{
		startTime = stopTime = Timer.stamp() - t;
		return t;
	}
	public function start():Void
	{
		time = stopTime;
		isRun = true;
	}
	public function stop():Void
	{
		stopTime = time;
		isRun = false;
	}

	public function new(gl:PeoteGL, width:Int, height:Int, color:Color = 0x000000FF)
	{
		this.gl = gl;
		this.width = width;
		this.height = height;
		set_color(color);
		
		if (PeoteGL.Version.isUBO) {
            trace("OpenGL Uniform Buffer Objects enabled.");
			uniformBuffer = new UniformBufferView();
			uniformBuffer.createGLBuffer(gl, width, height, xOffset, yOffset, xz, yz);
        }
        else {
            trace("OpenGL Uniform Buffer Objects disabled.");
        }
		
		if (PeoteGL.Version.isINSTANCED) {
            trace("OpenGL InstanceDrawing enabled.");
        }
        else {
            trace("OpenGL InstanceDrawing disabled.");
        }
		
		maxTextureImageUnits = gl.getParameter(gl.MAX_TEXTURE_IMAGE_UNITS);
		glStateTexture = new Vector<GLTexture>(maxTextureImageUnits);
		
		trace("GL.MAX_TEXTURE_SIZE:" + gl.getParameter(gl.MAX_TEXTURE_SIZE));
		trace("GL.MAX_TEXTURE_IMAGE_UNITS:" + gl.getParameter(gl.MAX_TEXTURE_IMAGE_UNITS));
		trace("GL.MAX_COMBINED_TEXTURE_IMAGE_UNITS:" + gl.getParameter(gl.MAX_COMBINED_TEXTURE_IMAGE_UNITS));
		trace("GL.MAX_VERTEX_TEXTURE_IMAGE_UNITS:" + gl.getParameter(gl.MAX_VERTEX_TEXTURE_IMAGE_UNITS));
		trace("GL.MAX_TEXTURE_SIZE:" + gl.getParameter(gl.MAX_TEXTURE_SIZE));
		trace("GL.MAX_VERTEX_ATTRIBS:" + gl.getParameter(gl.MAX_VERTEX_ATTRIBS));
		trace("GL.MAX_VARYING_VECTORS:" + gl.getParameter(gl.MAX_VARYING_VECTORS));
		trace("GL.MAX_VERTEX_UNIFORM_VECTORS:" + gl.getParameter(gl.MAX_VERTEX_UNIFORM_VECTORS));
		trace("GL.MAX_FRAGMENT_UNIFORM_VECTORS:" + gl.getParameter(gl.MAX_FRAGMENT_UNIFORM_VECTORS));
		trace("EXTENSIONS:\n" + gl.getSupportedExtensions());
		// to use internal 32 bit float-textures for webgl enable: gl.getExtension("EXT_color_buffer_float");
		// or look here https://stackoverflow.com/questions/45571488/webgl-2-readpixels-on-framebuffers-with-float-textures
		
		// TODO: enable per program
		gl.getExtension("OES_standard_derivatives");
		//gl.getExtension("OES_fragment_precision_high");
		
		// check precision
		var precision = gl.getShaderPrecisionFormat(gl.VERTEX_SHADER, gl.MEDIUM_FLOAT);
		if (precision != null) trace("vertexshader-precision MEDIUM_FLOAT",precision.precision, precision.rangeMin, precision.rangeMax);
		precision = gl.getShaderPrecisionFormat(gl.FRAGMENT_SHADER, gl.MEDIUM_FLOAT);
		if (precision != null) trace("fragmentshader-precision MEDIUM_FLOAT",precision.precision, precision.rangeMin, precision.rangeMax);
		
		initGlPicking();
		
		background = new Background(gl);
		
		displayList = new RenderList<Display>(new Map<Display,RenderListItem<Display>>());
	}
	

 	public inline function hasDisplay(display:Display):Bool
	{
		return display.isIn(this);
	}
			
    /**
        Adds an Display instance to the RenderList. If it's already added it can be used to 
		change the order of rendering relative to another display in the List.

        @param  display Display instance to add into the RenderList or to change it's order
        @param  atDisplay (optional) to add or move the display before or after another display in the Renderlist (at default it adds at start or end)
        @param  addBefore (optional) set to `true` to add the display before another display or at start of the Renderlist (at default it adds after atDisplay or at end of the list)
    **/
	public function addDisplay(display:Display, ?atDisplay:Display, addBefore:Bool=false)
	{
		display.addToPeoteView(this, atDisplay, addBefore);
	}
	
    /**
        This function removes an Display instance from the RenderList.
    **/
	public function removeDisplay(display:Display):Void
	{
		display.removeFromPeoteView(this);
	}

	public function setNewGLContext(newGl:PeoteGL)
	{
		trace("PeoteView setNewGLContext");
		if (newGl != null && newGl != gl) // only if different GL - Context	
		{
			// setNewGLContext for all childs
			for (display in displayList) display.setNewGLContext(newGl);
			
			// clear old gl-context if there is one
			if (gl != null) clearOldGLContext();
			
			// setNewGLContext
			gl = newGl;
			if (PeoteGL.Version.isUBO) uniformBuffer.createGLBuffer(gl, width, height, xOffset, yOffset, xz, yz);
		}
	}

	private function clearOldGLContext() 
	{
		trace("Display clearOldGLContext");
		if (PeoteGL.Version.isUBO) uniformBuffer.deleteGLBuffer(gl);
		for (display in displayList) display.clearOldGLContext();
	}

    /**
        This function need to call if window-size is changed
    **/
	public function resize(width:Int, height:Int):Void
	{
		this.width = width;
		this.height = height;
		// TODO: re-arange or resize all Displays
		
		if (PeoteGL.Version.isUBO) uniformBuffer.updateResolution(gl, width, height);
	}

	

	// ------------------------------------------------------------------------------
	// ----------------------------- GL-Picking -------------------------------------
	// ------------------------------------------------------------------------------
	var pickFB:GLFramebuffer;
	var pickTexture:GLTexture;
	var pickDepthTexture:GLTexture;
	var pickInt32:lime.utils.Int32Array;
	var pickUInt8:lime.utils.UInt8Array;
	
	private inline function initGlPicking() // TODO: refactor more into GLTool!
	{
		if (PeoteGL.Version.isINSTANCED) {
			pickInt32 = new lime.utils.Int32Array(4);
			pickTexture = TexUtils.createPickingTexture(gl, true); // RGBA32I
		} else {
			pickUInt8  = new lime.utils.UInt8Array(4);
			pickTexture = TexUtils.createPickingTexture(gl); // RGBA
		}		
		pickFB = GLTool.createFramebuffer(gl, pickTexture, pickDepthTexture, 1, 1); 
	}
	
	// TODO: function to call onClick eventhandler of all pickable
	
	public function getElementAt(mouseX:Float, mouseY:Float, display:Display, program:Program):Int
	{
		if (! program.hasPicking()) throw("Error: opengl-Picking - type of buffer/element is not pickable !");
		
		gl.bindFramebuffer(gl.FRAMEBUFFER, pickFB);
		
		//initGLViewport
		gl.viewport (0, 0, 1, 1);
		gl.scissor(0, 0, 1, 1);
		gl.enable(gl.SCISSOR_TEST);	
		
		// clear framebuffer
		if (PeoteGL.Version.isINSTANCED) {
			gl.clearBufferiv(gl.COLOR, 0, [0, 0, 0, 0]); // only the first value is the UInt32 value that clears the texture
			if (PeoteGL.Version.hasFRAMEBUFFER_DEPTH) {
				gl.clear(gl.DEPTH_BUFFER_BIT);
				gl.depthFunc(gl.LEQUAL);
			}
		}
		else {
			gl.clearColor(0.0, 0.0, 0.0, 0.0);
			if (PeoteGL.Version.hasFRAMEBUFFER_DEPTH) {
				gl.clear( gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT );
				gl.depthFunc(gl.LEQUAL);
			}
			else gl.clear( gl.COLOR_BUFFER_BIT );
		}
				
		// TODO: to wrap around webgl1 ( or do fetch all stacked Elements! )
		// put in a loop here ( in every pass render only up to the last found element )

		var xOff:Float = xOffset - (xOffset + mouseX - xOffset) / xz;
		var yOff:Float = yOffset - (yOffset + mouseY - yOffset) / xz;

		display.pick(xOff, yOff, this, program); // render with picking shader
		
		// read picked pixel (element-number)
		if (gl.checkFramebufferStatus(gl.FRAMEBUFFER) == gl.FRAMEBUFFER_COMPLETE) {
			if (peote.view.PeoteGL.Version.isINSTANCED) {
				gl.readPixels(0, 0, 1, 1, gl.RGBA_INTEGER, gl.INT, pickInt32);
				gl.bindFramebuffer(gl.FRAMEBUFFER, null);
				return pickInt32[0] - 1;
			}
			else {
				gl.readPixels(0, 0, 1, 1, gl.RGBA, gl.UNSIGNED_BYTE, pickUInt8);
				gl.bindFramebuffer(gl.FRAMEBUFFER, null);
				return pickUInt8[3] << 24 | pickUInt8[2] << 16 | pickUInt8[1] << 8 | pickUInt8[0] - 1;
			}
		}
		else throw("Error: opengl-Picking - Framebuffer not complete!");
		return -2;
	}
	
	// ------------------------------------------------------------------------------
	// -------------------------- Render to Texture ---------------------------------
	// ------------------------------------------------------------------------------
	public function renderToTexture(display:Display) {
		// activate the framebuffer from texture
		gl.bindFramebuffer(gl.FRAMEBUFFER, display.fbTexture.framebuffer);
		// clear framebuffer
		gl.viewport (0, 0, display.fbTexture.width, display.fbTexture.height);
		gl.scissor(0, 0, display.fbTexture.width, display.fbTexture.height);
		gl.enable(gl.SCISSOR_TEST);	
		/*if (peote.view.PeoteGL.Version.isINSTANCED) {
			gl.clearBufferiv(gl.COLOR, 0, [0, 0, 0, 0]); // only the first value is the UInt32 value that clears the texture
			gl.clear(gl.DEPTH_BUFFER_BIT);
		}
		else {*/
			gl.clearColor(0.0, 0.0, 0.0, 0.0);
			gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
		//}
		// TODO: set only if program added or background need it
		gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
		gl.depthFunc(gl.LEQUAL);
		// CHECK LATER: this works only with es3.0 ->  gl.drawBuffers([gl.COLOR_ATTACHMENT0]);
		
		display.renderFramebuffer(this); // render with picking shader
	}
	
	// ------------------------------------------------------------------------------
	// ----------------------------- Render -----------------------------------------
	// ------------------------------------------------------------------------------
	private inline function initGLViewport(w:Int, h:Int):Void
	{
		gl.viewport (0, 0, w, h);
		
		gl.scissor(0, 0, w, h);
		gl.enable(gl.SCISSOR_TEST);	
		
		gl.clearColor(red, green, blue, alpha);
		//gl.clearDepthf(1.0);
		
		// Optimize: only clear depth if is in use somewhere (depthON state!)
		gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
		
		// TODO: set only if program added or background need it
		gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
		//gl.blendFunc(gl.ONE_MINUS_SRC_ALPHA, gl.SRC_ALPHA); // reverse
		//glBlendFuncSeparate(gl.ONE_MINUS_SRC_ALPHA, gl.SRC_ALPHA, gl.ONE, gl.ZERO); // colors separate
		
		gl.depthFunc(gl.LEQUAL);
	}
	
	private inline function setGLDepth(enabled:Bool):Void
	{	
		if (enabled && !glStateDepth) {
			glStateDepth = true;
			gl.enable(gl.DEPTH_TEST);
		} else if (!enabled && glStateDepth) {
			glStateDepth = false;
			gl.disable(gl.DEPTH_TEST);
		}
	}
	private inline function setGLAlpha(enabled:Bool):Void
	{	
		if (enabled && !glStateAlpha) {
			glStateAlpha = true;
			gl.enable(gl.BLEND);
		} else if (!enabled && glStateAlpha) {
			glStateAlpha = false;
			gl.disable(gl.BLEND);
		}
	}
	
	// ------------------------------------------------------------------------------
	var displayListItem:RenderListItem<Display>;

	public function render():Void
	{	
		//trace("===peoteView.render===");
		initGLViewport(width, height);
		
		
		displayListItem = displayList.first;
		while (displayListItem != null)
		{
			displayListItem.value.render(this);			
			displayListItem = displayListItem.next;
		}
		
	}
	

}