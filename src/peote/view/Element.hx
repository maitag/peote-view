package peote.view;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;

@:remove @:autoBuild(peote.view.ElementImpl.build())
interface Element {}

class ElementImpl
{
#if macro

	public static function hasMeta(f:Field, s:String):Bool {for (m in f.meta) { if (m.name == s || m.name == ':$s') return true; } return false; }
		
	public static function build()
	{
		var hasNoNew:Bool = true;
		
		
		var classname = Context.getLocalClass().get().name;
		var classpackage = Context.getLocalClass().get().pack;
		
		trace("--------------- " + classname + " -------------------");
		
		// trace(Context.getLocalClass().get().superClass); 
		trace("TODO: autogenerate shaders and buffering");
		
// { module => elements.ElementSimpleChild, init => null, kind => KNormal,
// meta => { ??? => #function:1, add => #function:3, get => #function:0, has => #function:1, remove => #function:1 }, 
// name => ElementSimpleChild, pack => [elements], interfaces => [], params => [], __t => #abstract, doc => null,
// fields => class fields, isPrivate => false, constructor => null, isInterface => false, isExtern => false,
// superClass => { params => [], t => elements.ElementSimple }, exclude => #function:0, statics => class fields, overrides => [] }

		
		var fields = Context.getBuildFields();
		
		
		for (f in fields)
		{
			
			if (f.name == "new") {
				hasNoNew = false;
			}
			else if ( hasMeta(f, "attribute") )
			{
				switch (f.kind)
				{
					case FVar(t): trace("attribute:",f.name ); // t: TPath({ name => Int, pack => [], params => [] })

					default: throw Context.error('Error: attribute has to be an variable.', f.pos);
				}
				
			}
		}		
		
		return fields;
		
	}

#end
}