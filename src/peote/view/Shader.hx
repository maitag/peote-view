package peote.view;

class Shader 
{
	// -------------------------- VERTEX SHADER TEMPLATE --------------------------------	
	@:allow(peote.view) static var vertexShader(default, null):String =
	
	
	"
	::if isES3::#version 300 es::end::
	
	// Uniforms -------------------------
	::if isUBO::
	layout(std140) uniform uboView
	{
		vec2 uResolution;
		vec2 uViewOffset;
		float uViewZoom;
	};
	layout(std140) uniform uboDisplay
	{
		vec2 uOffset;
		float uZoom;
	};
	::else::
	uniform vec2 uResolution;
	uniform vec2 uOffset;
	uniform float uZoom;
	::end::
	
	// Attributes -------------------------
	::IN:: vec2 aPosition;
	::IN:: vec2 aPos;
	::IN:: vec2 aSize;
	//aElement
	//aTexCoord
	//aTile
	//aZindex
	//aRotation (+pivot)
	//aColor
	//aTime
	
	//aCustom0
	
	
	// custom Attributes ------------------

	// PICKING  ::if isES3:: flat out int instanceID; ::end::
	
	void main(void) {
		vec2 position = aPos + (aPosition * aSize);

		// PICKING instanceID = gl_InstanceID;
		
		float zoom = uZoom ::if isUBO:: * uViewZoom ::end::;
		float width = uResolution.x;
		float height = uResolution.y;
		::if isUBO::
		float deltaX = (uOffset.x  + uViewOffset.x) / uZoom;
		float deltaY = (uOffset.y  + uViewOffset.y) / uZoom;
		::else::
		float deltaX = uOffset.x;
		float deltaY = uOffset.y;
		::end::
		
		float right = width-deltaX*zoom;
		float left = -deltaX*zoom;
		float bottom = height-deltaY*zoom;
		float top = -deltaY * zoom;
			
		gl_Position = mat4 (
			vec4(2.0 / (right - left)*zoom, 0.0, 0.0, 0.0),
			vec4(0.0, 2.0 / (top - bottom)*zoom, 0.0, 0.0),
			vec4(0.0, 0.0, -1.0, 0.0),
			vec4(-(right + left) / (right - left), -(top + bottom) / (top - bottom), 0.0, 1.0)
		)
		* vec4 (position ,
			0.0
			, 1.0
			);
	}
	";
	
	
	
	// ------------------------ FRAGMENT SHADER TEMPLATE --------------------------------	
	@:allow(peote.view) static var fragmentShader(default, null):String =	

	
	"
	::if isES3::#version 300 es::end::
	
    precision highp float;
	
	::if isES3::
	flat in int instanceID;
	out vec4 color;
	// PICKING out int color;
	::end::

	
	void main(void)
	{	
		::if isES3::color::else::gl_FragColor::end:: = vec4 (1.0, 0.0, 0.0, 1.0);
		// PICKING ::if isES3::color::else::gl_FragColor::end:: =  instanceID*50;
	}
	";

	
	
	
	
}