package peote.view.utils;

@:generic
class RenderList<T>
{
	public var first(default, null):RenderListItem<T> = null; // first value in list
	public var last(default, null) :RenderListItem<T> = null; // last value in list
	
	public var itemMap:Map<T,RenderListItem<T>>;
	
	public var isEmpty(get, never):Bool;
	inline function get_isEmpty():Bool return first == null;
	
	public function new(itemMap:Map<T,RenderListItem<T>>) 
	{
		this.itemMap = itemMap;
	}
	
	public function add(value:T, atValue:T, addBefore:Bool)
	{	
		var newItem:RenderListItem<T> = null;
		
		if (addBefore) // add before element or at start of list
		{
			if (first == null) newItem = first = last = new RenderListItem<T>(value, null, null);
			else
			{
				if (atValue == null) {
					newItem = first = new RenderListItem<T>(value, null, first);
				} else {
					var atItem = itemMap.get(atValue);
					if (atItem != null) {						
						newItem = new RenderListItem<T>(value, atItem.prev, atItem);
						if (atItem == first) first = newItem;
					}
					else throw('Error on add: $atValue is not in list.');
				}			
			}
		}
		else  // add after element or at end of list
		{
			if (last == null) newItem = first = last = new RenderListItem<T>(value, null, null);
			else
			{
				if (atValue == null) {
					newItem = last = new RenderListItem<T>(value, last, null);
				} else {
					var atItem = itemMap.get(atValue);
					if (atItem != null) {						
						newItem = new RenderListItem<T>(value, atItem, atItem.next);
						if (atItem == last) last = newItem;
					}
					else throw('Error on add: $atValue is not in list.');
				}
			}			
		}
		
		// override if value already inside List
		var oldItem:RenderListItem<T> = itemMap.get(value);
		if (oldItem != null) removeItem(oldItem);
		itemMap.set(value, newItem);
	} 
	
	public function remove(value:T):Void
	{
		var item:RenderListItem<T> = itemMap.get(value);
		if (item != null) {
			itemMap.remove(value);
			removeItem(item);
		}
		else throw('Error on remove: $value is not in list.');
	}
	
	private inline function removeItem(item:RenderListItem<T>):Void {
		if (item == first) first = item.next;
		if (item == last ) last  = item.prev;
		item.unlink(); // remove if already exist
		item = null;
	}
	
	public function clear():Void
	{
		while (first != null) {
			if (last.value != null) itemMap.remove(last.value);
			removeItem(last);
		}		
	}
	
	
	/**
		Returns an iterator on the elements of the list.
	**/
	public inline function iterator() : RenderListIterator<T> {
		return new RenderListIterator<T>(first);
	}

}

//#if !hl @:generic#end
@:generic
private class RenderListIterator<T> {
	var item:RenderListItem<T>;
	public inline function new(first:RenderListItem<T>) item = first;
	public inline function hasNext():Bool return item != null;
	public inline function next():T {
		var value = item.value;
		item = item.next;
		return value;
	}
}
