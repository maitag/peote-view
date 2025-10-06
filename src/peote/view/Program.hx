package peote.view;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import peote.view.Color;

import peote.view.Mask;
import peote.view.PeoteGL.GLProgram;
import peote.view.PeoteGL.GLShader;
import peote.view.PeoteGL.GLUniformLocation;
import peote.view.BlendFactor;
import peote.view.BlendFunc;

import peote.view.intern.Util;
import peote.view.intern.GLTool;
import peote.view.intern.RenderList;
import peote.view.intern.RenderListItem;
import peote.view.intern.BufferInterface;
import peote.view.intern.UniformBufferView;
import peote.view.intern.UniformBufferDisplay;

/*
    o-o    o-o  o-o-o  o-o
   o   o  o        o      o
  o-o-o  o-o   o    o    o-o
 o      o     (_\    o      o
o      o-o     |\     o    o-o

*/

/**
	The Program is rendering the graphical elements of a `Buffer` with the corresponding shader and assigned `Texture`s.  
	The shader code can be modified at runtime by formulas or also by `glsl` code-injection and custom `uniforms`.  
	It supports different modes for `color blending`, `stencil masks` or `depth-buffer`.
**/
@:allow(peote.view,peote.ui)
class Program 
{
	/**
		The `Display` instances in which the program is contained.
	**/
	public var displays(default, null):Array<Display>;

	var gl:PeoteGL = null;

 	// TODO: setter for bufferswitching

	/**
		Gets the used `Buffer`.
	**/
	public var buffer(default, null):BufferInterface;
	
	/**
		Shows or hides the program during rendering.
	**/
	public var isVisible:Bool = true;

	/**
		Shows the program during rendering.
	**/
	public inline function show() isVisible = true;	

	/**
		Hides the program during rendering.
	**/
	public inline function hide() isVisible = false;

	/**
		To enable or disable color rendering, e.g. disable to only render into the stencil-buffer by drawing a mask.
	**/
	public var colorEnabled:Bool = true;
	
	/**
		To enable or disable the color/alpha blendmode.
	**/
	public var blendEnabled:Bool;

	/**
		Use a separate blend-function for the alpha channel if the blendmode is enabled.
	**/
	public var blendSeparate:Bool = false;

	/**
		Separate blend-function for the alpha channel if blendSeparate is true.
	**/
	public var blendFuncSeparate:Bool = false;
	
	var blendValues:Int = 0; // stores all 6 following values into one Int here
	
	/**
		`BlendFactor` for the source colors if into blendmode.
	**/
	public var blendSrc(get, set):BlendFactor;

	/**
		`BlendFactor` for the destination colors if into blendmode.
	**/
	public var blendDst(get, set):BlendFactor;

	/**
		`BlendFactor` for the source alpha channel if into blendmode.
	**/
	public var blendSrcAlpha(get, set):BlendFactor;

	/**
		`BlendFactor` for the destination alpha channel if into blendmode.
	**/
	public var blendDstAlpha(get, set):BlendFactor;

	inline function get_blendSrc():BlendFactor return BlendFactor.getSrc(blendValues);
	inline function get_blendDst():BlendFactor return BlendFactor.getDst(blendValues);
	inline function get_blendSrcAlpha():BlendFactor return BlendFactor.getSrcAlpha(blendValues);
	inline function get_blendDstAlpha():BlendFactor return BlendFactor.getDstAlpha(blendValues);
	inline function set_blendSrc(v:BlendFactor):BlendFactor { setBlendUseColor(); if (gl != null) glBlendSrc = v.toGL(gl); blendValues = v.setSrc(blendValues); return v; }
	inline function set_blendDst(v:BlendFactor):BlendFactor { setBlendUseColor(); if (gl != null) glBlendDst = v.toGL(gl); blendValues = v.setDst(blendValues); return v; }
	inline function set_blendSrcAlpha(v:BlendFactor):BlendFactor { setBlendUseColor(); if (gl != null) glBlendSrcAlpha = v.toGL(gl); blendValues = v.setSrcAlpha(blendValues); return v; }
	inline function set_blendDstAlpha(v:BlendFactor):BlendFactor { setBlendUseColor(); if (gl != null) glBlendDstAlpha = v.toGL(gl); blendValues = v.setDstAlpha(blendValues); return v; }

	/**
		`BlendFunc` for the color channels if into blendmode.
	**/
	public var blendFunc(get, set):BlendFunc;

	/**
		`BlendFunc` for the alpha channel if into blendmode.
	**/
	public var blendFuncAlpha(get, set):BlendFunc;

	inline function get_blendFunc():BlendFunc return BlendFunc.getFunc(blendValues);
	inline function get_blendFuncAlpha():BlendFunc return BlendFunc.getFuncAlpha(blendValues);	
	inline function set_blendFunc(v:BlendFunc):BlendFunc { if (gl != null) glBlendFunc = v.toGL(gl); blendValues = v.setFunc(blendValues); return v; }
	inline function set_blendFuncAlpha(v:BlendFunc):BlendFunc { if (gl != null) glBlendFuncAlpha = v.toGL(gl); blendValues = v.setFuncAlpha(blendValues); return v; }

	inline function setBlendUseColor() {
		useBlendColor = (glBlendSrc > 10 || glBlendDst > 10) ? true : false;
		useBlendColorSeparate = (useBlendColor || glBlendSrcAlpha > 10 || glBlendDstAlpha > 10) ? true : false;
	}

	inline function setDefaultBlendValues() {
		blendSrc  = blendSrcAlpha  = BlendFactor.SRC_ALPHA;
		blendDst  = blendDstAlpha  = BlendFactor.ONE_MINUS_SRC_ALPHA;
		blendFunc = blendFuncAlpha = BlendFunc.ADD;
	}

