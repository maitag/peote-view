package elements;

import peote.view.Element;

class ElementAnim implements Element
{
	@posX @set("PosSize") //@time("Position") @anim("Position") //@constStart(0) @constEnd(100)
	public var x:Int=0;
	@posY @set("PosSize") @time("Position") @anim("Position") //@constStart(0) @constEnd(100) 
	public var y:Int=0;
	
	@sizeX @set("PosSize") @anim("Size") @time("Size") public var w:Int; //@constStart(300) @constEnd(400) 
	@sizeY@set("PosSize") @anim("Size") @time("Size") public var h:Int; //@constEnd(200)
	
	// TODO: generate by macro if not exist
	public function new()
	{
	}

}
