haxe -xml doc/api/doc.xml \
	-cp src -lib lime -D doc-gen \
	--no-output -neko dummy.n \
	peote.view.PeoteView

haxelib run dox \
	-in "^peote\.view\.(PeoteView|Display|Program|Texture|Color)$" \
	-i doc/api/doc.xml \
	-o doc/api

rm doc/api/doc.xml