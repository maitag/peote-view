package peote.view.intern;

import haxe.ds.Vector;

/**
A BufferIterator can be used in `for (element in new BufferIterator<T>(buffer.elements, 0, buffer.length) )` loops to iterate over all elements into a `Buffer`.
**/
@:generic
class BufferIterator<T> 
{
	var elements:Vector<T>;
	var i:Int;
	var to:Int;

	/**
		Creates a new `BufferIterator<T>` instance.
		@param elements the elements vector of a buffer (e.g. buffer.elements)
		@param from iteration start value
		@param to iteration end value (e.g. buffer.length)
	**/
	public inline function new(elements:Vector<T>, from:Int, to:Int) {
		this.elements = elements;
		i = from;
		this.to = to;
	}

	public inline function next():T
		return elements.get(i++);

	public inline function hasNext():Bool
		return (i < to);	
}