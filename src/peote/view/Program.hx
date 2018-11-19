package peote.view;

import peote.view.PeoteGL.GLProgram;
import peote.view.PeoteGL.GLShader;
import peote.view.PeoteGL.GLUniformLocation;

import peote.view.utils.GLTool;

@:allow(peote.view)
class Program 
{
	public var alphaEnabled:Bool;
	public var zIndexEnabled:Bool;
	
	var display:Display = null;
	var gl:PeoteGL = null;

	var glProgram:GLProgram = null;
	var glVertexShader:GLShader = null;
	var glFragmentShader:GLShader = null;
	
	var buffer:BufferInterface; // TODO: make public with getter/setter
	
	var glShaderConfig = {
		isES3: false,
		isINSTANCED: false,
		isUBO: false,
		IN: "attribute",
		VARIN: "varying",
		VAROUT: "varying",
		hasTEXTURES: false,
		FRAGMENT_PROGRAM_UNIFORMS:"",
	};
	
	public function new(buffer:BufferInterface) 
	{
		this.buffer = buffer;
		alphaEnabled = buffer.hasAlpha();
		zIndexEnabled = buffer.hasZindex();
	}
	
 	private inline function isIn(display:Display):Bool
	{
		return (this.display == display);
	}
			
	private inline function addToDisplay(display:Display):Bool
	{
		trace("Program added to Display");
		if (this.display == display) return false; // is already added
		else
		{	
			// if added to another one remove it frome there first
			if (this.display != null) this.display.removeProgram(this);
			
			this.display = display;
			
			if (gl != display.gl) // new or different GL-Context
			{	
				if (gl != null) clearOldGLContext(); // different GL-Context
				setNewGLContext(display.gl); //TODO: check that this is not Null
			}
			else if (PeoteGL.Version.isUBO)
			{	// if Display is changed but same gl-context -> bind to UBO of new Display
				if (gl!=null) display.uniformBuffer.bindToProgram(gl, glProgram, "uboDisplay", 1);
			}
			
			return true;
		}	
	}

	private inline function removedFromDisplay():Void
	{
		display = null;
	}
		
	
	private inline function setNewGLContext(newGl:PeoteGL)
	{
		trace("Program setNewGLContext");
		gl = newGl;
		buffer._gl = gl;          // TODO: check here if buffer already inside another peoteView with different glContext (multiwindows)
		buffer.createGLBuffer();
		buffer.updateGLBuffer();
		
		for (t in activeTextures) t.texture.setNewGLContext(newGl);
		
		if (PeoteGL.Version.isES3) {
			glShaderConfig.isES3 = true;
			glShaderConfig.IN = "in";
			glShaderConfig.VARIN = "in";
			glShaderConfig.VAROUT = "out";
		}
		if (PeoteGL.Version.isUBO)       glShaderConfig.isUBO = true;
		if (PeoteGL.Version.isINSTANCED) glShaderConfig.isINSTANCED = true;
		
		createProgram();
	}

	private inline function clearOldGLContext() 
	{
		trace("Program clearOldGLContext");
		
		gl.deleteShader(glVertexShader);
		gl.deleteShader(glFragmentShader);
		gl.deleteProgram(glProgram);
		
		buffer.deleteGLBuffer();
		for (t in activeTextures) t.texture.clearOldGLContext();
	}

	private function reCreateProgram():Void 
	{
		gl.deleteShader(glVertexShader);
		gl.deleteShader(glFragmentShader);
		gl.deleteProgram(glProgram);
		createProgram();
	}
	
