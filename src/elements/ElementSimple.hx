package elements;

import peote.view.Element;

class ElementSimple implements Element
{
	@positionX @const public var x:Int=0; // signed 2 bytes integer
	@positionY  public var y:Int=0; // signed 2 bytes integer
	@positionZ  public var z:Int=0; // signed 2 bytes integer
	@width @const public var w:Int=100;
	@height public var h:Int=100;
	@color  public var c:Int = 0x000000;  // unsigned 4 bytes integer
	@attribute public var a:Float;
	/*
	@positionX  public var x:Array<Int>=[0,0]; // signed 2 bytes integer
	@positionY  public var y:Int=0; // signed 2 bytes integer
	@timesteps  public var t:Array<Int>;
	*/
	
	
	public function new(positionX:Int=0, positionY:Int=0, width:Int=100, height:Int=100 )
	{
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
	}


}
