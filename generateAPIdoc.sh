haxe -xml doc/api/doc.xml \
	-cp src -lib lime -lib format -lib vision -D doc-gen \
	--no-output -neko dummy.n \
	peote.view.PeoteView peote.view.Buffer peote.view.TextureCache peote.view.Program peote.view.Load peote.view.text.TextProgram

haxelib run dox \
	-i doc/api/doc.xml \
	-D source-path https://github.com/maitag/peote-view/blob/master/src/ \
	--keep-field-order \
	-o doc/api \
	--toplevel-package peote.view \
	-in "^peote\.view\.(PeoteView|Display|Program|Buffer|Texture|TextureData|TextureDataImpl|TextureFormat|TextureConfig|TextureCache|Color|Load|Mask|UniformFloat|BlendFactor|BlendFunc|text|text\.BMFont|text\.BMFontData|text\.Text|text\.TextProgram|text\.TextOptions)$" \

rm doc/api/doc.xml

# put ".label-inline { display:none; }" inside style.css to make it better readable!