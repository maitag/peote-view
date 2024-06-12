Changelog
=========

1.02 (06/12/2024)
-----------------
* Added `public` for the `.fbTexture` to make it read-access for Framebuffer-`Display`s
* Fixed `FBO/float-Texture` glitch where gl-EXT_color_buffer_float/OES_texture_float-extension was not set in time


1.01 (05/01/2024)
-----------------
* Added optional param for `Color.random(?alpha:Int)` and `randomize(?alpha:Int)`
* Completed inline documentation and DOX-API
* Completed `TextureData` functions for converting `TextureFormat`s
* Fixed `Texture` glitch while setting up the slots
* Fixed `TextureCache` and renamed `setImage()` into `setData()`
