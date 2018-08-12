package elements;
import peote.view.Element;

class ElementSimpleChild extends ElementSimple
{
	public static var vertexShader:String = "vshader";

	@attribute public var z:Int;
	
	public function new(id:Int=-1) 
	{
		super(id);
		
	}
	
}