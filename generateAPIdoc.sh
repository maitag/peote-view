haxe -xml doc/api/doc.xml \
	-cp src -lib lime -lib format -D doc-gen \
	--no-output -neko dummy.n \
	peote.view.PeoteView peote.view.Buffer

haxelib run dox \
	-i doc/api/doc.xml \
	-D source-path https://github.com/maitag/peote-view/blob/master/src/ \
	--keep-field-order \
	-o doc/api \
	--toplevel-package peote.view \
	-in "^peote\.view\.(PeoteView|Display|Program|Buffer|Texture|TextureData|TextureDataImpl|TextureFormat|TextureConfig|TextureCache|Color|Mask|UniformFloat|BlendFactor|BlendFunc)$" \

rm doc/api/doc.xml
