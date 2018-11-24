package peote.view;

import haxe.ds.IntMap;
import peote.view.PeoteGL.GLProgram;
import peote.view.PeoteGL.GLShader;
import peote.view.PeoteGL.GLUniformLocation;

import peote.view.utils.GLTool;
import peote.view.utils.RenderList;
import peote.view.utils.RenderListItem;

class ActiveTexture {
	public var unit:Int;
	public var texture:Texture;
	public var uniformLoc:GLUniformLocation;
	public function new(unit:Int, texture:Texture, uniformLoc:GLUniformLocation) {
		this.unit = unit;
		this.texture = texture;
		this.uniformLoc = uniformLoc;
	}
}

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
	
	var textureList:RenderList<ActiveTexture>;
	var textureLayers = new IntMap<Array<Texture>>();
	var textures = new Array<Texture>();

	public function new(buffer:BufferInterface) 
	{
		this.buffer = buffer;
		alphaEnabled = buffer.hasAlpha();
		zIndexEnabled = buffer.hasZindex();
		textureList = new RenderList<ActiveTexture>(new Map<ActiveTexture,RenderListItem<ActiveTexture>>());
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
		
		for (t in textures) t.setNewGLContext(newGl);
		
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
		for (t in textures) t.clearOldGLContext();
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
		
		textureList.clear();

		GLTool.linkGLProgram(gl, glProgram);
		
		// create textureList with new unitormlocations
		var unit:Int = 0;
		for (t in textures)
			textureList.add(new ActiveTexture(unit, t, gl.getUniformLocation(glProgram, "uTexture" + unit++)), null, null );
		
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
	}
	
	var uRESOLUTION:GLUniformLocation;
	var uZOOM:GLUniformLocation;
	var uOFFSET:GLUniformLocation;
	var uTIME:GLUniformLocation;
	
	public function setTextureLayer(layer:Int, textures:Array<Texture>):Void {
		if (textures == null) throw("Error, textures needs array of textures");
		if (textures.length == 0) throw("Error, array needs at least 1 texture");
		textureLayers.set(layer, textures);
		updateTextures();
	}
	
	public function updateTextures():Void {
		trace("Program - update Textures");
		var newTextures = new Array<Texture>();
		// collect new or removed all textures
		for (layer in textureLayers.keys()) {
			for (t in textureLayers.get(layer)) {
				if (textures.indexOf(t) < 0) newTextures.push(t);
			}
		}
		var i = textures.length;
		while (i-- > 0) 
			if (newTextures.indexOf(textures[i]) < 0) { // remove texture
				textures.splice(i, 1);
				textures[i].removedFromProgram();
			}
		for (t in newTextures) {
				if (textures.indexOf(t) < 0) { // add texture
					textures.push(t);
					if (! t.setToProgram(this)) throw("Error, texture already used by another program into different gl-context");
				}
		}
		
			
		if (textures.length == 0) glShaderConfig.hasTEXTURES = false;
		else {
			glShaderConfig.hasTEXTURES = true;
			// TODO: fill more textures templates
			glShaderConfig.FRAGMENT_PROGRAM_UNIFORMS = "uniform sampler2D uTexture0;";
		}

		
		if (gl != null) reCreateProgram(); // recompile shaders
			
	}
	
	
	public function setTextureUnit(texture:Texture, unit:Int):Void {
		var oldUnit:Int = -1;
		var sameUnitTexure:ActiveTexture = null;
		for (t in textureList) {
			if (t.texture == texture) oldUnit = t.unit;
			else if (unit == t.unit) sameUnitTexure = t;
		}
		if (oldUnit == -1) throw("Error, texture is not in use, try setTextureLayer(layer, [texture]) before setting unit-number manual");
		if (sameUnitTexure != null) sameUnitTexure.unit = oldUnit;
	}
	
 	public function hasTexture(texture:Texture, layer:Null<Int>):Bool
	{
		if (layer == null) {
			for (t in textureList) {
				if (t.texture == texture) return true;
			}
		}
		else if (textureLayers.get(layer).indexOf(texture) >= 0 ) return true;
		return false;
	}
	
	// ------------------------------------------------------------------------------
	// ----------------------------- Render -----------------------------------------
	// ------------------------------------------------------------------------------
	var textureListItem:RenderListItem<ActiveTexture>;

	private inline function render(peoteView:PeoteView, display:Display)
	{	
		//trace("    ---program.render---");
		gl.useProgram(glProgram); // ------ Shader Program
		
		// Texture Units
		textureListItem = textureList.first;
		while (textureListItem != null)
		{
			if (textureListItem.value.texture.glTexture == null) trace("=======PROBLEM========");
			
			if ( peoteView.isTextureStateChange(textureListItem.value.unit, textureListItem.value.texture.glTexture) ) {
				trace("activate Texture", textureListItem.value.unit);
				gl.activeTexture (gl.TEXTURE0 + textureListItem.value.unit);
				gl.bindTexture (gl.TEXTURE_2D, textureListItem.value.texture.glTexture);
				//glBindSampler(i, linearFiltering);
				//gl.enable(gl.TEXTURE_2D); // is default ?
			}
			gl.uniform1i (textureListItem.value.uniformLoc, textureListItem.value.unit); // optimizing: later in this.uniformBuffer for isUBO
			textureListItem = textureListItem.next;
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