	private function createProgram():Void  // TODO: do not compile twice if same program is used inside multiple displays
	{
		trace("create Program");
		
		if (activeTextures.length == 0)	glShaderConfig.hasTEXTURES = false;
		else {
			glShaderConfig.hasTEXTURES = true;
			// TODO: fill more textures templates
			glShaderConfig.FRAGMENT_PROGRAM_UNIFORMS = "uniform sampler2D uTexture0;";
		}
		
		glVertexShader   = GLTool.compileGLShader(gl, gl.VERTEX_SHADER,   GLTool.parseShader(buffer.getVertexShader(), glShaderConfig) );
		#if peoteview_debug_shader
		trace("\n"+GLTool.parseShader(buffer.getVertexShader(), glShaderConfig));
		#end
		glFragmentShader = GLTool.compileGLShader(gl, gl.FRAGMENT_SHADER, GLTool.parseShader(buffer.getFragmentShader(), glShaderConfig) );
		#if peoteview_debug_shader
		trace("\n"+GLTool.parseShader(buffer.getFragmentShader(), glShaderConfig));
		#end

		glProgram = gl.createProgram();

		gl.attachShader(glProgram, glVertexShader);
		gl.attachShader(glProgram, glFragmentShader);
		
		buffer.bindAttribLocations(gl, glProgram);
		
		GLTool.linkGLProgram(gl, glProgram);
		
		if (PeoteGL.Version.isUBO)
		{
			display.peoteView.uniformBuffer.bindToProgram(gl, glProgram, "uboView", 0);
			display.uniformBuffer.bindToProgram(gl, glProgram, "uboDisplay", 1);
		}
		else
		{
			uRESOLUTION = gl.getUniformLocation(glProgram, "uResolution");
			uZOOM = gl.getUniformLocation(glProgram, "uZoom");
			uOFFSET = gl.getUniformLocation(glProgram, "uOffset");
		}
		uTIME = gl.getUniformLocation(glProgram, "uTime");
		for (i in 0...activeTextures.length)
		{
			activeTextures[i].uniformLoc = gl.getUniformLocation(glProgram, "uTexture" + i);
		}	
	}
	
	var uRESOLUTION:GLUniformLocation;
	var uZOOM:GLUniformLocation;
	var uOFFSET:GLUniformLocation;
	var uTIME:GLUniformLocation;
	
	var activeTextures = new Array<{unit:Int, type:Int, texture:Texture, ?uniformLoc:GLUniformLocation}>(); // mehrere units fuer den selben typ (unit muss eindeutig sein)
	
	public function setTextures(textures:Array<{texture:Texture, ?textureType:Int, ?textureUnit:Int}>):Void {
		for (p in textures) setTexture(p.texture, p.textureType, p.textureUnit);
	}
	
	public function setTexture(texture:Texture, ?textureType:Int, ?textureUnit:Int):Void
	{
		// TODO: check buffer.maxTextureType -> element.maxTextureType
		if (textureType == null) textureType = 0;
		
		var autoTextureUnit = false;
		if (textureUnit == null) {			
			textureUnit = 0;
			autoTextureUnit = true;
		}
		else if (textureUnit >= gl.MAX_TEXTURE_IMAGE_UNITS) throw('Error, maximum for textureUnit is ${gl.MAX_TEXTURE_IMAGE_UNITS}.');
		
		var recompile = true;
		var isAdd = true;
		for (t in activeTextures) {
			if ((textureUnit == t.unit || autoTextureUnit) && textureType == t.type) {
				if (t.texture == texture) trace("this texture was already set");
				else {
					trace('Texture replaced');
					if (!texture.setToProgram(this)) throw("Error, texture already used by another gl-context.");
					// only recompile if textureslots/size changed
					if (t.texture.width == texture.width && t.texture.height == texture.width &&
						t.texture.slotsX == texture.slotsX && t.texture.slotsY == texture.slotsY) // TODO: check tiling also
						recompile = false;
					t.texture = texture;
				}
				isAdd = false;
				break;
			}
			if (t.unit == textureUnit) textureUnit++;
		}
		
		if (isAdd) {
			trace("new Texture added");
			if (!texture.setToProgram(this)) throw("Error, texture already used by another gl-context.");
			activeTextures.push({unit:textureUnit, type:textureType, texture:texture});
			// resort
			haxe.ds.ArraySort.sort(activeTextures, function(a, b):Int {
			  if (a.unit < b.unit) return -1;
			  else if (a.unit > b.unit) return 1;
			  return 0;
			});			
		}
		
		if (gl != null && recompile) reCreateProgram(); // recompile shaders
		trace("active textures:",activeTextures);
	}
	
