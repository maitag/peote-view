package;

import utils.MultipassTemplate;

/**
 * testing the Template.hx modifications
 */
class TestMultipassTemplate extends lime.app.Application
{

	public var context1 = {
		flag2: false,
		msg1: "hello",
	};

	public var context2 = {
		a:5,
		b:2,
		flag1: true,
		msg2: "world",
		flag3: true,
		pi:3.14,
		attributes: [ {name:"color", type:"uint", a:1.23}, {name:"custom", type:"float", a:42} ],
	};

	public function new() {
		super();
		try {
			var firstPass = new MultipassTemplate(tmpl).execute(context1);
			trace("first Pass:\n" + firstPass);
			var secondPass = new MultipassTemplate(firstPass).execute(context2);
			trace("second Pass:\n" + secondPass);
		} catch (err:Dynamic) {trace(err);}
		
	}
	
	public var tmpl =
	'
	::(a + b )::
	
	::if flag1::
		The  Message is ::msg1:: ::msg2::
		::if (msg2=="world"):: it is ::end:: 
		::if flag2::
			Flag 2 is true
		::elseif flag3::
	        Flag 3 is true
			Pi = ::pi::
		::else::
			The value of a is ::a::.
		::end::
	::end::
	
	::foreach attributes::
		name = ::name::, type = ::type::, a = ::a::
	::end::
	';
}