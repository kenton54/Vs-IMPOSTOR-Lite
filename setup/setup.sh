# Setup for MacOS and Linux, Windows gets it's own setup file cuz of Microsoft's bs lol.
echo Installing dependencies...
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib install flixel-addons
haxelib install flixel-tools
haxelib install flixel-ui
haxelib install hscript-iris
haxelib install tjson
haxelib install hxdiscord_rpc --skip-dependencies
haxelib install hxvlc --skip-dependencies
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit master
haxelib install extension-androidtools
echo Finished!