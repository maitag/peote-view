package elements;
import peote.view.Element;

class ElementSimpleChildChild extends ElementSimpleChild
{
	public static var vertexShader:String = "vshader";

	@attribute public var color:Int;
	
	public function new(id:Int=-1) 
	{
		super(id);
		
	}
	
}