	inline function updateBlendGLValues() {
		glBlendSrc = BlendFactor.getSrc(blendValues).toGL(gl);
		glBlendDst = BlendFactor.getDst(blendValues).toGL(gl);
		glBlendSrcAlpha = BlendFactor.getSrcAlpha(blendValues).toGL(gl);
		glBlendDstAlpha = BlendFactor.getDstAlpha(blendValues).toGL(gl);
		
		glBlendFunc = BlendFunc.getFunc(blendValues).toGL(gl);
		glBlendFuncAlpha = BlendFunc.getFuncAlpha(blendValues).toGL(gl);
	}

	var glBlendSrc:Int = 0;
	var glBlendDst:Int = 0;
	var glBlendSrcAlpha:Int = 0;
	var glBlendDstAlpha:Int = 0;
	var glBlendFunc:Int = 0;
	var glBlendFuncAlpha:Int = 0;

	var useBlendColor:Bool = false;
	var useBlendColorSeparate:Bool = false;

	/**
		Constant `Color` to use if into blendmode.
	**/
	public var blendColor(default, set):Color = 0x7F7F7F7F;
	inline function set_blendColor(v:Color):Color {
		glBlendR = v.r / 255.0;
		glBlendG = v.g / 255.0;
		glBlendB = v.b / 255.0;
		glBlendA = v.a / 255.0;
		return blendColor = v;
	}
	var glBlendR:Float;
	var glBlendG:Float;
	var glBlendB:Float;
	var glBlendA:Float;

	/**
		To enable or disable rendering into the depth-buffer.
	**/
	public var zIndexEnabled:Bool;

	/**
		To use the stencil-buffer for masking or to draw into it to use it afterwards by another program.
	**/
	public var mask:Mask = Mask.OFF;

	/**
		Clears the stencil-buffer.
	**/
	public var clearMask:Bool = false;

	/**
		Enable automatic shader generation for functioncalls what set, add or remove textures (also for snapToPixel, discardAtAlpha, shadercode-injection, formula and precision changes)
	**/
	public var autoUpdate:Bool = true;

	var _updateTexture:Bool = false;
	var _updateColorFormula:Bool = false;

	var glProgram:GLProgram = null;
	var glProgramPicking:GLProgram = null;
	var glVertexShader:GLShader = null;
	var glFragmentShader:GLShader = null;
	var glVertexShaderPicking:GLShader = null;
	var glFragmentShaderPicking:GLShader = null;

