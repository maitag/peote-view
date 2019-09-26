package utils;


@:forward
abstract VArrayItem<T>(Array<T>) from Array<T> to Array<T>
{
    public function new() {
        this = new Array<T>();
    }
    
    @:from
    public static function fromOther<T>(a:T):VArrayItem<T> {
        return [a];
    }
   
    @:from
    public static function fromArrayVArrayItem<T>(av:Array<VArrayItem<T>>):VArrayItem<T> {
        var vArrayItem = new VArrayItem<T>();
        for (v in av) {
			for (item in v) 
				vArrayItem.push(item);
    	}
        return vArrayItem;
    }

    @:from
    public static function fromArray<T>(aa:Array<T>):VArrayItem<T> {
        var vArrayItem = new VArrayItem<T>();
        for (a in aa) {
        	vArrayItem.push(a);
    	}
        return vArrayItem;
    }



}

@:forward
abstract NestedArray<T>(Array<VArrayItem<T>>) from Array<VArrayItem<T>> to Array<VArrayItem<T>>
{
    public function new() {
        this = new Array<VArrayItem<T>>();
    }
    
/*	public static function test()
    {
        var a:VArray<Int> = [3, 4];
        var b:VArray<Int> = [ [5, 6], 7 ];
        b.push(8);
		var c = [9, 10];
        var d:VArray<Int> = [ 1, [2], a, b, c ];
        for (item in d) trace(item);
        
		var e:Array<Int> = d;
		trace(e);
    }
*/	
	@:to
	public function toArray<T>():Array<T> {
		var a = new Array<T>();
		for (item in this) for (v in item) a.push(v);
		return a;
	}
	
	
}

