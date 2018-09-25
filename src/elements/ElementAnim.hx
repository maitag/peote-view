package elements;

import peote.view.Element;

class ElementAnim implements Element
{
	@posX @time("Position") //@set("PosSize") //@anim("Position") //@constStart(10) @constEnd(100)
	public var x:Int=0;
	@posY @time("Position") // @constEnd(100) @constStart(170) 
	public var y:Int=0;
	/*
	@sizeX @anim("Size") @time("Size") public var w:Int; //@constStart(300) @constEnd(400) 
	@sizeY @anim("Size") @time("Size") public var h:Int; //@constEnd(200)
	*/
	// TODO: generate by macro if not exist
	public function new()
	{
	}

}