	var glShaderConfig = {
		isPICKING: false,
		isES3: false,
		isINSTANCED: false,
		isUBO: false,
		IN: "attribute",
		VARIN: "varying",
		VAROUT: "varying",
		hasTEXTURES: false,
		hasTEXTURE_FUNCTIONS: false,
		hasFRAGMENT_INJECTION: false,
		FRAGMENT_PROGRAM_UNIFORMS:"",
		FRAGMENT_CALC_LAYER:"",
		TEXTURES:[],
		
		// TODO:
		TEXTURE_DEFAULTS:[],
		
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
		FORMULA_VARYINGS : {},
		FORMULA_CONSTANTS : {},
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
	var textureID_Defaults = new Array<{layer:Int, value:String}>();
	var used_by_ColorFormula:Int = 0;
	var usedID_by_ColorFormula:Int = 0;

	var defaultFormulaVars:StringMap<Color>;
	var defaultColorFormula:String;
	var colorFormula = "";
	var formula = new StringMap<String>();
	var formulaHasChanged:Bool = false;

	var fragmentFloatPrecision:Null<String> = null;

	/**
		Creates a new `Program` instance.
		@param buffer the `Buffer` what contains the graphical elements to render
	**/
	public function new(buffer:BufferInterface) 
	{
		this.buffer = buffer;
		
		displays = new Array<Display>();

		setDefaultBlendValues();
		blendEnabled = buffer.hasBlend();
		
		zIndexEnabled = buffer.hasZindex();
		
		colorIdentifiers = buffer.getColorIdentifiers();
		customIdentifiers = buffer.getCustomIdentifiers();
		customVaryings = buffer.getCustomVaryings();
		textureIdentifiers = buffer.getTextureIdentifiers();
		
		defaultColorFormula = buffer.getDefaultColorFormula();
		defaultFormulaVars = buffer.getDefaultFormulaVars();
		
		//trace("formula Names:"); for (f in buffer.getFormulaNames().keys()) trace('  $f => ${buffer.getFormulaNames().get(f)}');
		
		// copy default formulas into new formula
		for (k in buffer.getFormulas().keys()) formula.set(k, buffer.getFormulas().get(k) );
		
		//trace("formulas:"); for (f in formula.keys()) trace('  $f => ${formula.get(f)}');
		//trace("attributes:"); for (f in buffer.getAttributes().keys()) trace('  $f => ${buffer.getAttributes().get(f)}');
		
		try Util.resolveFormulaCyclic(buffer.getFormulas()) catch(e:Dynamic) throw ('Error: cyclic reference of "${e.errVar}" inside @formula "${e.formula}" for "${e.errKey}"');
		//trace("formula cyclic resolved:"); for (f in buffer.getFormulas().keys()) trace('  $f => ${buffer.getFormulas().get(f)}');
		Util.resolveFormulaVars(buffer.getFormulas(), buffer.getAttributes());
		//trace("default formula resolved:"); for (f in buffer.getFormulas().keys()) trace('  $f => ${buffer.getFormulas().get(f)}');
		
		#if peoteview_debug_program
		trace("defaultColorFormula = ", defaultColorFormula);
		trace("defaultFormulaVars = ", defaultFormulaVars);
		#end
		parseColorFormula();
	}

	/**
		Returns true is this program is inside the RenderList of a `Display` instance.
		@param display Display instance
	**/
	public inline function isIn(display:Display):Bool return (displays.indexOf(display) >= 0);

	/**
		Adds this program to the RenderList of a `Display` instance.
		Can be also used to change the order (relative to another program) if it is already added.
		@param display Display instance
		@param atProgram (optional) to add or move before or after another program in the RenderList (by default at start or at end)
		@param addBefore (optional) if 'true' it's added before another program or at start of the Renderlist (by default it's added after atProgram or at end)
	**/
	public function addToDisplay(display:Display, ?atProgram:Program, addBefore:Bool=false)
	{
		if ( ! isIn(display) ) {
			#if peoteview_debug_program
			trace("Add Program to Display");
			#end
			displays.push(display);
			setNewGLContext(display.gl);
		}
		#if peoteview_debug_display
		else trace("Change order of Program");
		#end
		
		display.programList.add(this, atProgram, addBefore);
	}

	/**
		Removes this program from the RenderList of a `Display` instance.
		@param display Display instance
	**/
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
			
			updateBlendGLValues();
			
			if (PeoteGL.Version.isES3) {
				glShaderConfig.isES3 = true;
				glShaderConfig.IN = "in";
				glShaderConfig.VARIN = "in";
				glShaderConfig.VAROUT = "out";
			}
			if (PeoteGL.Version.isUBO) glShaderConfig.isUBO = true;
			if (PeoteGL.Version.isINSTANCED) glShaderConfig.isINSTANCED = true;
			
			// gl-extensions for fragment-shader
			// TODO: let enable custom extensions for shaders like "GL_OES_fragment_precision_high"
			// TODO: optimize to not check every time!
			glShaderConfig.FRAGMENT_EXTENSIONS = [];
			if (gl.getExtension("OES_standard_derivatives") != null)
				glShaderConfig.FRAGMENT_EXTENSIONS.push({EXTENSION:"GL_OES_standard_derivatives"});
				
			if (gl.getExtension("EXT_color_buffer_float") != null)
				glShaderConfig.FRAGMENT_EXTENSIONS.push({EXTENSION:"EXT_color_buffer_float"});
			else if (gl.getExtension("OES_texture_float") != null)
				glShaderConfig.FRAGMENT_EXTENSIONS.push({EXTENSION:"OES_texture_float"});
			
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
		
		parseAndResolveFormulas();
				
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
		
		if ( !isPicking ) {
			uTIME = gl.getUniformLocation(glProg, "uTime");
			uniformFloatLocations = new Array<GLUniformLocation>();
			for (u in uniformFloats) uniformFloatLocations.push( gl.getUniformLocation(glProg, u.name) );
		}
		else {
			uTIME_PICK = gl.getUniformLocation(glProg, "uTime");
			uniformFloatPickLocations = new Array<GLUniformLocation>();
			for (u in uniformFloats) uniformFloatPickLocations.push( gl.getUniformLocation(glProg, u.name) );
		}
		
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

	var uniformFloatsVertex:Array<UniformFloat> = null;
	var uniformFloatsFragment:Array<UniformFloat> = null;
	// TODO: target-optimization for faster access
	var uniformFloats:Array<UniformFloat> = new Array<UniformFloat>();
	var uniformFloatLocations:Array<GLUniformLocation>;
	var uniformFloatPickLocations:Array<GLUniformLocation>;

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
			var regexp = Util.regexpIdentifier(colorIdentifiers[i]);
			if (regexp.match(formula))
				formula = regexp.replace( formula, '$1' + "c" + i );
		}
		for (i in 0...customIdentifiers.length) {
			var regexp = Util.regexpIdentifier(customIdentifiers[i]);
			if (regexp.match(formula))
				if (customVaryings[i] != null)
					formula = regexp.replace( formula, '$1' + customVaryings[i] );
				else throw('Error while parsing ColorFormula: custom identifier ${customIdentifiers[i]} need @varying to access in fragmentshader');
		}
		
		textureID_Defaults = new Array<{layer:Int, value:String}>();
		used_by_ColorFormula = 0;
		usedID_by_ColorFormula = 0;
		for (i in 0...textureIdentifiers.length) {
			var regexp = Util.regexpIdentifier(textureIdentifiers[i]);
			if (regexp.match(formula)) {
				if (textureLayers.exists(i)) formula = regexp.replace( formula, '$1' + "t" + i );
				used_by_ColorFormula |= 1 << i;
			}			
			regexp = Util.regexpIdentifier(textureIdentifiers[i]+"_ID");
			if (regexp.match(formula)) {
				formula = regexp.replace( formula, '$1' + i );
				usedID_by_ColorFormula |= 1 << i;
				if (!textureLayers.exists(i)) textureID_Defaults.push({layer:i, value:defaultFormulaVars.get(textureIdentifiers[i]).toGLSL()});
			}
		}

		for (i in 0...customTextureIdentifiers.length) {
			var regexp = Util.regexpIdentifier(customTextureIdentifiers[i]);
			if (regexp.match(formula)) {
				if (textureLayers.exists(textureIdentifiers.length + i)) formula = regexp.replace( formula, '$1' + "t" + (textureIdentifiers.length + i) );					
				used_by_ColorFormula |= 1 << (textureIdentifiers.length + i);
			}				
			regexp = Util.regexpIdentifier(customTextureIdentifiers[i]+"_ID");
			if (regexp.match(formula)) {
				formula = regexp.replace( formula, '$1' + (textureIdentifiers.length + i) );
				usedID_by_ColorFormula |= 1 << (textureIdentifiers.length + i);
				if(!textureLayers.exists(textureIdentifiers.length + i)) textureID_Defaults.push({layer:(textureIdentifiers.length + i), value:defaultFormulaVars.get(textureIdentifiers[textureIdentifiers.length + i]).toGLSL()});
			}
		}
		
