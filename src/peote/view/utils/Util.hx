package peote.view.utils;

import haxe.ds.StringMap;

class Util 
{

	static inline public function camelCase(a:String, b:String):String return a + b.substr(0, 1).toUpperCase() + b.substr(1);
	
	static inline public function toFloatString(value:Dynamic):String {
		var s:String = Std.string(value);
		return (s.indexOf(".") != -1 || s.indexOf("e-") != -1) ? s : s + ".0";
	}
	
	static inline public function color2vec4(c:UInt):String {
		return 'vec4(${toFloatString(((c & 0xFF000000)>>24)/255)}, ${toFloatString(((c & 0x00FF0000)>>16)/255)},' + 
		            ' ${toFloatString(((c & 0x0000FF00)>>8)/255)}, ${toFloatString((c & 0x000000FF)/255)})';
	}
	
	//static var glslKeywords = "attribute uniform varying layout centroid flat smooth noperspective patch sample subroutine in out inout invariant discard mat2 mat3 mat4 dmat2 dmat3 dmat4 mat2x2 mat2x3 mat2x4 dmat2x2 dmat2x3 dmat2x4 mat3x2 mat3x3 mat3x4 dmat3x2 dmat3x3 dmat3x4 mat4x2 mat4x3 mat4x4 dmat4x2 dmat4x3 dmat4x4 vec2 vec3 vec4 ivec2 ivec3 ivec4 bvec2 bvec3 bvec4 dvec2 dvec3 dvec4 uvec2 uvec3 uvec4 lowp mediump highp precision sampler1D sampler2D sampler3D samplerCube sampler1DShadow sampler2DShadow samplerCubeShadow sampler1DArray sampler2DArray sampler1DArrayShadow sampler2DArrayShadow isampler1D isampler2D isampler3D isamplerCube isampler1DArray isampler2DArray usampler1D usampler2D usampler3D usamplerCube usampler1DArray usampler2DArray sampler2DRect sampler2DRectShadow isampler2DRect usampler2DRect samplerBuffer isamplerBuffer usamplerBuffer sampler2DMS isampler2DMS usampler2DMS sampler2DMSArray isampler2DMSArray usampler2DMSArray samplerCubeArray samplerCubeArrayShadow isamplerCubeArray usamplerCubeArray".split(" ");
	static inline public function isWrongIdentifier(identifier:String):Bool {
		var regexp:EReg = ~/^([a-zA-z_]+\d*)+$/g;
		return( ! regexp.match(identifier) );
	}
	
	static public function resolveFormulaCyclic(formulas:StringMap<String>) {
		var resolved = new Array<String>();
		for (k in formulas.keys())
		{
			var err = resolveFormulaKey(k, formulas, resolved);
			if (err.errKey != null) throw(err);
			//trace("---");
		}
		for (k in formulas.keys()) {
			formulas.set( k, new EReg('___:::___', "g").replace( formulas.get(k), "" ) );
		}
	}
	
	static function resolveFormulaKey(key:String, formulas:StringMap<String>, resolved:Array<String>, ?fromKeys:Array<String>):{formula:String, errKey:String, errVar:String} {
		if (fromKeys == null) fromKeys = [key];
		if (resolved == null) resolved = [];
		
		var formula = formulas.get(key);
		if (resolved.indexOf(key) >= 0) return {formula:formula, errKey:null, errVar:null};
		//trace("RESOLVE:",fromKeys,key);
		
		for (k in formulas.keys()) if ( k != key ) 
		{
				var regexp = new EReg('(.*?\\b)$k(\\b.*?)', "g");
				if (regexp.match(formula) && (regexp.matched(1).substr(-1) != "."))
				{
					if (fromKeys.indexOf(k) >= 0) return {formula:formula, errKey:key, errVar:k}; // cyclic error
					
					var f = resolveFormulaKey(k, formulas, resolved, fromKeys.concat([k])); // < -- recursion
					if (f.errKey != null) return f; // cyclic error inside

					formula = regexp.replace( formula, '$1(___:::___' + f.formula +'___:::___)$2' );
				}
		}

		formulas.set(key, formula);
		resolved.push(key);
		return {formula:formula, errKey:null, errVar:null};
	}
	
	static public function resolveFormulaVars(formulas:StringMap<String>, attribs:StringMap<String>) {
		for (key in formulas.keys()) {
			var formula = formulas.get(key);
			for (k in attribs.keys()) {
				var regexp = new EReg('(.*?\\b)$k(\\b.*?)', "g");
				if (regexp.match(formula) && (regexp.matched(1).substr(-1) != "."))
					formula = regexp.replace( formula, '$1(' + attribs.get(k) + ')$2' );
			}
			formulas.set(key, formula);
		}
	}
	
}