# Development Platform for Modular Client-side Coffeescript

Forms an environment where it's easier to develop complex, large web applications. I update it once in a while as long as I'm using it.

## Install

    wget http://codeflow.org/download/asyncio.tar.bz2
    tar -xf asyncio.tar.bz2
    pushd lib
    wget http://coffeescript.org/extras/coffee-script.js
    popd
    ln -s $(pwd)/plate .local/bin/plate

## Use

Create a new directory, add `scripts/main.coffee`, don't worry about `index.html`, plate will generate one for you if it doesn't exist. It also opens a browser window.

    plate [directory] [port]

When you want to deploy the scripts you've been developing, pack them into a .tar -archive. Replace `manifest.json` in your index.html with the archive. I have bundled all the scripts in `lib` into the `dist/coffee-boot-min.js`.
