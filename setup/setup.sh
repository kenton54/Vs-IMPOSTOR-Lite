# Setup for MacOS and Linux, Windows gets it's own setup file cuz of Microsoft's bs lol.
echo Installing dependencies...
haxelib install lime --quiet
haxelib install openfl --quiet
haxelib install flixel --quiet
haxelib install flixel-addons --quiet
haxelib install flixel-tools --quiet
haxelib install flixel-ui --quiet
haxelib install hscript-iris --quiet
haxelib install hxcpp-debug-server --quiet
haxelib install hxdiscord_rpc --skip-dependencies --quiet
haxelib install hxvlc --skip-dependencies --quiet
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit master --quiet
haxelib install extension-androidtools --quiet
haxelib install hxgamemode --quiet
haxelib git hxcpp https://github.com/FunkinCrew/hxcpp/ c79483a7bf1c0afa77d35a8c564cecac83d5c890 --quiet
haxelib install hxp --quiet
haxelib install format --quiet
echo Finished!