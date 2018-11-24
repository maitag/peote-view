package peote.view.utils;

@:generic
class RenderListItem<T>
{
	public var value(default,null):T;
	public var next(default,null):RenderListItem<T>;
	public var prev(default,null):RenderListItem<T>;
	public inline function new(value:T, prev:RenderListItem<T>, next:RenderListItem<T>) 
	{
		this.value = value;
		this.next = next;
		this.prev = prev;
		if (prev != null) prev.next = this;
		if (next != null) next.prev = this;		
	}
	public inline function unlink()
	{
		if (prev != null) prev.next = next;
		if (next != null) next.prev = prev;		
	}
}