		// fill the REST with default values:
		for (name in defaultFormulaVars.keys()) {
			//var regexp = new EReg('(.*?\\b)${name}(.[rgbaxyz]+)?(\\b.*?)', "g");
			var regexp = Util.regexpIdentifier(name);
			if (regexp.match(formula))
				formula = regexp.replace( formula, '$1' + defaultFormulaVars.get(name).toGLSL() );
				//formula = regexp.replace( formula, '$1' + defaultFormulaVars.get(name).toGLSL('$2') + '$3' );
		}

		// check the existence of "vTexCoord": (TODO -> lets have some more simple for X and Y !)
		if (Util.regexpIdentifier("vTexCoord").match(formula)) {
			glShaderConfig.hasFRAGMENT_INJECTION = true;
		}

		glShaderConfig.FRAGMENT_CALC_LAYER = formula;
	}

	/**
		Set a formula to combine the colors of `@texUnit`s together with the `@color` attributes of an element.
		@param formula a String what contains the color formula
		@param varDefaults defines the default colors by a Map with the `texUnit` identifiers as keys
		@param autoUpdate set it to `true` (update) or `false` (no update), otherwise the `.autoUpdate` property is used
	**/
	public function setColorFormula(formula:String="", varDefaults:StringMap<Color>=null, ?autoUpdate:Null<Bool>):Void {
		colorFormula = formula;
		if (varDefaults != null)
			for (name in varDefaults.keys()) {
				if (Util.isWrongIdentifier(name)) throw('Error: "$name" is not an identifier, please use only letters/numbers or "_" (starting with a letter)');
				defaultFormulaVars.set(name, varDefaults.get(name));
			}
		_updateColorFormula = true;
		checkAutoUpdate(autoUpdate);
	}

	/**
		Inject custom glsl code into the vertexshader of a program.
		@param glslCode a String what contains the glsl code
		@param uTimeUniformEnabled if `true` you can use the global `time` uiform
		@param uniformFloats an Array of custom `UniformFloat`s
		@param autoUpdate set it to `true` (update) or `false` (no update), otherwise the `.autoUpdate` property is used
	**/
	public function injectIntoVertexShader(glslCode:String = "", uTimeUniformEnabled = false, uniformFloats:Array<UniformFloat> = null, ?autoUpdate:Null<Bool>):Void {
		uniformFloatsVertex = uniformFloats;
		glShaderConfig.VERTEX_INJECTION = ((uTimeUniformEnabled && !buffer.hasTime()) ? "uniform float uTime;" : "") + generateUniformFloatsGLSL(uniformFloats) + glslCode;
		accumulateUniformsFloat();
		checkAutoUpdate(autoUpdate);
	}

	/**
		Inject custom glsl code into the fragmentshader of a program.
		@param glslCode a String what contains the glsl code
		@param uTimeUniformEnabled if `true` you can use the global `time` uiform
		@param uniformFloats an Array of custom `UniformFloat`s
		@param autoUpdate set it to `true` (update) or `false` (no update), otherwise the `.autoUpdate` property is used
	**/
	public function injectIntoFragmentShader(glslCode:String = "", uTimeUniformEnabled = false, uniformFloats:Array<UniformFloat> = null, ?autoUpdate:Null<Bool>):Void {
		glShaderConfig.hasFRAGMENT_INJECTION = (glslCode == "") ? false : true;
		uniformFloatsFragment = uniformFloats;
		glShaderConfig.FRAGMENT_INJECTION = ((uTimeUniformEnabled) ? "uniform float uTime;" : "") + generateUniformFloatsGLSL(uniformFloats) + glslCode;
		accumulateUniformsFloat();
		checkAutoUpdate(autoUpdate);
	}

	private function generateUniformFloatsGLSL(uniformFloats:Array<UniformFloat>):String {
		var out:String = "";
		if (uniformFloats != null)
			for (u in uniformFloats) out += "uniform float " + u.name + ";";
		return out;
	}

	private function accumulateUniformsFloat() {
		if (uniformFloatsVertex == null) {
			if (uniformFloatsFragment != null) uniformFloats = uniformFloatsFragment;
		}
		else if (uniformFloatsFragment == null) {
			uniformFloats = uniformFloatsVertex;
		}
		else {
			uniformFloats = uniformFloatsVertex;
			for (u in uniformFloatsFragment) {
				if (uniformFloats.indexOf(u) < 0) {
					uniformFloats.push(u);
				}
			}
		}
	}

	/**
		Define formulas to change the calculation for element attributes at runtime
		@param name a String with the attribute identifier
		@param newFormula a String what contains the formula
		@param autoUpdate set it to `true` (update) or `false` (no update), otherwise the `.autoUpdate` property is used
	**/
	public function setFormula(name:String, newFormula:String, ?autoUpdate:Null<Bool>):Void {
		
		var formulaName = buffer.getFormulaNames().get(name); // TODO: better with 2 Arrays here
		
		if (formulaName != null) {
			#if peoteview_debug_program
			trace('  set formula: $formulaName = $newFormula' );
			#end
			formula.set(formulaName, newFormula);
		}
		else {
			if ([ for (k in buffer.getFormulaNames().keys()) buffer.getFormulaNames().get(k) ].indexOf(name) >= 0) {
				formula.set(name, newFormula);
			}
			else if (buffer.getFormulaVaryings().indexOf(name) >= 0) {
				#if peoteview_debug_program
				trace('  set formula for varying: $name = $newFormula' );
				#end
				formula.set(name, newFormula);
			}
			else if (buffer.getFormulaConstants().indexOf(name) >= 0) {
				#if peoteview_debug_program
				trace('  set formula for constant: $name = $newFormula' );
				#end
				formula.set(name, newFormula); // TODO: Error if newFormula contains other attributes
			}
			else if (buffer.getFormulaCustoms().indexOf(name) >= 0) {
				#if peoteview_debug_program
				trace('  set formula for custom: $name = $newFormula' );
				#end
				formula.set(name, newFormula);
			}
			else throw('Error: can not set Formula for $name if there is no property defined for @$name inside Element');
		}
		
		formulaHasChanged = true;
		checkAutoUpdate(autoUpdate);
	}

	// invoked via createProg()
	private function parseAndResolveFormulas():Void {
		if (formulaHasChanged)
		{
			var formulaResolved:StringMap<String> = [for (k in formula.keys()) k => formula.get(k) ];
			try Util.resolveFormulaCyclic(formulaResolved) catch(e:Dynamic) throw ('Error: cyclic reference of "${e.errVar}" inside formula "${e.formula}" for "${e.errKey}"');
			//trace("formula cyclic resolved:"); for (f in formulaResolved.keys()) trace('  $f => ${formulaResolved.get(f)}');
			Util.resolveFormulaVars(formulaResolved, buffer.getAttributes());
			//trace("formula resolved new:"); for (f in formulaResolved.keys()) trace('  $f => ${formulaResolved.get(f)}');
			
			function formulaTemplateValue(x:String, y:String, dx:String, dy:String):String
			{
				var nx = buffer.getFormulaNames().get(x);
				//if (nx == null) nx = x;
				if (nx == null) nx = "";
				
				var ny = buffer.getFormulaNames().get(y);
				//if (ny == null) ny = y;
				if (ny == null) ny = "";
				
				var fx = formulaResolved.get(nx);
				var fy = formulaResolved.get(ny);
				
				if ( fx != buffer.getFormulas().get(nx) || fy != buffer.getFormulas().get(ny) ) {
					if (fx == null) fx = buffer.getAttributes().get(nx);
					if (fx == null) fx = dx;
					
					if (fy == null) fy = buffer.getAttributes().get(ny);
					if (fy == null) fy = dy;
					
					if (x == "rotation" && fx != "0.0") fx = '($fx)/180.0*${Math.PI}';
					if (y == "zIndex" && fy != "0.0") fy = 'clamp( $fy/${Util.toFloatString(buffer.getMaxZindex())}, -1.0, 1.0)';
					
					//trace(' -- replacing Formula $nx, $ny => vec2($fx, $fy)');
					return('vec2($fx, $fy)');
				}
				else return null;
			}
			glShaderConfig.SIZE_FORMULA  = formulaTemplateValue("sizeX"   , "sizeY" ,"100.0", "100.0");
			glShaderConfig.POS_FORMULA   = formulaTemplateValue("posX"    , "posY"  ,  "0.0",   "0.0");
			glShaderConfig.ROTZ_FORMULA  = formulaTemplateValue("rotation", "zIndex",  "0.0",   "0.0");
			glShaderConfig.PIVOT_FORMULA = formulaTemplateValue("pivotX"  , "pivotY",  "0.0",   "0.0");
			
			// formulas for varyings
			for (n in buffer.getFormulaVaryings()) {				
				var f = formulaResolved.get(n);
				if ( f != buffer.getFormulas().get(n) )
				{
					if (f == null) f = buffer.getAttributes().get(n);
					Reflect.setField(glShaderConfig.FORMULA_VARYINGS, n, f);
					// trace(' -- replacing Formula $n => $f');
				}
				else Reflect.setField(glShaderConfig.FORMULA_VARYINGS, n, null);
			}
			// formulas for constants
			for (n in buffer.getFormulaConstants()) {				
				var f = formulaResolved.get(n);
				if ( f != null && f != buffer.getAttributes().get(n) )
				{
					Reflect.setField(glShaderConfig.FORMULA_CONSTANTS, n, f);
					// trace(' -- replacing Formula $n => $f');
				}
				else Reflect.setField(glShaderConfig.FORMULA_CONSTANTS, n, null);		
			}
		}
	}

	private function getTextureIndexByIdentifier(identifier:String, addNew:Bool = true):Int {
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

	private function validatePrecision(precision:Null<String>):Null<String> {
		if (precision != null) {
			if (["low", "medium", "high"].indexOf(precision.toLowerCase()) < 0) {
				if (["lowp", "mediump", "highp"].indexOf(precision.toLowerCase()) < 0)
					throw("Error, no valid precision format. Use 'low', 'medium' or 'high' (or leave it null for default)");
			}
			else precision += "p";
		}
		return precision;
	}

	/**
		Set the float precision for the fragmentshader
		@param precision a String what can be "low", "medium" or "high"
		@param autoUpdate set it to `true` (update) or `false` (no update), otherwise the `.autoUpdate` property is used
	**/
	public function setFragmentFloatPrecision(?precision:Null<String>, ?autoUpdate:Null<Bool>) {
		fragmentFloatPrecision =  PeoteGL.Precision.availFragmentFloat(validatePrecision(precision)); // template is set in createProgram
		checkAutoUpdate(autoUpdate);
	}

	/**
		Set the integer precision for the fragmentshader
		@param precision a String what can be "low", "medium" or "high"
		@param autoUpdate set it to `true` (update) or `false` (no update), otherwise the `.autoUpdate` property is used
	**/
	public function setFragmentIntPrecision(?precision:Null<String>, ?autoUpdate:Null<Bool>) {
		glShaderConfig.FRAGMENT_INT_PRECISION =  PeoteGL.Precision.availFragmentInt(validatePrecision(precision));
		checkAutoUpdate(autoUpdate);
	}

	/**
		Set the sampler2D precision for the fragmentshader
		@param precision a String what can be "low", "medium" or "high"
		@param autoUpdate set it to `true` (update) or `false` (no update), otherwise the `.autoUpdate` property is used
	**/
	public function setFragmentSamplerPrecision(?precision:Null<String>, ?autoUpdate:Null<Bool>) {
		glShaderConfig.FRAGMENT_SAMPLER_PRECISION =  PeoteGL.Precision.availFragmentSampler(validatePrecision(precision));
		checkAutoUpdate(autoUpdate);
	}

	/**
		Set the float precision for the vertexShader
		@param precision a String what can be "low", "medium" or "high"
		@param autoUpdate set it to `true` (update) or `false` (no update), otherwise the `.autoUpdate` property is used
	**/
	public function setVertexFloatPrecision(?precision:Null<String>, ?autoUpdate:Null<Bool>) {
		glShaderConfig.VERTEX_FLOAT_PRECISION =  PeoteGL.Precision.availVertexFloat(validatePrecision(precision));
		checkAutoUpdate(autoUpdate);
	}

	/**
		Set the integer precision for the vertexShader
		@param precision a String what can be "low", "medium" or "high"
		@param autoUpdate set it to `true` (update) or `false` (no update), otherwise the `.autoUpdate` property is used
	**/
	public function setVertexIntPrecision(?precision:Null<String>, ?autoUpdate:Null<Bool>) {
		glShaderConfig.VERTEX_INT_PRECISION = PeoteGL.Precision.availVertexInt(validatePrecision(precision));
		checkAutoUpdate(autoUpdate);
	}

	/**
		Set the sampler2D precision for the vertexShader
		@param precision a String what can be "low", "medium" or "high"
		@param autoUpdate set it to `true` (update) or `false` (no update), otherwise the `.autoUpdate` property is used
	**/
	public function setVertexSamplerPrecision(?precision:Null<String>, ?autoUpdate:Null<Bool>) {
		glShaderConfig.VERTEX_SAMPLER_PRECISION = PeoteGL.Precision.availVertexSampler(validatePrecision(precision));
		checkAutoUpdate(autoUpdate);
	}

	/**
		Activate pixelsnapping
		@param pixelDivisor a Float multiplicator at which snapping is to take place, set it to `null` to disable pixelsnapping
		@param autoUpdate set it to `true` (update) or `false` (no update), otherwise the `.autoUpdate` property is used
	**/
	public function snapToPixel(?pixelDivisor:Null<Float>, ?autoUpdate:Null<Bool>) {
		if (pixelDivisor == null) {
			glShaderConfig.isPIXELSNAPPING = false;
		}
		else {
			glShaderConfig.isPIXELSNAPPING = true;
			glShaderConfig.PIXELDIVISOR = Util.toFloatString(1/pixelDivisor);
		}
		checkAutoUpdate(autoUpdate);
	}

	/**
		From which alpha value the pixels are discarded.
		@param atAlphaValue a Float value for the alpha limit (`0.0` to `1.0`), set it to `null` to disable discarding
		@param autoUpdate set it to `true` (update) or `false` (no update), otherwise the `.autoUpdate` property is used
	**/
	public function discardAtAlpha(?atAlphaValue:Null<Float>, ?autoUpdate:Null<Bool>) {
		if (atAlphaValue == null) {
			glShaderConfig.isDISCARD = false;
		}
		else {
			glShaderConfig.isDISCARD = true;
			glShaderConfig.DISCARD = Util.toFloatString(atAlphaValue);
		}
		checkAutoUpdate(autoUpdate);
	}

	/**
		Assign a `Texture` instance to a texture-layer (by identifier).
		@param texture Texture instance
		@param identifier texture-layer identifier (optional) - without it, the first available or "default" is used
		@param autoUpdate set it to `true` (update) or `false` (no update), otherwise the `.autoUpdate` property is used
	**/
	public function setTexture(texture:Texture, ?identifier:String, ?autoUpdate:Null<Bool>):Void {
		if (texture == null) throw("Error, texture is null.");
		if (texture.programs == null) throw("Error, texture is disposed.");
		if (identifier == null) {
			if (textureIdentifiers.length > 0) identifier = textureIdentifiers[0];
			else if (customTextureIdentifiers.length > 0) identifier = customTextureIdentifiers[0];
			else identifier = "default";
		}
		#if peoteview_debug_program
		trace('(re)set texture of layer: $identifier');
		#end
		var layer = getTextureIndexByIdentifier(identifier);
		textureLayers.set(layer, [texture]);
		_updateTexture = true;
		checkAutoUpdate(autoUpdate);
	}

	/**
		Assign multiple `Texture` instances to a texture-layer (by identifier). Can switch between them by using an `@texUnit("identifier")` integer attribute inside the Element.
		@param textureUnits an Array of Texture instances
		@param identifier texture-layer identifier (optional) - without it, the first available or "default" is used
		@param autoUpdate set it to `true` (update) or `false` (no update), otherwise the `.autoUpdate` property is used
	**/
	public function setMultiTexture(textureUnits:Array<Texture>, ?identifier:String, ?autoUpdate:Null<Bool>):Void {
		if (identifier == null) {
			if (textureIdentifiers.length > 0) identifier = textureIdentifiers[0];
			else if (customTextureIdentifiers.length > 0) identifier = customTextureIdentifiers[0];
			else identifier = "default";
		}
		#if peoteview_debug_program
		trace('(re)set texture-units of layer: $identifier');
		#end
		var layer = getTextureIndexByIdentifier(identifier);
		if (textureUnits == null) throw("Error, textureUnits need to be an array of textures");
		if (textureUnits.length == 0) throw("Error, textureUnits needs at least 1 texture");
		var i = textureUnits.length;
		while (i-- > 0) {
			if (textureUnits[i] == null) throw('Error, texture $i is null.');
			if (textureUnits[i].programs == null) throw('Error, texture $i is disposed.');
			if (textureUnits.indexOf(textureUnits[i]) != i) throw("Error, textureLayer can not contain same texture twice.");
		}
		textureLayers.set(layer, textureUnits);
		_updateTexture = true;
		checkAutoUpdate(autoUpdate);
	}

	/**
		Adds a `Texture` to a texture-layer (by identifier). Can switch between them by using an `@texUnit("identifier")` integer attribute inside the Element.
		@param texture Texture instance
		@param identifier texture-layer identifier (optional) - without it, the first available or "default" is used
		@param autoUpdate set it to `true` (update) or `false` (no update), otherwise the `.autoUpdate` property is used
	**/
	public function addTexture(texture:Texture, ?identifier:String, ?autoUpdate:Null<Bool>):Void {
		if (texture == null) throw("Error, texture is null.");
		if (texture.programs == null) throw("Error, texture is disposed.");
		if (identifier == null) {
			if (textureIdentifiers.length > 0) identifier = textureIdentifiers[0];
			else if (customTextureIdentifiers.length > 0) identifier = customTextureIdentifiers[0];
			else identifier = "default";
		}
		#if peoteview_debug_program
		trace('add texture to the units of layer: $identifier');
		#end
		var layer = getTextureIndexByIdentifier(identifier);
		var textures:Array<Texture> = textureLayers.get(layer);
		if (textures != null) {
			if (textures.indexOf(texture) >= 0) throw("Error, textureLayer already contains this texture.");
			else {
				textures.push(texture);
				textureLayers.set(layer, textures);
			}
		}
		else textureLayers.set(layer, [texture]);
		_updateTexture = true;
		checkAutoUpdate(autoUpdate);
	}

	/**
		Removes a `Texture` from a texture-layer (by identifier) or from all layers where it is used.
		@param texture Texture instance
		@param identifier texture-layer identifier (optional)
		@param autoUpdate set it to `true` (update) or `false` (no update), otherwise the `.autoUpdate` property is used
	**/
	public function removeTexture(texture:Texture, ?identifier:String, ?autoUpdate:Null<Bool>):Void {
		if (texture == null) throw("Error, texture is null.");
		if (texture.programs == null) throw("Error, texture is disposed.");
		if (identifier == null) {
			#if peoteview_debug_program
			trace("remove texture from units of all layers");
			#end
			for (layer in textureLayers.keys()) {
				textureLayers.get(layer).remove(texture);
				if (textureLayers.get(layer).length == 0) {
					textureLayers.remove(layer);
					// CHECK: this ever called here?
					customTextureIdentifiers.remove(identifier);
				}
			}
		}
		else {
			#if peoteview_debug_program
			trace('remove texture from unit of layer: $identifier');
			#end
			var layer = getTextureIndexByIdentifier(identifier, false);
			if (layer < 0) throw('Error, textureLayer "$identifier" did not exists.');
			textureLayers.get(layer).remove(texture);
			if (textureLayers.get(layer).length == 0) {
				textureLayers.remove(layer);
				// TO keep the textureLayers-MAP <-> ARRAY-customTextureIdentifiers
				// this can not be removed here:
				// customTextureIdentifiers.remove(identifier);
				// TODO: better another removeTextureLayer() later!
			}
		}
		_updateTexture = true;
		checkAutoUpdate(autoUpdate);
	}

	/**
		Removes all `Texture`s of a texture-layer (by identifier) or removes all textures from all layers.
		@param identifier texture-layer identifier (optional)
		@param autoUpdate set it to `true` (update) or `false` (no update), otherwise the `.autoUpdate` property is used
	**/
	public function removeAllTexture(?identifier:String, ?autoUpdate:Null<Bool>):Void {
		if (identifier == null) {
			#if peoteview_debug_program
			trace("remove all textures from all layers");
			#end
			for (layer in textureLayers.keys()) {
				textureLayers.remove(layer);
			}
			customTextureIdentifiers = [];
		}
		else {
			#if peoteview_debug_program
			trace('remove all textures from layer $identifier');
			#end
			var layer = getTextureIndexByIdentifier(identifier, false);
			if (layer < 0) throw('Error, textureLayer "$identifier" did not exists.');
			textureLayers.remove(layer);
			customTextureIdentifiers.remove(identifier);
		}
		_updateTexture = true;
		checkAutoUpdate(autoUpdate);
	}

	private inline function checkAutoUpdate(autoUpdate:Null<Bool>) {
		if (autoUpdate != null) { if (autoUpdate) update(); }
		else if (this.autoUpdate) update();
	}

	// TODO: replaceTexture(textureToReplace:Texture, newTexture:Texture)

	/**
		Returns `true` if the program or a specific texture-layer contains a texture.
		@param texture Texture instance
		@param identifier texture-layer identifier, if set to `null` it searches into all texture-layers
	**/
	public function hasTexture(texture:Texture, ?identifier:String):Bool
	{
		if (texture == null) throw("Error, texture is null.");
		if (identifier == null) {
			for (t in activeTextures) if (t == texture) return true;
		}
		else {
			var textures = textureLayers.get(getTextureIndexByIdentifier(identifier, false));
			if (textures != null && textures.indexOf(texture) >= 0 ) return true;
		}
		return false;
	}

	/**
		Updates the shader templates and recompiles the shader.
	**/
	public function update():Void {

		if (_updateTexture) 
		{
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
			
			#if peoteview_debug_program
			trace("textureLayers", [for (layer in textureLayers.keys()) layer]);
			#end
		}

		if (_updateTexture || _updateColorFormula)
		{	
			parseColorFormula();
			
			glShaderConfig.FRAGMENT_PROGRAM_UNIFORMS = "";
			glShaderConfig.TEXTURES = [];
			
			if (activeTextures.length == 0) {
				glShaderConfig.hasTEXTURES = false;
			}
			else {
				glShaderConfig.hasTEXTURES = true;
				
				for (i in 0...activeTextures.length)
					glShaderConfig.FRAGMENT_PROGRAM_UNIFORMS += 'uniform sampler2D uTexture$i;';
				
				// fill texture-layer in template
				for (layer in textureLayers.keys())
				{
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
					
					// TODO: issue here e.g. if layer key is 1 after remove the key 0
					var used:Bool = ((used_by_ColorFormula & (1 << layer) ) > 0);
					var usedID:Bool = ((usedID_by_ColorFormula & (1 << layer) ) > 0);
					
					glShaderConfig.TEXTURES.push({
						LAYER:layer,
						UNITS:units,
						USED: used,
						USED_ID: usedID					
					});
				}			
			}
			
			// fill template for non-added textures to fetch default values
			glShaderConfig.TEXTURE_DEFAULTS = [];
			for (defaults in textureID_Defaults) {
				glShaderConfig.TEXTURE_DEFAULTS.push({LAYER:defaults.layer, DEFAULT_VALUE:defaults.value});
			}
			glShaderConfig.hasTEXTURE_FUNCTIONS = (usedID_by_ColorFormula == 0 && textureID_Defaults.length == 0) ? false : true;
		}

		if (gl != null) reCreateProgram(); // recompile shaders
		_updateTexture = false;
		_updateColorFormula = false;
	}

	/**
		To set the opengl index manually if using multiple textures.
		@param texture Texture instance
		@param index Integer value for the index (starts by `0`)
	**/
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
				if (textureListItem.value.texture.framebuffer == null) trace("activate Texture", textureListItem.value.unit);
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
		if (isVisible)
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
			for (i in 0...uniformFloats.length) gl.uniform1f (uniformFloatLocations[i], uniformFloats[i].value);
			
			peoteView.setColor(colorEnabled);
			peoteView.setGLDepth(zIndexEnabled);			
			peoteView.setGLBlend(blendEnabled, blendSeparate, glBlendSrc, glBlendDst, glBlendSrcAlpha, glBlendDstAlpha, blendFuncSeparate, glBlendFunc, glBlendFuncAlpha, blendColor, useBlendColor, useBlendColorSeparate, glBlendR, glBlendG, glBlendB, glBlendA);			
			peoteView.setMask(mask, clearMask);
			
			buffer.render(peoteView, display, this);
			gl.useProgram (null);
		}
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
			
			// TODO: check if peoteViews offset have to be here!
			gl.uniform2f (uOFFSET, (display.xOffset + peoteView.xOffset) / display.xz, 
			                       (display.yOffset + peoteView.yOffset - display.height) / display.yz );
		}
		
		gl.uniform1f (uTIME, peoteView.time);
		for (i in 0...uniformFloats.length) gl.uniform1f (uniformFloatLocations[i], uniformFloats[i].value);
		
		peoteView.setColor(colorEnabled);
		peoteView.setGLDepth(zIndexEnabled);		
		peoteView.setGLBlend(blendEnabled, blendSeparate, glBlendSrc, glBlendDst, glBlendSrcAlpha, glBlendDstAlpha, blendFuncSeparate, glBlendFunc, glBlendFuncAlpha, blendColor, useBlendColor, useBlendColorSeparate, glBlendR, glBlendG, glBlendB, glBlendA);		
		peoteView.setMask(mask, clearMask);
		
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
		for (i in 0...uniformFloats.length) gl.uniform1f (uniformFloatPickLocations[i], uniformFloats[i].value);
		
		peoteView.setGLDepth((toElement == -1) ? zIndexEnabled : false); // disable for getAllElementsAt() in peoteView
		
		//peoteView.setGLAlpha(false);
		peoteView.setGLBlend(false, blendSeparate, glBlendSrc, glBlendDst, glBlendSrcAlpha, glBlendDstAlpha, blendFuncSeparate, glBlendFunc, glBlendFuncAlpha, blendColor, useBlendColor, useBlendColorSeparate, glBlendR, glBlendG, glBlendB, glBlendA);
				
		buffer.pick(peoteView, display, this, toElement);
		gl.useProgram (null);		
	}

}



// helper type
private class ActiveTexture
{
	public var unit:Int;
	public var texture:Texture;
	public var uniformLoc:GLUniformLocation;
	public function new(unit:Int, texture:Texture, uniformLoc:GLUniformLocation) {
		this.unit = unit;
		this.texture = texture;
		this.uniformLoc = uniformLoc;
	}
}