	public function removeTexture(texture:Texture, textureType:Null<Int> = null, textureUnit:Null<Int> = null):Void
	{
		var i = activeTextures.length;
		while (i-- > 0) {
			var t = activeTextures[i];
			if ((texture==null || t.texture == texture) && (textureType==null || t.type==textureType) && (textureUnit==null || t.unit==textureUnit) ) {
				activeTextures.splice(i, 1);
				t.texture.removedFromProgram();
				if (gl != null) reCreateProgram(); // recompile shaders
				break;
			}
		}

	}
	public function removeTextureType(textureType:Int):Void removeTexture(null, textureType);
	public function removeTextureUnit(textureUnit:Int):Void removeTexture(null, null, textureUnit);

 	public function hasTexture(texture:Texture, ?textureType:Int, ?textureUnit:Int):Bool
	{
		for (t in activeTextures) {
			if ((texture == null || t.texture == texture) && (textureType == null || t.type == textureType) && (textureUnit == null || t.unit == textureUnit) )
				return true;
		}
		return false;
	}
	public function hasTextureType(textureType:Int):Void hasTexture(null, textureType);
	public function hasTextureUnit(textureUnit:Int):Void hasTexture(null, null, textureUnit);
	
	// ------------------------------------------------------------------------------
	// ----------------------------- Render -----------------------------------------
	// ------------------------------------------------------------------------------
	private inline function render(peoteView:PeoteView, display:Display)
	{	
		//trace("    ---program.render---");
		gl.useProgram(glProgram); // ------ Shader Program
		
		// Texture Units
		for (i in 0...activeTextures.length)
		{
			var t = activeTextures[i];
			//TODO: if t != null
			if ( peoteView.isTextureStateChange(i, t.texture.glTexture) ) {
				gl.activeTexture (gl.TEXTURE0 + t.unit);
				gl.bindTexture (gl.TEXTURE_2D, t.texture.glTexture);
				//glBindSampler(i, linearFiltering);
				//gl.enable(gl.TEXTURE_2D); // is default ?
			}
			gl.uniform1i (t.uniformLoc, i); // optimizing: later in this.uniformBuffer for isUBO
		}
		
		// TODO: from Program
		if (PeoteGL.Version.isUBO)
		{	
			// ------------- uniform block -------------
			//gl.bindBufferRange(gl.UNIFORM_BUFFER, 0, uProgramBuffer, 0, 8);
			gl.bindBufferBase(gl.UNIFORM_BUFFER, peoteView.uniformBuffer.block , peoteView.uniformBuffer.uniformBuffer);
			gl.bindBufferBase(gl.UNIFORM_BUFFER, display.uniformBuffer.block , display.uniformBuffer.uniformBuffer);
		}
		else
		{
			// ------------- simple uniform -------------
			gl.uniform2f (uRESOLUTION, peoteView.width, peoteView.height);
			gl.uniform1f (uZOOM, peoteView.zoom * display.zoom);
			gl.uniform2f (uOFFSET, (display.x + display.xOffset + peoteView.xOffset) / display.zoom, 
											 (display.y + display.yOffset + peoteView.yOffset) / display.zoom);
		}
		
		gl.uniform1f (uTIME, peoteView.time);
		
		peoteView.setGLDepth(zIndexEnabled);
		peoteView.setGLAlpha(alphaEnabled);
		
		buffer.render(peoteView, display, this);
		gl.useProgram (null);
	}
	// ------------------------------------------------------------------------------
	// ------------------------ OPENGL PICKING -------------------------------------- 
	// ------------------------------------------------------------------------------
	private inline function pick( mouseX:Int, mouseY:Int, peoteView:PeoteView, display:Display):Void
	{
		// TODO
		// gl.useProgram(glProgramPick);
		// TODO -> translate peoteview relative to zoom and mouseposition before rendreing
		// no changes for the uniform-buffers for the picking-shader
	}
	
}