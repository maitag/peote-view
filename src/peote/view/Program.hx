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
	
	public var colorFormula = "c * c0";
	
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
		FRAGMENT_CALC_LAYER:"c",
		TEXTURES:[],
	};
	
	var textureList = new RenderList<ActiveTexture>(new Map<ActiveTexture,RenderListItem<ActiveTexture>>());
	var textureLayers = new IntMap<Array<Texture>>();
	var activeTextures = new Array<Texture>();
	var activeUnits = new Array<Int>();

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
		
		for (t in activeTextures) t.setNewGLContext(newGl);
		
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
		for (t in activeTextures) t.clearOldGLContext();
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
		
		#if peoteview_debug_shader
		trace("\n"+GLTool.parseShader(buffer.getVertexShader(), glShaderConfig));
		#end
		glVertexShader   = GLTool.compileGLShader(gl, gl.VERTEX_SHADER,   GLTool.parseShader(buffer.getVertexShader(), glShaderConfig) );
		#if peoteview_debug_shader
		trace("\n"+GLTool.parseShader(buffer.getFragmentShader(), glShaderConfig));
		#end
		glFragmentShader = GLTool.compileGLShader(gl, gl.FRAGMENT_SHADER, GLTool.parseShader(buffer.getFragmentShader(), glShaderConfig) );

		glProgram = gl.createProgram();

		gl.attachShader(glProgram, glVertexShader);
		gl.attachShader(glProgram, glFragmentShader);
		
		buffer.bindAttribLocations(gl, glProgram);
				
		textureList.clear(); // maybe optimize later with own single-linked list here!

		GLTool.linkGLProgram(gl, glProgram);
		
		// create textureList with new unitormlocations
		for (i in 0...activeTextures.length) {
			textureList.add(new ActiveTexture(activeUnits[i], activeTextures[i], gl.getUniformLocation(glProgram, "uTexture" + i)), null, false );
		}
		
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
	
	public function setTextureLayer(textureUnits:Array<Texture>, layer:Null<Int>=null, update:Bool = true):Void {
		trace("set texture layer");
		if (layer == null) layer = buffer.getMaxTextureLayer();
		if (textureUnits == null) throw("Error, textures needs array of textures");
		if (textureUnits.length == 0) throw("Error, array needs at least 1 texture");
		var i = textureUnits.length;
		while (i-- > 0) if (textureUnits.indexOf(textureUnits[i]) != i) throw("Error, textureLayer can not contain same texture twice.");		
		textureLayers.set(layer, textureUnits);
		if (update) updateTextures();
	}
	
	public function addTexture(texture:Texture, layer:Null<Int>=null, update:Bool = true):Void {
		trace("add texture to layer "+ layer);
		if (layer == null) layer = buffer.getMaxTextureLayer();
		var textures:Array<Texture> = textureLayers.get(layer);
		if (textures != null) {
			if (textures.indexOf(texture) >= 0) throw("Error, textureLayer already contains this texture.");
			else {
				textures.push(texture);
				textureLayers.set(layer, textures);
			}
		}
		else textureLayers.set(layer, [texture]);
		if (update) updateTextures();
	}
	
	public function removeTextureLayer(layer:Int, update:Bool = true):Void {
		trace("remove texture layer");
		textureLayers.remove(layer);
		if (update) updateTextures();
	}
	
	public function removeTexture(texture:Texture, layer:Null<Int>=null, update:Bool = true):Void {
		trace("remove texture from layer");
		if (layer == null)
			for (l in textureLayers.keys()) {
				var textures:Array<Texture> = textureLayers.get(l);
				textures.remove(texture);
				if (textures.length == 0) textureLayers.remove(l);
				else textureLayers.set(l, textures );
			}
		else textureLayers.get(layer).remove(texture);
		if (update) updateTextures();
	}
	
	public function updateTextures():Void {
		trace("update Textures");
		// collect new or removed old textures
		var newTextures = new Array<Texture>();
		for (layer in textureLayers.keys()) {
			for (t in textureLayers.get(layer)) {
				if (newTextures.indexOf(t) < 0) newTextures.push(t);
			}
		}
		
		var i = activeTextures.length;
		while (i-- > 0) 
			if (newTextures.indexOf(activeTextures[i]) < 0) { // remove texture
				trace("REMOVE texture",i);
				activeTextures[i].removedFromProgram();
				activeTextures.splice(i, 1);
				activeUnits.splice(i, 1);
			}
		
		for (t in newTextures) {
			if (activeTextures.indexOf(t) < 0) { // add texture
				trace("ADD texture", activeTextures.length);
				activeTextures.push(t);
				var unit = 0;
				while (activeUnits.indexOf(unit) >= 0 ) unit++;
				activeUnits.push(unit);
				if (! t.setToProgram(this)) throw("Error, texture already used by another program into different gl-context");
			}
		}
				
		// -----------
		trace("textureLayers", [for (layer in textureLayers.keys()) layer]);
		
		if (activeTextures.length == 0) {
			glShaderConfig.hasTEXTURES = false;
			glShaderConfig.FRAGMENT_CALC_LAYER = "c";
		}
		else {
			glShaderConfig.hasTEXTURES = true;
			glShaderConfig.FRAGMENT_CALC_LAYER = colorFormula;
			
			glShaderConfig.FRAGMENT_PROGRAM_UNIFORMS = "";
			for (i in 0...activeTextures.length)
				glShaderConfig.FRAGMENT_PROGRAM_UNIFORMS += 'uniform sampler2D uTexture$i;';
			
			// fill texture-layer in template
			glShaderConfig.TEXTURES = [];
			for (layer in textureLayers.keys()) {
				var units = new Array < {UNIT_VALUE:String, TEXTURE:String,
										SLOTS_X:String, SLOTS_Y:String, SLOT_WIDTH:String, SLOT_HEIGHT:String,
										SLOTS_WIDTH:String, SLOTS_HEIGHT:String,
										TILES_X:String, TILES_Y:String,
										//TILE_WIDTH:String, TILE_HEIGHT:String,
										TEXTURE_WIDTH:String, TEXTURE_HEIGHT:String,
										FIRST:Bool, LAST:Bool}>();
				var textures = textureLayers.get(layer);
				for (i in 0...textures.length) {
					units.push({
						UNIT_VALUE:(i + 1) + ".0",
						TEXTURE:"uTexture" + activeTextures.indexOf(textures[i]),
						SLOTS_X: textures[i].slotsX + ".0",
						SLOTS_Y: textures[i].slotsY + ".0",
						SLOT_WIDTH:  textures[i].slotWidth  + ".0",
						SLOT_HEIGHT: textures[i].slotHeight + ".0",
						SLOTS_WIDTH:  Std.int(textures[i].slotsX * textures[i].slotWidth ) + ".0",
						SLOTS_HEIGHT: Std.int(textures[i].slotsY * textures[i].slotHeight) + ".0",
						TILES_X: textures[i].tilesX + ".0",
						TILES_Y: textures[i].tilesY + ".0",
						//TILE_WIDTH: Std.int( textures[i].slotWidth / textures[i].tilesX) + ".0",
						//TILE_HEIGHT:Std.int( textures[i].slotHeight/ textures[i].tilesY) + ".0",
						TEXTURE_WIDTH: textures[i].width + ".0",
						TEXTURE_HEIGHT:textures[i].height + ".0",
						FIRST:((i == 0) ? true : false), LAST:((i == textures.length - 1) ? true : false)
					});
				}
				trace("LAYER:", layer, units);
				glShaderConfig.TEXTURES.push({LAYER:layer, UNITS:units});
			}
		}

		
		if (gl != null) reCreateProgram(); // recompile shaders
			
	}
	
	
	public function setTextureUnit(texture:Texture, unit:Int):Void {
		trace("set texture unit to " + unit);
		var oldUnit:Int = -1;
		var j:Int = -1;
		for (i in 0...activeTextures.length) {
			if (activeTextures[i] == texture) {
				oldUnit = activeUnits[i];
				activeUnits[i] = unit;
			}
			else if (unit == activeUnits[i]) j = i;
		}
		if (oldUnit == -1) throw("Error, texture is not in use, try setTextureLayer(layer, [texture]) before setting unit-number manual");
		if (j != -1) activeUnits[j] = oldUnit;
		
		// update textureList units
		j = 0;
		for (t in textureList) t.unit = activeUnits[j++];
	}
	
 	public function hasTexture(texture:Texture, layer:Null<Int>=null):Bool
	{
		if (layer == null) {
			for (t in activeTextures) if (t == texture) return true;
		}
		else {
			var textures = textureLayers.get(layer);
			if (textures != null)
				if (textures.indexOf(texture) >= 0 ) return true;
		}
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
			
			if ( peoteView.isTextureStateChange(textureListItem.value.unit, textureListItem.value.texture) ) {
				gl.activeTexture (gl.TEXTURE0 + textureListItem.value.unit);
				trace("activate Texture", textureListItem.value.unit);
				gl.bindTexture (gl.TEXTURE_2D, textureListItem.value.texture.glTexture);
				//gl.bindSampler(textureListItem.value.unit, gl.TEXTURE_3D);
				//gl.enable(gl.TEXTURE_2D); // is default ?
			}
			gl.uniform1i (textureListItem.value.uniformLoc, textureListItem.value.unit); // optimizing: later in this.uniformBuffer for isUBO
			textureListItem = textureListItem.next;
		}
		
		// TODO: own uniforms for every Program
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