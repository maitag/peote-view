package peote.view;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import peote.view.PeoteGL.GLProgram;
import peote.view.PeoteGL.GLShader;
import peote.view.PeoteGL.GLUniformLocation;

import peote.view.utils.Util;
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
	public var autoUpdateTextures:Bool = true;
	
	var displays = new Array<Display>();
	var gl:PeoteGL = null;

	var glProgram:GLProgram = null;
	var glProgramPicking:GLProgram = null;
	var glVertexShader:GLShader = null;
	var glFragmentShader:GLShader = null;
	var glVertexShaderPicking:GLShader = null;
	var glFragmentShaderPicking:GLShader = null;
	
	public var buffer(default, null):BufferInterface; // TODO: setter for bufferswitching
	
	var glShaderConfig = {
		isPICKING: false,
		isES3: false,
		isINSTANCED: false,
		isUBO: false,
		IN: "attribute",
		VARIN: "varying",
		VAROUT: "varying",
		hasTEXTURES: false,
		FRAGMENT_PROGRAM_UNIFORMS:"",
		FRAGMENT_CALC_LAYER:"",
		TEXTURES:[],
		isDISCARD: true,
		DISCARD: "0.0",
		isPIXELSNAPPING: false,
		PIXELDIVISOR: "1.0",
		VERTEX_FLOAT_PRECISION : null,
		VERTEX_INT_PRECISION : null,
		VERTEX_SAMPLER_PRECISION : null,
		FRAGMENT_FLOAT_PRECISION : null,
		FRAGMENT_INT_PRECISION : null,
		FRAGMENT_SAMPLER_PRECISION : null,
		VERTEX_INJECTION : "",
		FRAGMENT_INJECTION : "",
		// TODO: headers to share functions between glPrograms
		//VERTEX_FUNCTION_HEADERS : "",
		//FRAGMENT_FUNCTION_HEADERS : "",
		SIZE_FORMULA : null,
		POS_FORMULA : null,
		ROTZ_FORMULA : null,
		PIVOT_FORMULA : null,
		FRAGMENT_EXTENSIONS: [],
	};
	
	var textureList = new RenderList<ActiveTexture>(new Map<ActiveTexture,RenderListItem<ActiveTexture>>());
	var textureListPicking = new RenderList<ActiveTexture>(new Map<ActiveTexture,RenderListItem<ActiveTexture>>());
	
	var textureLayers = new IntMap<Array<Texture>>();
	var activeTextures = new Array<Texture>();
	var activeUnits = new Array<Int>();

	var colorIdentifiers:Array<String>;
	var customIdentifiers:Array<String>;
	var customVaryings:Array<String>;

	var textureIdentifiers:Array<String>;
	var customTextureIdentifiers = new Array<String>();
	
	var defaultFormulaVars:StringMap<Color>;
	var defaultColorFormula:String;
	var colorFormula = "";
	
	var fragmentFloatPrecision:Null<String> = null;
	
	var useTextCoordVaryings:Bool = false;
	
	public function new(buffer:BufferInterface) 
	{
		this.buffer = buffer;
		alphaEnabled = buffer.hasAlpha();
		zIndexEnabled = buffer.hasZindex();
		
		colorIdentifiers = buffer.getColorIdentifiers();
		customIdentifiers = buffer.getCustomIdentifiers();
		customVaryings = buffer.getCustomVaryings();
		textureIdentifiers = buffer.getTextureIdentifiers();
		
		defaultColorFormula = buffer.getDefaultColorFormula();
		defaultFormulaVars = buffer.getDefaultFormulaVars();
		#if peoteview_debug_program
		trace("defaultColorFormula = ", defaultColorFormula);
		trace("defaultFormulaVars = ", defaultFormulaVars);
		#end
		parseColorFormula();
	}
	
 	public inline function isIn(display:Display):Bool return (displays.indexOf(display) >= 0);			

	public function addToDisplay(display:Display, ?atProgram:Program, addBefore:Bool=false)
	{
		#if peoteview_debug_program
		trace("Add Program to Display");
		#end
		if ( isIn(display) ) throw("Error, program is already added to this display");
		displays.push(display);
		setNewGLContext(display.gl);
		display.programList.add(this, atProgram, addBefore);
	}

	public function removeFromDisplay(display:Display):Void
	{
		#if peoteview_debug_program
		trace("Remove Program from Display"); // TODO <- PROBLEM with multiwindows-sample
		#end
		if (!displays.remove(display)) throw("Error, program is not inside display");
		display.programList.remove(this);
	}
		
	private inline function setNewGLContext(newGl:PeoteGL)
	{
		if (newGl != null && newGl != gl) // only if different GL - Context	
		{
			// check gl-context of all parents
			for (d in displays)
				if (d.gl != null && d.gl != newGl) throw("Error, program can not used inside different gl-contexts");
			
			// clear old gl-context if there is one
			if (gl != null) clearOldGLContext();
			#if peoteview_debug_program
			trace("Program setNewGLContext");
			#end
			gl = newGl;
			
			if (PeoteGL.Version.isES3) {
				glShaderConfig.isES3 = true;
				glShaderConfig.IN = "in";
				glShaderConfig.VARIN = "in";
				glShaderConfig.VAROUT = "out";
			}
			if (PeoteGL.Version.isUBO)       glShaderConfig.isUBO = true;
			if (PeoteGL.Version.isINSTANCED) glShaderConfig.isINSTANCED = true;
			
			// gl-extensions for fragment-shader
			glShaderConfig.FRAGMENT_EXTENSIONS = [];
			if (gl.getExtension("OES_standard_derivatives") != null)
				glShaderConfig.FRAGMENT_EXTENSIONS.push({EXTENSION:"GL_OES_standard_derivatives"});
			// TODO: let enable custom extensions for shaders like "GL_OES_fragment_precision_high"

			buffer.setNewGLContext(gl);
			createProgram();
			
			// setNewGLContext for all textures
			for (t in activeTextures) t.setNewGLContext(gl);		
		}
	}

	private inline function clearOldGLContext() 
	{
		#if peoteview_debug_program
		trace("Program clearOldGLContext");
		#end
		deleteProgram();
	}

	var ready:Bool = false; // TODO !!!
	private inline function reCreateProgram():Void 
	{
		ready = false; // TODO !!!
		deleteProgram();
		createProgram();
	}
	
	private inline function hasPicking() return buffer.hasPicking();
	
	private inline function deleteProgram()
	{	
		gl.deleteShader(glVertexShader);
		gl.deleteShader(glFragmentShader);
		gl.deleteProgram(glProgram);
		if (hasPicking()) {
			gl.deleteShader(glVertexShaderPicking);
			gl.deleteShader(glFragmentShaderPicking);
			gl.deleteProgram(glProgramPicking);	
		}
	}
	
	private inline function createProgram() {
		createProg();
		if (hasPicking()) createProg(true);		
	}
	
	private function createProg(isPicking:Bool = false):Void
	{
		#if peoteview_debug_program
		trace("create GL-Program" + ((isPicking) ? " for opengl-picking" : ""));
		#end
		glShaderConfig.isPICKING = (isPicking) ? true : false;
		
		if (fragmentFloatPrecision != null) glShaderConfig.FRAGMENT_FLOAT_PRECISION = fragmentFloatPrecision;
		else {
			if (buffer.needFragmentPrecision() && PeoteGL.Precision.FragmentFloat.medium < 23)
				glShaderConfig.FRAGMENT_FLOAT_PRECISION = PeoteGL.Precision.availFragmentFloat("highp");
			else 
				glShaderConfig.FRAGMENT_FLOAT_PRECISION = PeoteGL.Precision.availFragmentFloat("mediump");
		}
				
		var glVShader = GLTool.compileGLShader(gl, gl.VERTEX_SHADER,   GLTool.parseShader(buffer.getVertexShader(),   glShaderConfig), true );
		var glFShader = GLTool.compileGLShader(gl, gl.FRAGMENT_SHADER, GLTool.parseShader(buffer.getFragmentShader(), glShaderConfig), true );

		var glProg = gl.createProgram();

		gl.attachShader(glProg, glVShader);
		gl.attachShader(glProg, glFShader);
		
		buffer.bindAttribLocations(gl, glProg);
		
		GLTool.linkGLProgram(gl, glProg);
		
		if ( !isPicking && PeoteGL.Version.isUBO)
		{
			var index:Int = gl.getUniformBlockIndex(glProg, "uboView");
			if (index != gl.INVALID_INDEX) gl.uniformBlockBinding(glProg, index, UniformBufferView.block);
			index = gl.getUniformBlockIndex(glProg, "uboDisplay");
			if (index != gl.INVALID_INDEX) gl.uniformBlockBinding(glProg, index, UniformBufferDisplay.block);
		}
		else
		{	// Try to optimize here to let use picking shader the same vars
			if ( !isPicking ) {
				uRESOLUTION = gl.getUniformLocation(glProg, "uResolution");
				uZOOM = gl.getUniformLocation(glProg, "uZoom");
				uOFFSET = gl.getUniformLocation(glProg, "uOffset");
			} else {
				uRESOLUTION_PICK = gl.getUniformLocation(glProg, "uResolution");
				uZOOM_PICK = gl.getUniformLocation(glProg, "uZoom");
				uOFFSET_PICK = gl.getUniformLocation(glProg, "uOffset");
			}
		}
		if ( !isPicking )
			uTIME = gl.getUniformLocation(glProg, "uTime");
		else uTIME_PICK = gl.getUniformLocation(glProg, "uTime");
		
		if (!isPicking) {
			// create new textureList with new unitormlocations
			textureList.clear(); // maybe optimize later with own single-linked list here!
			for (i in 0...activeTextures.length) {
				textureList.add(new ActiveTexture(activeUnits[i], activeTextures[i], gl.getUniformLocation(glProg, "uTexture" + i)), null, false );
			}	
			glProgram = glProg;
			glVertexShader = glVShader;
			glFragmentShader  = glFShader;
		} else {
			// create new textureListPicking with new unitormlocations
			textureListPicking.clear(); // maybe optimize later with own single-linked list here!
			for (i in 0...activeTextures.length) {
				textureListPicking.add(new ActiveTexture(activeUnits[i], activeTextures[i], gl.getUniformLocation(glProg, "uTexture" + i)), null, false );
			}
			glProgramPicking = glProg;
			glVertexShaderPicking = glVShader;
			glFragmentShaderPicking  = glFShader;
		}
		ready = true;
	}
	
	var uRESOLUTION:GLUniformLocation;
	var uZOOM:GLUniformLocation;
	var uOFFSET:GLUniformLocation;
	var uTIME:GLUniformLocation;
	// TODO: optimize here (or all with typedef {uRESOLUTION:GLUniformLocation ...} )
	var uRESOLUTION_PICK:GLUniformLocation;
	var uZOOM_PICK:GLUniformLocation;
	var uOFFSET_PICK:GLUniformLocation;
	var uTIME_PICK:GLUniformLocation;
	
	private function parseColorFormula():Void {
		var formula:String = "";
		
		if (colorFormula != "") formula = colorFormula;
		else if (defaultColorFormula != "") formula = defaultColorFormula;
		else {
			var col = colorIdentifiers.copy();
			var tex = new Array<String>();
			for (i in 0...textureIdentifiers.length) 
				if (textureLayers.exists(i)) tex.push(textureIdentifiers[i]);
			for (i in 0...customTextureIdentifiers.length)
				if (textureLayers.exists(textureIdentifiers.length+i)) tex.push(customTextureIdentifiers[i]);
			
			// mix(mix(...))*restColor
			if (col.length + tex.length == 0) formula = Color.RED.toGLSL();
			else {
				if (tex.length > 0) {
					formula = tex.shift();
					if (col.length > 0) formula = '${col.shift()} * $formula';
				}
				for (t in tex) {
					if (col.length > 0) t = '${col.shift()} * $t ';
					formula = 'mix( $formula, $t, ($t).a )';
				}
				// if more colors than textures add/multiply the Rest
				while (col.length > 0) {
					formula += ((formula != "") ? "*": "") + col.shift();
					if (col.length > 0) formula = '($formula + ${col.shift()})';					
				}				
			}
			
		}
		for (i in 0...colorIdentifiers.length) {
			var regexp = new EReg('(.*?\\b)${colorIdentifiers[i]}(\\b.*?)', "g");
			if (regexp.match(formula))
				if (regexp.matched(1).substr(-1,1) != ".")
					formula = regexp.replace( formula, '$1' + "c" + i +'$2' );
		}
		for (i in 0...customIdentifiers.length) {
			var regexp = new EReg('(.*?\\b)${customIdentifiers[i]}(\\b.*?)', "g");
			if (regexp.match(formula))
				if (regexp.matched(1).substr(-1,1) != ".")
					formula = regexp.replace( formula, '$1' + customVaryings[i] +'$2' );
		}
		for (i in 0...textureIdentifiers.length) {
			var regexp = new EReg('(.*?\\b)${textureIdentifiers[i]}(\\b.*?)', "g");
			if (regexp.match(formula))
				if (textureLayers.exists(i) && regexp.matched(1).substr(-1,1) != ".")
					formula = regexp.replace( formula, '$1' + "t" + i +'$2' );
		}
		for (i in 0...customTextureIdentifiers.length) {
			var regexp = new EReg('(.*?\\b)${customTextureIdentifiers[i]}(\\b.*?)', "g");
			if (regexp.match(formula))
				if (textureLayers.exists(textureIdentifiers.length+i) && regexp.matched(1).substr(-1,1) != ".")
					formula = regexp.replace( formula, '$1' + "t"+(textureIdentifiers.length+i) +'$2' );
		}
		// fill the REST with default values:
		for (name in defaultFormulaVars.keys()) {
			//var regexp = new EReg('(.*?\\b)${name}(.[rgbaxyz]+)?(\\b.*?)', "g");
			var regexp = new EReg('(.*?\\b)${name}(\\b.*?)', "g");
			if (regexp.match(formula))
				if (regexp.matched(1).substr(-1,1) != ".")
						formula = regexp.replace( formula, '$1' + defaultFormulaVars.get(name).toGLSL() + '$2' );
			//formula = regexp.replace( formula, '$1' + defaultFormulaVars.get(name).toGLSL('$2') + '$3' );
		}
		
		glShaderConfig.FRAGMENT_CALC_LAYER = formula;
	}
	
	public function setColorFormula(formula:String, varDefaults:StringMap<Color>=null, ?autoUpdateTextures:Null<Bool>):Void {
		colorFormula = formula;
		if (varDefaults != null)
			for (name in varDefaults.keys()) {
				if (Util.isWrongIdentifier(name)) throw('Error: "$name" is not an identifier, please use only letters/numbers or "_" (starting with a letter)');
				defaultFormulaVars.set(name, varDefaults.get(name));
			}
		if (autoUpdateTextures != null) { if (autoUpdateTextures) updateTextures(); }
		else if (this.autoUpdateTextures) updateTextures();
	}
	
	// inject custom defines or functions into vertexshader
	public function injectIntoVertexShader(glslCode:String, ?autoUpdateTextures:Null<Bool>):Void {
		glShaderConfig.VERTEX_INJECTION = glslCode;
		checkAutoUpdate(autoUpdateTextures);
	}
	
	// inject custom defines or functions into fragmentshader
	public function injectIntoFragmentShader(glslCode:String, ?autoUpdateTextures:Null<Bool>):Void {
		glShaderConfig.FRAGMENT_INJECTION = glslCode;
		useTextCoordVaryings = (glslCode == "") ? false : true;
		checkAutoUpdate(autoUpdateTextures);
	}
	
	// TODO
	var formula:StringMap<String>;
	var attrib :StringMap<String>;
	var formulaNames :StringMap<String>;
	public function setFormula(name:String, newFormula:String, ?autoUpdateTextures:Null<Bool>):Void {
		
		formula = buffer.getFormulas();
		attrib = buffer.getAttributes();
		formulaNames = buffer.getFormulaNames();
		
		trace("formula:"); for (f in formula.keys()) trace('  $f => ${formula.get(f)}');
		trace("attrib:"); for (f in attrib.keys()) trace('  $f => ${attrib.get(f)}');
		
		if (formulaNames.exists(name))
			trace('default formula for $name is: ' + formula.get( formulaNames.get(name) ) );
		
			
		checkAutoUpdate(autoUpdateTextures);
	}
	
	// invoked via createProg()
	function parseAndResolveFormulas():Void {

		try Util.resolveFormulaCyclic(formula) catch(e:Dynamic) throw ('Error: cyclic reference of "${e.errVar}" inside @formula "${e.formula}" for "${e.errKey}"');
		//trace("formula cyclic resolved:"); for (f in formula.keys()) trace('  $f => ${formula.get(f)}');
		Util.resolveFormulaVars(formula, attrib);

		trace("formula resolved:"); for (f in formula.keys()) trace('  $f => ${formula.get(f)}');
		trace("attrib:"); for (a in attrib.keys()) trace('  $a => ${attrib.get(a)}');
		
	}
	
	// -------------------------------------------------
	
	function getTextureIndexByIdentifier(identifier:String, addNew:Bool = true):Int {
		var layer = textureIdentifiers.indexOf(identifier);
		if (layer < 0) {
			layer = customTextureIdentifiers.indexOf(identifier);
			if (layer < 0) {
				if (addNew) {
					if (Util.isWrongIdentifier(identifier)) throw('Error: "$identifier" is not an identifier, please use only letters/numbers or "_" (starting with a letter)');
					#if peoteview_debug_program
					trace('adding custom texture layer "$identifier"');
					#end
					layer = textureIdentifiers.length + customTextureIdentifiers.length;
					customTextureIdentifiers.push(identifier); // adds a custom identifier
				}
			}	
		}
		return layer;
	}
		
	function validatePrecision(precision:Null<String>):Null<String> {
		if (precision != null) {
			if (["low", "medium", "high"].indexOf(precision.toLowerCase()) < 0) {
				if (["lowp", "mediump", "highp"].indexOf(precision.toLowerCase()) < 0)
					throw("Error, no valid precision format. Use 'low', 'medium' or 'high' (or leave it null for default)");
			}
			else precision += "p";
		}
		return precision;
	}	
	// set float precision for fragmentShader 
	public function setFragmentFloatPrecision(?precision:Null<String>, ?autoUpdateTextures:Null<Bool>) {
		fragmentFloatPrecision =  PeoteGL.Precision.availFragmentFloat(validatePrecision(precision)); // template is set in createProgram
		checkAutoUpdate(autoUpdateTextures);
	}
	// set int precision for fragmentShader 
	public function setFragmentIntPrecision(?precision:Null<String>, ?autoUpdateTextures:Null<Bool>) {
		glShaderConfig.FRAGMENT_INT_PRECISION =  PeoteGL.Precision.availFragmentInt(validatePrecision(precision));
		checkAutoUpdate(autoUpdateTextures);
	}
	// set sampler2D precision for fragmentShader 
	public function setFragmentSamplerPrecision(?precision:Null<String>, ?autoUpdateTextures:Null<Bool>) {
		glShaderConfig.FRAGMENT_SAMPLER_PRECISION =  PeoteGL.Precision.availFragmentSampler(validatePrecision(precision));
		checkAutoUpdate(autoUpdateTextures);
	}
	// set float precision for vertexShader 
	public function setVertexFloatPrecision(?precision:Null<String>, ?autoUpdateTextures:Null<Bool>) {
		glShaderConfig.VERTEX_FLOAT_PRECISION =  PeoteGL.Precision.availVertexFloat(validatePrecision(precision));
		checkAutoUpdate(autoUpdateTextures);
	}
	// set int precision for vertexShader 
	public function setVertexIntPrecision(?precision:Null<String>, ?autoUpdateTextures:Null<Bool>) {
		glShaderConfig.VERTEX_INT_PRECISION = PeoteGL.Precision.availVertexInt(validatePrecision(precision));
		checkAutoUpdate(autoUpdateTextures);
	}
	// set sampler precision for vertexShader 
	public function setVertexSamplerPrecision(?precision:Null<String>, ?autoUpdateTextures:Null<Bool>) {
		glShaderConfig.VERTEX_SAMPLER_PRECISION = PeoteGL.Precision.availVertexSampler(validatePrecision(precision));
		checkAutoUpdate(autoUpdateTextures);
	}
	
	// enable pixelsnapping 
	public function snapToPixel(?pixelDivisor:Null<Float>, ?autoUpdateTextures:Null<Bool>) {
		if (pixelDivisor == null) {
			glShaderConfig.isPIXELSNAPPING = false;
		}
		else {
			glShaderConfig.isPIXELSNAPPING = true;
			glShaderConfig.PIXELDIVISOR = Util.toFloatString(1/pixelDivisor);
		}
		checkAutoUpdate(autoUpdateTextures);
	}
	
	// discard pixels with alpha lower then 
	public function discardAtAlpha(?atAlphaValue:Null<Float>, ?autoUpdateTextures:Null<Bool>) {
		if (atAlphaValue == null) {
			glShaderConfig.isDISCARD = false;
		}
		else {
			glShaderConfig.isDISCARD = true;
			glShaderConfig.DISCARD = Util.toFloatString(atAlphaValue);
		}
		checkAutoUpdate(autoUpdateTextures);
	}
	
	// set a texture-layer
	public function setTexture(texture:Texture, identifier:String, ?autoUpdateTextures:Null<Bool>):Void {
		#if peoteview_debug_program
		trace("(re)set texture of a layer");
		#end
		var layer = getTextureIndexByIdentifier(identifier);
		textureLayers.set(layer, [texture]);
		checkAutoUpdate(autoUpdateTextures);
	}
	
	// multiple textures per layer (to switch between them via unit-attribute)
	public function setMultiTexture(textureUnits:Array<Texture>, identifier:String, ?autoUpdateTextures:Null<Bool>):Void {
		#if peoteview_debug_program
		trace("(re)set texture-units of a layer");
		#end
		var layer = getTextureIndexByIdentifier(identifier);
		if (textureUnits == null) throw("Error, textureUnits need to be an array of textures");
		if (textureUnits.length == 0) throw("Error, textureUnits needs at least 1 texture");
		var i = textureUnits.length;
		while (i-- > 0)
			if (textureUnits[i] == null) throw("Error, texture is null.");
			else if (textureUnits.indexOf(textureUnits[i]) != i) throw("Error, textureLayer can not contain same texture twice.");		
		textureLayers.set(layer, textureUnits);
		checkAutoUpdate(autoUpdateTextures);
	}
	
	// add a texture to textuer-units
	public function addTexture(texture:Texture, identifier:String, ?autoUpdateTextures:Null<Bool>):Void {
		#if peoteview_debug_program
		trace("add texture into units of " + identifier);
		#end
		var layer = getTextureIndexByIdentifier(identifier);
		if (texture == null) throw("Error, texture is null.");
		var textures:Array<Texture> = textureLayers.get(layer);
		if (textures != null) {
			if (textures.indexOf(texture) >= 0) throw("Error, textureLayer already contains this texture.");
			else {
				textures.push(texture);
				textureLayers.set(layer, textures);
			}
		}
		else textureLayers.set(layer, [texture]);
		checkAutoUpdate(autoUpdateTextures);
	}
	
	public function removeTexture(texture:Texture, identifier:String, ?autoUpdateTextures:Null<Bool>):Void {
		#if peoteview_debug_program
		trace("remove texture from textureUnits of a layer");
		#end
		var layer = getTextureIndexByIdentifier(identifier, false);
		if (layer < 0) throw('Error, textureLayer "$identifier" did not exists.');
		if (texture == null) throw("Error, texture is null.");
		textureLayers.get(layer).remove(texture);
		if (textureLayers.get(layer).length == 0) {
			textureLayers.remove(layer);
			customTextureIdentifiers.remove(identifier);
		}
		checkAutoUpdate(autoUpdateTextures);
	}
	
	public function removeAllTexture(identifier:String, ?autoUpdateTextures:Null<Bool>):Void {
		#if peoteview_debug_program
		trace("remove all textures from a layer");
		#end
		var layer = getTextureIndexByIdentifier(identifier, false);
		if (layer < 0) throw('Error, textureLayer "$identifier" did not exists.');
		textureLayers.remove(layer);
		customTextureIdentifiers.remove(identifier);
		checkAutoUpdate(autoUpdateTextures);
	}
	
	inline function checkAutoUpdate(autoUpdateTextures:Null<Bool>) {
		if (autoUpdateTextures != null) { if (autoUpdateTextures) updateTextures(); }
		else if (this.autoUpdateTextures) updateTextures();
	}
	
	// TODO: replaceTexture(textureToReplace:Texture, newTexture:Texture)
	
 	public function hasTexture(texture:Texture, identifier:Null<String>=null):Bool
	{
		if (texture == null) throw("Error, texture is null.");
		if (identifier == null) {
			for (t in activeTextures) if (t == texture) return true;
		}
		else {
			var textures = textureLayers.get(getTextureIndexByIdentifier(identifier, false));
			if (textures != null)
				if (textures.indexOf(texture) >= 0 ) return true;
		}
		return false;
	}
	
	// ------------------------------------
	
	public function updateTextures():Void {
		#if peoteview_debug_program
		trace("update Textures");
		#end
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
				#if peoteview_debug_program 
				trace("REMOVE texture", i);
				#end
				activeTextures[i].removeFromProgram(this);
				activeTextures.splice(i, 1);
				activeUnits.splice(i, 1);
			}
		
		for (t in newTextures) {
			if (activeTextures.indexOf(t) < 0) { // add texture
				#if peoteview_debug_program
				trace("ADD texture", activeTextures.length);
				#end
				activeTextures.push(t);
				var unit = 0;
				while (activeUnits.indexOf(unit) >= 0 ) unit++;
				activeUnits.push(unit);
				t.addToProgram(this);
			}
		}
				
		// -----------
		#if peoteview_debug_program
		trace("textureLayers", [for (layer in textureLayers.keys()) layer]);
		#end
		parseColorFormula();
		
		if (activeTextures.length == 0) {
			glShaderConfig.hasTEXTURES = (useTextCoordVaryings) ? true : false;
		}
		else {
			glShaderConfig.hasTEXTURES = true;
			
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
										TEXTURE_WIDTH:String, TEXTURE_HEIGHT:String,
										FIRST:Bool, LAST:Bool}>();
				var textures = textureLayers.get(layer);
				for (i in 0...textures.length) {
					units.push({
						UNIT_VALUE:(i + 1) + ".0",
						TEXTURE:"uTexture" + activeTextures.indexOf(textures[i]),
						SLOTS_X: textures[i].slotsX + ".0",
						SLOTS_Y: textures[i].slotsY + ".0",
						SLOT_WIDTH:  Util.toFloatString(textures[i].slotWidth  / textures[i].width),
						SLOT_HEIGHT: Util.toFloatString(textures[i].slotHeight / textures[i].height),
						SLOTS_WIDTH: Util.toFloatString(textures[i].slotsX * textures[i].slotWidth / textures[i].width ),
						SLOTS_HEIGHT:Util.toFloatString(textures[i].slotsY * textures[i].slotHeight/ textures[i].height),
						TILES_X: textures[i].tilesX + ".0",
						TILES_Y: textures[i].tilesY + ".0",
						TEXTURE_WIDTH: textures[i].width + ".0",
						TEXTURE_HEIGHT:textures[i].height + ".0",
						FIRST:((i == 0) ? true : false), LAST:((i == textures.length - 1) ? true : false)
					});
				}
				#if peoteview_debug_program
				trace("LAYER:", layer, units);
				#end
				glShaderConfig.TEXTURES.push({LAYER:layer, UNITS:units});
			}
		}
		
		if (gl != null) reCreateProgram(); // recompile shaders			
	}
	
	
	public function setActiveTextureGlIndex(texture:Texture, index:Int):Void {
		#if peoteview_debug_program
		trace("set texture index to " + index);
		#end
		var oldUnit:Int = -1;
		var j:Int = -1;
		for (i in 0...activeTextures.length) {
			if (activeTextures[i] == texture) {
				oldUnit = activeUnits[i];
				activeUnits[i] = index;
			}
			else if (index == activeUnits[i]) j = i;
		}
		if (oldUnit == -1) throw("Error, texture is not in use, try setTextureLayer(layer, [texture]) before setting unit-number manual");
		if (j != -1) activeUnits[j] = oldUnit;
		
		// update textureList units
		j = 0; for (t in textureList) t.unit = activeUnits[j++];
		if (hasPicking()) j = 0; for (t in textureListPicking) t.unit = activeUnits[j++];
	}
	
	// ------------------------------------------------------------------------------
	// ----------------------------- Render -----------------------------------------
	// ------------------------------------------------------------------------------
	var textureListItem:RenderListItem<ActiveTexture>; // TODO: check if this can be problem while shared with picking

	private inline function render_activeTextureUnits(peoteView:PeoteView, textureList:RenderList<ActiveTexture>):Void {
		// Texture Units
		textureListItem = textureList.first;
		while (textureListItem != null)
		{
			#if peoteview_debug_program
			if (textureListItem.value.texture.glTexture == null) trace("=======PROBLEM========"); // TODO !!!
			#end
			
			if ( peoteView.isTextureStateChange(textureListItem.value.unit, textureListItem.value.texture) )
			{
				gl.activeTexture (gl.TEXTURE0 + textureListItem.value.unit);
				#if peoteview_debug_program
				trace("activate Texture", textureListItem.value.unit);
				#end
				gl.bindTexture (gl.TEXTURE_2D, textureListItem.value.texture.glTexture);
				
				//gl.bindSampler(textureListItem.value.unit, sampler); // only ES3.0
				//gl.enable(gl.TEXTURE_2D); // is default ?
			}
			gl.uniform1i (textureListItem.value.uniformLoc, textureListItem.value.unit); // optimizing: later in this.uniformBuffer for isUBO
			textureListItem = textureListItem.next;
		}
	}
	
	private inline function render(peoteView:PeoteView, display:Display)
	{
		#if peoteview_debug_program
		//trace("    ---program.render---");		
		if (!ready) trace("=======PROBLEM=====> not READY !!!!!!!!"); // TODO !!!
		#end
		gl.useProgram(glProgram);
		
		render_activeTextureUnits(peoteView, textureList);
		
		// TODO: custom uniforms per Program
		
		if (PeoteGL.Version.isUBO)
		{	
			// ------------- uniform block -------------
			// for multiple ranges
			//gl.bindBufferRange(gl.UNIFORM_BUFFER, peoteView.uniformBuffer.block, peoteView.uniformBuffer.uniformBuffer, 256, 3 * 4*4);
			//gl.bindBufferRange(gl.UNIFORM_BUFFER, display.uniformBuffer.block  , display.uniformBuffer.uniformBuffer  , 256, 2 * 4*4);
			gl.bindBufferBase(gl.UNIFORM_BUFFER, UniformBufferView.block, peoteView.uniformBuffer.uniformBuffer);
			gl.bindBufferBase(gl.UNIFORM_BUFFER, UniformBufferDisplay.block, display.uniformBuffer.uniformBuffer);
		}
		else
		{
			// ------------- simple uniform -------------
			gl.uniform2f (uRESOLUTION, peoteView.width, peoteView.height);
			gl.uniform2f (uZOOM, peoteView.xz * display.xz, peoteView.yz * display.yz);
			gl.uniform2f (uOFFSET, (display.x + display.xOffset + peoteView.xOffset) / display.xz, 
			                       (display.y + display.yOffset + peoteView.yOffset) / display.yz);
		}
		
		gl.uniform1f (uTIME, peoteView.time);
		
		peoteView.setGLDepth(zIndexEnabled);
		peoteView.setGLAlpha(alphaEnabled);
		
		buffer.render(peoteView, display, this);
		gl.useProgram (null);
	}
	
	// ------------------------------------------------------------------------------
	// ------------------------ RENDER TO TEXTURE ----------------------------------- 
	// ------------------------------------------------------------------------------
	private inline function renderFramebuffer(peoteView:PeoteView, display:Display)
	{
		gl.useProgram(glProgram);
		render_activeTextureUnits(peoteView, textureList);
		
		if (PeoteGL.Version.isUBO)
		{	
			// ------------- uniform block -------------
			gl.bindBufferBase(gl.UNIFORM_BUFFER, UniformBufferView.block, display.uniformBufferViewFB.uniformBuffer);
			gl.bindBufferBase(gl.UNIFORM_BUFFER, UniformBufferDisplay.block, display.uniformBufferFB.uniformBuffer);
		}
		else
		{
			// ------------- simple uniform -------------
			gl.uniform2f (uRESOLUTION, display.width, -display.height);
			gl.uniform2f (uZOOM, display.xz, display.yz);
			gl.uniform2f (uOFFSET, (display.xOffset + peoteView.xOffset) / display.xz, 
			                       (display.yOffset + peoteView.yOffset - display.height) / display.yz );
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
	private inline function pick( xOff:Float, yOff:Float, peoteView:PeoteView, display:Display, toElement:Int):Void
	{
		gl.useProgram(glProgramPicking);
		
		render_activeTextureUnits(peoteView, textureListPicking);
		
		// No view/display UBOs for PICKING-SHADER!
		gl.uniform2f (uRESOLUTION_PICK, 1, 1);
		gl.uniform2f (uZOOM_PICK, peoteView.xz * display.xz, peoteView.yz * display.yz);
		gl.uniform2f (uOFFSET_PICK, (display.x + display.xOffset + xOff) / display.xz,
		                            (display.y + display.yOffset + yOff) / display.yz);
		
		gl.uniform1f (uTIME_PICK, peoteView.time);
		
		peoteView.setGLDepth((toElement == -1) ? zIndexEnabled : false); // disable for getAllElementsAt() in peoteView
		peoteView.setGLAlpha(false);
		
		buffer.pick(peoteView, display, this, toElement);
		gl.useProgram (null);		
	}
	
}